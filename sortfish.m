function sortlist = sortfish(fishtime, sortlist)
% Sort fishes

list = zeros(length(sortlist),1);
for i = 1:length(sortlist)
    list(i) = (fishtime(sortlist(i)).flag == 0) * 2e6;
    list(i) = list(i) + datenum(fishtime(sortlist(i)).time(2,:));
    list(i) = list(i) + (fishtime(sortlist(i)).best == 0) * 100;
    list(i) = list(i) + ~strcmp(fishtime(sortlist(i)).time(2,:),fishtime(sortlist(i)).time(3,:)) * ...
        datenum(fishtime(sortlist(i)).time(3,:)) / 1e7;
    list(i) = list(i) + i / 1e12;
end
[~, temp] = sort(list);
sortlist = sortlist(temp);
end
