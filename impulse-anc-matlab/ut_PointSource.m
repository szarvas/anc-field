% Unittest script for the PointSource class
%   The script creates PointSources with a test signal. Then it uses
%   the PointSource.GetSignal(Vector2D) and PointSource.GetValue(Vector2D)
%   functions to calculate the signal
%   at a given location corresponding to a list of integral and fractional
%   delays. It creates comparative plots with analytically delayed
%   (expected) signal values and the signal resulting from the GetSignal
%   function.
%
%   Four plots demonstrate the correctness of the tested method by
%   observing results at large ( >> Thiran order), small ( < Thiran order)
%   very small ( < 1.0) and integral (= 3.0) delay values.

clc;
clear all;
close all;

length = 100;
delay = 11.24;
fs = 8000;

signal = sin(2*pi/15*(0:length-40));
delayed_signal = sin(2*pi/15*((0:length-40+floor(delay))-delay));
delayed_signal(1:ceil(delay)) = 0;

distance = delay / fs * 340;
delayed_signal = delayed_signal / ( 2 * sqrt(pi) * distance );

subplot(2,2,1)

stem(signal); hold on;
stem(delayed_signal, 'green');

ps = PointSource(Vector2D(0,distance), signal, fs);
tic;
ps_signal = ps.GetSignal(Vector2D(0,0));
toc;

stem(ps_signal, 'red');

title(sprintf('PointSource.GetSignal(Vector2D) with a total delay of %0.2f', delay));
plot([delay+1 delay+1],[-1 1], 'black');
legend('Original', 'Analytically delayed', 'Test');

hold off;

%%

length = 100;
delay = 1.24;
fs = 8000;

signal = sin(2*pi/15*(0:length-40));
delayed_signal = sin(2*pi/15*((0:length-40+floor(delay))-delay));
delayed_signal(1:ceil(delay)) = 0;

distance = delay / fs * 340;
delayed_signal = delayed_signal / ( 2 * sqrt(pi) * distance );

subplot(2,2,2)
stem(signal); hold on;
stem(delayed_signal, 'green');

ps = PointSource(Vector2D(0,distance), signal, fs);
ps_signal = ps.GetSignal(Vector2D(0,0));

stem(ps_signal, 'red');
title(sprintf('PointSource.GetSignal(Vector2D) with a total delay of %0.2f', delay));

plot([delay+1 delay+1],[-1 1], 'black');
legend('Original', 'Analytically delayed', 'Test');

ha = axes('Position',[0 0 1 1],'Xlim',[0 1],'Ylim',[0 
1],'Box','off','Visible','off','Units','normalized', 'clipping' , 'off');

text(0.5, 1,'\bf PointSource unittest','HorizontalAlignment' ,'center','VerticalAlignment', 'top')

%%

length = 100;
delay = 0.52;
fs = 8000;

signal = sin(2*pi/15*(0:length-40));
delayed_signal = sin(2*pi/15*((0:length-40+floor(delay))-delay));
delayed_signal(1:ceil(delay)) = 0;

distance = delay / fs * 340;
delayed_signal = delayed_signal / ( 2 * sqrt(pi) * distance );

subplot(2,2,3)
stem(signal); hold on;
stem(delayed_signal, 'green');

ps = PointSource(Vector2D(0,distance), signal, fs);
ps_signal = ps.GetSignal(Vector2D(0,0));

stem(ps_signal, 'red');
title(sprintf('PointSource.GetSignal(Vector2D) with a total delay of %0.2f', delay));

plot([delay+1 delay+1],[-1 1], 'black');
legend('Original', 'Analytically delayed', 'Test');

ha = axes('Position',[0 0 1 1],'Xlim',[0 1],'Ylim',[0 
1],'Box','off','Visible','off','Units','normalized', 'clipping' , 'off');

text(0.5, 1,'\bf PointSource unittest','HorizontalAlignment' ,'center','VerticalAlignment', 'top')

%%

length = 100;
delay = 3.0;
fs = 8000;

signal = sin(2*pi/15*(0:length-40));
delayed_signal = sin(2*pi/15*((0:length-40+floor(delay))-delay));
delayed_signal(1:ceil(delay)) = 0;

distance = delay / fs * 340;
delayed_signal = delayed_signal / ( 2 * sqrt(pi) * distance );

subplot(2,2,4)
stem(signal); hold on;
stem(delayed_signal, 'green');

ps = PointSource(Vector2D(0,distance), signal, fs);
ps_signal = ps.GetSignal(Vector2D(0,0));

stem(ps_signal, 'red');
title(sprintf('PointSource.GetSignal(Vector2D) with a total delay of %0.2f', delay));

plot([delay+1 delay+1],[-1 1], 'black');
legend('Original', 'Analytically delayed', 'Test');

ha = axes('Position',[0 0 1 1],'Xlim',[0 1],'Ylim',[0 
1],'Box','off','Visible','off','Units','normalized', 'clipping' , 'off');

text(0.5, 1,'\bf PointSource.GetSignal unittest','HorizontalAlignment' ,'center','VerticalAlignment', 'top')

