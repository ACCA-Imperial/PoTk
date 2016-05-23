classdef uniformFlow < dipole & PoTk.Expressable
%uniformFlow is the uniform background flow.
%
%  uf = uniformFlow(strength, angle)
%    Constructs a uniform flow object in a potential domain.  The flow
%    strength is a real scalar value and the angle is in [0, 2*pi). The
%    angle defaults to 0. In an unbounded domain uniform flow is a dipole
%    at the point at infinity. In the unitDomain this is some designated
%    point (see the beta argument in the unitDomain constructor).
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
    
    function printAnalyticExpression(uf)
        if uf.entirePotential
            fprintf([...
'For a flow strength of U at angle chi, the potential is\n\n', ...
'          -i chi\n', ...
'  U zeta e\n\n', ...
                ])
            return
        end
        
        fprintf([...
PoTk.Expressions.declarePrimeFunction(), ...
'Define the modified Green''s function to be\n\n', ...
PoTk.Expressions.declareGreens0(), ...
'\nGiven a conformal map z(zeta) to the physical domain\n', ...
'From the unit domain, define the constant b by the expression\n\n', ...
'                 b\n', ...
'  z(zeta) = ----------- + analytic part\n', ...
'            zeta - beta\n', ...
'\nfor zeta -> beta.\n', ...
'\nThen the uniform flow potential is given by\n\n', ...
'             /  i chi     d\n', ...
'  2 pi U b i | e      --------- G_0(zeta, a, conj(a)) -\n', ...
'             \\        d conj(a)\n', ...
'\n', ...
'                         -i chi  d                        \\\n', ...
'                      - e       --- G_0(zeta, a, conj(a)) |\n', ...
'                                d a                       /\n', ...
'\nwhere U is the strength of the flow and chi is the angle.\n'])
    end
end

methods(Access=protected)
    function bool = getOkForPlane(~)
        bool = true;
    end
end

end
