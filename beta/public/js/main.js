var socket = io();

socket.on("loadingGIF", function() {
          document.getElementById("cyLoading").style.visibility = "visible";
          document.getElementById("cyIndex").style.visibility = "hidden";
          });
