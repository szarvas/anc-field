function [W, error] = lms(input, output, n, pass, amu)
input = input(:);
output = output(:);
 
% Az adaptív szúrõ együtthatói
W = zeros (n,1);
 
% A gerjesztõjel buffere
x_buff = zeros(n,1);
 
% A hibajel buffere
% Csak diagnosztikai célokat szolgál
e_buff = [];

mu = 2e-4;

if nargin == 5
    mu = amu;
end

e_buff = zeros(1,pass*length(input));

for p = 1:pass
    
for k = 1:length(input)
    % Az aktuális bemeneti érték bufferbe töltése
    x_buff = [input(k); x_buff(1:end-1)];
    
    % A becsült kimenet elõállítása
    y_h = W.'*x_buff;
    
    % A hibajel elõállítása
    e = output(k) - y_h;
    
    % A hibajel bufferelése (diagnosztika)
    e_buff(1,(p-1)*length(input)+k) = e;
    
    % A szûrõegyütthatók adaptálása
    W = W + 2*mu*e*x_buff;
end

end
 
error = e_buff;
 
end
