classdef(Abstract) ReferenceFunction < PoTk.Evaluable
%poUniTest.ReferenceFunction describes the protocol for a reference
%function.

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

properties
    functionHandle
    tolerance
end

methods
    function ref = ReferenceFunction(fHandle, tol)
        if ~nargin
            return
        end
        
        if ~isa(fHandle, 'function_handle')
            error(PoTk.ErrorIdString.InvalidArgument, ...
                'Expected a function handle.')
        end
        ref.functionHandle = fHandle;
        
        % FIXME: Validate tolerance.
        if nargin > 1
            ref.tolerance = tol;
        end
    end
    
    function v = feval(ref, z)
        %Satisfies PoTk.Evaluable.
        
        v = ref.functionHandle(z);
    end
end

end
