function [r, c] = itorc(ind, N, symmetric)
if symmetric
    % index into diagonal matrix
    P = N*(N+1)/2;
    r = 1 + round(N - sqrt((P-ind+1)*2));
    c = ind - sum(N - (0:(r-2)));
else
    r = floor((ind-1) / N) + 1;
    c = ind - (N * (r-1));
end
end