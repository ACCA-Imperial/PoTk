classdef potentialDerivative < PoTk.evaluable
%potentialDerivative is a derivative of the potential.
%
%  W = potential(D, ...)
%  dW = diff(W)
%    Create the derivative of the potential object; this indirectly calls
%    the potentialDerivative constructor.

%The potentialDerivative constructor may be called directly, and has the
%same argument signature as potential, but potentialDerivative assumes the
%potentialKind objects have already been "blessed" by the potential
%constructor.
%  
%See also potential, potentialKind.

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
    domain
    order
    
    derivativeFunctions
    kindNames
end

methods
    function dW = potentialDerivative(domain, potentialKinds)
        if ~nargin
            return
        end
        
        if ~isa(domain, 'potentialDomain')
            error(PoTk.ErrorIdString.RuntimeError, ...
                'No valid potential domain detected in first argument.')
        end
        dW.domain = domain;
        
        if ~all(cellfun(@(x) isa(x, 'potentialKind'), potentialKinds))
            error(PoTk.ErrorIdString.RuntimeError, ...
                'Second argument must be cell array of "potentialKind".')
        end

        N = numel(potentialKinds);
        df = cell(1, N);
        names = cell(size(df));
        for i = 1:N
            df{i} = getDerivative(potentialKinds{i}, domain);
            names{i} = class(potentialKinds{i});
        end
        dW.derivativeFunctions = df;
        dW.kindNames = names;
    end
    
    function disp(dW)
        %override disp() builtin.
        
        D = dW.domain;
        if isa(D, 'planeDomain')
            connstr = 'an entire';
        elseif D.m == 0
            connstr = 'a simply connected';
        else
            connstr = sprintf('a %d-connected', D.m+1);
        end
        
        poloc = strsplit(fileparts(which('potential')), filesep);
        poloc = poloc{end-1};
        fprintf(['  <a href="matlab:helpPopup %s/potentialDerivative">' ...
            'potential</a> is the derivative of a complex potential on ' ...
            '%s domain\n'], poloc, connstr)
        
        names = dW.kindNames;
        if ~isempty(names)
            fprintf('\n  contributions to the potential are of kind\n')
            for i = 1:numel(names)
                fprintf('    <a href="matlab:helpPopup %s/%s">%s</a>\n', ...
                    poloc, names{i}, names{i})
            end
        end
        
        fprintf('\n')
    end
    
    function val = feval(dW, z)
        %provide function evaluation.
        
        val = complex(zeros(size(z)));
        if isempty(dW.domain)
            val = nan*val;
            return
        end
        
        df = dW.derivativeFunctions;
        for i = 1:numel(df)
            val = val + df{i}(z);
        end
    end
end

end
