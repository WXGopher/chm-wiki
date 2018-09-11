Introduction
============

The Canadian Hydrological Model (CHM) uses a novel, modular, mesh-based approach for developing and testing process representations in hydrological modelling. It can move between spatial scales, temporal scales, and spatial extents. Its key features include the abilities to i) capture spatial heterogeneity in surface discretizations in an efficient manner, ii) include multiple process representations; iii) change, remove, and decouple hydrological process algorithms, iv) work both with spatially localized (point) and non-localized (distributed) models, v) span multiple spatial extents and scales, and vi) utilize a variety of forcing fields for boundary and initial conditions. You can visit the project Github [page](https://github.com/Chrismarsh/CHM). Contact its core developer [Chris Marsh](https://github.com/Chrismarsh) for further details/inquiries.

Installation
============

For the general installation procedure, refer to the [CHM wiki](https://github.com/Chrismarsh/CHM/wiki/Building-CHM). A few tips for installation:

1. For `OS X` users, make sure you have `homebrew`, gcc, cmake installed, then simply invoke the `superbuild` instructions.

2. If you encounter an error like

               The imported target "CGAL::CGAL_Qt5" references the file
               but this file does not exist.  Possible reasons include:

   check the auto-generated log files and screen output (you may use `build_command 2>&1 |tee output.txt` and retrieve `output.txt`). There is a chance the build system cannot resolve package dependencies on Linux systems, or you might miss some packages that the build system was not aware of (this is most likely to happen on a fresh installed system). Trying to install those packages manually (through `apt-get` or a better way `aptitude`) will resolve this. Prerequisite packages (this list is not exaustive) including: `freeglut3-dev`, `python-dev`, `libxml2-dev`, `libxslt-dev`, `autotools`, `m4`, `libgmp-dev`, `MFPR`, `Armadillo(including BLAS, LAPACK, libboost-dev, etc.)`. `curl`. An even better way is to refer to [Building on Ubuntu 16.04](https://github.com/Chrismarsh/CHM/wiki/Building-CHM#building-on-ubuntu-1604)(manually install proj4/QT5/CGAL/Amardillo/TBB/Boost/GSL/Curses using `apt-get`)

3. Make sure you are doing an out-of-source build, i.e., build source outside the source folder, like

         mkdir build
         cd build
         cmake -DSUPERBUILD=TRUE ../CHM_SOURCE
         make -j10

4. If you failed a build for whatever reason, run `clean_cmake.sh` before the next build attempt. The reason is `cmake` is known to be sticky on its configuration files and the cache might become stale;

5. Set up library path. Edit your `.bashrc`, and add

         export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:path_to_build/lib/gsl/lib

   and do

         source ~/.bashrc

6. The default build option, though it uses a “release” build, should generate debugging symbols. If you want to leave out compiler optimizations to peek into how the code actually works, you would need to modify the corresponding cmake script.

How it works
============

Configuration parser $\rightarrow$ Terrain representation (raster data) $\rightarrow$ Parameterization (triangulation of raster data) $\rightarrow$ Input filter $\rightarrow$ Modular process $\rightarrow$ Output/Data visualization

Configuration parser
--------------------

Every aspect of the model structure including initial conditions, modules (and their parameters), forcing data, and output data can be modified through either the command line or through a JSON configuration file. Specifying parameters through the command line allows quick on-the-fly testing without compromising some base configuration files.

A sample JSON configuration file is listed in Appendix \[apdx\_hello\_world\].

### Command line

Specifying options through the [command line](https://github.com/Chrismarsh/CHM/wiki/Command-line) can be done with either long- or short-form flags, i.e., --help, --version(-v), --config-file(-f), --config(-c), --remove(-r), --remove-module(-d), --add-module(-m).

“<span>--config(-c)</span>” overrides configurations in configuration files; however, this parameter does not support list values, for example:

    -c config.Harder_precip_phase.const.b:1.5 -c config.debug.debug_level:"error"

“<span>--remove(-r)</span>” removes configurations, and it overrides configurations specified by “--config”:

    -c nproc:2 -r nproc

“<span>--remove-module(-d)</span>” removes a module, and it overrides configurations specified by “--config”:

    -d Marsh_shading_iswr

“<span>--add-module(-m)</span>” adds a module to the list:

    -m snobal -m Marsh_shading_iswr

### Configuration files {#sec_config}

[Configuration](https://github.com/Chrismarsh/CHM/wiki/Configuration) for CHM is via a structured JSON file. The config file is structured into “key:value” pairs separated by commas. Key names are enclosed in quotes (“ ”), for example:

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

Important notes:

1.  Some configuration options are not compatible with others;

2.  Do not prefix a number with zero (0). This is the octal prefix and it will cause the JSON parser to choke on lines that otherwise look fine;

3.  Currently, mesher produces meshes that projected in Albers Conic equal area. Support for full exists, but there is an issue with computing surface normals;

4.  Regardless of input coordinate system all input points are specified in latitude and longitude in WSG84.

Configurations include:

1.  [option](https://github.com/Chrismarsh/CHM/wiki/Configuration#option) specifies additional options in the simulation;

2.  [modules](https://github.com/Chrismarsh/CHM/wiki/Configuration#modules) specifies module components (introduces in Section \[sec\_module\] to load. Modules order as defined in this list has no bearing on the order they are run. Note modules are in a list (`[]`). Modules may be commented out to remove them from execution. Module names are case sensitive. The `point_mode` module is required to enable point mode, in addition to being enabled in `option.point_mode`;

3.  [remove\_depency](https://github.com/Chrismarsh/CHM/wiki/Configuration#remove_depency) is to resolve circular dependencies among modules;

4.  [config](https://github.com/Chrismarsh/CHM/wiki/Configuration#config) specifies module configurations;

5.  [parameter\_mapping](https://github.com/Chrismarsh/CHM/wiki/Configuration#parameter_mapping) specifies meta-data for on-mesh parameters;

6.  [output](https://github.com/Chrismarsh/CHM/wiki/Configuration#output) specifies various output formats;

7.  [global](https://github.com/Chrismarsh/CHM/wiki/Configuration#global) specifies a set of globally applicable parameters.

Mesh and `mesher`
-----------------

General information on mesh representation refers to [Mesh](https://github.com/Chrismarsh/CHM/wiki/Mesh), [Mesh generation](https://github.com/Chrismarsh/CHM/wiki/Mesh-generation), and an external tool for generating the meshes: [`Mesher`](https://github.com/Chrismarsh/mesher).

The mesh structure (`.mesh` file) is formed as follows:

1. The triangle vertices are stored under the “vertex” key, e.g.,

            "vertex": [
            [
            488489.5,
            6713518.0,
            1525.4852294921875
            ]

2.  Then a triangle is defined by indexing into that list of vertexes:

                    "elem": [
                    [
                    8033,
                    8160,
                    8043
                    ]
    

    So, the three edges of a triangle is from vertex 8033 $\rightarrow$ vertex 8160; vertex 8160 $\rightarrow$ vertex 8043; vertex 8043 $\rightarrow$ vertex 8033.

3.  Then “neigh” holds the neighbour topology:

                    "neigh": [
                    [
                    17687,
                    16277,
                    15812
                    ],
    

    So triangle 0 has triangles 17687, 16277, and 15812 as neighbours.\
    If a triangle is an edge triangle, it’ll be missing a neighbour, denoted by -1:
    
                    [
                    -1,
                    19214,
                    11591
                    ],


Filters {#sec_filters}
-------

[Filters](https://github.com/Chrismarsh/CHM/wiki/Filters) are a mechanism whereby the input forcing data can be modified in some way prior to the model run. For example, this could be use to apply a gauge undercatch to precipitation. Filters modify the data of a station in situ.

Note! Filters run in the order defined in the configuration file.

Input Timeseries
----------------

Time series data are input in a tab delimitated format. Refer to [Timeseries](https://github.com/Chrismarsh/CHM/wiki/Timeseries) for accepted format.

Modules and parallelization {#sec_module}
---------------------------

[Modules](https://github.com/Chrismarsh/CHM/wiki/Modules) are the short-hand for a process representation. A principal design goal of a module is that it may depend upon either some set of variables produced by other modules or on input forcing data. Modules define a set of variables which it provides globally to other modules. A module may not overwrite a variable that another module declares. It should also not overwrite the variables of another module. Implementation details on modules can be found [here](https://github.com/Chrismarsh/CHM/wiki/Modules#implementation-details).

1.  All `module`s have pre-/post-conditions;

    Pre condition

    :   input forcing data or post-conditions from other `module`s;

    Post condition

    :   see pre condition;

    Variables

    :   provide global variables to other `module`s, but these variables do not change in other `module`s.

2.  There are two types of `module`s:

    Forcing data interpolant

    :   depends upon point-scale input forcing data variables and interpolate these data onto every domain element;

    Standard process module

    :   depends only upon the output of interpolation `module`s or other `module`s’ output.

3.  Parallelizations are offered in two ways, each module belongs to one of them:

    Data parallel

    :   point-scale models that are applied to every triangle;

    Domain parallel

    :   requires knowledge of surrounding mesh points.

    Parallelization process group `module`s with same parallel type (data/domain) together and execute them simultaneously.

The class hierarchy of `module` looks like Figure \[module\_hier\]:

Output Handling and Data visualization
--------------------------------------

Visualization is via [Paraview](https://www.paraview.org/) if mesh output is enabled in the configuration file. If `PV_FILTER` is enabled in `CMakeLists.txt`, a Paraview [plugin](https://github.com/Chrismarsh/CHM/wiki/Visualization#datetime-plugin) to show the date and time is built.

To convert the Paraview output (vtu files) to arbitrary GIS format, refer to [this](https://github.com/Chrismarsh/CHM/wiki/VTU-conversion) page.

Resources
=========

TBA

Convert this document to PDF
=======================

To convert this document to PDF, follow the instructions below:

1. Install texlive, texlive-fonts-recommended, texlive-fonts-extra
2. Install pandoc
3. Copy `eisvogel.latex` to `~/.pandoc/templates`
4. Execute `pandoc CHM-tutorial.md -o CHM-tutorial.pdf --from markdown --template eisvogel --listings`


A “Hello World” example
=======================

Source code (JSON file) of the example is listed as follows:

      {
    
      "option":
      {
    
      // For point model to work, there must be an input and output station of the appropriate names. All other points will be ignored.
      // "point_mode":
      // {
      //   "output":"UpperClearing",
      //   "forcing":"UpperClearing"
      // },
    
      //      "notification_script":"./finished.sh",
      "per_triangle_timeseries":"false",
      "ui":false,
      "debug_level":"debug",
    
      "prj_name":"Marmot",
    
      "startdate":"20081001T140000",
      "enddate": "20081001T150000"
      //      "enddate":"20081001T000000"
      },
      "modules": //imporant these are [ ]
      [
      "solar",
      "iswr",
      "iswr_from_obs",
      // "point_mode",
      "Marsh_shading_iswr" // this is a domain parallel module
      //"fast_shadow" // this is a data parallel module
      // "scale_wind_vert",
    
      // "Harder_precip_phase",
    
      // "Sicart_ilwr",
      // "Walcek_cloud",
    
      //processes
      //    "snobal",
      //    "snowpack",
      // "Richard_albedo"
    
      ],
    
      // In case of a cycle depencency, remove dependencies between two modules.
      // If module A depends on B (A->B), then to remove the depency specify it as
      // "A":"B"
      // will remove the dependency on B from A.
      "remove_depency":
      {
      "scale_wind_vert":"snowpack",
      "scale_wind_vert":"snobal"
      },
      "config":
      {
      "Richard_albedo":
      {
      "min_swe_refresh":10,
      "init_albedo_snow":0.8
      },
      "point_mode":
      {
      "provide":
      {
      "iswr_diffuse":false,
      "iswr_direct":false,
      "iswr":false,
      "ilwr":false,
      "U_R":false,
      "vw_dir":false,
      "T_g":true
      }
    
      },
      "snobal":
      {
      "z_0":0.01
      },
      "snowpack":
      {
      "Snowpack":
      {
      "ROUGHNESS_LENGTH":0.01,
      "HEIGHT_OF_WIND_VALUE":2.96,
      "HEIGHT_OF_METEO_VALUES":2.6,
      "ATMOSPHERIC_STABILITY":"MO_MICHLMAYR"
      },
      "SnowpackAdvanced":
      {
      "ADJUST_HEIGHT_OF_WIND_VALUE":true,
      "ADJUST_HEIGHT_OF_METEO_VALUES":true,
      "HN_DENSITY":"MEASURED"
    
      }
      }
    
      },
      "meshes":
      {
      "mesh":"mesh/marmot1m.mesh"
      },
      "output":
      {
      "mesh":
      {
      "base_name":"shadow",
      "frequency":1
      }
    
      },
      "forcing":
      {
      "UTC_offset":6,
    
      "UpperClearing":
      {
      // "file":"met/upper_clearing_vwdir.txt",
      "file":"met/uc_2005_2018.txt",
      "longitude": -115.175362,
      "latitude":  50.956547,
      "elevation": 1844.6
      // "filter": {
      //    "scale_wind_speed": {
      //      "Z_F": 2,
      //      "variable": "u"
      //    }
      //  }
    
      }


      }
    
      }
