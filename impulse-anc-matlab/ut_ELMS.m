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

% W: els�dleges sz�r�
% S: m�sodlagos sz�r�
% T: referenciasz�r�
% D_: adott sz�r�h�z tartoz� k�sleltet�s
%          N_W   N_S  D_S  N_T  D_T
anc = ELMS(1000, 500, 200, 5000, 250, fs);

% Ezeket k�telez� megh�vni a szimul�ci� el�ttclc
anc.SetReferencePositions([0 2]);
anc.SetErrorPositions([0 0]);
anc.SetActuatorPositions([0.2 0]);
anc.AddSources(noise);

% Ezek az alap�rtelmezett �rt�kek is, nem k�telez� h�vni
anc.SetOption('mu_reference_filter_identification', 2e-1);
anc.SetOption('mu_identification', 1e-1);
anc.SetOption('mu', 1e-1);
anc.SetOption('normalization', true);
anc.SetOption('reference_filtering', false); % ki-be kapcsolhat� T sz�r�

anc.SetIndetificationSignal(float_buffer_0(2,:));
anc.SetIdentificationResponse(float_buffer_1(1,:));

% Alap�rtelmezett identifik�ci�s hossz, egyszer esetekben kevesebb is el�g
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

% Ez legfeljebb simlength ideig t�rt�nhet a zajforr�sok m�rete miatt
% anc.IdentifyReferenceFilter(simlength);
% figure; plot([anc.t_(1,:) anc.t_(2,:) anc.t_(3,:) anc.t_(4,:)])
anc.Simulate(80000);
% CalculateSupression(anc);

% Az ELMS oszt�ly �sszes attrib�tum�hoz l�sd az ELMS.m f�jl tetej�n a
% properties blokk tartalm�t
% Itt kiemelek n�h�ny fontosabbat

% Els�dleges sz�r� egy�tthat�i
% anc.w_;

% M�sodlagos sz�r� egy�tthat�i
% anc.s_;

% Referenciasz�r� egy�tthat�i
% anc.t_;