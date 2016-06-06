Mesh generation is handled by the program located at ```tools/mesher/main.py```. Mesher depends heavily upon GDAL and the GDAL python bindings.

Configuration parameters are set in a second .py file and passed as an argument to ```main.py``` on the command line. For example:
```bash
python main.py example_config.py
```

CHM assumes that all meshes are in UTM meters. Due to the diversity of input data, all input parameters and DEM files to mesher are projected to a unified UTM projection, defined by the EPSG number. Further, all files' nodata value is set to -9999. 

The extent of ```dem_filename``` is used to define the simulation extent. Input parameters are constrained to this extent. However, parameters need not cover the entire extent. Therefore modules *must* check that paramters are not NaN.

```max_area``` Is a constraint on the maximum size (m^2) of a triangle.

```parameter_files``` is a dictionary  that lists additional parameters. Because a triangle may cover more than one raster cell, the ```method``` variable specifies either 'mode' or 'mean'. This controls how the >1 cells are merged and assigned to a triangle. 'Mode' sets the triangle to be the value that is most common out of all cells.

```python
    parameter_files = {
        'landcover': { 'file' : 'eosd.tif',
                       'method':'mode'},  # mode, mean
        'svf':{'file':'wolf_svf1.tif',
               'method':'mean'
               }
    }
```
Complex basin shapes might result in the creation of many triangles along the complex edges. Thus ```simplify=True``` and ```simplify_tol``` can be used to simplify the basin outline. ```simplify_tol``` is the simplification tolerance specified in meters. Becareful as too high a tolerance will cause many lines to be outside of the bounds of the raster.


```python
# Configuration file for Mesher
EPSG=26911
dem_filename = 'bow_srtm1.tif'
max_area=1000000
parameter_files={ }

simplify     =   False
simplify_tol =   5   
```