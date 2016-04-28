function pog = potool(adomain)
%potool launches the PoTk interactive tool.
%
% potool
% potool(adomain)
% Launches the PoTk tool. A unit domain can optionally be given, which will
% be reflected through the unit circle and then treated as an external
% physical domain.

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

if nargin
    pog = PoG.mainWin('run', adomain);
else
    pog = PoG.mainWin('run');
end

if ~nargout
    clear pog
end
