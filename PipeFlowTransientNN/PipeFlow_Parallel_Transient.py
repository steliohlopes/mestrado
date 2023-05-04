# Libraries Import
import matplotlib.pyplot as plt
import numpy as np
from dolfin import *
import os
import timeit
# from mpi4py import MPI

comm = MPI.comm_world
rank = MPI.rank(comm)

# Helping self defined Functions
# Read subdomains from .msh file
def readDomains(inPath,inFile):
    # Read .msh File
    fid = open(inPath+inFile+'.msh', 'r')
    # Initialize variables
    found = 0
    finished = 0
    physicalNames = {}
    # Loop througn .msh lines
    for line in fid:
        if '$EndPhysicalNames' in line:
            finished == 1
            break
        elif '$PhysicalNames' in line:
            found = 1
        elif found==1 and finished == 0:
            word=line.split()
            if len(word)==3:
                physicalNames[word[2][1:len(word[2])-1]] = int(word[1])

    return physicalNames

# Deformation Tensor
def DD(u):
    #Cartesian
    D = 0.5*(nabla_grad(u) + nabla_grad(u).T)
    return D
#     return 0.5*(nabla_grad(u) + nabla_grad(u).T)

# Stress Tensor
def TT(u, p, mu):
    #Cartesian
    T = 2*mu*DD(u) - p*Identity(len(u))
    return T

# def gamma(u):
#     return pow(2*inner(DD(u),DD(u)),0.5)

# def eta(u):
#     return kappa*pow(gamma(u),n_exp-1)

def rheologicalModel(modelExpression,C,u):
    # Determine gammaDot from deformation tensor D
    # D = sym(grad(u))
    D = DD(u) # strain rate tensor
    gammaDot = project(sqrt(2*tr(dot(D,D))),C)
    gammaDotArray = gammaDot.vector().get_local()
    gammaDot.vector().set_local(abs(gammaDotArray))

    # Model variable Inputs (gammaDot)
    modelExpression.gammaDot=gammaDot

    return interpolate(modelExpression,C), gammaDot

# Inputs
# Mesh File
meshPath = './PipeFlow2/'
meshFile = 'PipeFlow'

# Timestep
t0=0
dt = 1e-6
tEnd = 1e-2
# Pressure Difference
Pin = 0.1
Pout = 0

# Fluid Properties
rho = 1000
mu = 0.1
alpha = 0.9
kappa = 1.5
n_exp = 0.6
# Mesh Elements
# Velocity
velocityElementfamily = 'Lagrange'
velocityElementOrder = 2
# Pressure
pressureElementfamily = 'Lagrange'
pressureElementOrder = 1


# # Rheology - Modified SMD (Souza Mendes e Dutra (2004)) + Cure(tauY(t)) 
tau0 = 6.21358           # Dinamic Yield Stress               
eta0 = 0.001            # Viscosity Value for Low shear rates
etaInf = 64.1  # Equilibrium Viscosity(Newtonian Plato: Lowgh shear rates)
k = 0.1              # Consistency Index
n = 0.7             # Power-law Index
ts = 663             # Caracteristic viscosity buildup time
eps = 1e-7

#Power Law
modelExpression = Expression('K*(pow(gammaDot+eps,nPow-1))',mpi_comm=comm, degree=2, \
                            K = k, nPow = n, \
                            eps = eps, gammaDot = Constant(1/eps))

# Solver Parameters
absTol = 1e-13
relTol = 1e-13
maxIter = 15
linearSolver = 'mumps'

Subdomains = readDomains(meshPath,meshFile)
if rank==0:
    print(Subdomains)

meshObj = Mesh()
with XDMFFile(comm,meshPath+"mesh.xdmf") as infile:
    infile.read(meshObj)
mvc = MeshValueCollection("size_t", meshObj, 2)
with XDMFFile(comm,meshPath+"mf.xdmf") as infile:
    infile.read(mvc, "name_to_read")
mf = cpp.mesh.MeshFunctionSizet(meshObj, mvc)

mvc2 = MeshValueCollection("size_t", meshObj, 3)
with XDMFFile(comm,meshPath+"mesh.xdmf") as infile:
    infile.read(mvc2, "name_to_read")
cf = cpp.mesh.MeshFunctionSizet(meshObj, mvc2)

# Get Element Shape: Triangle, etc...
elementShape = meshObj.ufl_cell()

# Set Mesh Elements
Uel = VectorElement(velocityElementfamily, elementShape, velocityElementOrder) # Velocity vector field
Pel = FiniteElement(pressureElementfamily, elementShape, pressureElementOrder) # Pressure field
Nel = FiniteElement(pressureElementfamily, elementShape, pressureElementOrder) # Viscosity field
UPel = MixedElement([Uel,Pel])

# Define any measure associated with domain and subdomains
dx = Measure('dx', domain=meshObj, subdomain_data=cf)
ds = Measure('ds', domain=meshObj, subdomain_data=mf)

# Vectors Normal to the Mesh
n = FacetNormal(meshObj) # Normal vector to mesh

# Function Spaces: Flow
# Mixed Function Space: Pressure and Velocity
W = FunctionSpace(meshObj,UPel)

