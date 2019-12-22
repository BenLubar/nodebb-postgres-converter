'use strict';

/* eslint-disable no-control-regex */

module.exports.data = function (obj) {
	delete obj._id;
	if (!obj.hasOwnProperty('_key')) {
		return null;
	}
	var key = obj._key;
	// Check if object keys contains ".". Skip as mongodb won't be able to create them.
	// Keys found when migrating production db "username:uid_old", "email:uid_old" and "email:confirmed".
	// Hopefully we can live without them.
	if (Object.keys(obj).find(k => k.includes("."))) {
		return null;
	}
	// Cleanup some "problematic" keys that could result in too long keys for index. They are not needed.
	if (key === "errors:404" || key === "ip:recent")
		return null;
	
	// clean up importer bugs
	delete obj.undefined;
	if ((key.startsWith('chat:room:') && key.endsWith('uids') && !key.endsWith(':uids')) || (key.startsWith('uid:') && key.endsWith('sessionUUID:sessionId') && !key.endsWith(':sessionUUID:sessionId'))) {
		return null;
	}

	// remove importer cache on live objects
	if (!key.startsWith('_imported')) {
		for (var k of Object.keys(obj)) {
			if (k.startsWith('_imported')) {
				delete obj[k];
			}
		}
	}

	return module.exports.value(obj);
}

module.exports.value = function (obj) {
	for (var k in obj) {
		if (!Object.prototype.hasOwnProperty.call(obj, k)) {
			continue;
		}
		var v = obj[k];
		if (!v || v === true) {
			continue;
		}
		if (v instanceof Date) {
			obj[k] = v.getTime();
			continue;
		}
		if (typeof v === 'number') {
			if (Number.isNaN(v)) {
				obj[k] = 'NaN';
			}
			continue;
		}
		if (typeof v === 'string') {
			if (v.indexOf('\x00') !== -1) {
				obj[k] = v.replace(/\x00/g, 'x00');
			}
			continue;
		}
		if (Array.isArray(v)) {
			obj[k] = v.map(function(a) {
				return String(a || '').replace(/\x00/g, 'x00');
			});
			continue;
		}

		// Object, possibly from a plugin
		obj[k] = module.exports.value(v);
	}

	return obj;
}
