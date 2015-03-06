p_u=4;
m_k=4; p_k=2;
m_f=0; p_f=2;

alphasort=true;
kfirst=true;
S=compute_sparsity( m_k, p_k, m_f, p_f, p_u, alphasort, kfirst, false );
K=matrix_gallery('tridiag', 5, -1, 2, -1);

multiplot_init(2,2)

multiplot;
spy2(S); title('S');
multiplot;
spy2(K); title('K');
multiplot;
spy2(kron(S,K)); title('S \otimes K');
multiplot;
spy2(kron(K,S)); title('K \otimes S');


        