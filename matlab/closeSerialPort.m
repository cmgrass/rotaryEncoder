function [] = closeSerialPort(serialObject)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

    fclose(serialObject);
    disp('Serial Connection Closed');
end

