function r = boundaryPartMake(domain, f0, f1)
%circulationNoNet removes net circulation from unit circle.
%
%  C = circulation(c0, c1, c2, ..., cm)
%  C = circulation([c0, c1, c2, ..., cm])
%    Creates a circulation object which describes the potential
%    contribution due to circulation around m inner circles and the unit
%    circle. For j = 0:m, each cj is a real scalar value specifying the
%    circulation strength on the jth circle. The net circulation is then
%    assigned to a designated point in the domain (see the beta argument
%    in the unitDomain constructor).
%
%See also potential, unitDomain, circulation.

% Everett Kropf, 2016
% Rhodri Nelson, 2016
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

%boundaryPartMake makes a function to evaluate points on the boundary from
%a list of functions.
%
% r = boundaryPartMake(domain, f0, f1, ..., fm)
% Takes a list of functions and returns a function r which is restricted to
% the boundary. The function r gives f0 values for points on C0, f1 values
% for points on C1, etc., up to fm values for points on Cm.

% Everett Kropf, 2016

if ~isa(domain, 'skpDomain')
    error('First argument must be an "skpDomain" object.')
end

m = domain.m;
if nargin - 1 ~= m + 1
    error('Number of functions given must match the number of boundaries.')
end
% if ~all(cellfun(@(x) isa(x, 'function_handle'), varargin))
%     error('Expected a list of function handles following the domain.')
% end

function v = reval(z)
    v = nan(size(z));
    [~, onj] = ison(domain, z);
    v(onj==0)=f0(z(onj==0));
    for j = 1:m
        ix = onj == j;
        v(ix) = f1(z(ix));
    end
end

r = @reval;

end
