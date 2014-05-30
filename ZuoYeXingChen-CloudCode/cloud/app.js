// 在Cloud code里初始化express框架
var express = require('express');
var app = express();

// App全局配置
app.set('views','cloud/views');   //设置模板目录
app.set('view engine', 'ejs');    // 设置template引擎
app.use(express.bodyParser());    // 读取请求body的中间件

app.get('/', function(req, res) {
	res.send('<h1>Welcome</h1>');
});

app.get('/hello', function(req, res) {
	res.send('Hello, you just set up your app!');
});

//最后，必须有这行代码来使express响应http请求
app.listen();