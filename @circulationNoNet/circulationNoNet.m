classdef circulationNoNet < circulation
%circulationNoNet removes net circulation from unit circle.

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
        C.netCirculation(circ(2:end));
    end
    
    function val = evalPotential(C, z)
        val = C.netCirculation.evalPotential(z) ...
            - sum(C.circVector(:))*C.greensFunction(z);
    end
    
    function C = setupPotential(C, W)
        if isempty(W.theDomain.infImage)
        error(PoTk.ErrorTypeString.RuntimeError, ...
            'No image of infinity from the physical domain specified.')
        end
        D = skpDomain(W.theDomain);
        
        circ = C.circVector;
        if numel(circ) ~= D.m + 1
            error(PoTk.ErrorTypeString.RuntimeError, ...
                ['Number of circulation values must be one greater ' ...
                'than the number\nof inner boundaries.']);
        end
        
        C.netCirculation = C.netCirculation.setupPotential(W);
        C.greensFunction = greensC0(W.theDomain.infImage, D);
    end
end

end
