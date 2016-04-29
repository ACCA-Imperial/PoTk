classdef pointVortexNoNet < pointVortex
%pointVortexNoNet represents point vortices with no net circulation.
%
%  pv = pointVortex(location, strength)
%    Constructs a pointVortex object where location is a vector of points
%    located in a domain given by a relatedly defined unitDomain object.
%    The vector strength is a vector of scalars the same size as the
%    location vector indicating the strength of each point vortex. The net
%    added flow from the point vortices is then assigned to a point vortex
%    designated as the property unitDomain.infImage. (See the beta
%    argumnet in the unitDomain constructor.) For a conformal map from an
%    unbounded physical domain to the bounded unit domain, this is the
%    image of the point at infinity under this map.
%
%See also potential, unitDomain, pointVortex.

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
        if ~nargin
            args = {};
        else
            args = {location, strength};
        end
        pv = pv@pointVortex(args{:});
        
        pv.netPointVortex = pointVortex(args{:});
    end
end

methods(Hidden)    
    function val = evalPotential(pv, z)
        if pv.entirePotential
            val = evalPotential@pointVortex(pv, z);
            return
        end
        
        val = pv.netPointVortex.evalPotential(z);
        val = val - sum(pv.strength(:))*pv.greensFunction(z);
    end
    
    function pv = setupPotential(pv, W)
        Du = W.unitDomain;
        if Du.m == 0
            error(PoTk.ErrorIdString.RuntimeError, ...
                'Use only plain "pointVortex" for simply connected domain.')
        end
        if isempty(Du.infImage)
            error(PoTk.ErrorIdString.RuntimeError, ...
                'No image of infinity from the physical domain specified.')
        end
        
        pv.netPointVortex = pv.netPointVortex.setupPotential(W);
        pv.greensFunction = greensC0(Du.infImage, skpDomain(Du));
    end
end

end
