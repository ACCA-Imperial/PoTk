%% Check P-function and constant.
clear


%%

q = 0.1;
a = -0.6;

w = skprime(a, 0, q);
[P, C] = poUnitTest.PFunction(q);
C = -1/C^2;

zp = [-0.017493+0.4828i
    0.45131+0.2309i
    0.41633-0.4828i
    -0.43732-0.43382i];

err = w(zp) - a*C*P(zp/a);
disp(err)
