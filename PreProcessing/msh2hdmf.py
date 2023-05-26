import meshio

# Inputs
# Mesh File
meshPath = './Whistle/'
meshFile = 'whistle'

msh = meshio.read(meshPath+meshFile+".msh")

for key in msh.cell_data_dict["gmsh:physical"].keys():
    if key == "triangle":
        triangle_data = msh.cell_data_dict["gmsh:physical"][key]
    elif key == "tetra":
        tetra_data = msh.cell_data_dict["gmsh:physical"][key]
for cell in msh.cells:
    if cell.type == "tetra":
        tetra_cells = cell.data
    elif cell.type == "triangle":
        triangle_cells = cell.data
tetra_mesh = meshio.Mesh(points=msh.points, cells={"tetra": tetra_cells},
                         cell_data={"name_to_read":[tetra_data]})
triangle_mesh =meshio.Mesh(points=msh.points,
                           cells=[("triangle", triangle_cells)],
                           cell_data={"name_to_read":[triangle_data]})

meshio.write(meshPath+"mesh.xdmf", tetra_mesh)
meshio.write(meshPath+"mf.xdmf", triangle_mesh)

