import meshio

# Inputs
# Mesh File
meshPath = './Pipe Flow Transient NN/PipeFlow2/ParallelPlates2D/'
meshFile = 'ParallelPlates2d'

msh = meshio.read(meshPath+meshFile+".msh")

for key in msh.cell_data_dict["gmsh:physical"].keys():
    if key == "line":
        line_data = msh.cell_data_dict["gmsh:physical"][key]
    elif key == "triangle":
        triangle_data = msh.cell_data_dict["gmsh:physical"][key]

for cell in msh.cells:
    if cell.type == "triangle":
        triangle_cells = cell.data
    elif cell.type == "line":
        line_cells = cell.data

triangle_mesh = meshio.Mesh(
    points=msh.points[:,:2],
    cells={"triangle": triangle_cells},
    cell_data={"name_to_read": [triangle_data]})

line_mesh = meshio.Mesh(
    points=msh.points[:,:2],
    cells=[("line", line_cells)],
    cell_data={"name_to_read": [line_data]})

meshio.write(meshPath+"mesh.xdmf", triangle_mesh)
meshio.write(meshPath+"mf.xdmf", line_mesh)