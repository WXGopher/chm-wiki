Configuration for CHM is via a structure json file.

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
Point mode selects that the model should be run in point mode, versus distributed mode. For point model to work, there must be an input and output station of the appropriate name. All other points will be ignored.
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

```

  "modules": //important these are [ ]
  [
    //met interp
     "Liston_wind",
    "Marsh_shading_iswr",
//    "iswr_from_obs",
    "Burridge_iswr",
//    "slope_iswr",
     "Liston_monthly_llra_ta",
     "kunkel_rh",
     "Thornton_p",
//    "point_mode",

    //met process
    "Walcek_cloud",
     "Sicart_ilwr",
    "Harder_precip_phase",
//     "threshold_p_phase",

    //processes
    "snobal",
    "Gray_inf",
//    "snowpack"
     "Richard_albedo"

  ],

  // In case of a cycle depencency, remove dependencies between two modules. 
  // If module A depends on B (A->B), then to remove the depency specify it as
  // "A":"B" 
  // will remove the dependency on B from A.
  "remove_depency":
  {
    "Richard_albedo":"snobal"
  },
  "config":
  {

    "slope_iswr":
    {
      "no_slope":true
    },
    "snowpack":"snowpack.json",
    "Richard_albedo":
    {
      "min_swe_refresh":10,
      "init_albedo_snow":0.8
    },
    "Liston_wind":
    {
      "serialize":false,
      "serialize_output":"meshes/granger30_liston_curvature.mesh"
    }
  },
  "meshes":
  {
    "mesh":"meshes/granger30.mesh",
//
    //map internal variables/parameters to the .mesh file's parameter section.
    "parameters":
    {
      "file":"meshes/granger30_liston_curvature.mesh"
    }

  },

  "parameters":
  {
    "soil":"parameters/wolf_soil_param.json",

    "landcover":
    {
      "12":
      {
        "desc":"shadow"
      },
      "20":
      {
        "desc":"lake",
        "is_waterbody":true
      },
      "31":
      {
        "desc":"snow ice"
      },
      "32":
      {
        "desc":"rock"
      },

      "33":
      {
        "desc":"exposed"
      },
      "51":
      {
        "desc":"shrub tall"
      },
      "52":
      {
        "desc":"shrub low"
      },
      "81":
      {
        "desc":"wetland-treed"
      },
      "82":
      {
        "desc":"wetland-shrub"
      },
      "83":
      {
        "desc":"wetland-herb"
      },
      "100":
      {
        "desc":"herb"
      },
      "211":
      {
        "desc":"coniferous dense"
      },
      "212":
      {
        "desc":"coniferous open"
      },
      "213":
      {
        "desc":"Coniferous Sparse"
      },
      "221":
      {
        "desc":"Broadleaf Dense"
      },
      "222":
      {
        "desc":"Broadleaf Open"
      },
      "232":
      {
        "desc":"Mixedwood Open"
      }

    }
  },
  "output":
  {
    "northface":
    {
      "easting": 489857.879,
      "northing": 6712108.525,
      "file": "granger_northface.txt",
      "type": "timeseries"
    },
    "southface":
    {
      "easting": 489881.078,
      "northing": 6712491.738,
      "file": "granger_southface.txt",
      "type": "timeseries"
    },
    "middle":
    {
      "easting": 489864.752,
      "northing": 6712277.792,
      "file": "granger_middle.txt",
      "type": "timeseries"
    },
     "mesh":
     {
       "base_name":"output/granger"
//       "variables":["swe","t","rh"],
//       "frequency":1 //every N timesteps
     }
  },
  "global":
  {
    "latitude":60.52163,
    "longitude":-135.197151,
    "UTC_offset":8
  },
  "forcing":
  {
      "buckbrush":
       {
         "file":"bb_1999-2002", // hm_oct2010 hm_oct2_4_2010 hm_sep_15_2006
         "easting": 489216.601,
         "northing": 6709533.168,
         "elevation": 1305
       },
     "alpine":
     {
       "file":"alp_1999-2002",  //fr_sep_15_2006
       "easting": 489879.341,
       "northing":  6714611.183,
       "elevation": 1559
      // "filter":
      // {
      //   "macdonald_undercatch":
      //   {
      //     "variable":"p"
      //   }
      },
      "forest":
      {
        "file":"for_1999-2002",  //fr_sep_15_2006
        "easting": 502601.621,
        "northing":   6717779.327 ,
        "elevation": 739
        // "filter":
        // {
        //   "macdonald_undercatch":
        //   {
        //     "variable":"p"
        //   }
      }

    
  }  

}

