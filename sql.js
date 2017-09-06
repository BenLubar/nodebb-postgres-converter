const path = require('path');
const bluebird = require('bluebird');
const readDir = bluebird.promisify(require('fs').readdir);
const readFile = bluebird.promisify(require('fs').readFile);
const transaction = require('./transaction.js');

async function executeSQL(pool, category) {
	var label = 'Step: ' + category;
	console.time(label);

	var dir = path.join(__dirname, 'sql', category);
	var names = await readDir(dir);

	var sequential = names.some(function(name) { return /^[1-9][0-9]*\./.test(name); });
	var parallel = names.some(function(name) { return !/^[1-9][0-9]*\./.test(name); });

	if (sequential && parallel) {
		throw new Exception('Internal error: ' + dir + ' contains both sequential and parallel steps.');
	}

	if (parallel) {
		await Promise.all(names.map(async function(name) {
			var subCategory = category + '/' + name;
			var fileName = path.join(dir, name);

			if (name.endsWith('.sql')) {
				var sql = await readFile(fileName, 'utf8');
				await transaction('SQL: ' + subCategory, pool, async function(tx) {
					await tx.query(sql);
				});
			} else {
				await executeSQL(pool, subCategory);
			}
		}));
	} else if (sequential) {
		names = names.sort(function(a, b) {
			return a.split(/\./)[0] - b.split(/\./)[0];
		});
		for (var name of names) {
			var subCategory = category + '/' + name;
			var fileName = path.join(dir, name);

			if (name.endsWith('.sql')) {
				var sql = await readFile(fileName, 'utf8');
				await transaction('SQL: ' + subCategory, pool, async function(tx) {
					await tx.query(sql);
				});
			} else {
				await executeSQL(pool, subCategory);
			}
		}
	}

	console.timeEnd(label);
}

module.exports = executeSQL;
