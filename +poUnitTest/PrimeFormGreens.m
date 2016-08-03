function gj = PrimeFormGreens(pf, j, domainTestObject)
%poUnitTest.PrimeFormGreens generates the Green's function wrt Cj.

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

type = domainTestObject.type;
D = domainTestObject.domainObject.skpDomain;
if j > 0
    if type == poUnitTest.domainType.Simple
        error(PoTk.ErrorIdString.RuntimeError, ...
            'In a simply connected domain j>0 makes no sense.')
    end
    thj = @(z) D.theta(j, z);
else
    thj = @(z) z;
end

function v = g0eval(z, a)
    switch type
        case poUnitTest.domainType.Simple
            v = log(z - a)/2i/pi;
            if a ~= 0
                v = v - log((z - 1/conj(a))*abs(a))/2i/pi;
            end

        otherwise
            v = log(pf(z, a)./pf(z, 1/conj(a)))/2i/pi;
            if a ~= 0
                v = v - log(abs(a))/2i/pi;
            end
    end
end

if j == 0    
    gj = @g0eval;
else
    dj = D.dv(j);
    qj = D.qv(j);
    gj = @(z,a) log(pf(z, a)./pf(z, thj(1/conj(a))) ...
        *qj/abs(a - dj))/2i/pi;
end

end
