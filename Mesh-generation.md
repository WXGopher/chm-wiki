Mesh generation is handled by the program located at ```tools/mesher/main.py```. Mesher depends heavily upon GDAL to handle the geospatial data and the GDAL python bindings. Mesher's input rasters can be in any 1-band raster than GDAL can open. The triangulation is performed using [Triangle](https://www.cs.cmu.edu/~quake/triangle.html).

Configuration parameters are set in a second .py file and passed as an argument to ```main.py``` on the command line. For example:
```bash
python main.py example_config.py
```

Experimental support is now enabled for lat/long input files. Due to the diversity of input data, all input parameters and DEM files to mesher are set to unified datum, defined by the EPSG number of `dem_filename`. Further, all files' nodata value is set to -9999. 

The coordinate system of `dem_filename` is used for all other files. However, the user may specify `EPSG` in the configuration file, which will override the coordinate system of `dem_filename`.

If a lat/long (i.e., geographic) dataset is found, a few things happen:
- Shortcuts in the meshing step cannot be taken, so meshing will likely take a bit longer
- CHM will scale all lat/long values by 100000 for the vtu output as Paraview seems to struggle rendering points so close to together.
- This scaling occurs during mesh read -- will be to be fixed later to be only in the vtu output.
- When triangles are checked during meshing to get the parameter and initial conditions, the triangle is temporarily projected to an equal-area conic so-as to determine the area in m^2.

The extent of ```dem_filename``` is used to define the simulation extent. Input parameters are constrained to this extent. However, parameters need not cover the entire extent. Therefore modules *must* check that paramters are not NaN.

```max_area``` Is a constraint on the maximum size (m^2) of a triangle.

```max_tolerance``` The maximum difference (vertical distance) between the triangle and the underlying raster

```min_area``` A minimum area (m^2) past which mesher should not refine a triangle further. A good setting is the square area of a DEM cell. This does not mean a triangle won't be smaller than this; rather, if a triangle is below this threshold it will automatically be accepted as valid. This will override the tolerance setting. For example, if the threshold is 3m^, and a 2m^ triangle is checked for validity, it will automatically be accepted, without checking the tolerance. A triangle may end up smaller than this threshold due to other splitting that occurs in order to guarantee triangle quality.

```errormetric``` Assigned an integer value that determines the error metric to use.
1 = Mean elevation difference 
2 = RMSE tolerance 

```parameter_files``` is a dictionary  that lists additional parameters. Because a triangle may cover more than one raster cell, the ```method``` variable specifies either 'mode' or 'mean'. This controls how the >1 cells are merged and assigned to a triangle. 'Mode' sets the triangle to be the value that is most common out of all cells.

```initial_conditions``` is a dictionary  that lists additional parameters. Because a triangle may cover more than one raster cell, the ```method``` variable specifies either 'mode' or 'mean'. This controls how the >1 cells are merged and assigned to a triangle. 'Mode' sets the triangle to be the value that is most common out of all cells.


```python
    parameter_files = {
        'landcover': { 'file' : 'eosd.tif',
                       'method':'mode'},  # mode, mean
        'svf':{'file':'wolf_svf1.tif',
               'method':'mean'
               }
    }
initial_conditions={
     'sm' : {'file': 'granger_sm_2000.tif', 'method': 'mean'},
    'swe' : {'file': 'granger_swe_2001.tif', 'method':'mean'}
}
```
Complex basin shapes might result in the creation of many triangles along the complex edges. Thus ```simplify=True``` and ```simplify_tol``` can be used to simplify the basin outline. ```simplify_tol``` is the simplification tolerance specified in meters. Be careful as too high a tolerance will cause many lines to be outside of the bounds of the raster.


```python
# Configuration file for Mesher
dem_filename = 'bow_srtm1.tif'
max_area=1000000
max_tolerance=50
min_area = 30**2
parameter_files={ }
initial_conditions={ } 
errormetric = 1 
simplify     =   False
simplify_tol =   5   
```

Mesher creates a directory with the same name as the input dem. This directory has the reprojected files (```*_projected```), Triangle's intermediary files (.node, .elem, .neigh), and the triangulation shape file (```*_USM.shp```).


