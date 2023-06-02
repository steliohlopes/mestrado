Mesh.MshFileVersion = 2; // Version of the MSH file format to use
SetFactory("OpenCASCADE");

// Parametros de geometria
D_inlet=0.5e-3;
L_inlet=5e-4; //Verificar medida
H_inlet=200e-6;
H_outlet=H_inlet;
W_outlet=2e-2;
L_outlet=2e-4;
R=1e-3;
alpha=45*(Pi/180); //radianos

l1 = 2*R/(Tan(Pi/2 - alpha));
l2 = R*Cos(alpha);
l3 = R*Sin(alpha);

// Parametro de malha
MeshFactor = 3e-4;


Point(1) = {0,0,0,MeshFactor}; //center
Point(2) = {0,0,D_inlet/2,MeshFactor};
Point(3) = {0,D_inlet/2,0,MeshFactor};
Point(4) = {0,0,-D_inlet/2,MeshFactor};
Point(5) = {0,-D_inlet/2,0,MeshFactor};

Circle(1) = {2,1,3};
Circle(2) = {3,1,4};
Circle(3) = {4,1,5};
Circle(4) = {5,1,2};

Line Loop(5) = {1,2,3,4};
Plane Surface(6) = {5};

//Side Wall outlet
Point(20) = {R+l2+l1,(D_inlet/2),W_outlet/2,MeshFactor};
Point(21) = {0,(D_inlet/2)+H_inlet,W_outlet/2,MeshFactor};
Point(22) = {0,(D_inlet/2)-R,W_outlet/2,MeshFactor};
Point(23) = {R+l2+l1+L_outlet,(D_inlet/2)+H_inlet,W_outlet/2,MeshFactor};
Point(25) = {R+l2+l1+L_outlet,(D_inlet/2),W_outlet/2,MeshFactor};
Point(26) = {R+l2,(D_inlet/2)-R-l3,W_outlet/2,MeshFactor};
Point(27) = {R,(D_inlet/2)-R,W_outlet/2,MeshFactor}; //center

Line(25) = {22,21};
Line(26) = {21,23};
Line(27) = {23,25};
Line(28) = {25,20};
Line(29) = {20,26};
Circle(30)= {26,27,22};

Line Loop(35) = {25:30};
Plane Surface(35) = (35);

Extrude {0,0,-W_outlet} { 
  Surface{35}; 
}

// BooleanDifference(50) = { Surface {36};Delete;} {Surface {11}; Delete;};

v() = BooleanFragments{ Volume{1}; Delete;}{ Surface{6}; Delete; };


// We then define a `Threshold' field, which uses the return value of the
// `Distance' field 1 in order to define a simple change in element size
// depending on the computed distances

// SizeMax -                     /------------------
//                              /
//                             /
//                            /
// SizeMin -o----------------/
//          |                |    |
//        Point         DistMin  DistMax

Field[1] = Distance;
Field[1].CurvesList = {9,12};
Field[1].Sampling = 100;

Field[2] = Threshold;
Field[2].InField = 1;
Field[2].SizeMin = MeshFactor / 4;
Field[2].SizeMax = MeshFactor;
Field[2].DistMin = L_outlet;
Field[2].DistMax = L_outlet+l1;

Field[3] = Distance;
Field[3].SurfacesList = {7,8,10,11,12,13,14};
Field[3].Sampling = 100;

Field[4] = Threshold;
Field[4].InField = 3;
Field[4].SizeMin = MeshFactor / 4;
Field[4].SizeMax = MeshFactor;
Field[4].DistMin = H_inlet;
Field[4].DistMax = H_inlet*2;


Field[5] = Distance;
Field[5].CurvesList = {1,2,3,4};
Field[5].Sampling = 25;

Field[6] = Threshold;
Field[6].InField = 5;
Field[6].SizeMin = MeshFactor / 3;
Field[6].SizeMax = MeshFactor;
Field[6].DistMin = D_inlet;
Field[6].DistMax = D_inlet*2;

Field[7] = Min;
Field[7].FieldsList = {2,4,6};

Background Field = 7;

Physical Surface("Inlet") = {6};
Physical Surface("Outlet") = {9};
Physical Surface("Wall") = {7,8,10,11,12,13,14};
Physical Volume("Fluid") = {1};


