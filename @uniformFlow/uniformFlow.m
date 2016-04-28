classdef uniformFlow < dipole
%uniformFlow is the uniform background flow.
%
%  uf = uniformFlow(strength, angle)
%    Constructs a uniform flow potential. The flow strength is a real
%    scalar value and the angle is in [0, 2*pi). The angle defaults to 0.
%    Background flow relies on the existence of the property
%    unitDomain.infImage, see the beta argument for unitDomain, which is
%    the image of the point at infinity under a conformal map from an
%    unbounded physical domain to the bounded circle domain.
%
%See also potential, unitDomain, dipole.

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
    function uf = uniformFlow(strength, angle)
        if ~nargin
            args = {};
        else
            if nargin < 2
                angle = 0;
            end
            
            % Pass dipole a placeholder point.
            args = {0, strength, angle};
        end
        
        uf = uf@dipole(args{:});
    end
end

methods(Hidden)
    function val = evalPotential(uf, z)
        if uf.entireDomain
            val = uf.strength*z*exp(-1i*uf.angle);
            return
        end
        
        val = evalPotential@dipole(uf, z);
    end
    
    function uf = setupPotential(uf, W)
        beta = W.unitDomain.infImage;
        if isempty(beta)
            error(PoTk.ErrorIdString.RuntimeError, ...
                'No image of infinity from the physical domain specified.')
        end
        uf.location = beta;
        
        uf = setupPotential@dipole(uf, W);
    end
end

methods(Access=protected)
    function bool = getOkForPlane(~)
        bool = true;
    end
end

end
