classdef uniformFlow < dipole
%uniformFlow is the uniform background flow.
%
%  uf = uniformFlow(strength, angle, scale)
%    Constructs a uniform flow object in a potential domain.  The flow
%    strength is a real scalar value and the angle is in [0, 2*pi). The
%    scale is a scalar value associated with a conformal map to some
%    physical domain; see the help for dipole for more information on the
%    scale. The location of the dipole in the unit domain is a point defined
%    in the unitDomain constructor (see the beta argument in unitDomain 
%    help), and is typically associated with the image of the point at 
%    infinity under a conformal map to an unbounded physical domain.
%
%See also potential, dipole, unitDomain, unboundedCircles.

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

methods
    function uf = uniformFlow(strength, angle, scale)
        if ~nargin
            args = {};
        else
            % Note dipole is given a placeholder point.
            if nargin > 2
                args = {0, strength, angle, scale};
            else
                args = {0, strength, angle};
            end
        end
        
        uf = uf@dipole(args{:});
    end
end

methods(Hidden)
    function val = evalPotential(uf, z)
        if uf.entirePotential
            val = uf.strength*z*exp(-1i*uf.angle);
            return
        end
        
        val = evalPotential@dipole(uf, z);
    end
    
    function uf = setupPotential(uf, W)
        D = W.unitDomain;
        if isa(W.domain, 'unitDomain')
            if isempty(D.infImage)
                error(PoTk.ErrorIdString.RuntimeError, ...
                    'No image of infinity from the physical domain specified.')
            end
            uf.location = D.infImage;
        else
            uf.location = inf;
        end
        
        uf = setupPotential@dipole(uf, W);
    end
end

methods(Access=protected)
    function bool = getOkForPlane(~)
        bool = true;
    end
end

end
