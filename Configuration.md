Configuration for CHM is via a structured json file.

Below, all options are detailed, however please note some configuration options may be incompatible with other options.

The config file is structured into key:value pairs separated by commas. Key names are enclosed in quotes (" ").
```
{
  "key":
   {
      "value1":123
   },
   "key2":
   {
    "value2:"True"
   }
}

```

#option

These are under ```option.X```:

### point_mode
Point mode selects that the model should be run in point mode, versus distributed mode. For point model to work, there must be an input and output station of the appropriate name. All other points will be ignored. Requires adding ```point_mode``` to the module list. Lastly, no modules which are defined ```parallel:domain``` may be used when ```point_mode:true``` is enabled. 
```json

    "point_mode":
    {
      "output":"UpperClearing",
      "forcing":"UpperClearing"
    },
```
### notification_script
This specifies the script to call upon model execution. This is useful for sending a notification to a computer or phone upon the completion of a long model run.
```json
    "notification_script":"./finished.sh"
```
And example of what ```finished.sh``` might do  is below, which triggers a notifcation to Pushbullet thus showing up on all computers and phones that the account is active on:
```bash
#!/bin/bash

curl -s -u <token here>: https://api.pushbullet.com/v2/pushes -d type=note -d title="Finished model run" >/dev/null
```

### per_triangle_timeseries
Keeping a continuous timeseries on all triangles is memory intensive and generally shouldn't be used. At the moment this is a legacy option and should be kept 'false' (also it's default behaviour).
```json
    "per_triangle_timeseries":"false"
```

### ui
There is a ncurses ui. However it is currently a little buggy and often requires a ```stty sane;clear``` call at the end. 
```
    "ui":true
```

### debug_level
This controls the verbosity of the output. Options are:
- verbose [ all messages ]
- debug   [ most messages useful for debugging ]
- warning [ only warnings]
- error   [ only errors which terminate model execution ]
Currently most internal messages are debug level. 
```json
    "debug_level":"debug"
```

### prj_name
Project name for reference in the ncurses ui
```json
    "prj_name":"Granger creek"
```

### startdate
By default, the model runs for the entirety of the input timeseries. ```startdate``` allows for starting at a time *after* the start of the timeseries
```json
    "startdate":"20010501T000000"
```
### enddate
By default, the model runs for the entirety of the input timeseries. ```enddate``` allows for ending at a time *before* the end of the timeseries
```json
       "enddate":"20010502T000000"
```

#modules

Modules order as defined in this list has no bearing on the order they are run. Note modules are in a list ([ ]). Modules may be commented out to remove them from execution. Module names are case sensitive. The ```point_mode``` module is required to enable point mode, in addition to being enable in ```option.point_mode```.
```json
  "modules": //important these are [ ]
  [
     "Liston_wind",
    "Burridge_iswr",
    "slope_iswr",
     "Liston_monthly_llra_ta",
     "kunkel_rh",
     "Thornton_p",
     "Walcek_cloud",
     "Sicart_ilwr",
     "Harder_precip_phase",
    "snobal",
    "Gray_inf",
     "Richard_albedo"

  ]
```
# remove_depency
Under some edge cases, a cyclic dependency is created when a module depends on A's output, and A depends on B's output. There is no way to automatically resolve this. It requires the modeller to manually break the cycle and force one module to run ahead of another (essentially time-lagged). 

An example of this occuring is that the albedo models require knowledge of SWE, provided by the snowmodel. However, the snowmodel requires albedo to run. Therefore, the modeller may define that the albedo routine is run first, then the snowpack model.

In detail: if module A depends on B (A->B), then to remove the decency of B from A, specify it as ```"A":"B" ```
```json
  "remove_depency":
  {
    "Richard_albedo":"snobal"
  }
```

#config
Each module, upon creation is provided a configuration instance (see [modules](modules)). These configuration data are set by creating a key that exactly matches the module name. For example
```json
"slope_iswr":
    {
      "no_slope":true
    }
```
would be accessed by the module as 
```cpp 
cfg.get<bool>("no_slope")```

If the configuration is sufficiently large or cumbersome, it may be best to have it in a separate file. This can be specified as
```json
"snowpack":"snowpack.json"
```
where ```snowpack.json``` looks like:

```json
{
	"Snowpack":
	{
		"HEIGHT_OF_WIND_VALUE" : 2,
		"ATMOSPHERIC_STABILITY" : "MONIN_OBUKHOV"
	},
	"SnowpackAdvanced":
	{
		"MAX_NUMBER_MEAS_TEMPERATURES":1
        }
}
```
In the snowpack module, ```ATMOSPHERIC_STABILITY``` would be accessed as
```cpp
cfg.get<bool>("SnowpackAdvanced.ATMOSPHERIC_STABILITY");
```


