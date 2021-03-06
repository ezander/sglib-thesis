underline( 'Tensor solver stats' );
if isfield( info, 'descr' )
    strvarexpand( 'description: $info.descr$' )
end
strvarexpand( 'time: $info.time$' )
strvarexpand( 'iterations: $info.iter$' )
strvarexpand( 'relative res.: $info.relres$' )
if isfield( info, 'errvec' ) && ~isempty(info.errvec)
    strvarexpand( 'relative error: $info.errvec(end)$' )
end
if isfield( info, 'rho' ) && isfield( info, 'updnormvec' ) && isfield( info, 'epsvec' )
    rho=info.rho;
    mind=min(length(info.updnormvec),length(info.norm_U+info.epsvec));
    errest=rho/(1-rho)*info.updnormvec(1:mind)/info.norm_U+info.epsvec(1:mind);
    strvarexpand( 'error est.: $errest(end)$' )
end

strvarexpand( 'error mc l2: $info.errest_l2$' )
strvarexpand( 'error mc L2: $info.errest_L2$' )

strvarexpand( 'epsilon: $info.epsvec(end)$' )

strvarexpand( 'precond calls: $sum(info.rank_res_before)$' )
if isfield( info, 'rank_K' )
    strvarexpand( 'op rank: $info.rank_K$' )
    strvarexpand( 'apps per rank: $sum(info.rank_sol_after)$' )
    strvarexpand( 'op applications: $info.rank_K*sum(info.rank_sol_after)$' )
end

strvarexpand( 'max. res rank: $max(info.rank_res_before)$' )
strvarexpand( 'last res rank: $info.rank_res_before(end)$' )
strvarexpand( 'max. sol rank: $max(info.rank_sol_after)$' )
strvarexpand( 'last sol rank: $info.rank_sol_after(end)$' )

if isfield( info, 'memorig' )
    strvarexpand( 'VmSize: $(info.memmax.VmSize-info.memorig.VmSize)/1024/1024$ MB' )
    strvarexpand( 'VmRSS:  $(info.memmax.VmRSS-info.memorig.VmRSS)/1024/1024$ MB' )
    strvarexpand( 'VmData: $(info.memmax.VmData-info.memorig.VmData)/1024/1024$ MB' )
end
