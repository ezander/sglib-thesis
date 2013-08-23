function plot_kl( pos, els, r_i_k, r_k_alpha )
clf;

if ~strcmp(get(gcf,'WindowStyle'),'docked')
    set( gcf, 'Position', [0, 0, 900, 900] );
end
set( gcf, 'Renderer', 'zbuffer' );
opts={'shading', 'flat', 'show_mesh', false};
for k=1:size(r_i_k,2)
    subplot(4,4,k);
    plot_field( pos, els, r_i_k(:,k), opts{:} );
    title(sprintf('KLE: r_{%d}',k));
    
    subplot(4,4,k+8);
    plot_field( pos, els, r_i_k(:,k), 'view', [30,15], opts{:} );
    title(sprintf('KLE: r_{%d}',k));
end
