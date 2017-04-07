function fishtime = fishingTimer(fishtime, allfish, time, id, map, rate, weatherlist,timezone)
% Calculate available times for each fish

if allfish(id).time1 == 0 && allfish(id).time2 == 24
    period = 1400;
    max = 65;
else
    period = 175;
    max = 500;
end

[result, best] = check(allfish(id), time);
if result
    flag = 1;
    fishtime(id,1).flag = 1;
    fishtime(id,1).best = best;
else
    flag = 0;
    fishtime(id,1).flag = 0;
    fishtime(id,1).best = 0;
end
for j = 1:max
    if check(allfish(id), time-period/24/3600*j) ~= flag
        break;
    end
end
fishtime(id,1).time(1,:) = adjust(time - period/24/3600*(j-1),period,timezone);

temp = time;
for k = 2:6
    for j = 1:max
        if check(allfish(id), temp+period/24/3600*j) ~= flag
            flag = 1 - flag;
            break;
        end
    end
    temp = temp + period/24/3600*j;
    if j == max
        for x = k:6
            fishtime(id,1).time(x,:) = adjust(temp,period,timezone);
        end
        break;
    else
        max = max - j;
        fishtime(id,1).time(k,:) = adjust(temp,period,timezone);
    end
end

    function [result, best] = check(fish, time)
        % check if current time could catch the fish
        
        best = 0;
        [~, ~, ehour, ~, ~] = Eorzea(time,timezone);
        if (ehour>=fish.time1 && ehour<fish.time2) || ...
                ((fish.time1>fish.time2) && (ehour>=fish.time1 || ehour<fish.time2))
            result = 0;
        else
            result = 0;
            return;
        end
        col = find(strcmp({map.zh},fish.map),1);
        weather = forecast(map(col).rate,calcWeather(time,timezone), ...
                        rate,weatherlist);
        for t = 1:length(fish.weather1)
            if strcmp(weather,fish.weather1(t))
                result = 1;
                if t == 1
                    best = 1;
                end
                break;
            end
        end
        if ~isempty(fish.weather2)
            weather2 = forecast(map(col).rate,calcWeather(time-1400/24/3600,timezone), ...
                        rate,weatherlist);
            for t = 1:length(fish.weather2)
                if strcmp(weather2,fish.weather2(t))
                    result = result & 1;
                    return;
                end
            end
            result = 0;
        end
    end

    function adjtime = adjust(time,period,timezone)
        % adjust time to o'clock
        
        [~, ~, ~, ~, past] = Eorzea(time,timezone);
        rest = mod(past, period/175*3600);
        adjtime = (past-rest) / (24*3600) * (70*60) / (24*3600);
        adjtime = datestr(adjtime + datenum('1970-01-01 00:00:00') + timezone/24, 31);
    end
end
