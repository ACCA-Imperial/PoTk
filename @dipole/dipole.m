classdef dipole < potentialKind
%dipole represents a dipole.

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
        
        % FIXME: Verify input.
        d.location = location;
        d.strength = strength;
        
        if nargin > 2
            d.angle = angle;
        end
    end
    
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
        if isempty(W.theDomain.infImage)
            error(PoTk.ErrorIdString.RuntimeError, ...
                'No image of infinity from the physical domain specified.')
        end
        
        D = skpDomain(W.theDomain);
        beta = W.theDomain.infImage;
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
