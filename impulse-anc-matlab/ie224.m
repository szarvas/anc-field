close all;
clear all;
clc;

fs = 8e3;

anc = iELMS(1500, 8000, 1200, fs);
A = file_to_variable('ie224/ie224-actuator-to-error.dat');
anc.SetSecondaryPath(A(1:4:end));

anc.SetOption('mu_identification', 1e-1);
anc.SetOption('mu', 1e-1);

%anc.s_ = file_to_variable('secpath.dat');

anc.Identify(640000);
%%
anc.SetOption('mu', 1e-2);
anc.ResetPrimaryFilter();

anc.SetNoiseToError( file_to_variable('ie224/ie224-noise-to-error.dat') );

anc.AddReference( file_to_variable('ie224/ie224-noise-to-reference_front.dat'), ...
                  file_to_variable('ie224/ie224-actuator-to-reference_front.dat'));
              
anc.AddReference( file_to_variable('ie224/ie224-noise-to-reference_back.dat'), ...
                  file_to_variable('ie224/ie224-actuator-to-reference_back.dat'));

anc.AddReference( file_to_variable('ie224/ie224-noise-to-reference_right.dat'), ...
                  file_to_variable('ie224/ie224-actuator-to-reference_right.dat'));
              
anc.AddReference( file_to_variable('ie224/ie224-noise-to-reference_left.dat'), ...
                  file_to_variable('ie224/ie224-actuator-to-reference_left.dat'));

anc.AddReference( file_to_variable('ie224/ie224-noise-to-reference_top.dat'), ...
                  file_to_variable('ie224/ie224-actuator-to-reference_top.dat'));

anc.AddReference( file_to_variable('ie224/ie224-noise-to-reference_bottom.dat'), ...
                  file_to_variable('ie224/ie224-actuator-to-reference_bottom.dat'));
%               
% coefW = file_to_variable('coefW.dat');
% anc.w_(1,1:8000) = coefW(1:8000);
% anc.w_(2,1:8000) = coefW(8001:16000);
% anc.w_(3,1:8000) = coefW(16001:24000);
% anc.w_(4,1:8000) = coefW(24001:32000);
% anc.w_(5,1:8000) = coefW(32001:40000);
% anc.w_(6,1:8000) = coefW(40001:48000);

% anc.AddReference( file_to_variable('noise_to_reference_tright.dat'), ...
%                   file_to_variable('actuator_to_reference_tright.dat'));
% 
% anc.AddReference( file_to_variable('noise_to_reference_tleft.dat'), ...
%                   file_to_variable('actuator_to_reference_tleft.dat'));
%               
% anc.AddReference( file_to_variable('noise_to_reference_ttop.dat'), ...
%                   file_to_variable('actuator_to_reference_ttop.dat'));
              
anc.Simulate(180 * 8000);
% 
n = anc.noise_at_error_(end-8000:end) * anc.noise_at_error_(end-8000:end)';
a = anc.error_(end-8000:end) * anc.error_(end-8000:end)';
10*log10(a/n)
% 
% noise = anc.noise_;
% noise_at_error = filter(anc.h_noise_to_error_, 1, noise);
% noise_at_reference = filter(anc.h_noise_to_reference_, 1, noise);
% antinoise = filter(anc.w_, 1, noise_at_reference);
% antinoise_at_error = filter(anc.h_actuator_to_error_, 1, antinoise);
% s = noise_at_error - antinoise_at_error;

% anc_off
% 
% ancoff = zeros(576,576);
% for k = 1:576
%     for l = 1:576
%         ancoff(k,l) = field_average(k,1,l);
%     end
% end
% 
% anc_on
% 
% ancon = zeros(576,576);
% for k = 1:576
%     for l = 1:576
%         ancon(k,l) = field_average(k,1,l);
%     end
% end

% dasW = zeros(1,6*8000);
% for b = 1:6
%     dasW(1,((b-1)*8000+1):((b-1)*8000+8000)) = anc.w_(b,:);
% end

% qq = q(6:6+546,6:6+398);
% imagesc(qq,[-10 10]); axis image;  xlabel('x [2 cm]'); ylabel('z [2 cm]');
% h = colorbar('YTickLabel',{'10','8','6','4','2','0','-2','-4','-6','-8','-10'});
% ylabel(h,'Noise supression [dB]');
