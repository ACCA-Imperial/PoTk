classdef sourceSinkPair < pointSingularity
%sourceSinkPair defines a source and a sink.
%
%  s = sourceSinkPair(location, opposite, strength)
%    Constructs a point source and point sink pair in the bounded circular
%    domain where the "source" is placed by the location variable and the
%    sink is placed by the opposite variable. The strength scalar
%    represents the strength of the pair, where a negative value swaps the
%    source/sink role of the points.
%
%See also potential, unitDomain, source, potentialKind.

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
    opposite
end

properties(Access=protected)
    primeFunctions
end

methods
    function s = sourceSinkPair(location, opposite, strength)
        if ~nargin
            return
        end
        
        if numel(location) ~= 1
            error(PoTk.ErrorIdString.InvalidArgument, ...
                'Source location must be a single point.')
        end
        s.location = location;

        if numel(location) ~= 1 && ~isempty(opposite)
            error(PoTk.ErrorIdString.InvalidArgument, ...
                'Sink location (opposite) must be a single point.')
        end
        s.opposite = opposite;

        if ~(numel(strength) == 1 && imag(strength) == 0)
            error(PoTk.ErrorIdString.InvalidArgument, ...
                'Strength must be a real scalar.')
        end
        s.strength = strength;
    end
    
    function ss = struct(s)
        %convert sourceSinkPair to struct.
        
        ss = struct@pointSingularity(s);
        ss.opposite = s.opposite;
    end
end
   
methods(Hidden)
    function val = evalPotential(s, z)
        if s.entirePotential
            val = s.strength*log((z - s.location)./(z - s.opposite))/2/pi;
            return
        end
        omv = s.primeFunctions;
        val = s.strength*log(omv{1}(z).*omv{2}(z)...
            ./omv{3}(z)./omv{4}(z))/(2*pi);
    end
    
    function s = setupPotential(s, W)
        D = W.unitDomain;
        alpha = s.location;
        beta = s.opposite;
        
        if ~isin(D, alpha)
            error(PoTk.ErrorIdString.RuntimeError, ...
                'The source point must be in the bounded unit domain.')
        end
        if ~isin(D, beta)
            error(PoTk.ErrorIdString.RuntimeError, ...
                'The sink point must be in the bounded unit domain.')
        end
        
        om = skprime(alpha, skpDomain(D));
        omv = {...
            om, ...
            skprime(1/conj(alpha), om), ...
            skprime(beta, om), ...
            skprime(1/conj(beta), om)};
        s.primeFunctions = omv;
    end
end

methods(Access=protected)
    function bool = getOkForPlane(~)
        bool = true;
    end
end

end
