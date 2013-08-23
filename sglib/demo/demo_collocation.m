function demo_collocation

clf;

% parameters for smolyak and pce
m_cl=2;
p_coll=7;
p=p_coll;
rule=@gauss_hermite_rule;
grid=@smolyak_grid;
grid=@full_tensor_grid;
compute_cl=@dummy_function2;
N_mc=20000;

% create grid and show it
[xd,wd]=grid( m_cl, p_coll, rule );
plot(xd(1,:),xd(2,:),'*k')
userwait;

% call black box method (compute_cl)
cl_i=compute_cl( xd );

% show solution on grid
tri=delaunay( xd(1,:), xd(2,:) );
trisurf( tri, xd(1,:), xd(2,:), cl_i );
userwait;

% create multiindex and compute pce coefficients of cl by projection
I_cl=multiindex( m_cl, p );
cl_beta=zeros( 1, size(I_cl,1) );
for j=1:size(I_cl,1);
    cl_beta(j)=(cl_i.*pce_evaluate( 1, I_cl(j,:), xd ))*wd;
end
cl_beta=cl_beta./(hermite_norm(I_cl).^2)';

% compute the interpolation of cl on the smolyak points for comparison and
% plot
cl_i2=pce_evaluate( cl_beta, I_cl, xd );
subplot(2,2,1); trisurf( tri, xd(1,:), xd(2,:), cl_i );
subplot(2,2,2); trisurf( tri, xd(1,:), xd(2,:), cl_i2 );
subplot(2,2,3); trisurf( tri, xd(1,:), xd(2,:), cl_i-cl_i2 );
userwait;

% compute error of pce approximation in L2
cl_norm=norm_integrate( cl_i, wd );
cl_err_norm=norm_integrate( cl_i-cl_i2, wd );
cl_err_norm/cl_norm*100

% do mc simulation of cl
th=randn( m_cl, N_mc );
cl_mc=compute_cl( th );

% and the same with the pce solution (should look the same)
cl_mc_pce=pce_evaluate( cl_beta, I_cl, th );

clf;
empirical_density( [cl_mc', cl_mc_pce'], 100, 20 );
legend('mc', 'pce');
userwait;

x1=sort(cl_mc);
y1=linspace(0,1,length(x1));
x2=sort(cl_mc_pce);
y2=linspace(0,1,length(x2));
plot( x1, y1, x2, y2 );
legend('mc', 'pce');
userwait;






function n=norm_integrate( ci, wi )
n=sqrt( integrate( ci.^2, wi ) );

function s=integrate( ci, wi )
s=ci*wi;

% One function that can be used to "simulate" some black-box computation of
% CL
function y=dummy_function1( theta )
y=sin(theta(1,:))+cos(theta(2,:))+atan(theta(1,:).*theta(2,:));

function y=dummy_function2( theta )
y=exp(sqrt(theta(1,:).^2+theta(2,:).^2));
