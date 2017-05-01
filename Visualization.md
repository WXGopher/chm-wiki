Visualization is via [Paraview](http://www.paraview.org/) if mesh output is enabled in the configuration file.

# Datetime plugin

A paraview plugin to show the date and time is built if ```PV_FILTER``` is enabled in CMakeLists.txt. This requires the paraview-dev libraries to be installed. Although included in CHM, the details of the filter can be found on it's [github page](https://github.com/Chrismarsh/vtk-paraview-datetimefilter). 

```Tools -> Manage Plugins -> Load new -> Navigate to build directory```
After restarting Paraview, you will have to reload the plugin via ```Tools -> Manage Plugins -> Load Selected```

Optionally, copy the compiled filter into the plugins directory of paraview and add
```<Plugin name="TimeAnnotate" auto_load="1"/>``` to the `.plugins` file. This will load the plugin automatically.

If mesh output is selected a pvd file, as well as multiple vtu files, are generated. The pvd file is an XML file that links each output to the julian date. This is required for showing the time. 

To add the datetime filter to the view, load the pvd file and ensure this is selected the left pane. Then, ```Filters->Search``` and search for ```datetime```. 

# Stations

If any output is specified then a `output_points.vtp` file is written to the root of the output folder. Forcing points are written to `stations.vtp` in the root output folder. The vtp files are a point dataset of the x,y,z value of the forcing stations, as well as the station name as a label. To view the points in Paraivew:

- Load the vtp file
- With the vtp file selected in the Pipeline Browser, choose Point Gaussian as the representation. Change the radius so the point is visible, or decrease it if it is too large.

To view the point labels:
- Select vtp file in the pipeline browser
- Create a new spreadhseet layout
- Select the points you wish to have labels displayed for
- View->Selection Display Inspector
- Choose Point Labels drop down and select 'Station name'.
- Use the cog next to 'selection colour' to change the display font (size, colour, etc) 

![](https://github.com/Chrismarsh/CHM/blob/master/viz_points.png)

# Output points
If single triangle point-output is selected, these points are written to a seperate vtp file in the output/points directory. To view, follow the above directions.