%%
length = 100;
delay = 11.24;
fs = 8000;

signal = sin(2*pi/15*(0:length-40));
delayed_signal = sin(2*pi/15*((0:length-40+floor(delay))-delay));
delayed_signal(1:ceil(delay)) = 0;

distance = delay / fs * 340;
delayed_signal = delayed_signal / ( 2 * sqrt(pi) * distance );

figure;
subplot(2,2,1);
stem(signal); hold on;
stem(delayed_signal, 'green');

ps = PointSource(Vector2D(0,distance), signal, fs);

ps_signal = zeros(1, length);
for k = 1:length
    ps_signal(k) = ps.GetValue(Vector2D(0,0), k);
end

stem(ps_signal, 'red');
title(sprintf('PointSource.GetValue(Vector2D) with a total delay of %0.2f', delay));
plot([delay+1 delay+1],[-1 1], 'black');
legend('Original', 'Analytically delayed', 'Test');

ha = axes('Position',[0 0 1 1],'Xlim',[0 1],'Ylim',[0 
1],'Box','off','Visible','off','Units','normalized', 'clipping' , 'off');
text(0.5, 1,'\bf PointSource.GetValue unittest','HorizontalAlignment' ,'center','VerticalAlignment', 'top')

%%
length = 100;
delay = 1.57;
fs = 8000;

signal = sin(2*pi/15*(0:length-40));
delayed_signal = sin(2*pi/15*((0:length-40+floor(delay))-delay));
delayed_signal(1:ceil(delay)) = 0;

distance = delay / fs * 340;
delayed_signal = delayed_signal / ( 2 * sqrt(pi) * distance );

subplot(2,2,2);
stem(signal); hold on;
stem(delayed_signal, 'green');

ps = PointSource(Vector2D(0,distance), signal, fs);

ps_signal = zeros(1, length);
for k = 1:length
    ps_signal(k) = ps.GetValue(Vector2D(0,0), k);
end

stem(ps_signal, 'red');
title(sprintf('PointSource.GetValue(Vector2D) with a total delay of %0.2f', delay));
plot([delay+1 delay+1],[-1 1], 'black');
legend('Original', 'Analytically delayed', 'Test');

ha = axes('Position',[0 0 1 1],'Xlim',[0 1],'Ylim',[0 
1],'Box','off','Visible','off','Units','normalized', 'clipping' , 'off');
text(0.5, 1,'\bf PointSource.GetValue unittest','HorizontalAlignment' ,'center','VerticalAlignment', 'top')

%%
length = 100;
delay = 0.37;
fs = 8000;

signal = sin(2*pi/15*(0:length-40));
delayed_signal = sin(2*pi/15*((0:length-40+floor(delay))-delay));
delayed_signal(1:ceil(delay)) = 0;

distance = delay / fs * 340;
delayed_signal = delayed_signal / ( 2 * sqrt(pi) * distance );

subplot(2,2,3);
stem(signal); hold on;
stem(delayed_signal, 'green');

ps = PointSource(Vector2D(0,distance), signal, fs);

ps_signal = zeros(1, length);
for k = 1:length
    ps_signal(k) = ps.GetValue(Vector2D(0,0), k);
end

stem(ps_signal, 'red');
title(sprintf('PointSource.GetValue(Vector2D) with a total delay of %0.2f', delay));
plot([delay+1 delay+1],[-1 1], 'black');
legend('Original', 'Analytically delayed', 'Test');

ha = axes('Position',[0 0 1 1],'Xlim',[0 1],'Ylim',[0 
1],'Box','off','Visible','off','Units','normalized', 'clipping' , 'off');
text(0.5, 1,'\bf PointSource.GetValue unittest','HorizontalAlignment' ,'center','VerticalAlignment', 'top')

%%
length = 100;
delay = 3.0;
fs = 8000;

signal = sin(2*pi/15*(0:length-40));
delayed_signal = sin(2*pi/15*((0:length-40+floor(delay))-delay));
delayed_signal(1:ceil(delay)) = 0;

distance = delay / fs * 340;
delayed_signal = delayed_signal / ( 2 * sqrt(pi) * distance );

subplot(2,2,4);
stem(signal); hold on;
stem(delayed_signal, 'green');

ps = PointSource(Vector2D(0,distance), signal, fs);

ps_signal = zeros(1, length);
tic;
for k = 1:length
    ps_signal(k) = ps.GetValue(Vector2D(0,0), k);
end
toc;

stem(ps_signal, 'red');
title(sprintf('PointSource.GetValue(Vector2D) with a total delay of %0.2f', delay));
plot([delay+1 delay+1],[-1 1], 'black');
legend('Original', 'Analytically delayed', 'Test');

ha = axes('Position',[0 0 1 1],'Xlim',[0 1],'Ylim',[0 
1],'Box','off','Visible','off','Units','normalized', 'clipping' , 'off');
text(0.5, 1,'\bf PointSource.GetValue unittest','HorizontalAlignment' ,'center','VerticalAlignment', 'top')

