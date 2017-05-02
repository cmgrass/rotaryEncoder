function [retVal] = logAngleData(mySerialPort, samples)
%LOGANGLEDATA Summary of this function goes here
%   This function is used to issue a step input, and log the response. The
%   arduino with matching code will receive a speed command, and serially
%   send back speed data.

    %% Flush existing data on buffer
    flushSerialPort(mySerialPort);

    %% Send start & speed commands
    fprintf(mySerialPort, '%s', num2str(1234)); % Start signal
    echo = 0;
    while echo ~= 1234
       echo = fscanf(mySerialPort, '%u'); 
    end
    
    %% Log data
    disp('Logging Data');

    retVal = zeros(1,samples);  % Initialize result matrix
    tic    % start clock
    for k = 1:samples   % Loop through the serial buffer
        data = fscanf(mySerialPort, '%f');    % read unsigned int
        if size(data) == 0  % Prevent Matlab error due to empty 0x0 double (`[]`)
            data = 0;   % If empty, assign `0`
        end
        retVal(k) = data;   % return result
        x(k) = toc;
        disp(data);    % for debugging
    end
    disp('Sample Duration :');
    disp(toc);  % Display sample duration

    %% Send stop command
    fprintf(mySerialPort, '%s', num2str(4321)); % Stop signal
    disp('Stop stream');
    
    %% Flush existing data on buffer
    flushSerialPort(mySerialPort);
    
    %% Plot Results
    figure;
    plot(x,retVal);
    title('Step response of DC motor: Angular Velocity Vs. Time');
    xlabel('Time (seconds)');
    ylabel('Angular Velocity (RPM)');

end