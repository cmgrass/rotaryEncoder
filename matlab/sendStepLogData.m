function [tuyTs] = sendStepLogData(mySerialPort, speed, samples)
%SENDSTEPLOGDATA Summary of this function goes here
%   This function is used to issue a step input, and log the response. The
%   arduino with matching code will receive a speed command, and serially
%   send back speed data.

    %% Flush existing data on buffer
    flushSerialPort(mySerialPort);

    %% Send start & speed commands
    fprintf(mySerialPort, '%s', num2str(9998)); % Start signal
    echo = 0;
    while echo ~= 9998
       echo = fscanf(mySerialPort, '%u'); 
    end
    fprintf(mySerialPort, '%s', num2str(speed));    % Speed value
    disp('Speed Sent');
    
    %% Log data
    disp('Logging Data');

    tuyTs = zeros(4,samples);  % Initialize result matrix
    tic    % start clock
    for k = 1:samples   % Loop through the serial buffer
        tuyTs(2,k) = speed;
        data = fscanf(mySerialPort, '%f');
        if size(data) == 0  % Prevent Matlab error due to empty 0x0 double (`[]`)
            data = 0;   % If empty, assign `0`
        end
        tuyTs(3,k) = data;   % return result
        tuyTs(1,k) = toc;
        %disp(data);    % for debugging
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

end