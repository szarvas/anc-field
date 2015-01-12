close all;
clear all;
clc;

fs = 8e3;

anc = ixELMS(8000, 8000, 200, fs);

% q = file_to_variable('dsp_actuator_to_error.dat');
% anc.SetSecondaryPath(q(1:4000));
% anc.SetSecondaryPath([zeros(1,49) 1 zeros(1,7950)]);

anc.SetSecondaryPath(file_to_variable('dsp_actuator_to_error.dat'));

anc.SetOption('mu_identification', 1e-3);
anc.SetOption('mu', 1e-2);

% anc.Identify(80000);

% anc.s_(1:8000) = file_to_variable('dsp_secpath.dat');
anc.s_ = file_to_variable('dsp_actuator_to_error.dat');

% anc.Identify(80000);

anc.SetNoiseToError( file_to_variable('dsp_noise_to_error.dat') );

anc.AddReference( file_to_variable('dsp_noise_to_front.dat'), ...
                  file_to_variable('dsp_actuator_to_front.dat'));
              
anc.AddReference( file_to_variable('dsp_noise_to_right.dat'), ...
                  file_to_variable('dsp_actuator_to_right.dat'));
              
anc.AddReference( file_to_variable('dsp_noise_to_left.dat'), ...
                  file_to_variable('dsp_actuator_to_left.dat'));

anc.AddReference( file_to_variable('dsp_noise_to_top.dat'), ...
                  file_to_variable('dsp_actuator_to_top.dat'));

anc.SetOption('mu', 1e-2);              
anc.Simulate(960000);

n = anc.noise_at_error_(end-8000:end) * anc.noise_at_error_(end-8000:end)';
a = anc.error_(end-8000:end) * anc.error_(end-8000:end)';
10*log10(a/n)
              
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
              
% 
% noise = anc.noise_;
% noise_at_error = filter(anc.h_noise_to_error_, 1, noise);
% noise_at_reference = filter(anc.h_noise_to_reference_, 1, noise);
% antinoise = filter(anc.w_, 1, noise_at_reference);
% antinoise_at_error = filter(anc.h_actuator_to_error_, 1, antinoise);
% s = noise_at_error - antinoise_at_error;

% coefW = zeros(1,4*8000);
% coefW(1:8000) = anc.w_(1,:);
% coefW(8001:16000) = anc.w_(2,:);
% coefW(16001:24000) = anc.w_(3,:);
% coefW(24001:32000) = anc.w_(4,:);
% 
dsp_anc_off

ancoff = zeros(386,386);
for k = 1:386
    for l = 1:386
        ancoff(k,l) = field_average(k,1,l);
    end
end
% 
% dsp_anc_on_4
% 
% ancon = zeros(386,386);
% for k = 1:386
%     for l = 1:386
%         ancon(k,l) = field_average(k,1,l);
%     end
% end
% 
% imagesc(10*log(ancon./ancoff),[-10 10]); axis image;  xlabel('x [2 cm]'); ylabel('z [2 cm]');

% dasW = zeros(1,6*8000);
% for b = 1:6
%     dasW(1,((b-1)*8000+1):((b-1)*8000+8000)) = anc.w_(b,:);
% end

% qq = q(6:6+546,6:6+398);
% imagesc(qq,[-10 10]); axis image;  xlabel('x [2 cm]'); ylabel('z [2 cm]');
h = colorbar('YTickLabel',{'10','8','6','4','2','0','-2','-4','-6','-8','-10'});
ylabel(h,'Noise supression [dB]');
