classdef potential < PoTk.Evaluable
%POTENTIAL is the complex potential.
%
%  W = potential(D, varargin)
%    Constructs the potential object given a potential domain object D and
%    zero or more potentialKind objects.
%
%Once constructed, the potential at points z in the potential domain
%may be evaluated by the syntax
%
%  val = W(z)
%
%See also potentialDomain, unitDomain, unboundedCircles, potentialKind,
%listKinds.

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
    domain                          % A potentialDomain object.
    
    potentialKinds                  % Cell array of potential contributions
end

methods
    function W = potential(D, varargin)
        if ~nargin
            W.domain = planeDomain;
            return
        end
        
        if ~isa(D, 'potentialDomain')
            error(PoTk.ErrorIdString.InvalidArgument, ...
                'First argument must be a ''potentialDomain'' object.')
        end
        W.domain = D;
        isPlane = isa(D, 'planeDomain');
        
        for i = 1:numel(varargin)
            if ~isa(varargin{i}, 'potentialKind')
                error(PoTk.ErrorIdString.InvalidArgument, ...
                    ['Expected a "potentialKind" object as argument in ' ...
                    'position %d.\nRecieved a "%s" instead.'], ...
                    i+1, class(varargin{i}))
            end
            
            pk = varargin{i};
            if ~isPlane
                pk = pk.setupPotential(W);
            else
                assert(pk.okForPlane, ...
                    PoTk.ErrorIdString.InvalidArgument, ...
                    ['Potential contribution "%s" makes no sense in ', ...
                    'the entire plane.'], class(pk))
                pk.entirePotential = true;
            end
            W.potentialKinds{end+1} = pk;
        end
    end
    
    function analytic(W)
        %analytic(W)
        
        PoTk.Expressable.fprintDoubleSeparator()
        fprintf('Analytic expressions for potential contributions.\n')
        
        pk = W.potentialKinds;
        for i = 1:numel(pk)
            PoTk.Expressable.fprintSingleSeparator()
            fprintf('Kind: %s\n\n', class(pk{i}))
            if ~isa(pk{i}, 'PoTk.Expressable')
                fprintf('  No expression given.\n')
                continue
            end
            
            printAnalyticExpression(pk{i})
        end
        
        PoTk.Expressable.fprintDoubleSeparator()
    end

    function dW = diff(W)
        %First order variable derivative of potential.
        %
        %  dW = DIFF(W)
        %  dval = dW(z)
        %  Where dW is a function handle which computes the derivative of
        %  the potential W at points z in the domain.
        
        dW = potentialDerivative(W.domain, W.potentialKinds);
    end
    
    function disp(W)
        %override disp() builtin.
        
        D = W.domain;
        if isa(D, 'planeDomain')
            connstr = 'an entire';
        elseif D.m == 0
            connstr = 'a simply connected';
        else
            connstr = sprintf('a %d-connected', D.m+1);
        end
        
        poloc = strsplit(fileparts(which('potential')), filesep);
        poloc = poloc{end-1};
        fprintf(['  <a href="matlab:helpPopup %s/potential">' ...
            'potential</a> is a complex potential on %s domain\n'], ...
            poloc, connstr)
        
        pk = W.potentialKinds;
        if ~isempty(pk)
            fprintf('\n  contributions to the potential are of kind\n')
            for i = 1:numel(pk)
                pname = class(pk{i});
                fprintf('    <a href="matlab:helpPopup %s/%s">%s</a>\n', ...
                    poloc, pname, pname)
            end
        end
        
        fprintf('\n')
    end
    
    function val = feval(D, z)
        %Evaluate the potential at a point z.
        %  val = feval(D, z)
        
        pk = D.potentialKinds;
        val = complex(zeros(size(z)));
        if isempty(pk)
            return
        end
        
        for i = 1:numel(pk)
            val = val + pk{i}.evalPotential(z);
        end
    end
    
    function D = unitDomain(W)
        %Access unit domain.
        %
        %  D = unitDomain(W);
        
        D = unitDomain(W.domain);
    end
end

end
