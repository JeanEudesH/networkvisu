// comment out this line from development 
//ocpu.seturl("http://0.0.0.0:8004/ocpu/library/networkVisu/R");
//ocpu.seturl("http://localhost:5656/ocpu/library/networkVisu/R");
var App = new Vue({
  el: "#exploreApp",
  data: {
    wsParams: {
      RfunctionName: "installationTable",
     /*  name: ['OpensilexDemo', 'Ephesia'],
      api: ['opensilex.org/openSilexAPI/rest/', '138.102.159.36:8080/phenomeEphesiaAPI/rest/'],
      */
      name: ["Diaphen", "OpensilexDemo", "Agrophen", "Pheno3C", "Phenovia", "PhenoField", "Ephesia"],
      api: ["147.100.175.121:8080/phenomeDiaphenAPI/rest/", "opensilex.org/openSilexAPI/rest/", "147.100.175.121:8080/phenomeAgrophenAPI/rest/", "147.100.175.121:8080/phenomePheno3cAPI/rest/", "147.100.175.121:8080/phenomePhenoviaAPI/rest/", "147.100.175.121:8080/phenomePhenofieldAPI/rest/", "138.102.159.36:8080/phenomeEphesiaAPI/rest/"],
      

    },
    selected: [],
    collectedData:{
      INST:[{api: "FALSE", name: "All"}],
      computedDF: [],
      refinedDF: [],
      functionName: "collectScientificObject"
    },
    graphParameters: {
        iframeInput: "plotDiv",
        outputName: "Graph.png",
        barplot: {
          functionName: "barplotGraph",
          filterBy: "filteredInstallation",
          parameterOfInterest: "parameterOfInterest",
          filteredInstallation: "filteredInstallation",
          groupBy: "groupBy"
        },
        piechart: {
          functionName: "pieGraph",
          parameterOfInterest: "pieparameterOfInterest",
          filteredInstallation: "piefilteredInstallation"
        },
        treemap: {
          functionName: "treemapGraph",
          class1: "class1",
          class2: "class2"
        },
        boxplot: {
          functionName: "boxplotGraph",
          parameterOfInterest: "boxparameterOfInterest",
          filteredInstallation: "boxfilteredInstallation"
        },
        radar: {
          functionName: "radarData",
          objectOfInterest: "objectOfInterest",
          variable: "variableOfInterest",
          outputName: "Graph.html"
        }
    },
    exportedData: {
      rawData: true, 
      filename: "file",
      format: "csv",
      functionName: "exportData",
      tablesDivId: "tables", 
      tabNavId: "navtabs", 
      searchedParameters: "searchedParameters"
    },
    tabs: { activetab: 1 }
  },
  computed: {
    INST: function () {
      var inst = [];
      for (var j = 0; j < this.wsParams.name.length; j++){
        instance = {name: this.wsParams.name[j], api: this.wsParams.api[j]};
        inst.push(instance)
      }
      return inst
    },
    refineDF: function(){
      var self = this;
      var data = self.collectedData.computedDF;
      var format = self.exportedData.format;
      var filename = self.exportedData.filename;
      return ocpu.rpc(
        self.exportedData.functionName,
        {
          DATA: data,
          format: format,
          filename: filename,
          rawData: 'FALSE'
        }, 
         function(df) {
          self.collectedData.refinedDF = df
         return df
         }
      ).fail(function(request){
        alert("Error: "+ request.responseText);
      });
    },
  },
  mounted:function(){
    this.fillListInput(inputId = this.graphParameters.barplot.filterBy ,inputList = this.wsParams.name);
    this.collectData();
   },
  methods: {
    installationTable: function(){
      var self = this;
        installationTable = [
            this.wsParams.name,
            this.wsParams.api
        ]
        return ocpu.rpc(
          //Create array of variables' options
          // R function name
          this.wsParams.RfunctionName,
          // list of arguments names and value
          {
            instancesNames: self.wsParams.name,
            instancesApi: self.wsParams.api
          },
      
          function(output) {
            //$("#cssLoader").removeClass("is-active");
            self.collectedData.INST = self.collectedData.INST.concat(output);

            return output;
          }
        ).fail(function(request) {
          //$("#cssLoader").removeClass("is-active");
          alert("Error: "+ request.responseText);
        });
    },
    fillListInput: function(inputId, inputList){
      inputData = [];
      inputList.forEach(function(inputItem) {
          item = {};
          item.id = inputItem;
          item.text = inputItem;
          inputData.push(item);
        });
        // console.log(inputData);
        defaultSelectParameters = {
          data: inputData
        };
        // merge objects
        finalSelectParameters = { ...defaultSelectParameters };
        $("#" + inputId).select2(finalSelectParameters);
    },
    collectData: function(){
        document.getElementById("spinner").style.visibility = "visible"; 
        var self = this;
        self.installationTable()
        // Fill variables
        // the arguments of the function ocpu.rpc are findable here :
        // https://www.opencpu.org/jslib.html#lib-jsonrpc
        return ocpu.rpc(
          //Create array of variables' options
          // R function name
          self.collectedData.functionName,
          // list of arguments names and value
          {
            inst: self.INST
          },
      
          function(output) {
            self.collectedData.computedDF = output
            document.getElementById("spinner").style.visibility = "hidden"; 
            return output;
          }
        ).fail(function(request) {
          $("#cssLoader").removeClass("is-active");
          alert("Error: "+ request.responseText);
        });
    },
    showbarGraph: function(){
        $("#cssLoader").addClass("is-active");
        var self = this;
        // Run the R function
        var parameterOfInterest = $("#"+self.graphParameters.barplot.parameterOfInterest).val();
        var filteredInstallation =$("#"+self.graphParameters.barplot.filteredInstallation).val();
        var groupBy = $("#"+self.graphParameters.barplot.groupBy).val();
        var outputName = this.graphParameters.outputName;
        var iframeInput = this.graphParameters.iframeInput;
        return(req = $(iframeInput).rplot(
          self.graphParameters.barplot.functionName,
            {
              computedDF: self.collectedData.computedDF,
              parameterOfInterest: parameterOfInterest,
              filteredInstallation: filteredInstallation,
              groupBy: groupBy
            },
            function(session) {
            $("#" + iframeInput).attr(
              "src",
              session.getFileURL(outputName)
            );
            $("#submit").removeAttr("disabled");
            $("#cssLoader").removeClass("is-active");
          }).fail(function(request) {
            $("#submit").removeAttr("disabled");
            $("#cssLoader").removeClass("is-active");
            alert("An unknown error has append : " + request.responseText);
          })
        );
    },
    showpieChart: function(){
      $("#cssLoader").addClass("is-active");
      var self = this;
      // Run the R function
      var parameterOfInterest = $("#"+self.graphParameters.piechart.parameterOfInterest).val();
      var filteredInstallation =$("#"+self.graphParameters.piechart.filteredInstallation).val();
      var outputName = this.graphParameters.outputName;
      var iframeInput = this.graphParameters.iframeInput;
      return(req = $(iframeInput).rplot(
        self.graphParameters.piechart.functionName,
          {
            computedDF: self.collectedData.computedDF,
            parameterOfInterest: parameterOfInterest,
            filteredInstallation: filteredInstallation
          },
          function(session) {
          $("#" + iframeInput).attr(
            "src",
            session.getFileURL(outputName)
          );
          $("#submit").removeAttr("disabled");
          $("#cssLoader").removeClass("is-active");
        }).fail(function(request) {
          $("#submit").removeAttr("disabled");
          $("#cssLoader").removeClass("is-active");
          alert("An unknown error has append : " + request.responseText);
        })
      );
    },
    treemapGraph: function(){
    $("#cssLoader").addClass("is-active");
    var self = this;
    // Run the R function
    var class1 = $("#"+self.graphParameters.treemap.class1).val();
    var class2 =$("#"+self.graphParameters.treemap.class2).val();
    var outputName = this.graphParameters.outputName;
    var iframeInput = this.graphParameters.iframeInput;
    return(req = $(iframeInput).rplot(
      self.graphParameters.treemap.functionName,
        {
          computedDF: self.collectedData.computedDF,
          class1: class1,
          class2: class2
        },
        function(session) {
        $("#" + iframeInput).attr(
          "src",
          session.getFileURL(outputName)
        );
        $("#submit").removeAttr("disabled");
        $("#cssLoader").removeClass("is-active");
      }).fail(function(request) {
        $("#submit").removeAttr("disabled");
        $("#cssLoader").removeClass("is-active");
        alert("An unknown error has append : " + request.responseText);
      })
    );
    },
    showboxplot: function(){
    $("#cssLoader").addClass("is-active");
    var self = this;
    // Run the R function
    var parameterOfInterest = $("#"+self.graphParameters.boxplot.parameterOfInterest).val();
    var filteredInstallation =$("#"+self.graphParameters.boxplot.filteredInstallation).val();
    var outputName = this.graphParameters.outputName;
    var iframeInput = this.graphParameters.iframeInput;
    return(req = $(iframeInput).rplot(
      self.graphParameters.boxplot.functionName,
        {
          computedDF: self.collectedData.computedDF,
          parameterOfInterest: parameterOfInterest,
          filteredInstallation: filteredInstallation
        },
        function(session) {
        $("#" + iframeInput).attr(
          "src",
          session.getFileURL(outputName)
        );
        $("#submit").removeAttr("disabled");
        $("#cssLoader").removeClass("is-active");
      }).fail(function(request) {
        $("#submit").removeAttr("disabled");
        $("#cssLoader").removeClass("is-active");
        alert("An unknown error has append : " + request.responseText);
      })
    );
    },
    showradar: function(){
  $("#cssLoader").addClass("is-active");
  var self = this;
  // Run the R function
  var objectOfInterest = $("#"+self.graphParameters.radar.objectOfInterest).val();
  var variable =$("#"+self.graphParameters.radar.variable).val();
  var outputName = this.graphParameters.radar.outputName;
  var iframeInput = this.graphParameters.iframeInput;
  return(req = ocpu.call(
    self.graphParameters.radar.functionName,
      {
        DATA: self.collectedData.computedDF,
        object: objectOfInterest,
        variable: variable
      },
      function(session) {
      $("#" + iframeInput).attr(
        "src",
        session.getFileURL(outputName)
      );
      $("#submit").removeAttr("disabled");
      $("#cssLoader").removeClass("is-active");
    }).fail(function(request) {
      $("#submit").removeAttr("disabled");
      $("#cssLoader").removeClass("is-active");
      alert("An unknown error has append : " + request.responseText);
    })
  );
    },
    download_graph: function(){
      var hiddenElement = document.getElementById('DownloadGraph');
  hiddenElement.href = "image/Graph.png";
  hiddenElement.target = '_blank';
  hiddenElement.download = 'Graph.png';
  hiddenElement.click();
    },
    download_json: function () {
  var raw = this.exportedData.rawData;
  if(raw ==='false'){
    var DATA = this.collectedData.refinedDF;
  } else{
    var DATA = this.collectedData.computedDF;
  }
  var hiddenElement = document.getElementById('Download');
  hiddenElement.href = 'data:json/application;charset=utf-8,' + JSON.stringify(DATA);
  hiddenElement.target = '_blank';
  hiddenElement.download = 'file.json';
  hiddenElement.click();
    },
    convertToCSV: function (objArray) {
  var array = typeof objArray != 'object' ? JSON.parse(objArray) : objArray;
  var str = '';
  var fields = Object.keys(array[0]);
  for (var i = 0; i < array.length; i++) {
      var line = '';
      for (var index in array[i]) {
          if (line != '') line += ','

          line += array[i][index];
      }

      str += line + '\r\n';
  }
  
  var csv = array.map(function(row){
    return fields.map(function(fieldName){
      return JSON.stringify(row[fieldName])
    }).join(',')
  })
  csv.unshift(fields.join(','))

  return csv.join('\r\n');
    },
    download_csv: function () {
  var raw = this.exportedData.rawData;
  if(raw ==='false'){
    var DATA = this.collectedData.refinedDF;
  } else{
    var DATA = this.collectedData.computedDF;
  }
  var csvContent =[];
  csvContent = this.convertToCSV(DATA);

  var hiddenElement = document.getElementById('Download');
  hiddenElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csvContent);
  hiddenElement.target = '_blank';
  hiddenElement.download = 'file.csv';
  hiddenElement.click();
    },
    download_xml: function () {
      alert("XML output not ready for the moment");
  // c'est du node.js 'require'
  // et ça marche pas :(
  var convert = require('xml-js');
  var raw = this.exportedData.rawData;
  if(raw ==='false'){
    var DATA = this.collectedData.refinedDF;
  } else{
    var DATA = this.collectedData.computedDF;
  }
  var xml_doc = convert.json2xml(DATA,options);

  var hiddenElement = document.getElementById('Download');
  hiddenElement.href = 'data:xml;charset=utf-8,' + encodeURI(xml_doc);
  hiddenElement.target = '_blank';
  hiddenElement.download = 'file.xml';
  hiddenElement.click();
    },
    tableSummarised: function() {
      var self = this;
      setTimeout(function () {
        var raw = self.exportedData.rawData;
        if(raw==="false"){
          var df = self.collectedData.refinedDF;
        } else {
          var df = self.collectedData.computedDF  
        }
        
        var colnames = Object.keys(df[0]);
        // create the JSON array for the columns required by DataTable
        var columns = [];
        for (i = 0; i < colnames.length; i++) {
          var obj = {};
          obj['data'] = colnames[i]
          columns.push(obj);
        }
  
        // DataTable update
        if ($.fn.DataTable.isDataTable("#mytable")) {
          $('#mytable').DataTable().clear().destroy();
          $('#mytable thead tr').remove();
        }
        $('#mytable').append(self.makeHeaders(colnames));
        $("#mytable").dataTable({
            data: df,
            columns: columns
          });
      },200)
  
    },
    makeHeaders: function (colnames) {
      var str = "<thead><tr>";
      for (var i = 0; i < colnames.length; i++) {
        str += "<th>" + colnames[i] + "</th>";
      }
      str +="</tr></thead>"
      return (str);
    }
  }
})