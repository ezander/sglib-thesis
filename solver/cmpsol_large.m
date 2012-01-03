function cmpsol_large
% show results for solving the huge model

clc
log_start( fullfile( log_file_base(), mfilename ) );
compare_solvers_pcg( 'model_medium_easy', get_solve_options, 'accurate', true )
show_tex_table(1,[]);
log_stop();


function opts=get_solve_options

% struct( 'longdescr', 'normal tensor solver', 'descr', 'normal');
gsi_std_opts={...
    'descr', 'gsi', ...
    'longdescr', 'gsi', ...
    'eps', 5e-6};

% struct( 'longdescr', 'dynamic tensor solver', 'dyn', true, 'descr', 'dynamic');
gsi_dyn_opts={...
    'descr', 'gsi dyn', ...
    'longdescr', 'gsi dyn', ...
    'dyn', true, ...
    'eps', 1e-8 };

% varargin2options( {'longdescr', 'prec tensor solver', ...
%    'dyn', true, 'prec_strat', {'inside'}, 'descr', 'dyn_inside'} );
gsi_inside_opts={...
    'descr', 'gsi dyn ilu', ...
    'longdescr', 'gsi dyn ilu', ...
    'prec_strat', {'inside'}, ...
    'dyn', true, ...
    'eps', 1e-8};

%ilu_setup=  {'type', 'ilutp', 'droptol', 2e-2, 'milu', 'row', 'udiag', 1 };
%opts{end+1}=varargin2options( {'longdescr', 'ilutp 2 row prec tensor solver', ...
%    'dyn', true, 'prec_strat', {'ilu', ilu_setup}, 'descr', 'dyn_ilutp'} );
ilu_options={'type', 'ilutp', 'droptol', 2e-2, 'milu', 'row', 'udiag', 1 };
gsi_ilu_opts={...
    'descr', 'gsi dyn ilu', ...
    'longdescr', 'gsi dyn ilu', ...
    'prec_strat', {'ilu', ilu_options}, ...
    'dyn', true, ...
    'eps', 1e-8};


optlist={gsi_std_opts, gsi_dyn_opts, gsi_inside_opts, gsi_ilu_opts};
opts={};
for def_opts=optlist
    opts{end+1}=varargin2options( def_opts{1} );
end


