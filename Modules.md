# Overview
Modules are the short-hand for a process representation. A principal design goal of a module is that it may depend either upon some set of variables produced by either other modules or on input forcing data. Modules define a set of variables which it provides globally to other modules. A module may not ever write any other variable global variable which it does declare. It should also not overwrite the variables of another module.

There are two types of modules: 
+ Forcing data interpolant
+ Standard module

Forcing data interpolants (```modules/interp_met```) depend upon point-scale input forcing data variables and interpolate these data onto every domain element. Standard modules (```modules/*```) depend only upon the output of the ```interp_met``` modules as well as other module outputs.

All modules may either be data parallel or domain parallel. Data parallel modules are point-scale models that are applied to every triangle. Domain parallel modules are modules that require knowledge of surrounding mesh points.

# Implementation Details
Modules inherent from ```module_base.hpp``` and implement a standard interface. In the most simple case, a module must have a constructor which defines all variable dependencies and a run function. 

## Data parallel
Data parallel modules implement a ```run``` function that takes as input a single mesh element to operate upon. These modules do not need to implement any special-sauce to be parallel. The main model loop automatically schedules modules to execute in parallel. Domain parallel modules may access the ```elem``` variable directly to get access to the triangle element.

The constructor is used to set a module to be the correct parallel type.

``` cpp
class data_parallel_example : public module_base
{
public:
    data_parallel_example(config_file cfg);
    ~data_parallel_example();
    void run(mesh_elem& elem, boost::shared_ptr<global> global_param);
}; 

data_parallel_example::data_parallel_example(config_file cfg)
        :module_base(parallel::data)
{
...
}
```

## Domain parallel
Domain parallel modules implement a run function that takes the entire mesh domain. The module must iterate over the faces of the domain to gain access to each element. This may be done in parallel but must be explicitly done by the module.
```
class domain_parallel_example : public module_base
{
public:
    domain_parallel_example(config_file cfg);
    ~domain_parallel_example();
    void run(mesh domain, boost::shared_ptr<global> global_param);
}; 

domain_parallel_example::domain_parallel_example(config_file cfg)
        :module_base(parallel::domain)
{
...
}

void run(mesh domain, boost::shared_ptr<global> global_param)
{
 #pragma omp parallel for
    for (size_t i = 0; i < domain->size_faces(); i++)
    {
        auto elem = domain->face(i);
       /** do stuff with elem **/
    }
}
```

## init()
In all cases a module may implement the ```init``` function.
```
void example_module::init(mesh domain, boost::shared_ptr<global> global_param)
```
Regardless of if the module is data or domain parallel, this function receives the entire mesh. ```init``` is called exactly once, after all other model setup has occurred, but prior to the main model execution loop. It is responsible for any initialization required by the model. An example of a complicated ```init``` is found in [Liston_wind](https://github.com/Chrismarsh/CHM/blob/master/src/modules/interp_met/Liston_wind.cpp) where the ```init``` function is used to pre-compute the wind curvature function.

## Variables

### Dependencies
In the constructor, a module declares itself to ```provides``` a set of variables and optionally ```depends``` upon other variables. Lastly, it may ```optionally``` depend upon a variable. If the the variable is not present, module dependency checks will still succeed, but the module *must* check prior to access to avoid a segfault. If a

```
# from another modules
depends("ilwr");

#optionally depend on another modules output
optional("snow_albedo");

#provide for another module.
provides("dQ");
```

### Variable access
Modules read from a variable stored on the mesh element via
```
auto albedo = elem->face_data("snow_albedo");
```
Modules may *only* write to variables they provide via
```
elem->set_face_data("dQ", 100.0);
```


