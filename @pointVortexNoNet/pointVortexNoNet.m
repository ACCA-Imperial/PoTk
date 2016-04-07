classdef pointVortexNoNet < pointVortex
%pointVortexNoNet represents point vortices with no net circulation.

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

properties
    netPointVortex
    greensFunction
end

methods
    function pv = pointVortexNoNet(location, strength)
        pv = pv@pointVortex(location, strength);
        
        pv.netPointVortex = pointVortex(location, strength);
    end
    
    function val = evalPotential(pv, z)
        val = pv.netPointVortex.evalPotential(z);
        val = val - sum(pv.strength(:))*pv.greensFunction(z);
    end
    
    function pv = setupPotential(pv, W)
        if isempty(W.theDomain.infImage)
        error(PoTk.ErrorTypeString.RuntimeError, ...
            'No image of infinity from the physical domain specified.')
        end
        D = skpDomain(W.theDomain);
        
        pv.netPointVortex = pv.netPointVortex.setupPotential(W);
        pv.greensFunction = greensC0(W.theDomain.infImage, D);
    end
end

end
