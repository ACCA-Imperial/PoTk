classdef dipole < pointSingularity
%dipole represents a dipole.
%
%  d = dipole(location, strength)
%  d = dipole(location, strength, angle)
%    Constructs a dipole at a point in a potential domain. The scalar
%    strengh specifies the strength of the dipole. The optional
%    argument angle (defaults to 0) specifies the angle of the dipole.
%
%See also potential, unitDomain.

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
    angle = 0
    
    greensXderivative
    greensYderivative
    
    dipoleMultiplier = 1           % From conformal map to unit domain.
end

methods
    function d = dipole(location, strength, angle)
        if ~nargin
            return
        end
        
        if numel(location) ~= 1
            error(PoTk.ErrorIdString.RuntimeError, ...
                'Location must be a single point.')
        end
        d.location = location;
        
        if ~(numel(strength) == 1 && imag(strength) == 0)
            error(PoTk.ErrorIdString.RuntimeError, ...
                'Strength must be a real scalar.')
        end
        d.strength = strength;
        
        if nargin > 2
            d.angle = angle;
        end
    end
    
    function d = struct(d)
        %Convert instance to structure.
        
        chi = d.angle;
        d = struct@pointSingularity(d);
        d.angle = chi;
    end
end

methods(Hidden)
    function val = evalPotential(d, z)
        if d.entirePotential
            val = d.strength./(z - d.location)/2/pi*exp(1i*d.angle);
            return
        end
        
        val = complex(zeros(size(z)));
        
        U = d.strength;
        if U == 0
            return
        end
        
        chi = d.angle;
        a = d.dipoleMultiplier;
        if mod(chi, pi) > eps(pi)
            % "Horizontal" component.
            dxg0 = d.greensXderivative;
            val = val - 4*pi*U*a*sin(chi)*dxg0(z);
        end
        if mod(chi + pi/2, pi) > eps(pi)
            % "Vertical" component.
            dyg0 = d.greensYderivative;
            val = val - 4*pi*U*a*cos(chi)*dyg0(z);
        end
    end
    
    function dw = getDerivative(d)
        if d.entirePotential
            dw = @(z) -d.strength./(z - d.location).^2/2/pi*exp(1i*d.angle);
            return
        end
        
        dzg0x = diff(d.greensXderivative);
        dzg0y = diff(d.greensYderivative);
        
        function v = deval(z)
            v = 0;
            
            U = d.strength;
            if U == 0
                return
            end
            
            chi = d.angle;
            a = d.dipoleMultiplier;
            if mod(chi, pi) > eps(pi)
                v = v - 4*pi*U*a*sin(chi)*dzg0x(z);
            end
            if mod(chi + pi/2, pi) > eps(pi)
                v = v - 4*pi*U*a*cos(chi)*dzg0y(z);
            end
        end
        
        dw = @deval;
    end
    
    function d = setupPotential(d, W)
        D = W.unitDomain;
        beta = d.location;
        if ~isin(D, beta)
            error(PoTk.ErrorIdString.RuntimeError, ...
                'The dipole must be located inside the bounded circle domain.')
        end
        
        if d.strength == 0
            return
        end
        D = skpDomain(D);
        d.greensXderivative = greensC0Dpxy(beta, 'x', D);
        d.greensYderivative = greensC0Dpxy(beta, 'y', d.greensXderivative);
    end
end

methods(Access=protected)
    function bool = getOkForPlane(~)
        bool = true;
    end
end

end
