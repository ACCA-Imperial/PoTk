classdef(Abstract) Expressions
%Expressions is a static class for stored analytic expressions.

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

methods(Static)
    function os = declarePrimeFunction()
        os = 'Let w(zeta, a) be the Schottky-Klein prime function.\n';
    end
    
    function os = declareGreens0()
        os = [...
'                                  /       w(zeta, a)       \\\n', ...
'                          1       | ---------------------- |\n', ...
'G_0(zeta, a, conj(a)) = ------ log|      /          1    \\ |\n', ...
'                        2 i pi    | |a| w| zeta, ------- | |\n', ...
'                                  \\      \\       conj(a) / /\n', ...
            ];
    end
end

end
