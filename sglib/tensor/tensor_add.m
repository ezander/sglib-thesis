function T=tensor_add( T1, T2, alpha )
% TENSOR_ADD Add two tensors.
%   TENSOR_ADD( T1, T2, ALPHA ) adds two tensors T1 and T2,
%   multiplying T2 by ALPHA first if given.
%
% Note 1: implementation is of course trivial, since addition of sparse
%   tensors if simply juxtaposition, but having this as a separate function
%   makes the code clearer.
%
% Note 2: This method does not perform reduction of the new tensor. You
%   have to call TENSOR_REDUCE manually to achieve this.
%
% Example (<a href="matlab:run_example tensor_add">run</a>)
%   T1={rand(8,2), rand(10,2)}
%   T2={rand(8,3), rand(10,3)}
%   Z=tensor_add(T1,T2,3)
%   norm( T1{1}*T1{2}'+3*T2{1}*T2{2}'-Z{1}*Z{2}', 'fro' )% should be approx. zero
%
% See also TENSOR_REDUCE, TENSOR_NULL, TENSOR_SCALE

%   Elmar Zander
%   Copyright 2007, Institute of Scientific Computing, TU Braunschweig.
%
%   This program is free software: you can redistribute it and/or modify it
%   under the terms of the GNU General Public License as published by the
%   Free Software Foundation, either version 3 of the License, or (at your
%   option) any later version.
%   See the GNU General Public License for more details. You should have
%   received a copy of the GNU General Public License along with this
%   program.  If not, see <http://www.gnu.org/licenses/>.


if nargin<3
    alpha=1;
end

check_tensors_compatible( T1, T2 );

persistent max_size;

if isempty(max_size)
    max_size=10000;
end

if tensor_rank(T1)+tensor_rank(T2)>max_size
    warning( 'tensor:tensor_add:large', ['Your tensor is growing pretty large. Forgotten to truncate?\n', ... 
        'max_size is currently %d. You may set it to a higher value by entering e.g. max_size=%d.'], ...
        max_size, 10*max_size );
    keyboard;
end
    

% Important: apply alpha only to one argument! This guy is a tensor not
% a cartesian product.
% TODO: Maybe a loop if faster than this mat2cell stuff? Check performance
T2{1}=alpha*T2{1};
dims=tensor_size(T1);
T=mat2cell( [cell2mat(T1(:)), cell2mat(T2(:))], dims )';
