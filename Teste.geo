// Gmsh project created by Jørgen S. Dokken 2020
SetFactory("OpenCASCADE");
Box(1) = {0, 0, 0, 1, 1, .285};
Box(2) = {0.4, 0.4, 0.285, .2, .2, .03};
Box(3) = {0., 0, 0.315, 1, 1, .01};
Box(4) = {0.0, 0.0, 0.325, 1, 1, 1};
v() = BooleanFragments{ Volume{1}; Delete;}{ Volume{2,3,4}; Delete; };
