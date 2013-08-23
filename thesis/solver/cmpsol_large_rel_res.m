function cmpsol_large_rel_res

% compares performance of the gsi and pcg for different values of the
% target relative residual

clc

log_start( fullfile( log_file_base(), mfilename ) );
compare_solvers_pcg( 'model_large_easy', get_solve_options, 'accurate', true )
show_tex_table_2d(2, [], 'hl',[3, 6]);
show_tex_table_2d(3, [], 'hl',[3, 6]);
show_tex_table_2d(4, [], 'hl',[3, 6]);
log_stop();

function opts=get_solve_options
%#ok<*AGROW>
opts={};

ilu_options={'type', 'ilutp', 'droptol', 2e-2, 'milu', 'row', 'udiag', 1 };


gsi_std_opts={...
    'descr', 'gsi', ...
    'longdescr', 'gsi', ...
    'solve_opts', {'div_b', 1, 'div_op', 1}, ...
    'eps', nan};

gsi_dyn_opts={...
    'descr', 'gsi dyn', ...
    'longdescr', 'gsi dyn', ...
    'dyn', true, ...
    'eps', 1e-8 };

gsi_ilu_opts={...
    'descr', 'gsi dyn/ilu', ...
    'longdescr', 'gsi dyn/ilu', ...
    'prec_strat', {'ilu', ilu_options}, ...
    'dyn', true, ...
    'eps', 1e-8, ...
    'solve_opts', {'div_b', 10, 'div_op', 10}, ...
    'check', false };



gpcg_std_opts={...
    'descr', 'gpcg', ...
    'longdescr', 'gpcg', ...
    'type', 'gpcg', ...
    'solve_opts', {'div_b', 1, 'div_op', 1}, ...
    'eps', nan};

gpcg_dyn_opts={...
    'descr', 'gpcg dyn', ...
    'longdescr', 'gpcg dyn', ...
    'type', 'gpcg', ...
    'dyn', true, 'eps', 1e-8 };

gpcg_ilu_opts={...
    'descr', 'gpcg dyn/ilu', ...
    'longdescr', 'gpcg dyn/ilu', ...
    'prec_strat', {'ilu', ilu_options}, ...
    'type', 'gpcg', ...
    'dyn', true, ...
    'eps', 1e-8, ...
    'solve_opts', {'div_b', 10, 'div_op', 10}, ...
    };


pcg_mean_opts={...
    'descr', 'pcg', ...
    'longdescr', 'pcg', ...
    'type', 'pcg', ...
    };

pcg_kron_opts={...
    'descr', 'pcg kron', ...
    'longdescr', 'pcg kron', ...
    'type', 'pcg', ...
    'prec', 'kron' };


if fasttest('get')
    tol_set=[ 1e-3, 1e-2];
    optlist = {gsi_ilu_opts,gpcg_ilu_opts,pcg_mean_opts};
else
    tol_set=[ 1e-4, 3e-4, 1e-3, 3e-3, 1e-2];
    optlist = {gsi_std_opts, gsi_dyn_opts, gsi_ilu_opts,...
        gpcg_std_opts, gpcg_dyn_opts, gpcg_ilu_opts,...
        pcg_mean_opts};
end

for tol=tol_set
    for def_opts=optlist
        opt=varargin2options( [def_opts{1}, {'tol',tol}] ); 
        if ~get_option(opt, 'dyn', false)
            opt.eps=opt.tol * 5e-3;
        end
        opts{end+1}=opt; 
    end
end

