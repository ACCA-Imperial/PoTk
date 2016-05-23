classdef(Abstract) Expressable
%Expressable is the analytic expression protocol.

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

methods(Hidden)
    function printAnalyticExpression(~)
        fprintf('  No expression defined.\n')
    end
end

properties(Hidden, Constant)
    doubleSepLine = ...
        '==========================================================='
    singleSepLine = ...
        '-----------------------------------------------------------'
end

methods(Static)
    function count = fprintDoubleSeparator(fh)
        if ~nargin
            fh = 1;
        end
        count = fprintf(fh, '%s\n', PoTk.Expressable.doubleSepLine);
        if ~nargout
            clear count
        end
    end
    
    function count = fprintSingleSeparator(fh)
        if ~nargin
            fh = 1;
        end
        count = fprintf(fh, '%s\n', PoTk.Expressable.singleSepLine);
        if ~nargout
            clear count
        end
    end
end

end
