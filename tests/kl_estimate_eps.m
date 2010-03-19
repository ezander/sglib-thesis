function [eps,alg_decay,p]=kl_estimate_eps(sigma, alg_decay, p)
% KL_ESTIMATE_EPS Short description of kl_estimate_eps.
%   KL_ESTIMATE_EPS Long description of kl_estimate_eps.
%
% Example (<a href="matlab:run_example kl_estimate_eps">run</a>)
%
% See also

%   Elmar Zander
%   Copyright 2010, Inst. of Scientific Computing, TU Braunschweig
%   $Id$ 
%
%   This program is free software: you can redistribute it and/or modify it
%   under the terms of the GNU General Public License as published by the
%   Free Software Foundation, either version 3 of the License, or (at your
%   option) any later version. 
%   See the GNU General Public License for more details. You should have
%   received a copy of the GNU General Public License along with this
%   program.  If not, see <http://www.gnu.org/licenses/>.

sigma=sigma(:)';
n=length(sigma);
N=min(3*n, 1000);

if nargin<3 || isempty(alg_decay) || isempty(p)
    [alg_decay,p]=kl_best_fit(sigma);
end
    
sigma_ex=kl_extrapolate( sigma, N, alg_decay, p );
eps=kl_eps( sigma, sigma_ex )

function [best_alg_decay,best_p]=kl_best_fit( sigma )
n=length(sigma);
best_fit=inf;
for alg_decay=[false,true]
    for p=1:1
        sigma_ex=kl_extrapolate( sigma, n, alg_decay, p );
        fit_value=kl_goodness_of_fit_( sigma, sigma_ex );
        if fit_value<best_fit
            best_fit=fit_value;
            best_alg_decay=alg_decay;
            best_p=p;
        end
    end
end

function fit_value=kl_goodness_of_fit_( sigma, sigma_ex )
n2=length(sigma);
n1=floor(n2/2);
fit_value=sum((sigma(n1:n2)-sigma_ex(n1:n2)).^2);

function eps=kl_eps( sigma, sigma_ex )
n=length(sigma);
N=length(sigma_ex);
s=sum(sigma.^2);
S=sum(sigma_ex(n+1:N).^2);
eps=sqrt(S)/sqrt(s);


function sigma_ex=kl_extrapolate( sigma, N, alg_decay, p )
n=length(sigma);
if alg_decay
    q=polyfit( log(1:n), log(sigma), p );
    sigma_ex=exp(polyval(q,log(1:N)));
else
    q=polyfit( 1:n, log(sigma), p );
    sigma_ex=exp(polyval(q,1:N));
end

clf
subplot(3,1,1);
loglog(sigma); hold on
loglog(sigma_ex, 'r')

subplot(3,1,2);
semilogy(sigma); hold on
semilogy(sigma_ex, 'r')

subplot(3,1,3);
plot(sigma); hold on
plot(sigma_ex, 'r')

