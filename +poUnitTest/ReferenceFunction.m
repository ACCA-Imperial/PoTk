classdef ReferenceFunction < PoTk.Evaluable
%poUniTest.ReferenceFunction describes the protocol and provides the basic
%implementation of a reference function.

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
end

properties(Access=private)
    tolerance_
end

properties(Dependent)
    tolerance
end

methods % setting & getting
    function ref = set.tolerance(ref, tol)
        % FIXME: Actually validate this.
        ref.tolerance_ = tol;
    end
    
    function tol = get.tolerance(ref)
        tol = ref.tolerance_;
    end
end

methods
    function ref = ReferenceFunction(fHandle)
        if ~nargin
            return
        end
        
        if ~isa(fHandle, 'function_handle')
            error(PoTk.ErrorIdString.InvalidArgument, ...
                'Expected a function handle.')
        end
        ref.functionHandle = fHandle;
    end
    
    function v = feval(ref, z)
        %Satisfies PoTk.Evaluable.
        
        v = ref.functionHandle(z);
    end
end

end
