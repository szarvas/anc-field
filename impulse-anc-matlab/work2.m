

colors = {'b','r','g','m'};
% figure; hold on;
% 
% for k = 1:4
%     plot(anc.h_noise_to_reference_(k,:,2),colors{k})
% end

references = {'left', 'right', 'front', 'back'};
nojz = 0;

latenciak = zeros(1,4);
maximumok = zeros(1,4);
% figure; hold on;
for k = 1:4
    filename = strcat('anechoic2/actuator_to_reference_', references{k}, '.dat');
    data = file_to_variable(filename);
    [l,p] = max(data);
    latenciak(k) = p;
    maximumok(k) = l;
end

latenciak
maximumok
