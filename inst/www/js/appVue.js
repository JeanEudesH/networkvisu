// comment out this line from development 
ocpu.seturl("http://0.0.0.0:8004/ocpu/library/networkVisu/R");

var App = new Vue({
  el: "#exploreApp",
  data: {
    wsParams: {
      name: ["Diaphen", "OpensilexDemo","Agrophen","Pheno3C","Phenovia","PhenoField","Ephesia"],
      api: ["147.100.175.121:8080/phenomeDiaphenAPI/rest/", "opensilex.org/openSilexAPI/rest/", "147.100.175.121:8080/phenomeAgrophenAPI/rest/", "147.100.175.121:8080/phenomePheno3cAPI/rest/", "147.100.175.121:8080/phenomePhenoviaAPI/rest/", "147.100.175.121:8080/phenomePhenofieldAPI/rest/", "138.102.159.36:8080/phenomeEphesiaAPI/rest/"],
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
        barplotGraphParameters: "",
        outputName: "Graph.png"
    },

  },
  computed: {
    INST: function () {
      return [{name: this.wsParams.name} , {api: this.wsParams.api}]
    }
  },
  methods: {
    initialize: function (){
        if ($("#name").length != 0) {
          this.wsParams.name = $("#name").val();
        } else {
          this.wsParams.name = this.wsParams.params.get("name");
        }
        if ($("#api").length != 0) {
          this.wsParams.api = $("#api").val();
        } else {
          this.wsParams.api = this.wsParams.params.get("api");
        }
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
          alert("Error: ");
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
            self.collectedData.computedDF = output
            $("#cssLoader").removeClass("is-active");
            return output;
          }
        ).fail(function(request) {
          $("#cssLoader").removeClass("is-active");
          alert("Error: ");
        });
    },
    showGraph: function(){
        $("#cssLoader").addClass("is-active");
        // Run the R function
        var parameterOfInterest = $("#parameterOfInterest").val();
        var filteredInstallation =$("#filteredInstallation").val();
        var groupBy = $("#groupBy").val();
        var outputName = this.graphParameters.outputName;
        var iframeInput = this.graphParameters.iframeInput;
        return(req = ocpu.call(
            this.graphParameters.functionName,
            {
              computedDF: this.collectData.computedDF,
              parameterOfInterest: parameterOfInterest,
              filteredInstallation: filteredInstallation,
              groupBy: groupBy,
              print: "TRUE"
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