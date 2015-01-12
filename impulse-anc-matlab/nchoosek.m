function res = nchoosek(n,k)
%NCHOOSEK binomial function
%   B = NCHOOSEK(N,K) returns the binomial function's value 
%   corresponding to N and K.

    if k > n
        res = 0;
    else
        res = factorial(n)/(factorial(k)*factorial(n-k));
    end
end