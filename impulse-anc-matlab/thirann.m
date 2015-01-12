function [ B A ] = thirann( N, D )
%THIRANN Designs an N order D delay Thiran allpass filter.
%   N specifies the filter's order, D is the total delay of
%   the filter. D must be greater than N-1.

    %Checking input parameter for filter stability
    if D <= N-1
        error('The delay must be greater than N-1');
    end
    
    %Calculating filter coefficients
    A = zeros(1,N+1);
    for k=0:N
        product = 1;
        for n = 0:N
            product = product * (D - N + n)/(D - N + k + n);
        end
        A(k+1) = (-1)^k*nchoosek(N,k)*product;
    end

    B = fliplr(A);

end
