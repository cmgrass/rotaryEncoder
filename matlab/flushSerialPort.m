function [] = flushSerialPort(mySerialPort)
%FLUSHSERIALPORT Summary of this function goes here
%   Detailed explanation goes here

    while mySerialPort.BytesAvailable > 0
        garbage = fread(mySerialPort, mySerialPort.BytesAvailable);   %% Read all data in buffer
    end
    
end

