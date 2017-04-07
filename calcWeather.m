function weatherrate = calcWeather(time,timezone)

unixSeconds = floor((time-datenum('1970-01-01 00:00:00')-timezone/24)*86400);
bell = unixSeconds / 175;
increment = mod((bell+8-mod(bell,8)),24);
totalDays = unixSeconds/4200;
totalDays = floor(totalDays);
calcBase = totalDays*100+increment;
step1 = bitxor(bitshift(calcBase,11,'uint32'),calcBase);
step2 = bitxor(bitshift(step1,-8),step1);
weatherrate = mod(step2,100);
end
