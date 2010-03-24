Ui_mat=reshape( Ui_vec, [], M );
[ui_i_k,ui_k_alpha]=pce_to_kl( Ui_mat, I_u, inf, [], [] );
Ui=kl_to_tensor(ui_i_k, ui_k_alpha);
Ui=tensor_truncate( Ui, 'eps', 1e-14 );

U=apply_boundary_conditions_solution( Ui, G, P_I, P_B );
U=tensor_truncate( U, 'eps', 1e-14 );
[u_i_k,u_k_alpha]=tensor_to_kl( U );

Ui_true=Ui;
U_true=U;
