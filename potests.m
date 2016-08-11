function result = potests(subset, selector)
%POTESTS runs validation tests for PoTk.
%
% potests
% potests all
%   Runs all the available tests in the test suite.
%
% potests <string>
%   Runs a subset of the tests in the suite specified by <string>. For
%   example,
%
%     potests Circulation*
%
%   runs only the circulation tests. See the documentation for the
%   TestSuite class for valid strings.
%
% See also: matlab.unittest.

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

import matlab.unittest.TestRunner
import matlab.unittest.TestSuite
import matlab.unittest.selectors.HasParameter

runner = TestRunner.withTextOutput('Verbosity', 2);

suiteArgs = {};
if nargin > 0
    switch subset
        case 'all'
            % This is the default.
            
        otherwise
            suiteArgs = {'Name', ['UnitTest.', subset]};
    end
end

if nargin > 1
    s = HasParameter('Property', 'domain', 'Name', selector);
    suiteArgs = [{s}, suiteArgs];
end

tests = TestSuite.fromPackage('UnitTest', suiteArgs{:});

result = run(runner, tests);

fprintf('\nTest run summary:\n\n')
disp(table(result))

if ~nargout
    clear result
end
