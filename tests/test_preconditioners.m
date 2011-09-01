function test_precond
%%

rand('seed',12353);
randn('seed',12353);
if fasttest('get')
    model_small_easy;
else
    model_medium_easy;
end
mean_g_func=make_spatial_func('0');
[a,b]=beta_find_ratio( 0.25 );
dist_k={'beta', {a,b}, 0.001, 1.0 };

define_geometry; 
discretize_model; 
if false
    display_model_details;
    discretize_model;
end
strvarexpand( '%var_f: $percent_var_f$' );
strvarexpand( '%var_k: $percent_var_k$' );

%return
%%
setup_equation


%%
F=tensor_to_array(Fi);
F=F+rand(size(F))*3;
sz=tensor_operator_size(Ki,1);
n=sz(1);

%%


for pkind=1:3
    stats=struct();
    tic
    strvarexpand( '($pkind$) setting up preconditioner...' );
    switch pkind
        case 1
            [Pinv,P,info]=stochastic_precond_mean_based( Ki, 'precond_type',0,'decomp_type','');
            stats.name='mean';
        case 2
            [Pinv,P,info]=stochastic_precond_mean_based( Ki, 'precond_type',1,'decomp_type','');
            stats.name='kron';
        case 3
            [Pinv,P,info]=stochastic_precond_mean_based( Ki, 'precond_type',3,'decomp_type','');
            stats.name='ikron';
    end
    stats.setup_time=toc;
    strvarexpand( '($pkind$) setup time: $stats.setup_time$ sec.' );

    PP={P{1}{2}{2}{1},P{2}{2}{2}{1}};
    PPT={PP{1}',PP{2}'};
    
    strvarexpand( '($pkind$) norm(P-P^T)/norm(P): $norm(full(PP{1}-PP{1}'')/norm(full(PP{1})))$' );
    strvarexpand( '($pkind$) norm(Q-Q^T)/norm(Q): $norm(full(PP{2}-PP{2}'')/norm(full(PP{2})))$' );

    DT=[Ki; {-PP{1},PP{2}} ];
    PPinv={inv(PP{1}),inv(PP{2})};
    PPinvT={PPinv{1}',PPinv{2}'};
    PD=tensor_operator_compose( PPinv, DT );

    iterop=@(x)(x-tensor_operator_apply(PPinv,tensor_operator_apply(Ki,x)) );
    iteropT=@(x)(x-tensor_operator_apply(Ki,tensor_operator_apply(PPinvT,x)) );
    iteropTop=@(x)(iteropT(iterop(x)));

    op=@(x)(tensor_operator_apply(PP,x)-tensor_operator_apply(Ki,x) );
    opT=@(x)(tensor_operator_apply(PPT,x)-tensor_operator_apply(Ki,x) );
    opTop=@(x)(opT(op(x)));
    
    
    %A=tensor_operator_to_matrix( Ki );
    %P=tensor_operator_to_matrix( PP );
    %D=A-P;
    
    %fro1=frobenius_norm( A )
    %fro2=frobenius_norm( Ki )
    %fro3=frobenius_norm( D  )
    %fro4=frobenius_norm( DT )
    %fro5=frobenius_norm( PD )
    %keyboard
    
    
    %%
%     stats.diff_norm_fro=frobenius_norm( A-P );
%     strvarexpand( '($pkind$) diff frob: $stats.diff_norm_fro$' );
    stats.diff_norm_fro=frobenius_norm( DT );
    strvarexpand( '($pkind$) diff frob: $stats.diff_norm_fro$' );
    
%     stats.diff_norm_2=spectral_norm( A-P );
%     strvarexpand( '($pkind$) diff spectral norm: $stats.diff_norm_2$' );
    stats.diff_norm_2=spectral_norm( opTop, n );
    strvarexpand( '($pkind$) diff spectral norm: $stats.diff_norm_2$' );

%     stats.diff_rho=spectral_radius( A-P );
%     strvarexpand( '($pkind$) diff spectral radius: $stats.diff_rho$' );
    stats.diff_rho=spectral_radius( DT, n );
    strvarexpand( '($pkind$) diff spectral radius: $stats.diff_rho$' );
    
    

    stats.idiff_norm_fro=frobenius_norm( PD ); %sqrt( abs( eigs( op3, n, 1) ) );
    strvarexpand( '($pkind$) iterop frob: $stats.idiff_norm_fro$' );

    stats.idiff_norm_2=sqrt( abs( eigs( opTop, n, 1) ) );
    strvarexpand( '($pkind$) iterop spectral norm: $stats.idiff_norm_2$' );

    stats.idiff_rho=spectral_radius( op, n );
    strvarexpand( '($pkind$) iterop rho: $stats.idiff_rho$' );

    stats.contract=simple_iteration_contractivity( Ki, Pinv );
    strvarexpand( '($pkind$) contractivity: $stats.contract$' );

    %%
    if true
        [X,flag,info]=generalized_solve_pcg( Ki, F(:), 'Minv', Pinv, 'verbosity', 0 );
        info.iter;
        strvarexpand( '($pkind$) pcg solve steps: $ans$ (rr: $info.relres$)' );
        stats.npcg=info.iter;
        [X,flag,info]=generalized_solve_simple( Ki, F(:), 'Minv', Pinv, 'verbosity', 0 );
        info.iter;
        strvarexpand( '($pkind$) simple solve steps: $ans$ (rr: $info.relres$)' );
        stats.ngsi=info.iter;
    end
    
    if pkind==1
        all_stats=stats;
    else
        all_stats(end+1)=stats;
    end
end
assignin( 'base', 'all_stats', all_stats );

%%
show_tex_table( 2, all_stats )


function s=spectral_norm( D, n )
if nargin>=2
    if iscell(D)
        D=@(x)(tensor_operator_apply(D,x));
        keyboard
    end
    %s=abs(eigs( D, n, 1, 'lm' ));
    s=sqrt( abs( eigs( D, n, 1) ) );
else
    s=svds( D, 1 );
end

%    stats.idiff_norm_2=;


function s=frobenius_norm( D )
if ~iscell(D)
    s=norm(D, 'fro' );
else
    s=0;
    for i=1:size(D,1)
        for j=1:size(D,1)
            a1=sum(sum(D{i,1}.*D{j,1}));
            a2=sum(sum(D{i,2}.*D{j,2}));
            s=s+a1*a2;
        end
    end
    s=sqrt(s);
end


function s=spectral_radius(D,n)
if nargin>=2
    if iscell(D)
        D=@(x)(tensor_operator_apply(D,x));
    end
    s=abs(eigs( D, n, 1, 'lm' ));
else
    s=abs(eigs( D, 1, 'lm' ));
end

