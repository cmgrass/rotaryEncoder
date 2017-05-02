%% Initialize
clear all; close all; clc;
load c_TUY_Data_linedup_zeroed;

%% Breakout TUY data
% time, input, output

t = TUY_Combo(1,:)';
u = TUY_Combo(2,:)';
y = TUY_Combo(3,:)';

Ts = t(5)-t(4); % sampling interval

%% Plot
figure(1);
plot(t,u,'b',t,y,'r')

%% Setup system identification data
data = iddata(y,u,Ts);  % This allows us to use `tftest`

%% System Parameters (tune these)
np = 1;
nz = 0;
ioDelay = NaN;

%% Perform system identification
sys1 = tfest(data,np,nz,ioDelay);

%% Output system transfer function results
num1 = sys1.Num;
den1 = sys1.Den;
ioDelay = sys1.ioDelay;

tf1 = tf(num1,den1,'InputDelay',ioDelay)

%% Plot experimental vs transfer function response
ytf1 = lsim(tf1,u,t);
figure(2);
plot(t,y,'b',t,ytf1,'.r')