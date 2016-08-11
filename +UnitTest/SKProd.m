function wf = SKProd(dv, qv, L)
%UnitTest.SKPROD is the product formula for the S-K prime function.
%
%   wf = skprod(dv, qv);
%   w = wf(z, alpha);
% 
% This function computes a truncated half Schottky group necessary
% to calculate the truncated product formula for the Schottky-Klein
% prime function. It returns a function handle which evaluates the prime
% function.
%
% -----
% Input:
%   dv = a vector of circle centers.
%   qv = a vector of circle radii.
%   L = (optional) truncation level of the product formula (default L=4).
%
% Output:
%   wf = a function handle to the prime function with signature
%     w = wf(z, alpha),
%   where z is an array of points at which to evaluate the function, and
%   alpha is a scalar parameter value.
%
% The "hat" version of the product formula, where the zero and pole have
% been factored out, may be accessed via
%    w_hat = wf(z, alpha, 'hat').
%
% -------
% Example:
% 
%   >> dv = [0.5, 0.5i];
%   >> qv = [0.1, 0.1];
%   >> wf = skprod(dv, qv, 6);
%   >> w = wf(-0.5-0.5i, 1);
%   >> w^2
%
%   ans =
%   
%              2.39754812001042 +      1.76164377385124i
%
% This value may be checked against
%   D. G. Crowdy and J. S. Marshall, "Computing the Schottky-Klein prime
%   function on the Schottky double of planar domains," CMFT 7 (2007) no.
%   1, 293-308.
%
% The prime function is documented in
%   H. Baker, Abelian Functions and the Allied Theory of Theta Functions,
%   Cambridge University Press, Cambridge, 1897, 1995.

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

if nargin < 3
    lmax = 4;
else
    lmax = L;
end

if numel(dv) ~= numel(qv)
    error('It is expected the numbers of centers and radii be equal.')
end

%Group generators.
m = numel(dv);
ngen = 2*m;
gens = cell(ngen, 1);
for j = 1:m
    th = [qv(j)^2 - abs(dv(j))^2, dv(j); -conj(dv(j)), 1]/qv(j);
    gens{j} = th;
    gens{j+m} = [th(4), -th(3); -th(2), th(1)];
end

% Group setup.
nhg = (ngen*(ngen - 1).^(0:lmax-1))/2;
grp = cell(sum(nhg), 1);
glvl = [0, cumsum(nhg(1:end-1))];

% Permutation-y matrix
perm = zeros(ngen, ngen-1);
for n = 1:ngen
    perm(n,:) = find(1:ngen ~= mod(n + ngen/2 - 1, ngen) + 1);
end

% Prep for search.
word = ones(1, lmax);
nptr = ones(1, lmax);
node = cell(lmax, 1);
lastg = zeros(1, lmax);

recur = @(f,varargin) f(f, varargin{:});
cmp = @(x,y) recur(@(f,x,y) ...
    x(1) < y(1) || x(1) == y(1) && f(f, x(2:end), y(2:end)), x, y);

function nfill(word)
    wlvl = numel(word);
    if wlvl > 1 && isempty(node{wlvl-1})
        nfill(word(1:end-1));
    end
    node{wlvl} = node{wlvl-1}*gens{word(wlvl)};
end

% Depth first search.
lvl = 0;
while true
    % Next deeper.
    lvl = lvl + 1;
    if lvl > 1
        word(lvl) = perm(word(lvl - 1), nptr(lvl));
        % Is inverse already in group?
        if lastg(lvl) > 0
            winv = mod(word(lvl:-1:1) + ngen/2 - 1, ngen) + 1;
            wchk = cmp(word, winv);
        else
            wchk = true;
        end
        if wchk
            lastg(lvl) = lastg(lvl) + 1;
            if isempty(node{lvl})
                nfill(word(1:lvl));
            end
            grp{glvl(lvl)+lastg(lvl)} = node{lvl};
        end
    else
        word(1) = nptr(1);
        node{1} = gens{word(1)};
        if word(1) <= ngen/2
            lastg(1) = lastg(1) + 1;
            grp{lastg(1)} = node{1};
        end
    end
    if lvl < lmax
        continue
    end
    
    while lvl > 0
        % Go back!
        node{lvl} = [];
        lvl = lvl - 1;
        
        % Try to turn.
        if nptr(lvl+1) < ngen - (lvl > 0)
            % Can turn.
            nptr(lvl+1) = nptr(lvl+1) + 1;
            break
        else
            % Can't turn.
            nptr(lvl+1) = 1;
        end
    end
    
    if (lvl == 0 && nptr(1) == 1) || all(lastg == nhg)
        break
    end
end

% Evaluate.
function w = skeval(z, alpha, hat)
    if numel(alpha) ~= 1
        error('The parameter alpha must be a scalar.')
    end
    
    if nargin > 2 && strcmp(hat, 'hat')
        dohat = true;
    else
        dohat = false;
    end
    
    if isa(z, 'double')
        islarge = abs(z) > 2^1000;
    elseif isa(z, 'single')
        islarge = abs(z) > 2^120;
    else
        error('Argument z must be single or double precision.')
    end
    atinf = isinf(z);
    
    if ~isinf(alpha) && ~dohat
        w = z - alpha;
    else
        w = complex(ones(size(z)));
    end
    
    function fprod(th)
        thjz = (th(1)*z + th(3))./(th(2)*z + th(4));
        if ~isinf(alpha)
            thja = (th(1)*alpha + th(3))./(th(2)*alpha + th(4));
            w = w.*(thjz - alpha).*(thja - z)...
                ./(thjz - z)/(thja - alpha);
        else
            w = w.*(th(1)/th(2) - z)./(thjz - z);
        end
    end
    cellfun(@fprod, grp)
    
    if ~isinf(alpha)
        w(atinf) = inf;
        % Normalize failed large number input.
        w(islarge & isnan(w)) = inf;
    else
        % No pole.
        w(atinf) = 1;
        w(islarge & isnan(w)) = 1;
    end
end

wf = @skeval;

end
