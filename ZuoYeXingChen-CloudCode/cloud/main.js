var app = require('cloud/app.js')
var upyun = require('cloud/upyun.js')

AV.Cloud.beforeSave("_User", function(request, response) {
	var username = request.object.get("username");
	var dir = username;
	upyun.MkDir(dir, function(err, data) {
		if (!err) {
			console.log("mkdir success: ", data)
			response.success();
		} else {
			console.log("mkdir failed: ", err)
			response.error(err.message);
		}
	});
});

AV.Cloud.afterUpdate("_User", function(request, response) {
	console.log("update user object")
})

AV.Cloud.afterSave("ZYXCTestObject", function(request, response) {
	console.log("save test object");
});

// Use AV.Cloud.define to define as many cloud functions as you want.
// For example:
AV.Cloud.define("hello", function(request, response) {
  response.success("Hello world!");
});
