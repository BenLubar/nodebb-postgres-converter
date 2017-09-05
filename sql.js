const path = require('path');
const bluebird = require('bluebird');
const readDir = bluebird.promisify(require('fs').readdir);
const readFile = bluebird.promisify(require('fs').readFile);
const transaction = require('./transaction.js');

async function findSQLFiles(category) {
	var dir = path.join(__dirname, 'sql', category);
	var files = await readDir(dir);
	return files.filter(function(name) {
		return name.endsWith('.sql');
	}).map(function(name) {
		return path.join(dir, name);
	});
}

async function executeSQL(pool, category) {
	var label = 'Step: ' + category;
	console.time(label);

	var filePaths = await findSQLFiles(category);
	await Promise.all(filePaths.map(async function(filePath) {
		var sql = await readFile(filePath, 'utf8');
		await transaction('SQL: ' + category + '/' + path.basename(filePath), pool, async function(tx) {
			await tx.query(sql);
		});
	}));

	console.timeEnd(label);
}

module.exports = executeSQL;
