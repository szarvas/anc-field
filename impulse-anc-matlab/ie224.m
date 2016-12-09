close all;
clear all;
clc;

% ========================================================================
% The first section of this file sets up the secondary path and does
% the inverse estimation. You have the option to save the result of this
% and save yourself some time. Read the comments on what to uncomment.
%
% The second section loads the primary paths and carries out the main
% ANC simulation
% ========================================================================

impulse_directory = '../examples/ie224-noise-results/';

fs = 8e3;

% Primary filter length 1500 per filter; secondary filter 8000;
% inverse delay 400
anc = iELMS(1500, 8000, 400, fs);

% We decimate the impulse response calculated at 32 kHz to get 8 kHz. It 
% was already bandlimited to about 2 kHz so this should be all right.
A = file_to_variable(strcat(impulse_directory, 'actuator-to-error.dat'));
anc.SetSecondaryPath(A(1:4:end));

anc.SetOption('mu_identification', 2);
anc.SetOption('mu', 1e-1);

% ========================================================================
% Uncomment the line below if you saved the identified secondary path
% before
% ========================================================================
% anc.s_ = file_to_variable(strcat(impulse_directory, 'secpath.dat'));

anc.Identify(640000);

% ========================================================================
% If you want to save the result of the secondary path identification
% (inverse) enable the line below. Then you don't have to call 
% `anc.Identify` when running the simulation with different primary paths,
% and can use `anc.s_ = file_to_variable(...)` instead.
% ========================================================================
% variable_to_file(strcat(impulse_directory, 'secpath.dat'), anc.s_)

%%
anc.SetOption('mu', 1e-2);
anc.ResetPrimaryFilter();

anc.SetNoiseToError( decimate4(file_to_variable(strcat(impulse_directory, 'noise-to-error.dat'))) );

% You can freely add or remove as many reference microphones as you want
anc.AddReference( decimate4(file_to_variable(strcat(impulse_directory, 'noise-to-reference_front.dat'))), ...
                  decimate4(file_to_variable(strcat(impulse_directory, 'actuator-to-reference_front.dat'))));
              
anc.AddReference( decimate4(file_to_variable(strcat(impulse_directory, 'noise-to-reference_back.dat'))), ...
                  decimate4(file_to_variable(strcat(impulse_directory, 'actuator-to-reference_back.dat'))));
              
anc.AddReference( decimate4(file_to_variable(strcat(impulse_directory, 'noise-to-reference_right.dat'))), ...
                  decimate4(file_to_variable(strcat(impulse_directory, 'actuator-to-reference_right.dat'))));
              
anc.AddReference( decimate4(file_to_variable(strcat(impulse_directory, 'noise-to-reference_left.dat'))), ...
                  decimate4(file_to_variable(strcat(impulse_directory, 'actuator-to-reference_left.dat'))));
              
anc.AddReference( decimate4(file_to_variable(strcat(impulse_directory, 'noise-to-reference_top.dat'))), ...
                  decimate4(file_to_variable(strcat(impulse_directory, 'actuator-to-reference_top.dat'))));
              
anc.AddReference( decimate4(file_to_variable(strcat(impulse_directory, 'noise-to-reference_bottom.dat'))), ...
                  decimate4(file_to_variable(strcat(impulse_directory, 'actuator-to-reference_bottom.dat'))));
              
% We simulate 180 seconds
anc.Simulate(180 * fs);

% Calculate the suppression 
n = anc.noise_at_error_(end-8000:end) * anc.noise_at_error_(end-8000:end)';
a = anc.error_(end-8000:end) * anc.error_(end-8000:end)';
10*log10(a/n)
