classdef sourcesAndSinks < pointSingularity
%sourceSinkPair defines a source and a sink.
%
%  s = sourcesAndSinks(locations, strengths)
%    Defines a collection of potential sources and sinks at the vector
%    locations in a potential domain. The vector strengths must be the
%    same size as locations. Locations must be within the potential
%    domain. It is possible to have sum(strengths) ~= 0, but this will
%    trigger a warning.
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
            error(PoTk.ErrorIdString.RuntimeError, ...
                'Mass imbalance; source and sink strengths do not sum to zero.')
        end
        
        s.location = locations;
        s.strength = strengths;
    end
    
    function [sv, mv] = sources(s)
        %Returns source points (positive strentgh value).
        %
        %  [sv, mv] = sources(s)
        %  Where sv are the locations and mv are the strengths of the
        %  source points.
        
        mask = s.strength > 0;
        sv = s.location(mask);
        mv = s.strength(mask);
    end
    
    function [sv, mv] = sinks(s)
        %Returns sink points (negative strentgh value).
        %
        %  [sv, mv] = sinks(s)
        %  Where sv are the locations and mv are the strengths of the
        %  sink points.
        
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
    
    function ds = getDerivative(s, ~)
        if s.entirePotential
        end
                
        pfv = s.primeFunctions;
        dfv = cell(size(pfv));
        dfv(:) = cellfun(@diff, pfv(:), 'uniformOutput', false);
        
        function dv = deval(z)
            dv = complex(zeros(size(z)));
            
            mv = s.strength;
            for k = 1:numel(mv)
                dv = dv + mv(k)/2/pi ...
                    *(dfv{k,1}(z)./pfv{k,1}(z) + dfv{k,2}(z)./pfv{k,2}(z));
            end
        end
        
        ds = @deval;
    end
    
    function s = setupPotential(s, W)
        D = W.unitDomain;
        av = s.location;
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
