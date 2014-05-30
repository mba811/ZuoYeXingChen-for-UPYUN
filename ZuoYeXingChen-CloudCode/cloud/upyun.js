var crypto = require('crypto');

var upyun_bucket = "zuoyexingchen";
var upyun_username = "test";
var upyun_password = md5("test123456");

function md5(string) {
	var md5sum = crypto.createHash('md5');
	md5sum.update(string, 'utf8');
	return md5sum.digest('hex');
}

function upyunSign(method, uri, date, length) {
	var sign = method + '&' + uri + '&' + date + '&' + length +
		'&' + upyun_password;
	var md5Sign = md5(sign);
	return 'UpYun ' + upyun_username + ':' + md5Sign;
}

function upyunMkDir(dir, callback) {
	var method = 'POST';
	var uri = "/" + upyun_bucket + "/" + dir;
	var date = (new Date()).toUTCString();
	var length = "0";

	var url = "http://v0.api.upyun.com" + uri;
	var sign = upyunSign(method, uri, date, length);

	AV.Cloud.httpRequest({
		method: method,
		url: url,
		headers: {
			'Folder': true,
			'Authorization': sign,
			'Date': date,
			'Content-Length': length
		},
		success: function(response) {
			console.log("upyunMkDir success: ", response.text);
			callback(null, response.text);
		},
		error: function(response) {
			console.log("upyunMkDir failed: ", response.text);
			callback(new Error(response.status), null);
		}
	});
}

exports.MkDir = upyunMkDir;