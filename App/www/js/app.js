
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
