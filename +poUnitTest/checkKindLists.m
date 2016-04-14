classdef checkKindLists < matlab.unittest.TestCase
%checkKindLists verifies kind lister runs.

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

methods(Test)
    function givesKinds(test)
        import matlab.unittest.constraints.EveryCellOf
        import matlab.unittest.constraints.IsInstanceOf
        s = listKinds();
        test.verifyThat(EveryCellOf(s), IsInstanceOf('char'))
    end
end

end
