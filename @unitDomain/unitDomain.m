classdef unitDomain
%unitDomain is the domain bounded by the unit disk.

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
    centers
    radii
    infImage
    conformalMaps
end

properties(Dependent)
    dv
    qv
end

methods
    function D = unitDomain(dv, qv, beta, maps)
        if ~nargin
            return
        end
        
        D.checkUnitDomain(dv, qv)
        D.centers = dv;
        D.radii = qv;
        
        if nargin > 2
            if numel(beta) ~= 1
                error(PoTk.ErrorIdString.InvalidArgument, ...
                    'Argument beta must be a scalar value.')
            end
            if ~isin(D, beta)
                error(PoTk.ErrorIdString.InvalidArgument, ...
                    'Point beta must be in the bounded domain.')
            end
            D.infImage = beta;        
        end
        
        if nargin > 3
            % Is this going to get used?
            D.conformalMaps = maps;
        end
    end
    
    function C = circleRegion(D)
        try
            C = circleRegion([0; D.dv(:)], [1; D.qv(:)]);
        catch err
            if strcmp(err.identifier, 'MATLAB:UndefinedFunction')
                error(PoTk.ErrorIdString.RuntimeError, ...
                    ['This functionality requires the conformal mapping ' ...
                    'toolkit (CMT).\nIf it is installed, check that its ' ...
                    'directory is on the search path.'])
            else
                rethrow(err)
            end
        end
    end
    
    function tf = isin(D, z)
        % Check point z is in domain.
        %   tf = isin(D, z)
        
        % Assume z is not scalar.
        if any(abs(z(:)) >= 1)
            tf = false;
            return
        end
        
        m = numel(D.dv);
        for j = 1:m
            if any(abs(z(:) - D.dv(j)) < D.qv(j))
                tf = false;
                return
            end
        end
        
        tf = true;
    end
    
    function h = plot(D, varargin)
        C = circleRegion(D);
        h = plot(C, varargin{:});
        
        if ~nargout
            clear h
        end
    end
    
    function D = skpDomain(D)
        D = skpDomain(D.dv, D.qv);
    end
end

methods % Setting and getting.
    function dv = get.dv(D)
        dv = D.centers;
    end
    
    function qv = get.qv(D)
        qv = D.radii;
    end
end

methods(Static)
    function checkUnitDomain(dv, qv)
        m = numel(dv);
        s1 = abs(bsxfun(@minus, dv, dv.')) + diag(inf(m, 1)) ...
            - bsxfun(@plus, qv, qv');
        s2 = abs(dv) + qv;
        if any(s1(:) <= 0) || any(s2(:) >= 1)
            error(PoTk.ErrorIdString.RuntimeError, ...
                'Circle intersection detected.')
        end
    end
end

end
