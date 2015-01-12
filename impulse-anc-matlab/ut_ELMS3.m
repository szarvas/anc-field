clc;
clear all;
close all;

fs = 8000;

simulation_steps = 20000;

% anc02;

% noise = bandnoise(3800, 1.0, fs, simulation_steps);
% noise_at_ref = [zeros(1,5) noise(1:end-5)];
% noise_at_err = 0.2 * [zeros(1,50) noise(1:end-50)];
% 
% act = bandnoise(3800, 1.0, fs, simulation_steps);
% act_at_err = 0.8 * [zeros(1,15) act(1:end-15)];
% act_at_ref = 0.0 * [zeros(1,40) act(1:end-40)];

% noise = float_buffer_0(1,:);
% noise_at_ref = float_buffer_1(2,:);
% noise_at_err = float_buffer_1(1,:);
% 
% act = float_buffer_0(3,:);
% act_at_ref = float_buffer_1(2,:);
% act_at_err = float_buffer_1(1,:);

% Only the number of sources matter now
no = [
    PointSource([0 10], [], fs)
    ];

% W: elsõdleges szûrõ
% S: másodlagos szûrõ
% T: referenciaszûrõ
% D_: adott szûrõhöz tartozó késleltetés
%          N_W   N_S  D_S  N_T  D_T
anc = iELMS(4000, 1000, 200, 5000, 250, fs);

% Ezeket kötelezõ meghívni a szimuláció elõtt
anc.SetReferencePositions([0 2]);
anc.SetErrorPositions([0 0]);
anc.SetActuatorPositions([0.2 0]);
anc.AddSources(no);

% Ezek az alapértelmezett értékek is, nem kötelezõ hívni
anc.SetOption('mu_reference_filter_identification', 2e-1);
anc.SetOption('mu_identification', 1e-2);
anc.SetOption('mu', 1e-3);
anc.SetOption('normalization', true);
anc.SetOption('reference_filtering', false); % ki-be kapcsolható T szûrõ

anc.SetIndetificationSignal(file_to_variable('identification_signal.dat'));
anc.SetIdentificationResponse(file_to_variable('identification_result.dat'));

% Alapértelmezett identifikációs hossz, egyszer esetekben kevesebb is elég
anc.SetOption('diag_plot_identification', false);
for i = 1:14
    anc.Identify(2000); % todo: ez így nem lesz jó
end
anc.SetOption('diag_plot_identification', true);
anc.Identify(2000);

anc.h_noise_to_error_(1,:) = file_to_variable('noise_to_error.dat');
anc.h_noise_to_reference_(1,:) = file_to_variable('noise_to_reference_front.dat');
% anc.h_noise_to_reference_(2,:) = file_to_variable('noise_to_reference_back.dat');
% anc.h_noise_to_reference_(2,:) = file_to_variable('noise_to_reference_right.dat');
% anc.h_noise_to_reference_(3,:) = file_to_variable('noise_to_reference_left.dat');
% anc.h_noise_to_reference_(5,:) = file_to_variable('noise_to_reference_top.dat');

% Generating the acoustic model filters
% [W e] = lms(noise, noise_at_err, 8000, 10, 1e-5); % noise,err
% figure; plot(e); title('noise, err');
% anc.h_noise_to_error_(1,:) = W;
% 
% [W e] = lms(noise, noise_at_ref, 8000, 10, 1e-5); % noise,ref
% figure; plot(e); title('noise, ref');
% anc.h_noise_to_reference_(1,:) = W;
% 
% [W e] = lms(act, act_at_err, 16000, 3, 1e-4); % act,err
% figure; plot(e); title('act, err');
anc.h_actuator_to_error_(1,:) = file_to_variable('actuator_to_error.dat');

% [W e] = lms(act, act_at_ref, 8000, 10, 1e-5); % act,ref
% figure; plot(e); title('act, ref');
anc.h_actuator_to_reference_(1,:) = file_to_variable('actuator_to_reference_front.dat');
% anc.h_actuator_to_reference_(2,:) = 0*file_to_variable('actuator_to_reference_back.dat');
% anc.h_actuator_to_reference_(3,:) = 0*file_to_variable('actuator_to_reference_back.dat');
% anc.h_actuator_to_reference_(4,:) = 0*file_to_variable('actuator_to_reference_back.dat');
% anc.h_actuator_to_reference_(5,:) = 0*file_to_variable('actuator_to_reference_back.dat');


% Ez legfeljebb simlength ideig történhet a zajforrások mérete miatt
% anc.IdentifyReferenceFilter(simlength);
% figure; plot([anc.t_(1,:) anc.t_(2,:) anc.t_(3,:) anc.t_(4,:)])
anc.Simulate(100000);
% CalculateSupression(anc);

% Az ELMS osztály összes attribútumához lásd az ELMS.m fájl tetején a
% properties blokk tartalmát
% Itt kiemelek néhány fontosabbat

% Elsõdleges szûrõ együtthatói
% anc.w_;

% Másodlagos szûrõ együtthatói
% anc.s_;

% Referenciaszûrõ együtthatói
% anc.t_;