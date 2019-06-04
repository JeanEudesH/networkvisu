// comment out this line from development 
ocpu.seturl("http://0.0.0.0:8004/ocpu/library/networkVisu/R");

var App = new Vue({
  el: "#exploreApp",
  data: {
    wsParams: {
      name: ['OpensilexDemo','Pheno3C','Phenovia','PhenoField','Ephesia'],
      api: ["opensilex.org/openSilexAPI/rest/", "147.100.175.121:8080/phenomePheno3cAPI/rest/", "147.100.175.121:8080/phenomePhenoviaAPI/rest/", "147.100.175.121:8080/phenomePhenofieldAPI/rest/", "138.102.159.36:8080/phenomeEphesiaAPI/rest/"],
      RfunctionName: "installationTable"
    },
    collectedData:{
      INST:[],
      computedDF:[],
      functionName: "collectData"
    },
    graphParameters: {
        iframeInput: "plotDiv",
        functionName: "barplotGraph",
        barplotGraphParameters: {
          filterBy: "filteredInstallation",
          print: "FALSE",
          parameterOfInterest: "parameterOfInterest",
          filteredInstallation: "filteredInstallation",
          groupBy: "groupBy"
        },
        functionPieGraph: "pieGraph",
        pieChartParameters: {
          print: "FALSE",
          parameterOfInterest: "pieparameterOfInterest",
          filteredInstallation: "piefilteredInstallation"
        },
        outputName: "Graph.png"
    },
    tabs: { activetab: 1 }
  },
  computed: {
    INST: function () {
      return [{name: this.wsParams.name} , {api: this.wsParams.api}]
    }
  },
  mounted:function(){
    this.fillListInput(inputId = this.graphParameters.barplotGraphParameters.filterBy ,inputList = this.wsParams.name);
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
            $("#cssLoader").removeClass("is-active");
            self.collectedData.INST = output

            return output;
          }
        ).fail(function(request) {
          $("#cssLoader").removeClass("is-active");
          alert("Error: "+ request.responseText);
        });
    },
    collectData: function(){
        $("#cssLoader").addClass("is-active");
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
            instancesNames: self.wsParams.name,
            instancesApi: self.wsParams.api
          },
      
          function(output) {
            $("#cssLoader").removeClass("is-active");
            self.collectedData.computedDF = output
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
        var parameterOfInterest = $("#"+self.graphParameters.barplotGraphParameters.parameterOfInterest).val();
        var filteredInstallation =$("#"+self.graphParameters.barplotGraphParameters.filteredInstallation).val();
        var groupBy = $("#"+self.graphParameters.barplotGraphParameters.groupBy).val();
        var outputName = this.graphParameters.outputName;
        var iframeInput = this.graphParameters.iframeInput;
        return(req = $(iframeInput).rplot(
          self.graphParameters.functionName,
            {
              computedDF: self.collectedData.computedDF,
              parameterOfInterest: parameterOfInterest,
              filteredInstallation: filteredInstallation,
              groupBy: groupBy,
              print: self.graphParameters.barplotGraphParameters.print
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
      var parameterOfInterest = $("#"+self.graphParameters.pieChartParameters.parameterOfInterest).val();
      var filteredInstallation =$("#"+self.graphParameters.pieChartParameters.filteredInstallation).val();
      var outputName = this.graphParameters.outputName;
      var iframeInput = this.graphParameters.iframeInput;
      return(req = $(iframeInput).rplot(
        self.graphParameters.functionPieGraph,
          {
            collectData: self.collectedData.computedDF,
            parameterOfInterest: parameterOfInterest,
            filteredInstallation: filteredInstallation,
            print: self.graphParameters.pieChartParameters.print
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