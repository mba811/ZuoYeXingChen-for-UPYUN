var crypto = require('crypto');

function md5(string) {
	var md5sum = crypto.createHash('md5');
	md5sum.update(string, 'utf8');
	return md5sum.digest('hex');
}

exports.md5 = md5;
