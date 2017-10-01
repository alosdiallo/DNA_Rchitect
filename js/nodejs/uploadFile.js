//Require packages for formidable
var http = require('http');
var formidable = require('formidable');
var fs = require('fs');

//Require packages for socket.io
var express = require("express");
var app = express();
var server = http.createServer(app).listen(3000);
var io = require("socket.io")(server);

//Require packages for eventEmitter (for internal server-side event communication)
var eventEmitter = require('events').EventEmitter;
var em = new eventEmitter();

//Require package for request
var request = require('request');

//Serve static files
app.use(express.static("./public"));

//Socket.io server (for server-client-server communication)
io.on("connection", function(socket) {
      console.log("someone connected");
      
      //emit socket to main.js to change div visibility and make loader visible
      em.on('fileuploaded', function() {
            console.log('Event fileuploaded emitted')
            socket.emit("loadingGIF");
            });
      
      //emit socket to hic_network.js to run cytoscape and change cy div visibility
      em.on('jsonCreated', function() {
            console.log('Event jsonCreated emitted')
            socket.emit("loadingCy");
            });
      
      });

//em listener for startChildProcess event, which is emitted after file is uploaded (this is used instead of form.on('end',...) inorder to properly handle both upload by browse (which is handled appropriated by form.on('end',...), and upload by url with 'request' (which is not handled by form.on('end',...) because the end event here is form-parsing, not the completion of the request.get('url'))
em.on('startChildProcess', function() {
      // Open child_process to execute bash script, passing uploadedFile as option (NOTE: uploaded file must be named 'matrix.txt')
      const { execFile } = require('child_process');
      const child = execFile('./makejson.sh', ['matrix.txt'], (error, stdout, stderr) => {
                             if (error) {
                             throw error;
                             }
                             console.log(stdout);
                             });
      child.on('exit', function(code, signal) {
               console.log('child process exited with ' + `code ${code} and signal ${signal}`);
               em.emit('jsonCreated');
               });
      });

//Create formidable server to handle file upload from local disc browse or url
var uploadFrom = http.createServer(function (req, res) {
                                   console.log('Server request made');
                                   
                                   if (req.method.toLowerCase() == 'post') {
                                   var form = new formidable.IncomingForm();
                                   
                                   form.parse(req, function (err, fields, files) {
                                              
                                              //For below user upload-error cases -- need to figure out how to remove the unhandled file from the queue **********
                                              if (fields.urlforfile !== '' && files.filetoupload.name !== '') {
                                              res.writeHead(200, {'Content-Type': 'text/html'});
                                              res.write('<form action="" method="post" enctype="multipart/form-data">');
                                              res.write('Submit EITHER a url OR browse for a file<br>');
                                              res.write('<input type="text" name="urlforfile" placeholder="enter url"><br>');
                                              res.write('<input type="file" name="filetoupload"><br>');
                                              res.write('<input type="submit" value="Submit">');
                                              res.end();
                                              
                                              } else if (fields.urlforfile == '' && files.filetoupload.name == '') {
                                              res.writeHead(200, {'Content-Type': 'text/html'});
                                              res.write('<form action="" method="post" enctype="multipart/form-data">');
                                              res.write('You submitted nothing, try again<br>');
                                              res.write('<input type="text" name="urlforfile" placeholder="enter url"><br>');
                                              res.write('<input type="file" name="filetoupload"><br>');
                                              res.write('<input type="submit" value="Submit">');
                                              res.end();
                                              
                                              } else if (fields.urlforfile == '' && files.filetoupload.name !== '') {
                                              //eventEmitter to trigger socket.io server
                                              em.emit('fileuploaded');
                                              var oldpath = files.filetoupload.path;
                                              // change files.filetoupload.name to 'matrix.txt'; bash script executed by child_process assumes file is called matrix.txt
                                              var newpath = __dirname + '/matrix.txt';
                                              console.log(__dirname + '/');
                                              fs.rename(oldpath, newpath, function (err) {
                                                        if (err) throw err;
                                                        //eventEmitter to start Child_Process that executes bash script
                                                        em.emit('startChildProcess');
                                                        //Return success response to client
                                                        res.write('File uploaded and moved!');
                                                        res.end();
                                                        });

                                              } else if (fields.urlforfile !== '' && files.filetoupload.name == '') {
                                              //eventEmitter to trigger socket.io server
                                              em.emit('fileuploaded');
                                              //Request file from url and write to directory with name 'matrix.txt'
                                              request.get(fields.urlforfile)
                                              .on('error', function (err) {                                                                                console.log(err);
                                                  })
                                              .pipe(fs.createWriteStream('matrix.txt').on('finish', function() {
                                                                                          //eventEmitter to start Child_Process that executes bash script
                                                                                          em.emit('startChildProcess');
                                                                                          //Return success response to client
                                                                                          res.write('File uploaded from url!');
                                                                                          res.end();
                                                                                          }));
                                              }
                                              
                                              });
                                   
                                   } else {
                                   res.writeHead(200, {'Content-Type': 'text/html'});
                                   res.write('<form action="" method="post" enctype="multipart/form-data">');
                                   res.write('Enter url (including https://) with which your data file can be accessed:<br>');
                                   res.write('<input type="text" name="urlforfile" placeholder="enter url"><br>');
                                   res.write('<input type="file" name="filetoupload"><br>');
                                   res.write('<input type="submit" value="Submit">');
                                   return res.end();
                                   }
                                   
                                   }).listen(8080);

console.log("Starting socket app - http://localhost:3000 and formidable server -  http://localhost:8080");
