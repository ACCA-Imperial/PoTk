classdef circulationNoNet < circulation
%circulationNoNet removes net circulation from unit circle.
%
%  C = circulation(c0, c1, c2, ..., cm)
%  C = circulation([c0, c1, c2, ..., cm])
%    Creates a circulation object which describes the potential
%    contribution due to circulation around m+1 boundaries in a domain with
%    connectivity m+1. For j = 0:m, each cj is a real scalar value
%    signifying the circulation strength on the jth boundary. The net
%    circulation is then assigned to a point vortex at infinity if the
%    associated domain is unbounded, or a designated point in a bounded
%    domain. In the case of unitDomain, this point is unitDomain.infImage
%    (see the beta argument in the unitDomain constructor).
%
%See also potential, unitDomain, circulation.

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
    netCirculation
    greensFunction
end

methods
    function C = circulationNoNet(varargin)
        C = C@circulation(varargin{:});
        
        circ = C.circVector;
        C.netCirculation = circulation(circ(2:end));
    end
end

methods(Hidden)
    function val = evalPotential(C, z)
        val = C.netCirculation.evalPotential(z) ...
            - sum(C.circVector(:))*C.greensFunction(z);
    end
    
    function dc = getDerivative(C, domain)
        dnc = getDerivative(C.netCirculation, domain);
        dg0 = diff(C.greensFunction);
        zeta = domain.mapToUnitDomain;
        dzeta = domain.mapToUnitDomainDeriv;
        dc = @(z) dnc(z) - sum(C.circVector(:))*dg0(zeta(z)).*dzeta(z);
    end
    
    function C = setupPotential(C, W)
        D = W.unitDomain;
        if D.m == 0
            error(PoTk.ErrorIdString.RuntimeError, ...
                'Use only plain "circulation" for simply connected domain.')
        end
        if isempty(D.infImage)
            error(PoTk.ErrorIdString.RuntimeError, ...
                'No image of infinity from the physical domain specified.')
        end
        
        circ = C.circVector;
        if numel(circ) ~= D.m + 1
            error(PoTk.ErrorIdString.RuntimeError, ...
                ['Number of circulation values must be one greater ' ...
                'than the number\nof inner boundaries.']);
        end
        
        C.netCirculation = C.netCirculation.setupPotential(W);
        C.greensFunction = greensC0(D.infImage, skpDomain(D));
    end
end

end
