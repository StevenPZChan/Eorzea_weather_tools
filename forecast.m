function weather = forecast(mapid,weatherrate,rate,weatherlist)
for i = 1:length(rate)
    if rate(i).id == mapid
        for j = size(rate(i).rate,1):-1:1
            if weatherrate >= rate(i).rate(j,2)
                j = j + 1;
                break;
            end
        end
        weather = cell2mat(weatherlist{rate(i).rate(j,1)+1});
        break;
    end
end
end
