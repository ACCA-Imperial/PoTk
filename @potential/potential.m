classdef potential
%potential is the complex potential.

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
    theDomain
    
    potentialFunctions
end

methods
    function W = potential(D, varargin)
        if ~nargin
            return
        end
        
        if ~isa(D, 'unitDomain')
            error(PoTk.ErrorTypeString.InvalidArgument, ...
                'Domain must be a "unitDomain" object.')
        end
        W.theDomain = D;
        
        for i = 1:numel(varargin)
            % FIXME: Check argument is a 'potentialKind'.
            W.potentialFunctions{end+1} = varargin{i}.setupPotential(W);
        end
    end
    
    function val = feval(D, z)
        if isempty(D.theDomain)
            val = nan(size(z));
            return
        end
        
        val = complex(zeros(size(z)));
        pf = D.potentialFunctions;
        for i = 1:numel(pf)
            val = val + pf{i}.evalPotential(z);
        end
    end
    
    function out = subsref(W, S)
        % Provide function-like behaviour.
        
        if numel(S) == 1 && strcmp(S.type, '()')
            out = feval(W, S.subs{:});
        else
            out = builtin('subsref', W, S);
        end
    end
end

end
