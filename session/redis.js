'use strict';

const redis = require('redis');
const { promisify } = require('util');

for (var fn of ['scan', 'type', 'get', 'pttl']) {
	redis.RedisClient.prototype[fn + 'Async'] = promisify(redis.RedisClient.prototype[fn]);
}

module.exports = async function(connection, each) {
	const client = redis.createClient(connection);

	try {
		var cursor = '0';
		do {
			var result = await client.scanAsync(cursor, 'MATCH', 'sess:*', 'COUNT', '1000');
			cursor = result[0];

			for (var key of result[1]) {
				var type = await client.typeAsync(key);
				if (type === 'string') {
					var data = await client.getAsync(key);
					var ttl = parseInt(await client.pttlAsync(key), 10);
					if (ttl < 0) {
						continue;
					}

					await each({
						sid: key.substring('sess:'.length),
						sess: data,
						expire: Date.now() + ttl
					});
				}
			}
		} while (cursor !== '0');
	} finally {
		client.quit();
	}
};
