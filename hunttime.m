function [atime,stime] = hunttime(map,monster,ktime,rate,weatherlist,timezone)

x = fopen('resettime.txt');
resettime = fread(x);
fclose(x);
resettime = datenum(char(resettime'));

arank = [];
srank = [];
mintime = zeros(1,length(monster));
maxtime = zeros(1,length(monster));
for i = 1:length(monster)
    if monster(i).type == 'A'
        arank = cat(1,arank,i);
    else
        srank = cat(1,srank,i);
    end
    if ktime(i) < resettime
        mintime(i) = resettime + monster(i).coolDown/86400*0.6-1/24;
        maxtime(i) = resettime + monster(i).maxDown/86400*0.6-1/24;
    else
        mintime(i) = ktime(i) + monster(i).coolDown/86400;
        maxtime(i) = ktime(i) + monster(i).maxDown/86400;
    end
    if i == 9
        [~,day] = Eorzea(mintime(i),timezone);
        if day > 3+5/24
            mintime(i) = mintime(i)+(32-day)*70/60/24;
            maxtime(i) = mintime(i)+(3+5/24)*70/60/24;
        else
            maxtime(i) = mintime(i)+(3+5/24-day)*70/60/24;
        end
    elseif i == 11
        if now() > maxtime(i)
            temp = now();
        else
            temp = mintime(i)-16/24*70/60/24;
        end
        while 1
            nexttime = nextWeather(1,map(monster(i).id).rate,temp+10/86400,'小雨',timezone);
            for n = 1:100
                if ~strcmp('小雨',forecast(map(monster(i).id).rate,calcWeather(nexttime+n*8/24*70/60/24+10/86400,timezone),rate,weatherlist))
                    break;
                end
            end
            if n >= 2
                break;
            end
            temp = nexttime;
        end
        mintime(i) = max(mintime(i),nexttime+30/24/60);
        maxtime(i) = max(mintime(i),min(maxtime(i),nexttime+n*8/24*70/60/24));
    elseif i == 15
        if now() > maxtime(i)
            temp = now();
        else
            temp = mintime(i);
        end
        lasttime = max(nextWeather(-1,map(monster(i).id).rate,temp,'小雨',timezone), ...
            nextWeather(-1,map(monster(i).id).rate,temp,'暴雨',timezone));
        while 1
            nexttime = min(nextWeather(1,map(monster(i).id).rate,lasttime+10/86400,'小雨',timezone), ...
            nextWeather(1,map(monster(i).id).rate,lasttime+10/86400,'暴雨',timezone));
        if nexttime - lasttime > 200/24/60+8/24*70/60/24
            break;
        end
        lasttime = nexttime;
        end
        mintime(i) = max(mintime(i),lasttime+200/24/60+8/24*70/60/24);
        maxtime(i) = max(mintime(i),min(maxtime(i),nexttime));
    elseif i == 16
        [~,day] = Eorzea(mintime(i),timezone);
        if day > 19+5/24
            mintime(i) = mintime(i)+(32+15+17/24-day)*70/60/24;
            maxtime(i) = mintime(i)+(3+12/24)*70/60/24;
        elseif day < 15+17/24
            mintime(i) = mintime(i)+(15+17/24-day)*70/60/24;
            maxtime(i) = mintime(i)+(3+12/24)*70/60/24;
        else
            maxtime(i) = mintime(i)+(19+5/24-day)*70/60/24;
        end
    end
end
[amintime,indexa] = sort(mintime(arank));
amaxtime = maxtime(arank(indexa));
[smintime,indexs] = sort(mintime(srank));
smaxtime = maxtime(srank(indexs));

for i = 1:length(indexa)
    atime.id(i,1) = arank(indexa(i));
    atime.str(i,:) = strcat(datestr(mintime(arank(indexa(i))),31),' 至',32,datestr(maxtime(arank(indexa(i))),31));
end
for i = 1:length(indexs)
    stime.id(i,1) = srank(indexs(i));
    stime.str(i,:) = strcat(datestr(mintime(srank(indexs(i))),31),' 至',32,datestr(maxtime(srank(indexs(i))),31));
end

    function nexttime = nextWeather(direct,mapid,time,tweather,timezone)
        nexttime = time + direct*8/24*70/60/24;
        while 1
            weatherrate = calcWeather(nexttime,timezone);
            if strcmp(tweather,forecast(mapid,weatherrate,rate,weatherlist))
                break;
            end
            nexttime = nexttime + direct*8/24*70/60/24;
        end
        unixSeconds = (nexttime-datenum('1970-01-01 00:00:00')-timezone/24)*86400;
        hour = mod(unixSeconds*60*24/70,86400)/3600;
        nexttime = nexttime - mod(hour,8)/24*70/60/24;
    end
end
