classdef pointVortex < potentialKind
%pointVortex represents a point vortex.

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
    location
    strength
end    

properties(Access=protected)
    greensFunctions
end

methods
    function pv = pointVortex(location, strength)
        if ~nargin
            return
        end
        
        % FIXME: Check vectors are same size. Check strength is real only.
        pv.location = location;
        pv.strength = strength;
    end
    
    function disp(pv)
        disp(struct(pv))
    end
    
    function val = evalPotential(pv, z)
        val = complex(zeros(size(z)));
        g0v = pv.greensFunctions;
        s = pv.strength;
        
        for k = find(s(:) ~= 0)'
            val = val + s(k)*g0v{k}(z);
        end
    end
    
    function pv = setupPotential(pv, W)
        D = skpDomain(W.theDomain);
        g0v = cell(1, numel(pv.location));
        
        for k = find(pv.strength(:) ~= 0)'
            g0v{k} = greensC0(pv.location, D);
        end
        pv.greensFunctions = g0v;
    end
    
    function pv = struct(pv)
        pv = struct('location', pv.location, ...
            'strength', pv.strength);
    end
end

end
