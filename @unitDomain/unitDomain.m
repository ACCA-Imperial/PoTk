classdef unitDomain < potentialDomain
%unitDomain is the domain bounded by the unit disk.
%
%  D = unitDomain(dv, qv, beta)
%    Constructs an object representing the (punctured) unit disk. The
%    vectors dv and qv represent boundary circles bounded by the unit
%    circle. The point beta represents the image of infinity from some
%    conforamlly equivalent domain to the (punctured) unit disk.
%
%See also potentialDomain.

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
    centers             % Circle centers vector.
    radii               % Circle radii vector.
end

properties(Dependent)
    dv                  % Alias to centers.
    qv                  % Alias to radii.
    m                   % Shortcut for numel(centers).
end

methods
    function D = unitDomain(dv, qv, beta)
        if ~nargin
            return
        end
        
        if isa(dv, 'unitDomain')
            D = dv;
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
    end
    
    function C = circleRegion(D)
        %Convert unitDomain to CMT circleRegion.
        %Requires the conformal mapping toolkit (CMT) be installed.
        
        try
            C = circleRegion([0; D.dv(:)], [1; D.qv(:)]);
        catch err
            if strcmp(err.identifier, 'MATLAB:UndefinedFunction')
                PoTk.ErrorRequiresCMT()
            else
                rethrow(err)
            end
        end
    end
    
    function tf = isin(D, z)
        % Check point z is in domain.
        %   tf = isin(D, z)
        
        % Assume z is not scalar.
        if any(abs(z(:)) > 1 + eps(2))
            tf = false;
            return
        end
        
        m = numel(D.dv);
        for j = 1:m
            if any(abs(z(:) - D.dv(j)) <= D.qv(j) - eps(2))
                tf = false;
                return
            end
        end
        
        tf = true;
    end
    
    function h = plot(D, varargin)
        %Use the CMT to plot the domain.
        %Requires the conformal mapping toolkit (CMT) be installed.
        
        C = circleRegion(D);
        h = plot(C, varargin{:});
        
        if ~nargout
            clear h
        end
    end
    
    function D = skpDomain(D)
        %Convert a unitDomain to an skpDomain object.
        D = skpDomain(D.dv, D.qv);
    end
end

methods(Static)
    function checkUnitDomain(dv, qv)
        %Check that all circles are within the unit circle, and that there
        %are no circle intersections.
        
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

methods % Setting and getting.
    function dv = get.dv(D)
        dv = D.centers;
    end
    
    function qv = get.qv(D)
        qv = D.radii;
    end
    
    function m = get.m(D)
        m = numel(D.centers);
    end
end

end
