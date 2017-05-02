function [serialObject] = openSerialPort(port, baud, data, stop, parity)
%OPENSERIALPORT Summary of this function goes here
%   Detailed explanation goes here

%% Define serial port object
delete(instrfind)
serialObject = serial(port);    % 'COM8'
serialObject.BaudRate = baud;     % 9600
serialObject.DataBits = data;        % 8
serialObject.StopBits = stop;        % 1
serialObject.Parity = parity;     % 'none'
fopen(serialObject);

%% Serial handshake
k = 0;
while (k ~= 'F')
    k = fread(serialObject,1,'uchar');
end
if (k == 'F')
    disp('Serial Connection Established');
end
fprintf(serialObject,'%c','F');

end

