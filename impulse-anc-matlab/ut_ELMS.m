clc;
clear all;
close all;

result;

fs = 8000;
simlength = 48000;

% Only the number of sources matter now
noise = [
    PointSource([0 10], [0], fs)
    ];

% W: elsõdleges szûrõ
% S: másodlagos szûrõ
% T: referenciaszûrõ
% D_: adott szûrõhöz tartozó késleltetés
%          N_W   N_S  D_S  N_T  D_T
anc = ELMS(1000, 500, 200, 5000, 250, fs);

% Ezeket kötelezõ meghívni a szimuláció elõttclc
anc.SetReferencePositions([0 2]);
anc.SetErrorPositions([0 0]);
anc.SetActuatorPositions([0.2 0]);
anc.AddSources(noise);

% Ezek az alapértelmezett értékek is, nem kötelezõ hívni
anc.SetOption('mu_reference_filter_identification', 2e-1);
anc.SetOption('mu_identification', 1e-1);
anc.SetOption('mu', 1e-1);
anc.SetOption('normalization', true);
anc.SetOption('reference_filtering', false); % ki-be kapcsolható T szûrõ

anc.SetIndetificationSignal(float_buffer_0(2,:));
anc.SetIdentificationResponse(float_buffer_1(1,:));

% Alapértelmezett identifikációs hossz, egyszer esetekben kevesebb is elég
anc.SetOption('diag_plot_identification', false);
for i = 1:14
    anc.Identify(2000);
end
anc.SetOption('diag_plot_identification', true);
anc.Identify(2000);

% Generating the acoustic model filters
[W e] = lms(float_buffer_0(1,:), float_buffer_1(1,:), 500, 10); % noise,err
% figure; plot(e); title('noise, err');
anc.h_noise_to_error_(1,:) = W;

[W e] = lms(float_buffer_0(1,:), float_buffer_1(2,:), 500, 10); % noise,ref
% figure; plot(e); title('noise, ref');
anc.h_noise_to_reference_(1,:) = W;

[W e] = lms(float_buffer_0(2,:), float_buffer_1(1,:), 500, 10); % act,err
% figure; plot(e); title('act, err');
anc.h_actuator_to_error_(1,:) = W;

[W e] = lms(float_buffer_0(2,:), float_buffer_1(2,:), 500, 10); % act,ref
% figure; plot(e); title('act, ref');
anc.h_actuator_to_reference_(1,:) = W;

% Ez legfeljebb simlength ideig történhet a zajforrások mérete miatt
% anc.IdentifyReferenceFilter(simlength);
% figure; plot([anc.t_(1,:) anc.t_(2,:) anc.t_(3,:) anc.t_(4,:)])
anc.Simulate(80000);
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