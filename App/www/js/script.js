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