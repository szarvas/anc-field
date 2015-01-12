function [integral_delay, b, a] = FdFilterDesign(delay)
    % FdFilterDesign designs a Thiran fractional delay filter and
    %   calculates an additional integral delay value. The total
    %   delay of the applied filter and the integral delay equals
    %   to the given parameter.
    %
    %   Use isempty(b) to determine whether FD filtering is
    %   required.
    
    % Target filter order
    filter_order = 3;
    
    % Decreasing filter order if target cannot be met
    % The Thiran filter must have an order of at most
    % N < D+1
    while delay <= filter_order - 1
        filter_order = filter_order - 1;
    end
    
    % If delay is an integer no FDfilter is required
    if abs(round(delay) - delay) < eps
        integral_delay = round(delay);
        b = [];
        a = [];
    % else designing an optimal FDfilter having a delay of
    % N-1 < delay < N+1
    else
        integral_delay = floor(delay) - filter_order;
        if integral_delay < 0
            integral_delay = 0;
        end
        fractional_delay = delay - integral_delay;
        [b a] = thirann(filter_order, fractional_delay);
    end
end