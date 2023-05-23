Mesh.MshFileVersion = 2; // Version of the MSH file format to use

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
MeshFactor = 4e-5;

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

//leftWall
p = 20;
Point(p) = {L_inlet,(D_inlet/2)+H_inlet,0,MeshFactor};
Point(p+1) = {L_inlet,(D_inlet/2)+H_inlet,W_outlet/2,MeshFactor};
Point(p+2) = {L_inlet,(D_inlet/2)-R,W_outlet/2,MeshFactor};
Point(p+3) = {L_inlet,(D_inlet/2)-R,0,MeshFactor};
l = newl;
Line(l) = {8,p};
Line(l+1) = {p,p+1};
Line(l+2) = {p+1,p+2};
Line(l+3) = {p+2,p+3};
Line(l+4) = {p+3,18};
s=news;
Line Loop(s) = {l:l+4,11,8};
Plane Surface(s) = (s);

Point(p+4) = {L_inlet,(D_inlet/2)-R,-W_outlet/2,MeshFactor};
Point(p+5) = {L_inlet,(D_inlet/2)+H_inlet,-W_outlet/2,MeshFactor};
s=news;
Line Loop(s) = {l:l+4,11,8};
Plane Surface(s) = (s);
Line(l+5) = {p+3,p+4};
Line(l+6) = {p+4,p+5};
Line(l+7) = {p+5,p};
Line Loop(s+1) = {-33,l+5:l+7,-l,9,10};
Plane Surface(s+1) = (s+1);

//TopWall
Point(p+8) = {L_inlet+R+l2+l1+L_outlet,(D_inlet/2)+H_inlet,-W_outlet/2};
Point(p+9) = {L_inlet+R+l2+l1+L_outlet,(D_inlet/2)+H_inlet,W_outlet/2};
l = newl;
Line(l) = {p+5,p+8};




