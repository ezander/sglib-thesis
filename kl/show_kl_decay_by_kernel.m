function show_kl_decay_by_kernel

mh=multiplot_init( 3, 4);


m=50;
[pos,els]=load_pdetool_geom( 'lshape', 'numrefine', 1 ); %#ok<ASGLU>
G_N=pdetool_mass_matrix(pos, els);
x=linspace(-4,4,201);
funcs={@gaussian_covariance, @exponential_covariance, @spherical_covariance};
lc_fs=[5, 2, 1, 0.5, 0.2];


for i=1:length(funcs)
    
    for j=1:length(lc_fs);
        cov_func={funcs{i},{lc_fs(j), 1}};
        [v_f,sigma]=kl_solve_evp( covariance_matrix( pos, cov_func ), G_N, m ); %#ok<ASGLU>
        y=funcall( cov_func, x, [] );
        
        multiplot( i, 1 ); plot(x,y);
        multiplot( i, 2 ); plot(sigma);
        multiplot( i, 3 ); plot(sigma); logaxis( gca, 'x' );
        multiplot( i, 4 ); plot(sigma); logaxis( gca, 'xy' );
    end
    for k=1:4
        multiplot(i, k); legend_parametric('l_c=%3.1f', lc_fs);
    end
    drawnow;
end

for i=1:length(funcs)
    save_figure( mh(i,1), {'kl_by_kernel_cov_%s', func2str(funcs{i})} );
    save_figure( mh(i,2), {'kl_by_kernel_eig_%s', func2str(funcs{i})} );
    save_figure( mh(i,3), {'kl_by_kernel_logeig_%s', func2str(funcs{i})} );
    save_figure( mh(i,4), {'kl_by_kernel_loglogeig_%s', func2str(funcs{i})} );
end
