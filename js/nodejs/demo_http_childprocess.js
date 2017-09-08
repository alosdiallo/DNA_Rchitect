//var http = require('http')
//
//// create a server object:
//http.createServer(function (req, res) {
//                  res.writeHead(200, {'Content-Type': 'text/html'});
//                  res.write('Hello World!'); // write a response to the client
//                  res.end(); // end the response
//                  }).listen(8080); // the server object listens on port 8080
//

////Works to make child process and print version of node
//const { execFile } = require('child_process');
//const child = execFile('node', ['--version'], (error, stdout, stderr) => {
//                       if (error) {
//                       throw error;
//                       }
//                       console.log(stdout);
//                       });

//Works to run the shell script ./makejson.sh fed argument ['matrix.txt]
const { execFile } = require('child_process');
const child = execFile('./makejson.sh', ['matrix.txt'], (error, stdout, stderr) => {
                       if (error) {
                       throw error;
                       }
                       console.log(stdout);
                       });
