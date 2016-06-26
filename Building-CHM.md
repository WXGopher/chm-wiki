#Dependencies
* Matlab (optional)
* Armadillo
* boost
* GNU GSL
* Intel TBB
* GDAL (>2.0)
* CGAL
* Paraview (if building the filter) otherwise VTK
* C++11 compliant compiler

# Building on Ubuntu 16.04

* GDAL
sudo wget http://download.osgeo.org/gdal/2.1.0/gdal-2.1.0.tar.gz
sudo tar -xzvf gdal-2.1.0.tar.gz
cd gdal-2.1.0
./configure
sudo make
sudo make install

* QT5
sudo apt-get install libqt5svg5*
sudo apt-get install qt5-default

* CGAL
sudo apt-get install libcgal-dev
sudo apt-get install libcgal-demo

* Armadillo
sudo apt-get install libarmadillo-dev

* Boost
sudo apt-get install libboost-all-dev

* TBB
sudo apt-get install libtbb-dev

* GSL
sudo apt-get install libgsl0-dev

* Curses
sudo apt-get install libncurses-dev

* VTK
sudo add-apt-repository ppa:elvstone/vtk7
sudo apt-get update
sudo apt-get install vtk7
export LD_LIBRARY_PATH="/opt/VTK-7.0.0"i

* Python
sudo apt-get install libpython3.5-dev


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
