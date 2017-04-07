function [emonth, eday, ehour, eminute, past] = Eorzea(time,timezone)
% Calculate Eorzea time from Earth time

unixSeconds = (time-datenum('1970-01-01 00:00:00')-timezone/24)*86400;
past = unixSeconds / (70*60) * (24*3600);
emonth = floor(mod(past, 12*32*24*3600) / (32*24*3600)) + 1;
eday = floor(mod(past, 32*24*3600) / (24*3600)) + 1;
ehour = floor(mod(past, 24*3600) / 3600);
eminute = floor(mod(past, 3600) / 60);
end