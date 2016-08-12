classdef domainAnnulus < poUnitTest.domainForTesting
%poUnitTest.domainAnnulus is an annular domain.

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
    type = poUnitTest.domainType.Annulus
    domainObject = unitDomain(0, 0.1, -0.4)
    testPoints = [
        -0.017493+0.4828i
        0.45131+0.2309i
        0.41633-0.4828i
        -0.43732-0.43382i]
    betaLocations = struct(...
        'inside', -0.4, ...
        'circle0', -1);
end

methods
    function maps = mapsExternal(dom, benum)
        beta = dom.beta(benum);
        switch benum
            case poUnitTest.betaParameter.circle0
                z = @(zeta) 1i*(1-zeta)./(1+zeta);
                residue = 2i; % parameter on boundary
                zeta = @(z) (1i - z)./(1i + z);
                dz = @(zeta) -2i./(1 + zeta).^2;
                dzeta = @(z) -2i./(1i + z).^2;
                
            otherwise
                z = @(zeta) 1./(zeta - beta);
                residue = 1;
                zeta = @(z) 1./z + beta;
                dz = @(zeta) -1./(zeta - beta).^2;
                dzeta = @(z) -1./z.^2;
        end
        
        maps = poUnitTest.mapsExternal(z, dz, residue, zeta, dzeta);
    end
end

end
