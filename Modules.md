# Overview
Modules are the short-hand for a process representation. A principal design goal of a module is that it may depend either upon some set of variables produced by either other modules or on input forcing data. Modules define a set of variables which it provides globally to other modules. A module may not ever write any other variable global variable which it does declare. It should also not overwrite the variables of another module.

There are two types of modules: 
+ Forcing data interpolant
+ Standard module

Forcing data interpolants (```modules/interp_met```) depend upon point-scale input forcing data variables and interpolate these data onto every domain element. Standard modules (```modules/*```) depend only upon the output of the ```interp_met``` modules as well as other module outputs.

Standard modules are either data parallel or domain parallel. Data parallel modules

# Details
Modules inherent from ```module_base.hpp``` and implement a standard interface. In the most simple case, a module must have a constructor and 





There is a single instance of a module