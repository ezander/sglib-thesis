info=struct();
info=process_param( 'N', info, 'N$value$' );
info=process_param( 'geom', info );
info=process_param( 'dist', info, '$value$' );
info=process_param( 'dist_params', info, '$value{1}$_$value{2}$' );
info=process_param( 'dist_shift', info, 'mu$value$' );
info=process_param( 'dist_scale', info );
model_base=info.base;

info=process_param( 'solver', info, '$value$' );
info=process_param( 'reltol', info, 'tol$-log10(value)$' );
info=process_param( 'trunc_mode', info, 'trm$value$' );
info=process_param( 'orth_mode', info, '$value$' );
info=process_param( 'eps', info, 'eps$-log10(value)$' );
info=process_param( 'eps_mode', info, '$value$' );
solver_base=info.base;

% build={
%     @build_model, ['./mat/model-', model_base, '.mat'];
%     @solve_model, ['./mat/solve-', solver_base, '.mat'];
%     };
%build={
%   @build_model, ['./mat/model-', solver_base, '.mat'];
%    @solve_model, ['./mat/solve-', solver_base, '.mat'];
%    };
if isoctave
  dir='oct';
else
  dir='mat';
end

build={
    'build_model', ['./', dir, '/model-', solver_base, '.mat'];
    'solve_model', ['./', dir, '/solve-', solver_base, '.mat'];
    };
autoloader;

