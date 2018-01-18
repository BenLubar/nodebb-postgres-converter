'use strict';

const redis = require('redis');

function waitInsert(client) {
	return new Promise(function (resolve) {
		if (!client.should_buffer) {
			return resolve();
		}
		client.stream.once('drain', resolve);
	});
}

async function insertOne(client, data) {
	var expireAt = data.expireAt;
	delete data.expireAt;

	var nk = Object.keys(data).length;

	if (nk === 3 && data.hasOwnProperty('score') && data.hasOwnProperty('value')) {
		client.zadd(data._key, data.score, data.value);
	} else if (nk === 2 && data.hasOwnProperty('members')) {
		client.sadd(data._key, data.members);
	} else if (nk === 2 && data.hasOwnProperty('array')) {
		client.lpush(data._key, data.array);
	} else if (nk === 2 && data.hasOwnProperty('data') || data.hasOwnProperty('value')) {
		client.set(data._key, data.data || data.value);
	} else {
		var command = [data._key];
		for (var key of Object.keys(data)) {
			if (key !== '_key') {
				command.push(key, data[key]);
			}
		}
		client.hmset(command);
	}

	if (expireAt) {
		client.pexpireat(data._key, expireAt);
	}

	await waitInsert(client);
}

async function bulkInsert(client, each) {
	await each(async function (data) {
		await insertOne(client, data);
	});
}

async function writer(output, concurrency, memory, callback) {
	const client = redis.createClient(output);

	await callback(async function (each) {
		await bulkInsert(client, each);
	}, async function (reader, input) {
		await reader(input, async function (each) {
			await bulkInsert(client, async function (insert) {
				await each(async function (session) {
					await insert({
						_key: 'sess:' + session.sid,
						data: session.sess,
						expireAt: session.expire,
					});
				});
			});
		});
	});
}

module.exports = writer;
