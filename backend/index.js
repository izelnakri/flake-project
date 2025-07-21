const http = require("http");

const PORT = process.env.PORT || 4000;

console.log("meh");
console.log("maybe");

http.createServer((_, res) => {
  res.writeHead(200, { "Content-Type": "text/html" });
  res.end(`<h1>This is backend, nihaa</h1>`);
}).listen(PORT, () => console.log(`Backend running on http://localhost:${PORT}`));
