classdef FiniteDifference < poUnitTest.ReferenceFunction
%poUnitTest.FiniteDifference is a reference function for testing
%derivatives.

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
    deltaH = 1e-6
end

methods
    function ref = FiniteDifference(fHandle)
        if nargin
            sargs = {fHandle};
        else
            sargs = {};
        end
        ref = ref@poUnitTest.ReferenceFunction(sargs{:});
        ref.tolerance = ref.deltaH;
    end
    
    function v = feval(ref, z)
        h = ref.deltaH;
        fun = ref.functionHandle;
        v = (fun(z + h) - fun(z))/h;
    end
end

end
