Mesh.MshFileVersion = 2; // Version of the MSH file format to use
SetFactory("OpenCASCADE");

// Parametros de geometria
D_inlet=0.5e-3;
L_inlet=1e-3; //Verificar medida
H_inlet=200e-6;
H_outlet=H_inlet;
W_outlet=2e-2;
L_outlet=2e-2;
R=1e-3;
alpha=45*(Pi/180); //radianos

l1 = 2*R/(Tan(Pi/2 - alpha));
l2 = R*Cos(alpha);
l3 = R*Sin(alpha);

// Parametro de malha
MeshFactor = 4e-4;

// Cylinder 
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

Extrude {L_inlet,0,0} {
  Surface{6};
}

//Side Wall outlet
Point(20) = {L_inlet+R+l2+l1,(D_inlet/2),W_outlet/2,MeshFactor};
Point(21) = {L_inlet,(D_inlet/2)+H_inlet,W_outlet/2,MeshFactor};
Point(22) = {L_inlet,(D_inlet/2)-R,W_outlet/2,MeshFactor};
Point(23) = {L_inlet+R+l2+l1+L_outlet,(D_inlet/2)+H_inlet,W_outlet/2,MeshFactor};
Point(25) = {L_inlet+R+l2+l1+L_outlet,(D_inlet/2),W_outlet/2,MeshFactor};
Point(26) = {L_inlet+R+l2,(D_inlet/2)-R-l3,W_outlet/2,MeshFactor};
Point(27) = {L_inlet+R,(D_inlet/2)-R,W_outlet/2,MeshFactor}; //center

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

BooleanDifference = { Surface {36};Delete;} {Surface {11}; Delete;};
Coherence;


// Delete {Surface{44};}


// Physical Surface("Inlet") = {6};
// Physical Surface("Outlet") = {49};
// Physical Surface("Wall") = {15,19,23,27,43};

// Point(21) = {L_inlet+R+l2+l1,(D_inlet/2),-W_outlet/2,MeshFactor};




// Line(24) = {p+14,p+10};




// Plane Surface(s+5) = (s+5);



// //leftWall

// Point(p) = {L_inlet,(D_inlet/2)+H_inlet,0,MeshFactor};


// Point(p+3) = {L_inlet,(D_inlet/2)-R,0,MeshFactor};
// l = newl;
// Line(l) = {8,p};
// Line(l+1) = {p,p+1};
// Line(l+2) = {p+1,p+2};
// Line(l+3) = {p+2,p+3};
// Line(l+4) = {p+3,18};
// s=news;
// Line Loop(s) = {l:l+4,11,8};
// Plane Surface(s) = (s);

// Point(p+4) = {L_inlet,(D_inlet/2)-R,-W_outlet/2,MeshFactor};
// Point(p+5) = {L_inlet,(D_inlet/2)+H_inlet,-W_outlet/2,MeshFactor};
// s=news;
// Line Loop(s) = {l:l+4,11,8};
// Plane Surface(s) = (s);
// Line(l+5) = {p+3,p+4};
// Line(l+6) = {p+4,p+5};
// Line(l+7) = {p+5,p};
// Line Loop(s+1) = {-33,l+5:l+7,-l,9,10};
// Plane Surface(s+1) = (s+1);
// //TopWall
// Point(p+8) = {L_inlet+R+l2+l1+L_outlet,(D_inlet/2)+H_inlet,-W_outlet/2,MeshFactor};


// Point(p+11) = {L_inlet+R+l2+l1,(D_inlet/2)+H_inlet,-W_outlet/2,MeshFactor};
// Line(l+8) = {p+5,p+11};
// Line(l+9) = {p+11,p+10};
// Line(l+10) = {p+10,p+1};
// Line Loop(s+2) = {-30,-36,37:39};
// Plane Surface(s+2) = (s+2);
// Line(l+11) = {p+11,p+8};
// Line(l+12) = {p+8,p+9};
// Line(l+13) = {p+9,p+10};
// Line Loop(s+3) = {l+11:l+13,-38};
// Plane Surface(s+3) = (s+3);

// //outlet

// Point(p+13) = {L_inlet+R+l2+l1+L_outlet,(D_inlet/2),-W_outlet/2,MeshFactor};
// Line(l+14) = {p+8,p+13};
// Line(l+15) = {p+13,p+12};
// Line(l+16) = {p+12,p+9};
// Line Loop(s+4) = {l+14:l+16,-41};
// Plane Surface(s+4) = (s+4);



// Line(l+19) = {p+11,p+15};
// Line(l+20) = {p+15,p+13};
// Line Loop(s+6) = {l+19:l+20,-40,-43};
// Plane Surface(s+6) = (s+6);

// //Bottom Wall outlet
// Line(l+21) = {p+15,p+14};
// Line Loop(s+7) = {-46,-49,-44,l+21};
// Plane Surface(s+7) = (s+7);

// //Bottom Mid Wall outlet

// Point(p+17) = {L_inlet+R+l2,(D_inlet/2)-R-l3,-W_outlet/2,MeshFactor};
// Line(l+22) = {p+15,p+17};
// Line(l+23) = {p+17,p+16};
// Line(l+24) = {p+16,p+14};
// Line Loop(s+8) = {l+22:l+24,-50};
// Plane Surface(s+8) = (s+8);




// //SideWallFront




// Transfinite Curve{l+11} = 20;

// Line(l+12) = {p+11,p+12};
// Line(l+13) = {p+12,p+13};
// Line(l+14) = {p+13,p+9};
// Line Loop(s+3) = {-40:-43,-31,-39};
// Plane Surface(s+3) = (s+3);
// // Line Loop(s+3) = {-41:-43,-39,-31,-59,-60};
// // Plane Surface(s+3) = (s+3);



// //SideWallBack
// Point(p+14) = {L_inlet+R,(D_inlet/2)-R,-W_outlet/2,MeshFactor}; //center

// Circle(l+15)= {p+4,p+14,p+15};
// Transfinite Curve{l+15} = 20;
// Line(l+16) = {p+15,p+16};
// Line(l+17) = {p+16,p+17};
// Line(l+18) = {p+17,p+8};
// Line Loop(s+4) = {44:47,-37,-35};
// Plane Surface(s+4) = (s+4);


// //Bottom
// Line(l+20) = {p+11,p+15};
// Line Loop(s+6) = {-32,40,49,-44,-34};
// Plane Surface(s+6) = (s+6);
//+









//+
Show "*";
