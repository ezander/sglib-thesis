function stats=pcg_gather_stats( what, stats, varargin )
switch(what)
    case 'init'
        stats=gather_stats_init( stats, varargin{:} );
    case 'step'
        stats=gather_stats_step( stats, varargin{:} );
    case 'finish'
        stats=gather_stats_finish( stats, varargin{:} );
    otherwise
        error( 'sglib:pcg_gather_stats:wrong_arg', 'Unknown argument value: %s', what );
end


function stats=gather_stats_init( stats, initres )
norm_func={@gvector_norm,  {stats.G}, {2}};
stats.res_norm=[initres]; %#ok
stats.res_relnorm=[1]; %#ok
stats.res_accuracy=[];
stats.res_relacc=[];
stats.upratio=[1];%#ok
stats.sol_err=[];
stats.sol_relerr=[];
if has_true_solution( stats )
    %stats.X_true_eps=tensor_truncate( stats.X_true, stats.trunc_options );
    stats.sol_err=funcall( norm_func, stats.X_true );
    stats.sol_relerr=[1]; %#ok
    %stats.soleps_err=funcall( norm_func, stats.X_true_eps );
    stats.soleps_relerr=[1]; %#ok
end



function stats=gather_stats_step( stats, F, A, Xn, Rn, normres, relres, upratio )
norm_func={@gvector_norm,  {stats.G}, {2}};

% maybe there is a difference between the residual in the alg and here
% I think so...
%TRn=gvector_add( F, gvector_operator_apply( A, Xn ), -1 );
%normres=funcall( norm_func, TRn );
%relres=normres/stats.initres;

%DRn=gvector_add( Rn, gvector_add( F, operator_apply( A, Xn ), -1 ), -1 );
%ra=funcall( norm_func, DRn );
%ra=funcall( norm_func, DRn );

stats.res_norm(end+1)=normres;
stats.res_relnorm(end+1)=relres;
%stats.res_accuracy(end+1)=ra;
%stats.res_relacc(end+1)=ra/normres;
stats.upratio(end+1)=upratio;

if has_true_solution( stats )
    solerr=funcall( norm_func, gvector_add( Xn, stats.X_true, -1 ) );
    solrelerr=solerr/stats.sol_err(1);
    stats.sol_err(end+1)=solerr;
    stats.sol_relerr(end+1)=solrelerr;

    %solepserr=funcall( norm_func, gvector_add( Xn, stats.X_true_eps, -1 ) );
    %solepsrelerr=solepserr/stats.soleps_err(1);
    %stats.soleps_err(end+1)=solepserr;
    %stats.soleps_relerr(end+1)=solepsrelerr;
end

function stats=gather_stats_finish( stats, varargin ) 
fields=intersect( fieldnames(stats), {'X_true', 'X_true_eps', 'G'} );
stats=rmfield( stats, fields );
%nothing yet

function bool=has_true_solution( stats )
bool=isfield( stats, 'X_true' ) && ~isempty( stats.X_true );
