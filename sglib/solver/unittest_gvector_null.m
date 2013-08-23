function unittest_gvector_null
% UNITTEST_GVECTOR_NULL Test the VECTOR functions.
%
% Example (<a href="matlab:run_example unittest_gvector_null">run</a>)
%    unittest_gvector_null
%
% See also TESTSUITE

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

munit_set_function( 'gvector_null' );

assert_equals( gvector_null(ones(3,4,5)), zeros(3,4,5), 'full' );

Z=gvector_null({rand(8,3), rand(10,3)});
assert_equals( norm( Z{1}*Z{2}', 'fro' ), 0, 'norm' );
assert_equals( size(Z{1}), [8,0], 'size_1' );
assert_equals( size(Z{2}), [10,0], 'size_2' );

Z=gvector_null({rand(8,3), rand(10,3), rand(12,3)});

assert_equals( cellfun('size', Z, 1 ), [8,10,12], 'size_dim1' );
assert_equals( cellfun('size', Z, 2 ), [0,0,0], 'size_dim2' );

