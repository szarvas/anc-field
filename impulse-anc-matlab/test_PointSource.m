% UNITTEST for the PointSource class. See 'help PointSource' for more information.

close all;
clear all;
clc;

dist = .9;
testlength = 100;

x = sin(2*pi/15*(0:testlength-40));

src = PointSource(0,0,x,8000);

tic
for k=0:testlength
    y(k+1) = src.at(0,dist,k);
    src.at(k,0,2*dist);
end
toc

figure; hold on;
stem(x,'green');
stem(y,'blue');

delay = dist/340*8000;
att = (2*sqrt(pi)*dist);
z = sin(2*pi/15*((0:testlength)-delay))/att;

plot(z,'red');

x=[delay, delay];
y=[1,-1];
plot(x,y,'black')