C = FunctionSpace(meshObj,Nel)

w0 = Function(W)
(u0, p0) = w0.leaf_node().split()
c0 = Function(C)

##### Functions
## Trial and Test function(s)
dw = TrialFunction(W)
(v, q) = TestFunctions(W)

w = Function(W)

# Split into Velocity and Pressure
(u, p) = (as_vector((w[0], w[1], w[2])), w[3])

eta = Function(C)

# Time step Constant
Dt = Constant(dt)
t = dt

# Apply Flow Boundary Conditions
bcU1 = DirichletBC(W.sub(0),Constant((0.0,0.0,0.0)),mf,Subdomains['Wall'])
bcU2 = DirichletBC(W.sub(0),Constant((0.0,0.0,0.0)),mf,Subdomains['Garganta'])
bcs = [bcU1,bcU2]

w1 = Function(W)
w_mid = Function(W)
(u_mid, p_mid) = (as_vector((w_mid[0], w_mid[1],w_mid[2])), w_mid[3])

#Create XDMF File for results
PipeFlow_file = XDMFFile(meshPath+'Results70/'+meshFile+".xdmf")
PipeFlow_file.parameters["flush_output"] = True
PipeFlow_file.parameters["functions_share_mesh"]= True
PipeFlow_file.parameters["rewrite_function_mesh"] = False
# u0.rename("Velocity Vector", "")
# p0.rename("Pressure", "")
# PipeFlow_file.write(u0, t)
# PipeFlow_file.write(p0, t)


eta, gammaDot = rheologicalModel(modelExpression,C,u0)

# eta = Constant(mu)
err = 1
# Start timer
start = timeit.default_timer()

while t <= tEnd and err!=0:

    if rank==0:
        begin('Flow - Time:{:.3f}s and dt:{:.5f}s\n'.format(t,dt))

    # Assign Fluids Properties
    (u0, p0) = w0.leaf_node().split()

    # a01 = (rho*dot(dot(u,grad(u)),v) + inner(TT(u,p,eta0),DD(v)))*dx()
    a01 = rho*dot((u-u0)/Dt,v)*dx() + (inner(TT(u,p,eta),DD(v)))*dx()

            # Inlet Pressure                         # Outlet Pressure                            # Gravity
    L01 = - (Pin)*dot(n,v)*ds(Subdomains['Inlet']) - (Pout)*dot(n,v)*ds(Subdomains['Outlet']) # + inner(rho*fb(inputs),v)*dx()      
        
    # Mass Conservation(Continuity)
    a02 = (q*div(u))*dx()
    L02 = 0

    # Complete Weak Form
    F0 = (a01 + a02) - (L01 + L02)
        # Jacobian Matrix
    J0 = derivative(F0,w,dw)

        
    ##########   Numerical Solver Properties
    # Problem and Solver definitions
    problemU0 = NonlinearVariationalProblem(F0,w,bcs,J0)
    solverU0 = NonlinearVariationalSolver(problemU0)
    # # Solver Parameters
    prmU0 = solverU0.parameters 
    prmU0['nonlinear_solver'] = 'newton'
    prmU0['newton_solver']['absolute_tolerance'] = absTol
    prmU0['newton_solver']['relative_tolerance'] = relTol
    prmU0['newton_solver']['maximum_iterations'] = maxIter
    prmU0['newton_solver']['linear_solver'] = linearSolver
    # prmU0['newton_solver']['preconditioner'] = 'ilu'
    # info(prmU0,True)  #get full info on the parameters
    # Solve Problem
    (no_iterations,converged) = solverU0.solve()
    
    (u1, p1) = w.leaf_node().split()
    u1.rename("Velocity Vector", "")
    p1.rename("Pressure", "")
    if rank==0:
        begin('---------------- Saving ----------------\n')
    PipeFlow_file.write(u1, t)
    PipeFlow_file.write(p1, t)
    try:
        err = abs(norm(u0)-norm(u1))/norm(u0)
        begin('erro:{:.5f}\n'.format(err))
    except:
        pass


    eta, gammaDot = rheologicalModel(modelExpression,C,u1)

    w0.assign(w)
    t += dt
    
# End Time
stop = timeit.default_timer()
total_time = stop - start
    
# Output running time in a nice format.
mins, secs = divmod(total_time, 60)
hours, mins = divmod(mins, 60)
if rank==0:
    begin("Total running time: %dh:%dmin:%ds \n" % (hours, mins, secs))
    

# w1.assign(w)
# (u1,p1) = w1.split()
# u1.rename("Velocity Vector", "")
# p1.rename("Pressure", "")

# ParallelPlates3D_file = XDMFFile(meshPath+meshFile+".xdmf")
# ParallelPlates3D_file.parameters["flush_output"] = True
# ParallelPlates3D_file.parameters["functions_share_mesh"]= True
# ParallelPlates3D_file.write(u1, 0.0)
# ParallelPlates3D_file.write(p1, 0.0)

#run as '  mpirun -np 1 python3 PipeFlow2/PipeFlow_Parallel_Transient.py |& grep -v "Read -1"  '