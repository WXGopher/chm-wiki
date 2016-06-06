The conversion of the vtu format to arbitrary GIS formats is provided by ```vtu2geo``` located in ```tools/vtu2geo/main.py```. 

This tool produces an internal shp file that corresponds to the triangulation and uses GDAL to rasterize this to an output geotiff.  

The vtu files contain multiple variables. Therefore, each output geotiff is a 1-band file corresponding to the selected output. The variables of interest as set in the ```variables``` list.

For vtu variables that are parameters (and therefore constant with time), only 1 output file is needed. These are defined in the ```parameters``` list. Only 1 geotiff will be produced from these.

```base``` is the base vtu name, and should correspond to the ```output.mesh.base_name``` option in the main configuration file.

```pixel_size``` is the size of the raster cells in m^2.

```EPSG``` should be specified to define the coordinate system of the geotiff.

```python
    base = "granger"
    input_path = 'output/'
    EPSG=26908 
    variables = ['total_inf','total_excess']  #set to None to dump all variables
    parameters = ['Aspect'] # paramters are one offs we want to extract from the vtu files
    pixel_size = 10 # (m)
```