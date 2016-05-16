classdef unboundedCircles < potentialDomain
%unboundedCircles is a potential domain.
%
%  D = unboundedCircles(sv, rv)
%  Creates an unbounded circle domain described by the vector of centers sv
%  and the vector of radii rv.
%
%Requires the Conformal Mapping Toolkit.
%
%See also potentialDomain, unitDomain.

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

properties(Dependent)
    centers
    radii
    m
end

properties(SetAccess=protected,Hidden)
    circleRegionObject
    
    unitDomainObject
end

methods
    function D = unboundedCircles(sv, rv)
        if ~nargin
            D.circleRegionObject = circleRegion();
            return
        end
        
        % FIXME: validate input.
        try
            C = circleRegion(sv, rv);
        catch err
            if strcmp(err.identifier, 'MATLAB:UndefinedFunction')
                PoTk.ErrorRequiresCMT()
            else
                rethrow(err)
            end
        end
        
        D.circleRegionObject = C;
        
        % Construct unit domain.
        zeta = mobius(0, rv(1), 1, -sv(1));
        D.mapToUnitDomain = zeta;
        D.mapToUnitDomainDeriv = @(z) -rv(1)./(z - sv(1)).^2;
        D.mapFromUnitDomain = inv(zeta);
        D.mapFromUnitDomainDeriv = @(z) -rv(1)./z.^2;
        D.dipoleMultiplier = rv(1);

        Du = zeta(C);
        D.unitDomainObject = unitDomain(...
            Du.centers(2:end), Du.radii(2:end), pole(inv(zeta)));
    end
    
    function C = circleRegion(D)
        %Convert to CMT circleRegion.
        
        C = D.circleRegionObject;
    end
    
    function zg = meshgrid(D, resolution, scale)
        %Rectangular grid of points for domain at resolution.
        %
        %  zg = meshgrid(D)
        %  zg = meshgrid(D, resolution)
        %  zg = meshgrid(D, resolution, scale)
        
        if nargin < 2 || isempty(resolution)
            resolution = 200;
        end
        if nargin < 3
            scale = 1.2;
        end
        
        sv = D.centers;
        rv = D.radii;
        ax = plotbox(D, scale);
        [X, Y] = meshgrid(linspace(ax(1), ax(2), resolution), ...
            linspace(ax(3), ax(4), resolution));
        zg = complex(X, Y);
        for j = 1:numel(sv)
            zg(abs(zg - sv(j)) <= rv(j) + eps(max(abs(sv)))) = nan;
        end
    end
    
    function h = numberBoundaries(D)
        %Place boundary numbers at circle centers.
        
        dv = D.centers;
        h = (1:D.m+1)';
        for j = h'
            h(j) = text(real(dv(j)), imag(dv(j)), num2str(j-1));
        end
        
        if ~nargout
            clear h
        end
    end
    
    function h = plot(D, varargin)
        %Plot unbounded circle domain.
        
        h = plot(D.circleRegionObject, varargin{:});
        
        if ~nargout
            clear h
        end
    end
    
    function ax = plotbox(D, scale)
        %Get plot box dimensions at scale.
        %
        %  ax = plotbox(D)
        %  ax = plotbox(D, scale)
        %  Scale default is 1.2.
        
        if nargin < 2
            scale = 1.2;
        end
        
        ax = plotbox(D.circleRegionObject, scale);
    end
    
    function D = unitDomain(D)
        %Convert to unitDomain.
        
        D = D.unitDomainObject;
    end
end

methods %Setting and getting
    function sv = get.centers(D)
        sv = D.circleRegionObject.centers;
    end
    
    function rv = get.radii(D)
        rv = D.circleRegionObject.radii;
    end
    
    function m = get.m(D)
        m = numel(D.centers) - 1;
    end
end

end
