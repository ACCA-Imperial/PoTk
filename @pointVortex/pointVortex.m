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
        val = complex(zeros(size(z)));
        g0v = pv.greensFunctions;
        s = pv.strength;
        
        for k = find(s(:) ~= 0)'
            val = val + s(k)*g0v{k}(z);
        end
    end
    
    function pv = setupPotential(pv, W)
        D = skpDomain(W.domain);
        g0v = cell(1, numel(pv.location));
        
        for k = find(pv.strength(:) ~= 0)'
            g0v{k} = greensC0(pv.location(k), D);
        end
        pv.greensFunctions = g0v;
    end
end

end
