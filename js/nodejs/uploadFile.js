//Code to upload a file and move it to specified path (currently /Users/simongray)

var http = require('http');
var formidable = require('formidable');
var fs = require('fs');

http.createServer(function (req, res) {
                  if (req.url == '/fileupload') {
                  var form = new formidable.IncomingForm();
                  form.parse(req, function (err, fields, files) {
                             var oldpath = files.filetoupload.path;
                             var newpath = '/Users/simongray/Desktop/HMS_Bioinformatics/Visualization_HiC/upload_file_js/' + files.filetoupload.name;
                             fs.rename(oldpath, newpath, function (err) {
                                       if (err) throw err;
                                       res.write('File uploaded and moved!');
                                       res.end();
                                       });
                             });
                  
                  form.on('end', function() {
                          
                          // Pass uploadedFile as option, here uploaded file is called 'matrix.txt'
                          const { execFile } = require('child_process');
                          const child = execFile('./makejson.sh', ['matrix.txt'], (error, stdout, stderr) => {
                                                 if (error) {
                                                 throw error;
                                                 }
                                                 console.log(stdout);
                                                 });
                          
                          });

// This code works, but doesn't do what we want to pause until file exists...
//                  if (fs.existsSync('/Users/simongray/Desktop/HMS_Bioinformatics/Visualization_HiC/upload_file_js/matrix.txt')) {
//                  res.writeHead(200, {'Content-Type': 'text/html'});
//                  res.write('Hello World!'); // write a response to the client
//                  res.end(); // end the response
//                  };

//This code works by itself, but fails here because it needs to be executed after the uploaded file is moved to the directory
//                  const { execFile } = require('child_process');
//                  const child = execFile('./makejson.sh', ['matrix.txt'], (error, stdout, stderr) => {
//                                         if (error) {
//                                         throw error;
//                                         }
//                                         console.log(stdout);
//                                         });
                  
                  } else {
                  res.writeHead(200, {'Content-Type': 'text/html'});
                  res.write('<form action="fileupload" method="post" enctype="multipart/form-data">');
                  res.write('<input type="file" name="filetoupload"><br>');
                  res.write('<input type="submit">');
                  res.write('</form>');
                  return res.end();
                  }
                  }).listen(8080);


//This code works
//var http = require('http');
//var fs = require('fs');
//if (fs.existsSync('/Users/simongray/Desktop/HMS_Bioinformatics/Visualization_HiC/upload_file_js/matrix.txt')) {
//    http.createServer(function (req, res) {
//                      res.writeHead(200, {'Content-Type': 'text/html'});
//                      res.write('Hello World!'); // write a response to the client
//                      res.end(); // end the response
//                      }).listen(8080); // the server object listens on port 8080
//}
