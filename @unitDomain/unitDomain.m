classdef unitDomain
%unitDomain is the domain bounded by the unit disk.

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
    centers
    radii
end

properties(Dependent)
    dv
    qv
end

methods
    function D = unitDomain(dv, qv)
        if ~nargin
            return
        end
        
        % Check for circle intersections.
        
        D.centers = dv;
        D.radii = qv;
    end
end

methods % Setting and getting.
    function dv = get.dv(D)
        dv = D.centers;
    end
    
    function qv = get.qv(D)
        qv = D.radii;
    end
end

end
