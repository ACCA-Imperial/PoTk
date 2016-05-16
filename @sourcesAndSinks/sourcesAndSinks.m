classdef sourcesAndSinks < pointSingularity
%sourceSinkPair defines a source and a sink.
%
%  s = sourcesAndSinks(locations, strengths)
%    Defines a collection of potential sources and sinks at the vector
%    locations. The vector strengths must be the same size as locations.
%    Locations must be within the potential domain. It is possible to
%    have sum(strengths) ~= 0, but this will trigger a warning.
%
%See also potential, unitDomain, planeDomain, potentialKind.

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
    
end

properties(Access=protected)
    primeFunctions
end

methods
    function s = sourcesAndSinks(locations, strengths)
        if ~nargin
            return
        end
        
        if ~isequal(size(locations), size(strengths))
            error(PoTk.ErrorIdString.RuntimeError, ...
                'Location and strength vectors must have same size.')
        end
        locations = locations(:);
        strengths = strengths(:);
        
        if sum(strengths) ~= 0
            warning('PoTk:FlowImbalance', ...
                'Source and sink strengths do not sum to zero.')
        end
        
        s.location = locations;
        s.strength = strengths;
    end
    
    function [sv, mv] = sources(s)
        mask = s.strength > 0;
        sv = s.location(mask);
        mv = s.strength(mask);
    end
    
    function [sv, mv] = sinks(s)
        mask = s.strength < 0;
        sv = s.location(mask);
        mv = s.strength(mask);
    end
end

methods(Hidden)
    function val = evalPotential(s, z)
        val = complex(zeros(size(z)));
        mv = s.strength;
        if s.entirePotential
            sv = s.location;
            for k = 1:numel(mv)
                val = val + mv(k)/2/pi*log(z - sv(k));
            end
        end
        
        pfv = s.primeFunctions;
        for k = 1:size(pfv, 1)
            val = val + mv(k)/2/pi*log(pfv{k,1}(z).*pfv{k,2}(z));
        end
    end
    
    function ds = getDerivative(s, domain)
        if s.entirePotential
        end
                
        pfv = s.primeFunctions;
        dfv = cell(size(pfv));
        dfv(:) = cellfun(@diff, pfv(:), 'uniformOutput', false);
        
        zeta = domain.mapToUnitDomain;
        dzeta = domain.mapToUnitDomainDeriv;
        function dv = deval(z)
            zz = zeta(z);
            dv = complex(zeros(size(z)));
            
            mv = s.strength;
            for k = 1:numel(mv)
                dv = dv + mv(k)/2/pi ...
                    *(dfv{k,1}(zz)./pfv{k,1}(zz) + dfv{k,2}(zz)./pfv{k,2}(zz));
            end
            dv = dv.*dzeta(z);
        end
        
        ds = @deval;
    end
    
    function s = setupPotential(s, W)
        zeta = W.domain.mapToUnitDomain;
        D = W.unitDomain;
        av = zeta(s.location);
        if ~isin(D, av)
            error(PoTk.ErrorIdString.RuntimeError, ...
                'Sources and sinks must be within the domain.')
        end
        
        N = numel(av);
        pfv = cell(N, 2);
        for k = 1:N
            if k > 1
                om = skprime(av(k), om);
            else
                om = skprime(av(1), skpDomain(D));
            end
            omc = invParam(om);
            pfv(k,:) = {om, omc};
        end
        s.primeFunctions = pfv;
    end
end

methods(Access=protected)
    function bool = getOkForPlane(~)
        bool = true;
    end
end

end
