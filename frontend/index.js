const http = require("http");

const PORT = process.env.PORT || 3000;

http.createServer((_, res) => {
  res.writeHead(200, { "Content-Type": "text/html" });
  res.end("<h1>This is frontend</h1>");
}).listen(PORT, () => console.log(`Frontend running on http://localhost:${PORT}`));
