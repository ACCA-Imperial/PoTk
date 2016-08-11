classdef betaParameter
%poUnitTest.betaParameter represents possible locations for the beta
%parameter in unit tests.

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

enumeration
    origin
    inside
    circle0
end

methods
    function s = label(obj)
        s = lower(char(obj));
    end
end

methods(Static)
    function c = default
        [m, s] = enumeration('poUnitTest.betaParameter');
        c = cell2struct(num2cell(m), s);
    end
end

end
