# Dependencies
* Cmake >3.3
* Matlab (optional)
* Armadillo
* boost
* GNU GSL
* Intel TBB
* GDAL (>2.0)
* CGAL
* Paraview (if building the filter) 
* VTK (if not building the filter)
* ncurses
* C++11 compliant compiler
* netCDF C with c++ bindings

# Superbuild
If SUPERBUILD is defined, CHM will download, patch, and build all required dependencies. To do this, do

```
cmake -DSUPERBUILD=TRUE .
```

Note, TBB is currently not built.

If gperftools fails to build with an error about nanosleep it is due to this regression (?) with older gcc versions
https://bugs.launchpad.net/ubuntu/+source/gcc-4.6/+bug/1269803

disable tcmalloc with `-DUSE_TCMALLOC=FALSE`

If using Intel's C++ compiler cmake version >=3.6 is required to build VTK/Paraview
http://public.kitware.com/pipermail/paraview/2017-March/039725.html

# netCDF
The NetCDF-cxx4 pre 4.2 does not work with CHM and thus 4.3+ is required. However, this generally requires building HDF5, netCDF, and netCDF cxx from source. NetCDF is fussy about which HDF5 version it is build against.

Although there is a superbuild component for netCDF,  the cxx4 bindings do not reliably link against the custom built netcdf, and often end up linking against a system netcdf, causing runtime errors. 

If you need to build netCDF, then do a custom build of GDAL as the superbuild GDAL will not link against netcdf and hdf5. 

To do a manual build of netCDF:
### Build HDF5
https://support.hdfgroup.org/HDF5/release/obtainsrc.html
```
$ ./configure --prefix=/opt/netcdf --enable-cxx --enable-shared --enable-unsupported
$ make
$ make install
```

### Build netCDF
Use git master
 ```
$ git clone https://github.com/Unidata/netcdf-c.git
$ cd netcdf-c
$ autoreconf -if
$ CPPFLAGS="-I/opt/netcdf/include" LDFLAGS="-L/opt/netcdf/lib" ./configure --prefix=/opt/netcdf --enable-netcdf-4 --enable-shared
$ make
$ make install
```

### Build netCDF cxx
```
$ git clone https://github.com/Unidata/netcdf-cxx4.git
$ cd netcdf-cxx4
$ cmake -DNETCDF_C_LIBRARY=/opt/netcdf/lib/libnetcdf.so -DnetCDF_INCLUDE_DIR=/opt/netcdf/include -DCMAKE_INSTALL_PREFIX=/opt/netcdf .
$ make
$ make install
```
and then build CHM with

```
$cmake -DCMAKE_PREFIX_PATH=/opt/netcdf ~/CHM
```

# Building on Ubuntu 16.04:

GDAL
```
sudo wget http://download.osgeo.org/gdal/2.1.0/gdal-2.1.0.tar.gz
sudo tar -xzvf gdal-2.1.0.tar.gz
cd gdal-2.1.0
./configure
sudo make
sudo make install
 ```
Proj4
```
sudo apt-get install libproj-dev
```

QT5
```
sudo apt-get install libqt5svg5*
sudo apt-get install qt5-default
sudo apt-get install libcgal-qt5-dev  (note: optional, CHM not dependent on qt5 but required because of [this](https://github.com/CGAL/cgal/issues/471) bug)
```
CGAL
```
sudo apt-get install libcgal-dev
sudo apt-get install libcgal-demo
```
Armadillo
```
sudo apt-get install libarmadillo-dev
```
Boost
```
sudo apt-get install libboost-all-dev
```
TBB
```
sudo apt-get install libtbb-dev
```
GSL
```
sudo apt-get install libgsl0-dev
```
Curses
```
sudo apt-get install libncurses-dev
```

VTK
```
sudo add-apt-repository ppa:elvstone/vtk7
sudo apt-get update
sudo apt-get install vtk7
export LD_LIBRARY_PATH="/opt/VTK-7.0.0"
```
Python
```
sudo apt-get install libpython3.5-dev
```

#To build:
    cmake .
    make

#To test:
    cmake .
    make check
    make test

#Trouble shooting
##Matlab
### OSX 
* Create a symbolic link from /usr/bin to the matlab install
* ```sudo ln -s /Applications/MATLAB_R2013a.app/bin/matlab /usr/bin/matlab```

###OSX:
## Triangle
Triangle needs to be edited to remove the fpu_control.h header
    $ cat > /usr/include/fpu_control.h

    #define _FPU_SETCW(cw) // nothing
    #define _FPU_GETCW(cw) // nothing
http://stackoverflow.com/a/4766863/410074

###Linux:
Usage of the matlab engine requires installing csh
##Intel compiler
    /usr/lib/armadillo_bits/config.hpp
comment out l. 173

##VTK
Older versions of VTK may have to patch here
http://review.source.kitware.com/#/c/11956/5/Common/Core/vtkMath.h
when building with C++11 

on CentOS 7.3.1611 (CORE), e.g., WestGrid machines, requires the VTK patch in the main tree to circumvent this issue
https://gitlab.kitware.com/vtk/vtk/issues/17077


##Google test
Google test can be patched following

http://stackoverflow.com/questions/4655439/print-exception-what-in-google-test

to print the boost::exception diagnostic information

    diff -r /Users/chris/Documents/PhD/code/CHM/tests/gtest/include/gtest/internal/gtest-internal copy.h /Users/chris/Documents/PhD/code/CHM/tests/gtest/include/gtest/internal/gtest-internal.h
    65,66d64
    < #include <boost/exception/all.hpp>
    < 
    1080,1081c1078
    <     catch (boost::exception &e) { \
    <       std::cout << boost::diagnostic_information(e) << std::endl;  \
    ---
    >     catch (...) { \
