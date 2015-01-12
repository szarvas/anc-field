function [W, error] = lms(input, output, n, pass, amu)
input = input(:);
output = output(:);
 
% Az adapt�v sz�r� egy�tthat�i
W = zeros (n,1);
 
% A gerjeszt�jel buffere
x_buff = zeros(n,1);
 
% A hibajel buffere
% Csak diagnosztikai c�lokat szolg�l
e_buff = [];

mu = 2e-4;

if nargin == 5
    mu = amu;
end

e_buff = zeros(1,pass*length(input));

for p = 1:pass
    
for k = 1:length(input)
    % Az aktu�lis bemeneti �rt�k bufferbe t�lt�se
    x_buff = [input(k); x_buff(1:end-1)];
    
    % A becs�lt kimenet el��ll�t�sa
    y_h = W.'*x_buff;
    
    % A hibajel el��ll�t�sa
    e = output(k) - y_h;
    
    % A hibajel bufferel�se (diagnosztika)
    e_buff(1,(p-1)*length(input)+k) = e;
    
    % A sz�r�egy�tthat�k adapt�l�sa
    W = W + 2*mu*e*x_buff;
end

end
 
error = e_buff;
 
end
