function demo_kl_expand
% DEMO_KL_EXPAND Demonstrate usage of the Karhunen-Loeve expansion functions

%% Setup grid
subplot(1,1,1); clf; hold off
n=10;
[pos,els]=create_mesh_1d(0,1,n);

%% Create covariance matrix
cov_u={@gaussian_covariance, {0.3,2}};
C_u=covariance_matrix( pos, cov_u );

%% Plot the covariance function
x1=linspace(-1,1,100)'; x2=zeros(size(x1));
plot( x1, funcall( cov_u, x1, x2 ) );
userwait

%% Create KL with variance correction on and G_N=I
u_i_k=kl_solve_evp( C_u, [], 3, 'correct_var', true );
plot( pos, u_i_k );
%legend( 'v_1', 'v_2', 'v_3' );
userwait

%% Compute the mean and variance of the KL
% Mean should be zero in this case and variance 4
[mu,sig2]=pce_moments( [zeros(size(u_i_k,1),1), u_i_k], multiindex(3,1)); %#ok can't get only sig2
fprintf( 'sigma^2=%f\n', sig2 );

%% Now compute KL with a true mass matrix

G_N=mass_matrix( pos, els );
u_i_k=kl_solve_evp( C_u, G_N, 3, 'correct_var', true );
[mu,sig2]=pce_moments( [zeros(size(u_i_k,1),1), u_i_k], multiindex(3,1)); %#ok can't get only sig2
fprintf( 'sigma^2=%f\n', sig2 );


%% Set parameters for complete field expansion
% We need marginal densities, covariance function and parameters for the
% expansions...
p=5; %order of pce
m_u=4; % number of kl terms for underlying field
l_u=5; % number of kl terms for random field

h_u=@(gamma)(beta_stdnor(gamma,4,2));
u_i=pce_expand_1d(h_u,p);
[mu,sig2]=pce_moments( u_i, [] );
%cov_u=@(x1,x2)(gaussian_covariance( x1, x2, 0.3, sqrt(sig2) ) );
cov_u={@gaussian_covariance, {0.3, sqrt(sig2)}, {3,4} };
G_N=mass_matrix( pos, els );
%G_N=[];

%% Make PC expansion of the random field
% Using basic ghanem&sakamoto algorithm
% KL is used here only for the underlying Gaussian field
C_u=covariance_matrix( pos, cov_u );
C_gam=transform_covariance_pce( C_u, u_i, 'comp_ii_reltol', 1e-4 );
v_gam=kl_solve_evp( C_gam, G_N, m_u, 'correct_var', true );
[u_i_alpha,I_u]=pce_transform_multi( v_gam, u_i );

xi=randn(m_u,50);
u_real1=pce_field_realization( u_i_alpha, I_u, xi );
plot( pos, u_real1 );

%% Make KL on RF and project on it
v_i_k=kl_solve_evp( C_u, G_N, l_u );
[u_i_k,u_k_alpha]=project_pce_on_kl( u_i_alpha, I_u, v_i_k );

%% Get KL of PCE expansion directly by SVD
[u_i_k2,u_k_alpha2]=pce_to_kl( u_i_alpha, I_u, l_u, G_N );
%u_i_k2=u_i_k2(:,2:end);

%% Show that both are results are basically the same
% The correlation coefficient between each two functions should be one or
% minus one.

ccorr=abs(u_i_k*u_i_k2' ./ sqrt( sum(u_i_k.^2,2)*sum(u_i_k2.^2,2)' ));
format short
disp( diag(ccorr)' )

%% Now get a realization for the KL-PCE expanded field
u_real2=kl_pce_field_realization( u_i_k, u_k_alpha, I_u, xi );
plot( pos, u_real2 );
userwait

%% Show small difference between realizations
hold off
plot( pos, u_real1(:,1:3) );
hold on
plot( pos, u_real2(:,1:3) );
hold off
userwait

%%%%%%%%%%
C_u_pce=pce_covariance( u_i_alpha, I_u );
A=pce_normalize( u_i_alpha, I_u );
A(:,1)=0;
C_u_pce2=A*A';

norm(C_u_pce-C_u)
norm(C_u_pce2-C_u)

%%
v_i_k=kl_solve_evp( C_u_pce, G_N, l_u );
[u_i_k,u_k_alpha]=project_pce_on_kl( u_i_alpha, I_u, v_i_k );
[u_i_k2,u_k_alpha2]=pce_to_kl( u_i_alpha, I_u, l_u, G_N );
cc=cross_correlation( u_i_k(:,2:end), u_i_k2(:,2:end), G_N );
fprintf( 'cross correlation=%f\n', cc );

u_1=pce_field_realization( u_i_alpha(5,:), I_u, randn(m_u,10000) );
subplot(1,1,1); clf;
hold on;
kernel_density( u_1, 100, 0.05, 'g' );
xb=linspace(-.2,1.2); plot( xb, beta_pdf( xb, 4, 2 ), 'r' );
hold off;
userwait

%% PDF of KL random vars for the two different KL generation methods
clf; hold off;
N=10000;
xi=randn(m_u,N);
u_1=pce_field_realization( u_k_alpha, I_u, xi );
u_2=pce_field_realization( u_k_alpha2, I_u, xi );
subplot(2,2,1);
kernel_density( [u_1(1,:); u_2(1,:)]', 100, 0.3 );
subplot(2,2,2);
kernel_density( [u_1(2,:); u_2(2,:)]', 100, 0.3 );
subplot(2,2,3);
kernel_density( [u_1(3,:); u_2(3,:)]', 100, 0.3 );
subplot(2,2,4);
kernel_density( [u_1(4,:); u_2(4,:)]', 100, 0.3 );
userwait

%% PDFs at different values of x for the two different KL generation methods
% result: the kl on the pce is much better in terms of marginal densities
% then the projection of the pce on the kl eigenfunctions
subplot(1,1,1); clf;
N=10000;
xi=randn(m_u,N);
u_1=kl_pce_field_realization( u_i_k,  u_k_alpha,  I_u, xi );
u_2=kl_pce_field_realization( u_i_k2, u_k_alpha2, I_u, xi );
subplot(2,2,1);
xb=linspace(-.2,1.2); plot( xb, beta_pdf( xb, 4, 2 ), 'r' );
hold on;
kernel_density( [u_1(1,:); u_2(1,:)]', 100, 0.05 );
drawnow;
hold off;
subplot(2,2,2);
xb=linspace(-.2,1.2); plot( xb, beta_pdf( xb, 4, 2 ), 'r' );
hold on;
kernel_density( [u_1(2,:); u_2(2,:)]', 100, 0.05 );
drawnow;
hold off;
subplot(2,2,3);
xb=linspace(-.2,1.2); plot( xb, beta_pdf( xb, 4, 2 ), 'r' );
hold on;
kernel_density( [u_1(3,:); u_2(3,:)]', 100, 0.05 );
drawnow;
hold off;
subplot(2,2,4);
xb=linspace(-.2,1.2); plot( xb, beta_pdf( xb, 4, 2 ), 'r' );
hold on;
kernel_density( [u_1(4,:); u_2(4,:)]', 100, 0.05 );
drawnow;
hold off;
userwait
