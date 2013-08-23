function demo_tensor_methods

clf;
dock;
basename='rf_kl_1d_sfem21';

%% load the geomatry
% 1D currently, so nothing to plot here
kl_model_version=1;
[pos,els,bnd]=load_kl_model( [basename '_k'], kl_model_version, [], {'pos','els','bnd'} );
N=size(pos,2);

%% load the kl variables of the conductivity k
[k_i_k,k_k_alpha,I_k]=load_kl_model( [basename '_k'], kl_model_version, [], {'r_i_k', 'r_k_alpha', 'I_r'} );
subplot(1,2,1); plot(pos,k_i_k); title('KL eigenfunctions');
subplot(1,2,2); plot_kl_pce_realizations_1d( pos, k_i_k, k_k_alpha, I_k ); title('mean/var/samples');
userwait;

%% load the kl variables of the right hand side f
[f_j_i,phi_i_alpha,I_f]=load_kl_model( [basename '_f'], kl_model_version, [], {'r_i_k', 'r_k_alpha', 'I_r'} );
subplot(1,2,1); plot(pos,f_j_i); title('KL eigenfunctions');
subplot(1,2,2); plot_kl_pce_realizations_1d( pos, f_j_i, phi_i_alpha, I_f ); title('mean/var/samples');
userwait;

%% define (deterministic) boundary conditions g
% this defines the function g(x)=x_1
select=@(x,n)(x(n,:)');
g_func={ select, {1}, {2} };
% dummy pce (just the mean)
g_i_alpha=funcall( g_func, pos);
I_g=multiindex(0,0);
% "null" kl expansion of g
[g_i_k,g_k_alpha]=pce_to_kl( g_i_alpha, I_g, 0 );



%% combine the multiindices
[I_k,I_f,I_g,I_u]=multiindex_combine( {I_k, I_f, I_g}, -1 );
M=size(I_u,1); %#ok


%% create the right hand side
phi_i_beta=compute_pce_rhs( phi_i_alpha, I_f, I_u );
F=kl_to_tensor( f_j_i, phi_i_beta );
f_mat=F{1}*F{2}';
f_vec=f_mat(:);

g_k_beta=compute_pce_rhs( g_k_alpha, I_g, I_u );
G=kl_to_tensor( g_i_k, g_k_beta );
g_mat=G{1}*G{2}';
g_vec=g_mat(:);


%% load and create the operators
kl_operator_version=9;
stiffness_func={@stiffness_matrix, {pos,els}, {1,2}};
opt.verbosity=1;
opt.show_timings=true;
K=load_kl_operator( [basename '_op_mu_delta'], kl_operator_version, k_i_k, k_k_alpha, I_k, I_u, stiffness_func, 'mu_delta', opt );
K_ab=load_kl_operator( [basename '_op_ab'], kl_operator_version, k_i_k, k_k_alpha, I_k, I_u, stiffness_func, 'alpha_beta', opt );
% create matrix and tensor operators
K_mat=cell2mat(K_ab);


%% apply boundary conditions
[P_I,P_B]=boundary_projectors( bnd, N );

Ki=apply_boundary_conditions_operator( K, P_I );
Ki_mat=apply_boundary_conditions_operator( K_mat, P_I );

Fi=apply_boundary_conditions_rhs( K, F, G, P_I, P_B );
fi_vec=apply_boundary_conditions_rhs( K_mat, f_vec, g_vec, P_I, P_B );
fi_vec2=apply_boundary_conditions_rhs( K, f_vec, g_vec, P_I, P_B );
fi_mat=apply_boundary_conditions_rhs( K, f_mat, g_mat, P_I, P_B );
%
all_same=(norm(fi_vec-fi_vec2)+norm(fi_vec-fi_mat(:))+norm(Fi{1}*Fi{2}'-fi_mat)==0);
underline('apply_boundary_conditions');
fprintf( 'all_same: %g\n', all_same );


%% solve the system via direct solver for comparison
ui_vec=Ki_mat\fi_vec;

underline( 'Residual of direct solver:' );
fprintf( '(matrix op) %g \n', norm( fi_vec-tensor_operator_apply( Ki, ui_vec ) ) );
fprintf( '(tensor op) %g \n', norm( fi_vec-tensor_operator_apply( Ki_mat, ui_vec ) ) );



%% Solve system with Matlab's pcg (must use normal vectors for rep)
% the preconditioner
Mi=Ki(1,:);
Mi_mat=tensor_operator_to_matrix( Mi );
% solve
tic; [ui_vec2(:,1),flag]=pcg(Ki_mat,fi_vec,[],[],Mi_mat,[],[]); t(1)=toc;
tic; [ui_vec2(:,2),flag]=pcg(@funcall_funfun,fi_vec,[],[],Mi_mat,[],[],{@tensor_operator_apply,{Ki_mat},{1}}); t(2)=toc;
tic; [ui_vec2(:,3),flag]=pcg(@funcall_funfun,fi_vec,[],[],Mi_mat,[],[],{@tensor_operator_apply,{Ki},{1}}); t(3)=toc;
tic; [ui_vec2(:,4),flag]=pcg(@(x)(Ki_mat*x),fi_vec,[],[],Mi_mat,[],[]); ta(4)=toc;

underline( 'PCG accuracy: ' );
for i=1:4
    fprintf( '  %g', norm(ui_vec-ui_vec2(:,i) ) )
end
fprintf( '\n' );

%% Now apply the world-famous tensor product solver
% u_vec=apply_boundary_conditions_solution( u_vec_i, g_vec, P_I, P_B );
%[Ui,flag,relres,iter]=tensor_operator_solve_richardson( Ki, Fi, 'M', Mi );

underline( 'Tensor product PCG: ' );

[Ui,flag,info]=tensor_operator_solve_pcg( Ki, Fi, 'M', Mi );
ui_vec3=tensor_to_vector( Ui );
truncate='none';
fprintf( 'truncate: %s:: flag: %d, relres: %g, iter: %d, relerr: %g k: %d\n', truncate, flag, info.relres, info.iter, norm(ui_vec-ui_vec3 )/norm(ui_vec), size(Ui{1},2) );

for tolexp=1:7
    tol=10^-tolexp;
    [Ui,flag,info]=tensor_operator_solve_pcg( Ki, Fi, 'M', Mi, 'truncate_options', {'eps',tol, 'relcutoff', true} );
    ui_vec3=tensor_to_vector( Ui );
    truncate=sprintf('eps 10^-%d', tolexp);
    relerr=gvector_error( ui_vec3, ui_vec, 'relerr', true );
    k=tensor_rank( Ui );
    R=relerr/tol;
    fprintf( 'truncate: %s:: flag: %d, relres: %g, iter: %d, relerr: %g k: %d, R: %g\n', truncate, flag, info.relres, info.iter, relerr, k, R );
end


