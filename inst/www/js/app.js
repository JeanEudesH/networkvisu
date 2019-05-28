/*
 * ******************************************************************************
 *                                     app.js
 *  js
 *  Copyright © INRA 2019
 *  Creation date:  06 March, 2019
 *  Contact: arnaud.charleroy@inra.fr
 * ******************************************************************************
 */

$(function() {
  // Comment for production case
  ocpu.seturl("http://0.0.0.0:8004/ocpu/apps/opensilex/opensilex-datavis-rapp-demo/R");

  // initialize parameters when token is valid
  $("#token").change(function() {
    initInputs();
  });

  // show graph button
  $("#submit").click(function(e) {
    e.preventDefault();
    functionsParameters = getInputs();
    // basical
    // create a plot from htmlwidget named function name .e.g plotVar with Widget.html
    showPlot("plotDiv", "plotVarDemo", functionsParameters);
  });
});

function initInputs() {
  var config = initOpenSilexParameters();
  // test token send in url
  if (config.token == null || config.token == "") {
    alert("An accessToken is required");
    return false;
  } 
  if (config.wsUrl == null || config.wsUrl == "") {
    alert("A wsUrl is required");
    return false;
  } 
  
  // variables' initialization
  // if fail disabled input
  setListInputFromRList("variable","variableList", config, {
    maximumSelectionLength: 2,
    multiple: true
  });

}

function getInputs() {
  var config = initOpenSilexParameters();

  // input parameters in the form of the R function
  var varURIs = $("#variable").val();

  if (varURIs == null || varURIs.length == 0) {
    alert("you must choose at least one variable");
    return false;
  }
  functionsParameters = {
    varURI: varURIs,
    token: config.token,
  };
  if (config.wsUrl !== null) {
    functionsParameters["wsUrl"] = config.wsUrl;
  }
  return functionsParameters;
}
