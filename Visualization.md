Visualization is via [Paraview](http://www.paraview.org/) if mesh output is enabled in the configuration file.

A paraview plugin is built if ```PV_FILTER``` is enabled in CMakeLists.txt. This requires the paraview-dev libraries to be installed. Although included in CHM, the details of the filter can be found on it's [github page](https://github.com/Chrismarsh/vtk-paraview-datetimefilter). 

```Tools -> Manage Plugins -> Load new -> Navigate to build directory```

After restarting Paraview, you will have to reload the plugin via ```Tools -> Manage Plugins -> Load Selected```

If mesh output is selected a pvd file, as well as multiple vtu files, are generated. The pvd file is an XML file that links each output to the julian date. This is required for showing the time. 

To add the datetime filter to the view, load the vtp output and ensure this is selected the left pane. Then, ```Filters->Search``` and search for ```datetime```. 

 