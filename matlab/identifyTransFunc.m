function [tfResult] = identifyTransFunc(tuyTs,np,nz,ioDelay)
%IDENTIFYTRANSFUNC Summary of this function goes here
%   Detailed explanation goes here

    %% Arrange t,u,y,Ts data for `iddata`
    t = tuyTs(1,:)';  % transpose to column vector
    u = tuyTs(2,:)';
    y = tuyTs(3,:)';
    Ts = tuyTs(4,:)';
    TsAvg = mean(Ts); % sampling interval
    
    %% Plot overlaying input 'u' and output 'y'
    figure(1);
    plot(t,u,'b',t,y,'r')
    
    %% Setup system identification data
    data = iddata(y,u,TsAvg);  % This allows us to use `tftest`

    %% Perform system identification
    sys1 = tfest(data,np,nz,ioDelay);

    %% Output system transfer function results
    num1 = sys1.Num;
    den1 = sys1.Den;
    ioDelay = sys1.ioDelay;

    tfResult = tf(num1,den1,'InputDelay',ioDelay);

    %% Plot experimental vs transfer function response
    
    % Generate evenly spaced time samples
    tSize = size(t,1);
    tSim = zeros(1,tSize);
    for k = 1:tSize
        if k > 1 
            tSim(k)=tSim(k-1)+TsAvg;
        else
            tSim(k)=0;
        end
    end
        
    % Simulate
    %tfSim = lsim(tfResult,u,t);
    
    % Plot
    %figure(2);
    %plot(t,y,'b',t,tfSim,'.r')
end

