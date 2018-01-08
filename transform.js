module.exports.row = function transformRow(columns) {
	return columns.map(function(col) {
		if (col === null) {
			return '\\N';
		}

		return String(col).replace(/[\\\n\r\t]/g, function(x) {
			switch (x) {
				case '\\':
					return '\\\\';
				case '\n':
					return '\\n';
				case '\r':
					return '\\r';
				case '\t':
					return '\\t';
			}
		});
	}).join('\t') + '\n';
}

module.exports.array = function transformArray(array) {
	if (array.length === 0) {
		return '{}';
	}

	return '{"' + array.map(function(v) {
		return String(v).replace(/[\\"]/g, function(x) {
			return '\\' + x;
		});
	}).join('","') + '"}';
}
