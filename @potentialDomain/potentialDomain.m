classdef(Abstract) potentialDomain
%potentialDomain is a potential function domain.
%
%Abstract class denoting a generic potential function domain. Currently
%only provides pedigree. All potential domains should have this as a
%superclass.

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
    
    % FIXME: This is a kludge for the diplole.
    mapMultiplier = 1
end

end
