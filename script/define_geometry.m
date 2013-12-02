%% load or create the geomatry
geom=get_base_param( 'geom', '' );
if isempty(geom)
    N=get_base_param( 'N', 50 );
    [pos_s,els_s]=create_mesh_1d( 0, 1, N );
    mass_func=@mass_matrix;
    bare_stiffness_func=@stiffness_matrix;
else
    num_refine=get_base_param( 'num_refine', 1 );
    show_mesh=get_base_param( 'show_mesh', false );
    [pos_s,els_s]=load_pdetool_geom( geom, 'numrefine', num_refine);
    if show_mesh
        % foo
    end
    mass_func=@pdetool_mass_matrix;
    bare_stiffness_func=@pdetool_stiffness_matrix;
end

num_refine_after=get_base_param( 'num_refine_after', 0 );
P_s=speye(size(pos_s,2));
pos=pos_s;
els=els_s;
for i=1:num_refine_after
    [pos, els, P]=refine_mesh(pos, els);
    P_s = P * P_s;
end

G_N_s=mass_func( pos_s, els_s );
G_N=mass_func( pos, els );
bnd_nodes=find_boundary( els, true );
stiffness_func={bare_stiffness_func, {pos, els}, {1, 2}};

[d,N]=size(pos);

%
is_neumann=get_base_param( 'is_neumann', make_spatial_func('false') );

all_bnd_nodes=bnd_nodes;
neumann_ind=funcall( is_neumann, pos(:,all_bnd_nodes) );
neumann_nodes=all_bnd_nodes(neumann_ind);
bnd_nodes=all_bnd_nodes(~neumann_ind);
