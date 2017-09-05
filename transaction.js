async function transaction(label, pool, callback) {
	console.time(label);
	const client = await pool.connect();

	try {
		await client.query('START TRANSACTION;');
		await callback(client);
		await client.query('COMMIT;');
	} catch (ex) {
		await client.query('ROLLBACK;');
		console.error('Transaction failed: ' + label);
		throw ex;
	} finally {
		client.release();
		console.timeEnd(label);
	}
}

module.exports = transaction;
