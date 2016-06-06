The internal topographic representation is via an unstructured triangular mesh (herein 'the mesh'). An example of what this looks like is below.

![](https://github.com/Chrismarsh/CHM/blob/master/mesh.png)


Internally, the mesh is held in a CGAL structure that provides various ease-of-use structures. The relevant files are in ```mesh/```. 

Because the triangle iterators provided by CGAL have a non-deterministic order, as well as being incompatible with OpenMP, the way to access the i-th triangle is via
```cpp
#pragma omp parallel for
    for (size_t i = 0; i < domain->size_faces(); i++)
    {
        auto elem = domain->face(i);
     ...
    }
```