%file_patterns={'sparsity/show_*', 'mc/show_*', 'kl/show_*', 'pce/show_*',
%'solution/show_*', 'ranfield/show_*'};
file_patterns={
    % Chapter 1: Introduction
    % Section 1.1: Summary
    'ranfield/show_mesh_and_sample'; ...
    % Chapter 3
    % Section 
    'figures/show_svd_vs_kl_error';...
    % Chapter 5:
    'figures/show_ranks_res_and_solution'; ...
    % Chapter 6: Results
    % Section 6.1: Models
    %  - plot input random fields 
    'ranfield/show_input_random_fields'; ...
    %  - plot the meshes used 
    'figures/show_geometry'; ...
    'figures/show_model_bcs_and_solution'; ...
    'figures/show_residual_and_error_gsi'; ...
    'figures/show_residual_and_error_gpcg'; ...
    % appendix
    % - show error of norm computation methods
    'tests/show_norm_errors';...
    };


ask=get_base_param( 'ask', true );
recreate_all=get_base_param( 'recreate_all', false );
default_exec=get_base_param( 'default_exec', true );
create_all_figures( file_patterns, 'recreate_all', recreate_all, 'ask', ask, 'default_exec', default_exec );
