var util = require('cloud/util.js');
// 在Cloud code里初始化express框架
var express = require('express');
var app = express();

// App全局配置
app.set('views','cloud/views');   //设置模板目录
app.set('view engine', 'ejs');    // 设置template引擎
app.use(express.bodyParser());    // 读取请求body的中间件

app.get('/', function(req, res) {
	res.status(200);
	res.send('<h1>Welcome</h1>');
});

var polling_clients = {};
var uploaded_photos = {};

app.get('/uploaded-photos', function(req, res) {
	var directory = req.query['directory'];
	console.log("polling client: ", directory);
	polling_clients[directory] = res;
});

app.post('/upload-photo-success', function(req, res) {
	var body = req.body;
	var code = body['code'];
	var message = body['message'];
	var url = body['url'];
	var time = body['time'];
	var sign = body['sign'];
	var form_api_secret = "61g5MnhZi/mRvjkJhvPwX7efSYU=";

	var sign_str = code + '&' + message + '&' + url + '&' + time + '&' + form_api_secret;
	var sign_md5 = util.md5(sign_str);

	if (sign != sign_md5) {
		console.log('invalid post notify');
		return ;
	}

	var my_url = url.substring(1, url.length - 4);
	var arr = my_url.split('/');
	if (arr.length != 2) {
		console.log('invalid url');
		return ;
	}

	res.status(200);

	var directory = arr[0];
	var photo_md5 = arr[1];
	console.log("upload-image-success: ", directory, photo_md5);

	var client = polling_clients[directory];
	if (!client) {
		console.log("no client polling", directory);
		if (uploaded_photos[directory]) {
			uploaded_photos[directory].push(photo_md5);
		} else {
			uploaded_photos[directory] = [photo_md5];
		}
		return ;
	}

	if (uploaded_photos[directory]) {
		client.json({photos: uploaded_photos[directory]});
		polling_clients[directory] = null;
		uploaded_photos[directory] = null;
	}

	console.log("success !!!");
})

//最后，必须有这行代码来使express响应http请求
app.listen();