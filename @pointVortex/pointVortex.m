classdef pointVortex < pointSingularity
%pointVortex represents a point vortex.
%
%  pv = pointVortex(location, strength)
%    Constructs a pointVortex object where location is a vector of points
%    located in a domain given by a relatedly defined unitDomain object.
%    The vector strength is a vector of scalars the same size as the
%    location vector indicating the strength of each point vortex. All net
%    flow from the point vortices is assigned to the unit circle as a
%    circulation of strength -sum(strength).
%
%See also potential, unitDomain, pointVortexNoNet.

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

properties(Access=protected)
    greensFunctions
end

methods
    function pv = pointVortex(location, strength)
        if ~nargin
            return
        end
        
        if ~isequal(size(location(:)), size(strength(:)))
            error(PoTk.ErrorIdString.InvalidArgument, ...
                'Location and strength vectors must be same size.')
        end
        pv.location = location;
        
        if any(imag(strength(:)) ~= 0)
            error(PoTk.ErrorIdString.InvalidArgument, ...
                'Strength values must be all real.')
        end
        pv.strength = strength;
    end
end

methods(Hidden)
    function val = evalPotential(pv, z)
        if pv.entirePotential
            N = numel(pv.location);
            val = reshape(sum(...
                arrayfun(@(k) log(z(:) - pv.location(k))/2i/pi, 1:N), 2), ...
                size(z));
            return
        end
        
        val = complex(zeros(size(z)));
        g0v = pv.greensFunctions;
        s = pv.strength;
        
        for k = find(s(:) ~= 0)'
            val = val + s(k)*g0v{k}(z);
        end
    end
    
    function dpv = getDerivative(pv, domain, ~)
        zeta = domain.mapToUnitDomain;
        dzeta = domain.mapToUnitDomainDeriv;
        
        g0v = pv.greensFunctions;
        dg0v = cell(size(g0v));
        for k = find(pv.strength(:)' ~= 0)
            dg0v{k} = diff(g0v{k});
        end
        
        function v = dEval(z)
            v = 0;
            sv = pv.strength;
            for i = find(sv(:)' ~= 0)
                v = v + sv(i)*dg0v{i}(zeta(z)).*dzeta(z);
            end
        end
        
        dpv = @dEval;
    end
    
    function pv = setupPotential(pv, W)
        zeta = W.domain.mapToUnitDomain;
        g0v = cell(1, numel(pv.location));        
        for k = find(pv.strength(:) ~= 0)'
            g0v{k} = greensC0(zeta(pv.location(k)), skpDomain(W.unitDomain));
        end
        pv.greensFunctions = g0v;
    end
end

methods(Access=protected)
    function bool = getOkForPlane(~)
        bool = true;
    end
end

end
