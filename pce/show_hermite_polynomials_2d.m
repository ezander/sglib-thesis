function show_hermite_polynomials_2d

for i=0:3
    i=3;
    for j=i:3
        fprintf( 'H_{%d,%d}\n', i, j );
        d=1.5;
        x=linspace(-d,d);
        [X,Y]=meshgrid(x);
        Z=pce_evaluate( 1, [i j], [X(:) Y(:)]' );
        Z=reshape(Z,size(X));
        clf;
        surf(X,Y,Z)
        view(2);
        hold on;
        shading flat
        %contour(X,Y,Z)
        hold on;
        
        xlabel('x_1');
        ylabel('x_2');
        %legend('H_0','H_1','H_2','H_3','H_4')
        %xaxis([-d,d])
        %yaxis([-d,d])
        grid off
        axis equal
        axis tight
        
        title('Hermite polynomials')
        save_figure( gcf, {'hermite_polynomials_2d-%d_%d', i,j} );
        return;
    end
end


