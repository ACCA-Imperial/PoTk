classdef dipole < potentialKind
%dipole represents a dipole.
%
%  d = dipole(location, strength)
%  d = dipole(location, strength, angle)
%    Constructs a dipole in the bounded circular domain at the given
%    location which should be inside a relatedly defined unitDomain. The
%    scalar strengh specifies the strength of the dipole. The optional
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
    location
    strength
    angle = 0
    
    dhForwardDiff = 1e-8;
    greensFunctions
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
end

methods(Hidden)
    function val = evalPotential(d, z)
        val = complex(zeros(size(z)));
        
        g0v = d.greensFunctions;
        chi = d.angle;
        h = d.dhForwardDiff;
        if ~isempty(g0v{2})
            val = val + (g0v{2}(z) - g0v{1}(z))/h*sin(chi);
        end
        if ~isempty(g0v{3})
            val = val + (g0v{3}(z) - g0v{1}(z))/h*cos(chi);
        end
    end
    
    function d = setupPotential(d, W)
        beta = d.location;
        if ~isin(W.theDomain, beta)
            error(PoTk.ErrorIdString.RuntimeError, ...
                'The dipole must be located inside the bounded circle domain.')
        end
        
        D = skpDomain(W.theDomain);
        chi = d.angle;
        h = d.dhForwardDiff;
        db = beta + h*[1, 1i];
        
        g0v = {greensC0(beta, D), [], []};
        if mod(chi, pi) > eps(pi)
            % Horizontal component.
            g0v{2} = greensC0(db(1), g0v{1});
        end
        if mod(chi + pi/2, pi) > eps(pi)
            % Vertical component.
            g0v{3} = greensC0(db(2), g0v{2});
        end
        d.greensFunctions = g0v;
    end
end

end