#meshes
The meshes section has two sections:
- mesh
- parameters
###mesh
```mesh``` is the file path  to the main .mesh file that contains the DEM information, as well as optionally, parameters. 
###parameters
```parameters``` is a set of key:value pairs to other mesh files that contain extra parameters to be used.
```json
  "meshes":
  {
    "mesh":"meshes/granger30.mesh",
    "parameters":
    {
      "file":"meshes/granger30_liston_curvature.mesh"
    }

  }
```
Mesh parameters are not guaranteed to cover the entire extent of the of the DEM. A module may test for a parameter on a triangle as follows:
```cpp
 if (face->has_parameter("swe2"))
        {
            if( !is_nan(face->get_parameter("swe2")))
            {
                sbal->z_s = face->get_parameter("swe2") / sbal->rho;
            }
        }
```
# parameters
Often, the parameters in the mesh may requires information. For example, landcover might be a numeric class value. The parameters can thus be arbitrary extra data. These can be thought of the meta-data for the on-mesh parameters. These parameters may be either located in another file:
```json 
  "parameters":
  {
    "soil":"parameters/wolf_soil_param.json"
  }
```
or as a key:value set. In all cases, the parameter name is how it will be referenced in the module that is looking for it. 
```json
    "landcover":
    {
      "20":
      {
        "desc":"lake",
        "is_waterbody":true
      },
      "31":
      {
        "desc":"snow ice"
      }
   }
```
# output
Output may be either to a timeseries for a specific location on the mesh or it may be the entirety of the mesh.

### timeseries
The name of the timeseries key is used to uniquely identify this output. A x,y coordinate (given as ```easting``` and ```northing```) is provided. The triangle that contains this point is then selected for output. An error is raised if no triangle contains the point. ```file``` denotes the output file name. The output is in csv format. ```timeseries``` is a legacy option and should be set to "timeseries" and forgotten.
```json
  "output":
  {
    "northface":
    {
      "easting": 489857.879,
      "northing": 6712108.525,
      "file": "granger_northface.txt",
      "type": "timeseries"
    }
 }
```
### mesh
Alternatively, the entire mesh is written to Paraview's vtu format for visulatization in Paraview and for analysis. ```base_name``` is the base file name to be used. In this case the files will be named sequentially ```granger.0001.vtu```, ```granger.0002.vtu```, &c in the output directory. 

If mesh output is enabled, the default behaviour to is write every variable at each timestep. Only variables defined in the ```provides``` call is eligible for output. 

#### variables
```"variables":[ ] ``` can be set to write a subset of variables. This is useful for reducing the size of output files.

#### frequency
Frequency can be set to write ever N timesteps. The pvd file will properly display the time of each output.
  
```json
     "mesh":
     {
       "base_name":"output/granger",
       "variables":["swe","t","rh"],
       "frequency":1 
     }
```
# global
Global defines a set of globally applicable parameters. The key name is a unique identifier. If ```point_mode``` is being used, then the station used in ```point_mode``` must exist in this list.

## latitude, longitude
Awkwardly, the lat/long of the basin is given despite the underlying mesh being defined in UTM. ```longitude``` is negative westward.
```json
"latitude":60.52163,
"longitude":-135.197151
```
##UTC_offset
The utc offset is used to determine solar parameters. Positive west.
```json
    "UTC_offset":8
```
##forcing 
Forcing data are defined as an input [timeseries](timeseries) in tab delineated format with ISO datetime. Input forcing stations do not need to be located within the simulation domain. Therefore they can act as 'virtual stations' so-as to use reanalysis data, or met stations located outside of the basin.

### file 
```file``` is a relative or absolute path
```json
"file":"bb_1999-2002"```

### easting, northing
Easting and Northing of the input station
```json
         "easting": 489216.601,
         "northing": 6709533.168
```
### elevation
Elevation is given in meters. It does *not* need to be equal to the elevation of the triangle upon which it lies if the station is located in the simulation domain.

### filter
If a [filter](filters) is defined, it must be defined on the forcing file and operate upon a variable that exists in the forcing data.

```json
      "buckbrush":
       {
         "file":"bb_1999-2002", 
         "easting": 489216.601,
         "northing": 6709533.168,
         "elevation": 1305,
         "filter":
         {
           "macdonald_undercatch":
           {
             "variable":"p"
           }
        }
     }
```

