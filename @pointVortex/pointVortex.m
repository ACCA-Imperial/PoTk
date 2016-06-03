classdef pointVortex < pointSingularity
%pointVortex represents a point vortex.
%
%  pv = pointVortex(location, strength)
%    Constructs a pointVortex object where location is a vector of points
%    located in a potential domain. The vector strength is a vector of
%    scalars the same size as the location vector indicating the strength
%    of each point vortex. If there are any boundaries in the domain, the
%    point vortices create a net circulation which is assigned to the
%    boundary with the zero index. In the unit domain this means the net
%    circulation is assigned to the bounding unit circle.
%
%See also potential, unitDomain, pointVortexNoNet.

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
    greensFunctions
end

methods
    function pv = pointVortex(location, strength)
        if ~nargin
            return
        end
        
        if ~isequal(size(location(:)), size(strength(:)))
            error(PoTk.ErrorIdString.InvalidArgument, ...
                'Location and strength vectors must be same size.')
        end
        pv.location = location;
        
        if any(imag(strength(:)) ~= 0)
            error(PoTk.ErrorIdString.InvalidArgument, ...
                'Strength values must be all real.')
        end
        pv.strength = strength;
    end
end

methods(Hidden) % Computation
    function val = evalPotential(pv, z)
        if pv.entirePotential
            N = numel(pv.location);
            val = reshape(sum(...
                arrayfun(@(k) log(z(:) - pv.location(k)), 1:N), 2), ...
                size(z))/2i/pi;
            return
        end
        
        val = complex(zeros(size(z)));
        g0v = pv.greensFunctions;
        s = pv.strength;
        
        for k = find(s(:) ~= 0)'
            val = val + s(k)*g0v{k}(z);
        end
    end
    
    function dpv = getDerivative(pv)
        if pv.entirePotential
            dpv = getDerivativeEntireDomain(pv);
            return
        end
        
        g0v = pv.greensFunctions;
        dg0v = cell(size(g0v));
        for k = find(pv.strength(:)' ~= 0)
            dg0v{k} = diff(g0v{k});
        end
        
        function v = dEval(z)
            v = 0;
            sv = pv.strength;
            for i = find(sv(:)' ~= 0)
                v = v + sv(i)*dg0v{i}(z);
            end
        end
        
        dpv = @dEval;
    end
    
    function dpv = getDerivativeEntireDomain(pv)
        N = numel(pv.location);
        dpv = @(z) reshape(sum(...
            arrayfun(@(k) 1./(z(:) - pv.location(k)), 1:N), 2), ...
            size(z))/2i/pi;
    end
    
    function pv = setupPotential(pv, W)
        g0v = cell(1, numel(pv.location));        
        for k = find(pv.strength(:) ~= 0)'
            g0v{k} = greensC0(pv.location(k), skpDomain(W.unitDomain));
        end
        pv.greensFunctions = g0v;
    end
end

methods(Hidden) % Documentation
    function terms = docTerms(pv)
            terms = {'pointVortex'};
        if pv.entirePotential
            return
        end
        terms = ['skprime', 'greensC0', terms];
    end
    
    function str = latexExpression(pv)
        if pv.entirePotential
            if numel(pv.location) == 1
                str = [...
                    '\frac{\gamma}{2\pi\mathrm{i}} \log\left( ', ...
                    '\zeta - \alpha \right)'];
            else
                str = [...
                    '\frac{1}{2\pi\mathrm{i}} \sum_{k=1}^N \gamma_k ', ...
                    '\log\left( \zeta - \alpha_k \right)'];
            end
            return
        end
        
        if numel(pv.location) == 1
            str = [...
                '\gamma G_0(\zeta,\alpha,\overline{\alpha}) ', ...
                '\qquad\mathrm{(point\;vortex)}'];
        else
            str = [...
                '\sum_{k=1}^N \gamma_k ', ...
                'G_0(\zeta,\alpha_k,\overline{\alpha_k}) ', ...
                '\qquad \mathrm{(point\; vortices)}'];
        end
    end
    
    function pointVortexTermLatexToDoc(pv, do)
        if numel(pv.location) == 1
            do.addln(...
                ['the point vortex located by ', ...
                do.eqInline('\alpha'), ' with vortex strength ', ...
                do.eqInline('\gamma')]);
        else
            do.addln(...
                ['the point vortex locations by ', ...
                do.eqInline('\alpha_k'), ' with strengths ', ...
                do.eqInline('\gamma_k')])
        end
    end
end

methods(Access=protected)
    function bool = getOkForPlane(~)
        bool = true;
    end
end

end
