Mesh.MshFileVersion = 2; // Version of the MSH file format to use

// Parametros de geometria
L = 12e-3;
l = 2e-3;
R = 100e-6;
r = 50e-6;
r0 = 0;

// refinamento da garganta
Div=50;
dx=l/Div;

// Parametro de malha
MeshFactor = 4e-5;


Point(1) ={L/2, R, 0,MeshFactor};
Point(2) = {L/2, r0, 0,MeshFactor};
Point(3) = {l/2,r0 , 0,MeshFactor};
Point(4) = {-l/2,r0 , 0,MeshFactor};
Point(5) = {-L/2,r0 , 0,MeshFactor};
Point(6) = {-L/2,R , 0,MeshFactor};

// Criando pontos da garganta
For x In {-l/2:l/2:dx}
    p = newp;
    f =r + (R-r) *Sin(Pi*Fabs(x)/l); 
    Point(p) = {x,f , 0,MeshFactor};
EndFor

// Linhas
l = newl;
Line(l) = {newp-1, 1};

For point In {1:newp-2}
    l = newl;
    Line(l) = {point, point+1} ; 
EndFor

Line Loop(1) = {1:l};
Plane Surface(1) = (1);

/* 
Extrude angulo de Pi/2*4
*/

Extrude { {1,0,0}, {0,0,0}, Pi/2} {
    Surface{1};
}

s = news;
// Printf("%f",s);
Extrude { {1,0,0}, {0,0,0}, Pi/2} {
    Surface{(s-1)};
}

s = news;
// Printf("%f",s);
Extrude { {1,0,0}, {0,0,0}, Pi/2} {
    Surface{(s-1)};
}

s = news;
// Printf("%f",s);
Extrude { {1,0,0}, {0,0,0}, Pi/2} {
    Surface{(s-1)};
}


// We then define a `Threshold' field, which uses the return value of the
// `Distance' field 1 in order to define a simple change in element size
// depending on the computed distances
//
// SizeMax -                     /------------------
//                              /
//                             /
//                            /
// SizeMin -o----------------/
//          |                |    |
//        Point         DistMin  DistMax

Field[1] = Distance;
// Field[1].PointsList = {};
Field[1].CurvesList = {131:327:4, 407:603:4, 683:879:4,
    959:1155:4,117,393,669,945};
Field[1].Sampling = 20;

Field[2] = Threshold;
Field[2].InField = 1;
Field[2].SizeMin = MeshFactor / 3;
Field[2].SizeMax = MeshFactor;
Field[2].DistMin = r/10;
Field[2].DistMax = r*50;

Field[3] = Distance;
Field[3].CurvesList = {4};
Field[3].Sampling = 100;

Field[4] = Threshold;
Field[4].InField = 3;
Field[4].SizeMin = MeshFactor / 3;
Field[4].SizeMax = MeshFactor;
Field[4].DistMin = r/10;
Field[4].DistMax = r*50;


Field[5] = Min;
Field[5].FieldsList = {2, 4};
Background Field = 5;

Physical Surface("Inlet") = {128,404,680,956};

Physical Surface("Outlet") = {398,674,950,122};

Physical Surface("Wall") = {119,395,671,947,
                            132,960,408,684};


Physical Surface("Garganta") ={548, 504, 332, 508, 512, 516, 520, 524, 528, 532, 536, 540, 
    544, 600, 552, 556, 560, 564, 568, 572, 576, 580, 584, 588, 592, 596, 608, 604, 244, 
    208, 212, 216, 220, 224, 228, 232, 236, 240, 204, 248, 252, 256, 260, 264, 268, 272, 
    276, 168, 136, 140, 144, 148, 152, 156, 160, 164, 280, 172, 176, 180, 184, 188, 192, 
    196, 200, 468, 432, 436, 440, 444, 448, 452, 456, 460, 464, 428, 472, 476, 480, 484, 
    488, 492, 496, 320, 284, 288, 292, 296, 300, 304, 308, 312, 316, 500, 324, 328, 412, 
    416, 420, 424, 788, 784, 1064, 1060, 1068, 792, 1056, 780, 1072, 1052, 796, 776, 800, 
    1076, 1048, 772, 1044, 804, 1080, 768, 764, 808, 1040, 1084, 812, 1088, 760, 1036, 1092, 
    816, 1032, 756, 820, 1096, 752, 1028, 748, 1024, 1100, 824, 1104, 744, 828, 1020, 1016, 
    1108, 832, 740, 836, 1112, 1012, 736, 732, 1008, 1116, 840, 728, 844, 1120, 1004, 1000, 
    1124, 848, 724, 720, 996, 1128, 852, 716, 992, 856, 1132, 712, 988, 1136, 860, 864, 984, 
    1140, 708, 980, 1144, 868, 704, 976, 700, 872, 1148, 972, 1152, 696, 876, 968, 1156, 880, 
    692, 1160, 688, 884, 964};

Physical Volume("Fluid") = {1:4};

