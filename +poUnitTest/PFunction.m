function P = PFunction(q, truncation)
%poUnitTest.PFunction is the so-called "P-function" for an annular domain.
%
% P = PFunction(q)
% P = PFunction(q, truncation)
% Given a radius 0 < q < 1 the return value P is a function handle to
% evaluate the P-function at a given truncation using the product formula.
% Default truncation is 8.
%
% The connection between the P-function and the S-K prime function is
%
%     w(z,a) = C(q)*a*P(z/a, q)
%
% where C(q) is a constant that depends only on q.
%
% D. Crowdy and J. Marshall. "Green's functions for Laplace's equation in
% multiply connected domains." IMA MAT, 72, 2007: 278--301.
% doi:10.1093/imamat/hxm007.
%
% See also skprime.

% Everett Kropf, 2016
% 
% This file is part of the Potential Toolkit (PoTk).
% 
% PoTk is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% 
% PoTk is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with PoTk.  If not, see <http://www.gnu.org/licenses/>.

if nargin < 2
    truncation = 8;
end

q2k = cumprod(repmat(q^2, 1, truncation));

function val = Peval(z)
    sz = size(z);
%     val = bsxfun(@(z,q2k) (1 - q2k.*z).*(1 - q2k./z), z(:), q2k);
    val = cell2mat(...
        arrayfun(@(x) (1 - x*z(:)).*(1 - x./z(:)), q2k, 'uniform', false));
    val = reshape(prod([1 - z, val], 2), sz);
end

P = @Peval;

end
