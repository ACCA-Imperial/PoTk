classdef(Abstract) Evaluable
%Evaluable provides function like evaluation protocol.
%
%Subclasses of this abstract class must implement a "function evaluation"
%method with the signature
%  v = feval(obj, z)
%
%See also subsref.

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

methods(Abstract)
    v = feval(obj, z)
end

methods(Hidden)
    function out = subsref(obj, S)
        % Provide function-like behaviour.
        %
        %   obj = classInstance(...);
        %   v = obj(z);
        
        if numel(S) == 1 && strcmp(S.type, '()')
            out = feval(obj, S.subs{:});
        else
            out = builtin('subsref', obj, S);
        end
    end
end

end
