
colors = {'b','r','g','m'};
% figure; hold on;
% 
% for k = 1:4
%     plot(anc.h_noise_to_reference_(k,:,2),colors{k})
% end

references = {'left', 'right', 'front', 'back'};
nojz = 0;

latenciak = zeros(4,4);
maximumok = zeros(4,4);
% figure; hold on;
for nojz = 0:3
    for k = 1:4
        filename = strcat('anechoic3/noise_', num2str(nojz) ,'_to_reference_', references{k}, '.dat');
        data = file_to_variable(filename);
        [l,p] = max(data);
        latenciak(nojz+1, k) = p;
        maximumok(nojz+1, k) = l;
%         plot(data, colors{k});
    end
end

latenciak
maximumok
det(latenciak)
