% identification
model=mfilename;

% load continuous model
model_continuous_easy
is_neumann=make_spatial_func('x<x');

% geometry discretisation
num_refine=2;
num_refine_after=1;

% right hand side
m_f=30;
p_f=3;
l_f=30;

% coefficient field
m_k=15;
p_k=3;
l_k=15;

% dirirchlet boundary conditions
m_g=0;
p_g=1;
l_g=0;

% neumann boundary conditions
m_h=0;
p_h=1;
l_h=0;

% solution
p_u=3;
