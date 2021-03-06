%% combine the multiindices
% (i.e. build the product sample space $Omega_u=Omega_k \times Omega_f \times
% Omega_g$ in which the solution lives)
I_k=multiindex(m_k,p_k);
I_f=multiindex(m_f,p_f);
I_g=multiindex(m_g,p_g);

%[I_k,I_f,I_g,I_u]=multiindex_combine( {I_k, I_f, I_g}, -1 );
[I_f,I_g,I_r]=multiindex_combine( {I_f, I_g}, -1 );
M_k=size(I_k,1);
M_r=size(I_r,1);
G_k=spdiags(multiindex_factorial(I_k),0,M_k,M_k);
G_r=spdiags(multiindex_factorial(I_r),0,M_r,M_r);
M=0;

%% create the right hand side
% i.e. scale the pce coefficients with the norm of the stochastic ansatz
% functions and create tensor, matrix and vector versions out of it
f_k_beta=compute_pce_rhs( f_k_alpha, I_f, I_r );
F=kl_to_tensor( f_i_k, f_k_beta );

g_k_beta=compute_pce_rhs( g_k_alpha, I_g, I_r );
G=kl_to_tensor( g_i_k, g_k_beta );


%% load and create the operators 

% create tensor operators
K=kl_pce_compute_operator(k_i_k, k_k_alpha, I_k, I_k, stiffness_func, 'tensor');

% extend stuff to third order
K=extend_kl_operator( K, I_r );
F=extend_rhs( F, I_k );
G=extend_rhs( G, I_k );



%% apply boundary conditions
[P_I,P_B]=boundary_projectors( bnd_nodes, size(pos,2) );

Ki=apply_boundary_conditions_operator( K, P_I );
Fi=apply_boundary_conditions_rhs( K, F, G, P_I, P_B );
[Mi_inv, Mi]=stochastic_precond_mean_based( Ki );
