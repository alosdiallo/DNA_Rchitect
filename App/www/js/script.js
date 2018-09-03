
// Make sure the Shiny connection is established
$(document).on('shiny:connected', function(event) {

  /********** NON-REACTIVE DOM MANIPULATION **********/
  // Detect input change and change UI to reflect that
  var prevText = '';
  $(document).on('shiny:inputchanged', function(event) {
    if (event.name === 'txt1' && event.value !== prevText) {
      prevText = event.value;
      $('#placeholder1').append(
        'You have entered text: ' + event.value + '<br>'
      );
    }
  });

  
 $(document).on('shiny:inputchanged', function(event) {
 
///////////////////////////////////////////////////////////////
var x = document.getElementById("genome").value;
var checkBoxCoord = document.getElementById("byCoordinates");
var checkBoxGenes = document.getElementById("byGenes");

document.getElementById("geneIdDiv").style.display = "inline";
document.getElementById("searchByCoordinatesDiv").style.visibility = "hidden";

if (checkBoxCoord.checked == true){
document.getElementById("searchByCoordinatesDiv").style.visibility = "visible";
document.getElementById("searchByCoordinatesDiv").style.display = "inline";
document.getElementById("geneIdDiv").style.display = "none";

} 
if (checkBoxGenes.checked == true){
	document.getElementById("geneIdDiv").style.visibility = "visible";
document.getElementById("geneIdDiv").style.display = "inline";
document.getElementById("searchByCoordinatesDiv").style.display = "none";
}

  });
//////////////////////////////////////////////////////////
  
 function isNumberKey(evt)
    {
        var charCode = (evt.which) ? evt.which : event.keyCode
        if (charCode > 31 && (charCode < 48 || charCode > 57))
           return false;

        return true;
    }

  
  /************ REACTIVE DOM MANIPULATION ************/
  // Insert a textInput after a complicated calculation
  function complicatedCalculation(a, b, callback) {
    var res = a + b;
    console.log('Complicated calculation finished!');
    callback(res);
  }
  

  
  complicatedCalculation(1, 1, function(value) {
    Shiny.unbindAll();
    // insert a reactive textInput
    $('#placeholder2').append(
      '<div class=\"form-group shiny-input-container\">' +
        '<label for=\"txt2\"> A JS-created textInput </label>' +
        '<input id=\"txt2\" type=\"text\"' +
                'class=\"form-control\" value=\"\">' + 
      '</div>'
    );
    $('#txt2').val(value);
    Shiny.bindAll();
  });
});

//////////////////////////////////////////////////////////////////////////////
//Include javascript code to make shiny communicate with introJS

// initialize an introjs instance
var intro = introJs();

// handler 1
Shiny.addCustomMessageHandler("setHelpContent",
// callback function.
// note: message is passed by shiny and contains the tour data
function(message){
	// load data, show progress bar
	intro.setOptions({steps: message.steps }).setOption("showProgress", true);
}
);

// handler 2
Shiny.addCustomMessageHandler("startHelp",
// callback function
function(message) {
	// start intro.js
	// note: we don't need information from shiny, just start introJS
	intro.start();
}
);

// send message to shiny to initiate tab change
intro.onbeforechange(function(targetElement) {
	if(this._currentStep==12){
		var n=Math.random();
		Shiny.onInputChange("changeTab",n);
	}
}).start();
 
///////////////////////////////////////////////////////////////////////////////
//JavaScript for handling Cytoscape Network Download as PNG. This code was copied verbatim from: https://github.com/cytoscape/r-cytoscape.js/tree/master/inst/examples/shiny

// Wait for cy to be defined and then add event listener
$(document).ready(function() {
	Shiny.addCustomMessageHandler("saveImage",
	function(message) {
		//console.log("saveImage");
		var result = cy.png();
		//Shiny.onInputChange("imgContent", result);
		console.log("imgContent: " + result);
		// From: http://stackoverflow.com/questions/25087009/trigger-a-file-download-on-click-of-button-javascript-with-contents-from-dom
		dl = document.createElement('a');
		document.body.appendChild(dl);
		dl.download = "download.png";
		dl.href = result;
		dl.click();
	}
);
});

