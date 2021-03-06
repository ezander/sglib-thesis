function show_correlation_and_fields

%#ok<*NASGU>


% We use the pde toolbox to generate the geometry and the mass matrix
% (gramian)
%[pos,els]=load_pdetool_geom( 'cardioid', 'numrefine', 1 );
%[pos,els]=load_pdetool_geom( 'square', 'numrefine', 2 );
[pos,els]=load_pdetool_geom( 'square', 'numrefine', 2 );
G_N = pdetool_mass_matrix(pos, els);

% expansion of the right hand side field (f)
m_f=100;

funcs={@gaussian_covariance, @exponential_covariance, @spherical_covariance};
lc_fs=[0.03,0.1,0.3,1,3];

mh=multiplot_init( length(funcs), length(lc_fs));
set(get(mh(1),'parent'),'renderer','painters')


for i=1:length(funcs);
    for j=1:length(lc_fs)
        cov_func={funcs{i},{lc_fs(j), 1}};
        cov_f=cov_func;
        cov_gam=cov_func;
        % now expanding field in ...
        disp( 'expanding field, this may take a while ...' );
        fprintf( '%s   %g\n', func2str(funcs{i}),lc_fs(j));
        
        [f_i_alpha, I_f]=expand_gaussian_field_pce( cov_gam, pos, G_N, m_f );
        
        multiplot( mh, i, j );
        %set( mh(i,j), 'Renderer', 'zbuffer' );
        f_ex=pce_field_realization( f_i_alpha, I_f );
        plot_field( pos, els, f_ex );
        shading interp;
        zlim([-2,2]);
        colorbar
    end
end
same_scaling( mh, 'c' );


for i=1:length(funcs);
    for j=1:length(lc_fs)
        save_figure( mh(i,j), {'ranfield_%s_l_%g', func2str(funcs{i}),lc_fs(j)} );
    end
end


