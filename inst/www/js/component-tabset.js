vue.component('graph-tabset',{
    props:{
        title:String,
        param1:String,
        param2:String,
        filter:Boolean,
        outputName: String,
        outputDivName: String,
        functionName: String,



},
    template:`
         <div v-if="tabs.activetab === 1" class="tabcontent">
                                        <div id=this.props.title>
                                        {{title}}
                                            <!-- parameterOfInterest -->
                                            <div class="form-group">
                                                <br>
                                                <strong>
                                                    <label> {{param1}} </label>
                                                </strong>
                                                <select id="this.props.param1" name="parameterOfInterest">
                                                    <option value="Type">Type</option>
                                                    <option value="Year">Year</option>
                                                    <option value="Experiments">Experiments</option>
                                                    <option value="Installation">Installation</option>
                                                </select> 
                                            </div>
                                            <!-- groupBy -->
                                            <div class="form-group">
                                                <strong>
                                                    <label> {{param2}} </label>
                                                </strong>
                                                <select id="this.props.param2" name="groupBy">
                                                    <option value="Type">Type</option>
                                                    <option value="Year">Year</option>
                                                    <option value="Experiments">Experiments</option>
                                                    <option value="Installation">Installation</option>
                                                </select> 
                                            </div>
                                            <div class="form-group" v-if='filter'>
                                                <strong>
                                                    <label>Filter by installation ? </label>
                                                </strong>

                                                <select id="filteredInstallation" v-model="selected" multiple>
                                                    <option v-for="option in collectedData.INST" v-bind:value="option.api">
                                                        {{ option.name }}
                                                    </option>
                                                </select>
                                                <br>
                                            </div>
                                            <!-- submit -->
                                            <div id = "spinner" class="lds lds-spinner"  style="visibility:visible"><div></div><div></div><div></div><div></div><div></div><div></div><div></div><div></div><div></div><div></div><div></div><div></div></div>
                                            <button id="submit" type="submit" class="btn btn-primary" v-on:click.prevent="showbarGraph">
                                                Show BarPlot!
                                            </button>
                                            <br>    
                                            ne marche pas pour le moment : est-ce qu'il y a besoin (un "enregistrer l'image sous..." marche très bien)
                                            <button v-on:click="download_graph()" class="btn btn-primary"><i class="fa fa-download"></i> Download Graph </button>
                                            <a id="DownloadGraph">

                                            <div class="embed-responsive embed-responsive-16by9" >
                                                <img class="embed-responsive-item" src="image/Graph.png" id="this.props.outputDivName" allowfullscreen style="width:70%; height:70%"></img>
                                            </div>
                                        </div>
                                </div>
    `
})