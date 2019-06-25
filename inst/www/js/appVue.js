// comment out this line from development 
//ocpu.seturl("http://0.0.0.0:8004/ocpu/library/networkVisu/R");
ocpu.seturl("http://localhost:5656/ocpu/library/networkVisu");
var App = new Vue({
  el: "#exploreApp",
  data: {
    wsParams: {
      name: ['OpensilexDemo'],
      api: ["147.100.175.121:8080/phenomePheno3cAPI/rest/"],
      RfunctionName: "installationTable"
    },
    collectedData:{
      INST:[],
      computedDF:[],
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
        boxplot: {
          functionName: "boxplotGraph",
          parameterOfInterest: "boxparameterOfInterest",
          filteredInstallation: "boxfilteredInstallation"
        }
    },
    tabs: { activetab: 1 }
  },
  computed: {
    INST: function () {
      var inst = [];
      for (var j = 0; j < this.wsParams.name.length; j++){
        inst[j] = {name: this.wsParams.name[j], api: this.wsParams.api[j]}
      }
      return inst
    }
  },
  mounted:function(){
    this.fillListInput(inputId = this.graphParameters.barplot.filterBy ,inputList = this.wsParams.name);
    this.collectData() ;
   },
  methods: {
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
            self.collectedData.INST = output

            return output;
          }
        ).fail(function(request) {
          //$("#cssLoader").removeClass("is-active");
          alert("Error: "+ request.responseText);
        });
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
/*             instancesNames: self.wsParams.name,
            instancesApi: self.wsParams.api */
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
}
  }
})