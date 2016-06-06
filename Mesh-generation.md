Mesh generation is handled by the program located at ```tools/mesher/main.py```. Configuration parameters are set in a second .py file and passed as an argument to ```main.py``` on the command line.

CHM assumes that all meshes are in UTM meters. Due to the diversity of input data, all input parameters and DEM are projected to a unified UTM projection, defined by the EPSG number. Further, all files' nodata value is set to -9999. 

The extent of ```dem_filename``` is used to define the simulation extent. Input parameters and
```python
# Configuration file for Mesher
EPSG=26911
dem_filename = 'bow_srtm1.tif'
max_area=1000000
parameter_files={ }

simplify     =   False
simplify_tol =   5   #amount in meters to simplify the polygon by. Careful as too much will cause many lines to be outside of the bounds of the raster.

```