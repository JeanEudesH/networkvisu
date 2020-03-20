// comment out this line from development 
ocpu.seturl("http://0.0.0.0:8004/ocpu/library/networkVisu/R");
//ocpu.seturl("http://localhost:5656/ocpu/library/networkVisu/R");
var App = new Vue({
  el: "#exploreApp",
  data: {
    selected: [],
    collectedData: {
      INST: [{ api: "FALSE", name: "All" }],
      computedDF: [{ key: "nom", value: 2 },
                   { key: "nom", value: 8 }  
                  ],
      functionName: "collectScientificObject"
    },
    graphParameters: {
      iframeInput: "plotDiv",
      outputName: "Graph.png",
      barplot: {
        functionName: "barplotGraph",
        parameterOfInterest: "parameterOfInterest",
        filteredInstallation: "filteredInstallation",
        groupBy: "groupBy"
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
    tabs: { 
      activetab: 2,
      loading: true 
    }
  },
  computed: {
    /* comme data mais recalculé quand l'input change */
  },
  mounted: {
    /* fonction à lancer au démarage de l'app */
  },
  /* les "variables de vue" */
  methods: {
    /* un exemple de fonction avec ocpu.rpc c'est la fonction de base */
    installationTable: function () {
      var self = this;
      return ocpu.rpc(
        //Create array of variables' options
        // R function name
        self.wsParams.RfunctionName,
        // list of arguments names and value
        {
          instancesNames: self.wsParams.name,
          instancesApi: self.wsParams.api
        },

        function (output) {
          //$("#cssLoader").removeClass("is-active");
          self.collectedData.INST = self.collectedData.INST.concat(output);

          return output;
        }
      ).fail(function (request) {
        //$("#cssLoader").removeClass("is-active");
        alert("Error: " + request.responseText);
      });
    },
    /* un exemple avec un .rplot */
    showbarGraph: function () {
      $("#cssLoader").addClass("is-active");
      /* petite astuce pour que le this marche à l'intérieur d'une fonction */
      var self = this;
      // Run the R function
      /* ici je récupère les valeurs des paramètres, différentes manières */
      var parameterOfInterest = $("#" + this.graphParameters.barplot.parameterOfInterest).val();
      var filteredInstallation = $("#select_id_1").val();
      var groupBy = "All"
      var outputName = self.graphParameters.outputName;
      var iframeInput = self.graphParameters.iframeInput;
      return (req = $(iframeInput).rplot(
        /* nom de la fonction */
        self.graphParameters.barplot.functionName,
        /* arguments et valeurs des arguments */
        {
          computedDF: self.collectedData.computedDF,
          parameterOfInterest: parameterOfInterest,
          filteredInstallation: filteredInstallation,
          groupBy: groupBy
        },
        /* actions à faire lorsque réponse */
        function (session) {
          $("#" + iframeInput).attr(
            "src",
            session.getFileURL(outputName)
          );
          $("#submit").removeAttr("disabled");
          $("#cssLoader").removeClass("is-active");
        }).fail(function (request) {
          $("#submit").removeAttr("disabled");
          $("#cssLoader").removeClass("is-active");
          alert("An unknown error has append : " + request.responseText);
        })
      );
    },
    /* un exemple avec ocpu.call */
    showradar: function () {
      $("#cssLoader").addClass("is-active");
      var self = this;
      // Run the R function
      var objectOfInterest = $("#" + self.graphParameters.radar.objectOfInterest).val();
      var variable = $("#" + self.graphParameters.radar.parameterOfInterest).val();
      var outputName = this.graphParameters.radar.outputName;
      var iframeInput = this.graphParameters.iframeInput;
      return (req = ocpu.call(
        self.graphParameters.radar.functionName,
        {
          DATA: self.collectedData.computedDF,
          object: objectOfInterest,
          variable: variable
        },
        function (session) {
          $("#" + iframeInput).attr(
            "src",
            session.getFileURL(outputName)
          );
          $("#submit").removeAttr("disabled");
          $("#cssLoader").removeClass("is-active");
        }).fail(function (request) {
          $("#submit").removeAttr("disabled");
          $("#cssLoader").removeClass("is-active");
          alert("An unknown error has append : " + request.responseText);
        })
      );
    },
    download_graph: function () {
      var hiddenElement = document.getElementById('DownloadGraph');
      hiddenElement.href = "image/Graph.png";
      hiddenElement.target = '_blank';
      hiddenElement.download = 'Graph.png';
      hiddenElement.click();
    },
    download_json: function () {
      var DATA = this.collectedData.computedDF;
      var hiddenElement = document.getElementById('Download');
      hiddenElement.href = 'data:json/application;charset=utf-8,' + JSON.stringify(DATA);
      hiddenElement.target = '_blank';
      hiddenElement.download = 'file.json';
      hiddenElement.click();
    },
    tableSummarised: function () {
      var self = this;
      setTimeout(function () {
        var df = self.collectedData.computedDF
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
      }, 200)

    },
    makeHeaders: function (colnames) {
      var str = "<thead><tr>";
      for (var i = 0; i < colnames.length; i++) {
        str += "<th>" + colnames[i] + "</th>";
      }
      str += "</tr></thead>"
      return (str);
    }
  },
  /*  ou alors juste aller piquer du code depuis ce template */
  components: {
    'tab-compo': {
      inheritAttrs: true,
      props: {
        title: String,
        param1: String,
        param2: String,
        functionname: String,
        outputpath: String,
        filter: Boolean
      },
      template: `
        <div class="tabcontent">
            <h1>{{title}}</h1>
            <br>
            <div class="form-group" style="Text-align:left;Width:20%;float:left">
                <strong> {{param1}}</strong>
                <select v-bind:id="param1">   
                    <option value="Type">Type</option>
                    <option value="Year">Year</option>
                    <option value="Experiments">Experiments</option>
                    <option value="Installation">Installation</option>
                </select> 
            </div>
    
            <div class="form-group" style="Text-align:right;Width:20%;float:right">
                <strong > {{param2}} </strong>
                <select v-bind:id="param2">
                    <option value="Type">Type</option>
                    <option value="Year">Year</option>
                    <option value="Experiments">Experiments</option>
                    <option value="Installation">Installation</option>
                </select> 
            </div>
            <br>
            <div class="form-group" v-if='filter'>
            <strong>
                <label>Filter by installation ? </label>
            </strong>
            
            <select id="filteredInstallation" v-model="$parent.collectedData.INST" multiple v-for=" Options in $parent.collectedData.INST">
                <option>
                {{Options.name}}
                </option>
            </select>
            <br>
            </div>
            

          <transition name="slide-fade">
            <div id = "spinner" class="lds lds-spinner" v-if="$parent.tabs.loading"><div></div><div></div><div></div><div></div><div></div><div></div><div></div><div></div><div></div><div></div><div></div><div></div></div>
          </transition>

            <button id="submit" type="submit" class="btn btn-primary" v-on:click="$emit('myevent')" >
                Show {{title}} !
            </button>
    
        <div class="embed-responsive embed-responsive-16by9" v-if="outputpath.indexOf('png')!=-1">
            <img class="embed-responsive-item" v-bind:src='outputpath' allowfullscreen id='plotDiv' ></img>
        </div>
    

        <div class="embed-responsive embed-responsive-16by9" v-if="outputpath.indexOf('html')!=-1">
            <iframe class="embed-responsive-item" v-bind:src='outputpath' allowfullscreen id='plotDiv' ></iframe>
        </div>

        </div>`
    }
  }
})


