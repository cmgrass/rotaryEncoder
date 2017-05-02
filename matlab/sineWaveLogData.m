function [tuyTs] = sineWaveLogData(mySerialPort, samples)
%SINEWAVELOGDATA Summary of this function goes here
%   Detailed explanation goes here

    %% Flush existing data on buffer
    flushSerialPort(mySerialPort);

    %% Send start
    fprintf(mySerialPort, '%s', num2str(9998)); % Start signal
    pause(1);
    echo = 0;
    while echo ~= 9998
       echo = fscanf(mySerialPort, '%u'); 
    end
    disp('Started');
    
    %% Send Signal, Log data

    % Initialize sine wave properties
    A=1874;
    f=1/1200;
    
    % Initialize result matrix
    tuyTs = zeros(4,samples);
    
    tic    % start clock
    for k = 1:samples   % Loop through the serial buffer
        
        % Generate, send signal
        uTemp = A*sin(2*pi*f*k)+A;
        tuyTs(2,k) = round(uTemp);
        fprintf(mySerialPort, num2str(tuyTs(2,k)));
        
        % Read data
        yTemp = fscanf(mySerialPort, '%f');
        if size(yTemp) == 0  % Prevent Matlab error due to empty 0x0 double (`[]`)
            yTemp = 0;   % If empty, assign `0`
        end
        disp(yTemp);    % for debugging
        
        % Return results
        tuyTs(3,k) = yTemp;
        tuyTs(1,k) = toc;
        if k > 1
            tuyTs(4,k) = tuyTs(1,k)-tuyTs(1,(k-1)); % sampling time for averaging later on
        else
            tuyTs(4,k) = 0;
        end
    end
    
    disp('Sample Duration :');
    disp(toc);  % Display sample duration

    %% Send stop command
    fprintf(mySerialPort, '%s', num2str(9999)); % Stop signal
    disp('Stop stream');
    
    %% Flush existing data on buffer
    flushSerialPort(mySerialPort);
    
    %% Plot Results
    figure;
    subplot(2,1,1);
    plot(tuyTs(1,:),tuyTs(2,:));
    title('Input `u` to Valveshaft System: Crankshaft RPM Vs. Time');
    xlabel('Time (seconds)');
    ylabel('Crankshaft Angular Velocity (RPM))');
    
    subplot(2,1,2);
    plot(tuyTs(1,:),tuyTs(3,:));
    title('Response `y` of Valveshaft System: Valveshaft RPM Vs. Time');
    xlabel('Time (seconds)');
    ylabel('Valveshaft Angular Velocity (RPM)');    
    
    %% Plot experimental vs transfer function response
    figure(2);
    plot(tuyTs(1,:),tuyTs(2,:),'b',tuyTs(1,:),tuyTs(3,:),'r');
    title('Input `u` (blue), and Response `y` (red), of Valveshaft System: RPM Vs. Time');
    xlabel('Time (seconds)');
    ylabel('Shaft Angular Velocity (RPM)'); 

end

