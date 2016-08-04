function r = boundaryPartMake(domain, f0, f1)
%boundaryPartMake makes a function to evaluate points on the boundary from
%a list of functions.
%
% r = boundaryPartMake(domain, f0, f1, ..., fm)
% Takes a list of functions and returns a function r which is restricted to
% the boundary. The function r gives f0 values for points on C0, f1 values
% for points on C1, etc., up to fm values for points on Cm.

% Everett Kropf, 2016

if ~isa(domain, 'skpDomain')
    error('First argument must be an "skpDomain" object.')
end

m = domain.m;
if nargin - 1 ~= m + 1
    error('Number of functions given must match the number of boundaries.')
end
% if ~all(cellfun(@(x) isa(x, 'function_handle'), varargin))
%     error('Expected a list of function handles following the domain.')
% end

function v = reval(z)
    v = nan(size(z));
    [~, onj] = ison(domain, z);
    v(onj==0)=f0(z(onj==0));
    for j = 1:m
        ix = onj == j;
        v(ix) = f1(z(ix));
    end
end

r = @reval;

end
