classdef(Abstract) potentialDomain
%potentialDomain is a potential function domain.
%
%Abstract class denoting a generic potential function domain. Provides
%property storage for conformal maps to and from unit domain. Any subclass
%with one or more boundaries should at a minimum define protected properties
%
%   mapToUnitDomain
%   mapToUnitDomainDeriv
%
%on construction. Future implementations may also protected properties
%
%   mapFromUnitDomain
%   mapFromUnitDomainDeriv
%
%be defined.
%
%See also unitDomain.

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

properties(SetAccess=protected)
    infImage            % Image of infinity to domain under given map.
    mapToUnitDomain     % How to put points in unit domain.
    mapToUnitDomainDeriv
    mapFromUnitDomain   % Hot to get points back from unit domain.
    mapFromUnitDomainDeriv
    
    % Dipole needs this value in a domain with boundaries.
    dipoleMultiplier = 1
end

end
