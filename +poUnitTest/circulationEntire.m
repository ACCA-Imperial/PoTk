classdef circulationEntire < poUnitTest.entireTests
%poUnitTest.circulationEntire checks the circulation potentials fail in the
%plane domain.

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
    function circulationFails(test)
        D = test.domain;
        C = circulation(1, 2);
        test.verifyError(...
            @() potential(D, C), ...
            PoTk.ErrorIdString.InvalidArgument)
    end
    
    function circulationNoNetFails(test)
        D = test.domain;
        C = circulationNoNet(1, 2);
        test.verifyError(...
            @() potential(D, C), ...
            PoTk.ErrorIdString.InvalidArgument)
    end
end

end