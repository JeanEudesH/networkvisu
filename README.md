# Phis network exploration

R Application exploring different instances of PHIS information system.

The app should be used in the 'ressources' instance of PHIS and as a communication tool. 

The different instances of PHIS are requested as 'guest' user.

The app propose different visualisation graphs such as barplot, boxplot and pie chart, treemap and radar chart. (more will be possible)

The list of instances is : OpensilexDemo, Pheno3C, Phenovia, PhenoField, Ephesia.

Some difficulties are encountered when retrieving too much information at once. For the moment, it is recommended to use only a few set of installations.
 
Install this app using the following command. And run it as follows :
```
install_apps("JeanEudesH/networkvisu")
ocpu_start_app("JeanEudesH/networkvisu")
#or
ocpu_start_app("compareVariableDemoVue")
```
And finally open the following link in your browser :

http://localhost:5656/ocpu/library/networkvisu/www/index.html
