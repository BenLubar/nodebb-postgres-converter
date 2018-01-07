async function transaction(label, pool, callback) {
	const client = await pool.connect();
	console.time(label);

	try {
		await client.query(`START TRANSACTION`);
		await callback(client);
		await client.query(`COMMIT`);
	} catch (ex) {
		await client.query(`ROLLBACK`);
		console.error('Transaction failed: ' + label);
		throw ex;
	} finally {
		console.timeEnd(label);
		client.release();
	}
}

module.exports = transaction;
