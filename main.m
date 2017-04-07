function main()
%% Initialization
global map weather rate allfish list allsight list2 monster ktime timezone
tic;
load('map.mat');
load('weather.mat');
load('rate.mat');
load('allfish.mat');
load('fishlist.mat');
load('allsight.mat');
load('sightlist.mat');
load('monster.mat');
load('ktime.mat');
z = fopen('timezone.txt');
timezone = fread(z);
fclose(z);
timezone = str2double(char(timezone'));
% parpool;

%% GUI
% global h_weather h_hunt h_fishing h_sightseeing
h_weather = gobjects(1);
h_hunt = gobjects(1);
h_fishing = gobjects(1);
h_sightseeing = gobjects(1);

h_main = figure('name','天气相关小工具','menubar','none','numbertitle','off', ...
    'position',[200 400 400 300],'resize','off','deletefcn',@hClose);
h_button1 = uicontrol(h_main,'style','pushbutton','fontsize',16, ...
    'position',[90 180 100 50],'string','天气预报','callback',@weatherForecast);
h_button2 = uicontrol(h_main,'style','pushbutton','fontsize',16, ...
    'position',[210 180 100 50],'string','狩猎预测','callback',@hunt);
h_button3 = uicontrol(h_main,'style','pushbutton','fontsize',16, ...
    'position',[90 100 100 50],'string','钓鱼时钟','callback',@fishing);
h_button4 = uicontrol(h_main,'style','pushbutton','fontsize',16, ...
    'position',[210 100 100 50],'string','探索笔记','callback',@sightseeing);
fprintf('Initialized for %.2fs.\n',toc());

    function hClose(~, ~)   % Main window closed
        if ishghandle(h_weather)
            delete(h_weather);
        end
        if ishghandle(h_hunt)
            delete(h_hunt);
        end
        if ishghandle(h_fishing)
            delete(h_fishing);
        end
        if ishghandle(h_sightseeing)
            delete(h_sightseeing);
        end
        delete(gcp('nocreate'));
    end

%% Weather Forecast
    function weatherForecast(~, ~)
        set(h_button1,'enable','off');
        wnum = inputdlg(char('请输入需要查看的未来天气数（不大于16）：','（每个天气需要约2秒计算时间）'), ...
            '',1,{'3'});
        if isempty(wnum)
            set(h_button1,'enable','on');
            return;
        end
        pause(0.1);
        tic;
        m1 = figure(6);
        set(m1,'name','','menubar','none','numbertitle','off', ...
            'position',[350 520 120 60],'resize','off');
        uicontrol(m1,'style','text','backgroundcolor',[0.94 0.94 0.94], ...
            'fontsize',16,'position',[0 0 120 60],'string', ...
            char('请稍候...',strcat('（约',num2str(2*str2double(wnum)),'秒）')), ...
            'horizontalalignment','center');
        pause(0.1);
        timer1 = timer('Period',1,'TimerFcn',@showtime, ...
            'ExecutionMode','fixedrate','StartDelay',0,'BusyMode','queue');
        timer2 = timer('Period',30,'TimerFcn',@showweather, ...
            'ExecutionMode','fixedrate','StartDelay',0,'BusyMode','queue');
        h_weather = figure(2);
        set(h_weather,'name','天气预报','menubar','none','numbertitle','off', ...
            'position',[50 50 1280 690],'resize','off','deletefcn',@hWeatherClose);
        s1 = uicontrol(h_weather,'style','text', ...
            'backgroundcolor',[0.94 0.94 0.94],'fontsize',12, ...
            'position',[0,660,640,20],'string','', ...
            'horizontalalignment','center');
        s2 = uicontrol(h_weather,'style','text', ...
            'backgroundcolor',[0.94 0.94 0.94],'fontsize',12, ...
            'position',[640,660,640,20],'string','', ...
            'horizontalalignment','center');
        s3 = gobjects(1,16);
        s4 = gobjects(1,16);
        for i = 1:16    % map name
            s3(i) = uicontrol(h_weather,'style','text', ...
                'backgroundcolor',[0.94 0.94 0.94],'fontsize',12, ...
                'position',[110+i*30,640,30,20],'string','', ...
                'horizontalalignment','center');
            s4(i) = uicontrol(h_weather,'style','text', ...
                'backgroundcolor',[0.94 0.94 0.94],'fontsize',12, ...
                'position',[750+i*30,640,30,20],'string','', ...
                'horizontalalignment','center');
        end
        s5 = gobjects(length(map),1);
        mapL = [24 1:6 25];
        mapS = [26 7:10 27];
        mapT = [28 11:15 29];
        mapI = [30 17 18];
        mapD = [31 20 21 19];
        mapA = [23 32:34 22];
        mapM = 16;
        mapind = [mapL mapS mapT mapI mapD mapA mapM];
        for i = 1:length(map)   % map name
            if i <= 21
                s5(i) = uicontrol(h_weather,'style','text', ...
                    'backgroundcolor',[0.94 0.94 0.94],'fontsize',12, ...
                    'position',[0,630-i*30,140,30],'string',map(mapind(i)).zh, ...
                    'horizontalalignment','left');
            else
                s5(i) = uicontrol(h_weather,'style','text', ...
                    'backgroundcolor',[0.94 0.94 0.94],'fontsize',12, ...
                    'position',[640,1260-i*30,140,30],'string',map(mapind(i)).zh, ...
                    'horizontalalignment','left');
            end
        end
        s6 = gobjects(length(map),str2double(wnum));
        img = 0.94*ones(32,32,3);
        for i = 1:size(s6,1)    % image shown
            for j = 1:size(s6,2)
                if i <= 21
                    s6(i,j) = axes(h_weather,'color',[0.94 0.94 0.94], ...
                        'unit','pixels','position',[110+j*30,635-i*30,30,30], ...
                        'xlim',[0.5 32.5],'ylim',[0.5 32.5],'xticklabel','', ...
                        'yticklabel','');
                else
                    s6(i,j) = axes(h_weather,'color',[0.94 0.94 0.94], ...
                        'unit','pixels','position',[750+j*30,1265-i*30,30,30], ...
                        'xlim',[0.5 32.5],'ylim',[0.5 32.5],'xticklabel','', ...
                        'yticklabel','');
                end
                image(s6(i,j),img);
                axis(s6(i,j),'off');
            end
        end
        close(m1);
        fprintf('Weather shown for %.2fs.\n',toc());
        drawnow;
        start(timer1);
        start(timer2);
        
        function showtime(~, ~) % timer1
            set(s1,'string',strcat('本地时间：',datestr(now(),31)));
            [emonth, eday, ehour, eminute, ~] = Eorzea(now(),timezone);
            set(s2,'string',strcat('艾欧泽亚时间：',num2str(emonth),'月', ...
                num2str(eday),'日',num2str(ehour),'时',num2str(eminute),'分'));
        end
        
        function showweather(~, ~)  % timer2
            for jj = 1:size(s6,2)
                [~, ~, ehour, ~, past] = Eorzea(now()+1400*(jj-2)/24/3600,timezone);
                rest = mod(past, 8*3600);
                adjtime = (past-rest) / (24*3600) * (70*60) / (24*3600);
                adjtime = adjtime + datenum('1970-01-01 00:00:00') + timezone/24;
                x = ehour - mod(ehour, 8);
                set(s3(jj),'string',num2str(x),'tooltipstring',datestr(adjtime,13));
                set(s4(jj),'string',num2str(x),'tooltipstring',datestr(adjtime,13));
                for ii = 1:size(s6,1)
                    tweather = forecast(map(mapind(ii)).rate, ...
                        calcWeather(now()+1400*(jj-2)/24/3600,timezone), ...
                        rate,weather.ch);
                    [img,colormap] = imread(strcat('icons\',tweather,'.png'), ...
                        'backgroundcolor',[0.94 0.94 0.94]);
                    if ~isempty(colormap)
                        img = ind2rgb(img,colormap);
                    end
                    set(get(s6(ii,jj),'children'),'cdata',img);
                end
            end
        end
        
        function hWeatherClose(~, ~)    % weather window closed
            set(h_button1,'enable','on');
            stop(timer1);
            stop(timer2);
            delete(timer1);
            delete(timer2);
        end
    end

%% Hunting
    function hunt(~, ~)
        set(h_button2,'enable','off');
        pause(0.1);
        tic;
        m1 = figure(6);
        set(m1,'name','','menubar','none','numbertitle','off', ...
            'position',[350 520 90 40],'resize','off');
        uicontrol(m1,'style','text','backgroundcolor',[0.94 0.94 0.94], ...
            'fontsize',16,'position',[0 0 90 40],'string','请稍候...', ...
            'horizontalalignment','center');
        pause(0.1);
        timer1 = timer('Period',30,'TimerFcn',@calc, ...
            'ExecutionMode','fixedrate','StartDelay',0,'BusyMode','queue');
        h_hunt = figure(3);
        set(h_hunt,'name','狩猎预测','menubar','none','numbertitle','off', ...
            'position',[200 100 930 740],'resize','off','deletefcn',@hHuntClose);
        s1 = gobjects(29,2);
        s2 = gobjects(29,2);
        s3 = gobjects(29,2);
        s4 = gobjects(29,2);
        for ii = 1:29   % text
            s1(ii) = uicontrol(h_hunt,'style','text', ...
                'backgroundcolor',[0.94 0.94 0.94],'fontsize',12, ...
                'position',[0,725-25*ii,150,30],'string','', ...
                'tooltipstring','', ...
                'horizontalalignment','left');
            s2(ii) = uicontrol(h_hunt,'style','text', ...
                'backgroundcolor',[0.94 0.94 0.94],'fontsize',12, ...
                'position',[150,725-25*ii,340,30],'string','', ...
                'tooltipstring','', ...
                'horizontalalignment','left');
            s3(ii) = uicontrol(h_hunt,'style','text', ...
                'backgroundcolor',[0.94 0.94 0.94],'fontsize',12, ...
                'position',[490,725-25*ii,100,30],'string','', ...
                'tooltipstring','', ...
                'horizontalalignment','left');
            s4(ii) = uicontrol(h_hunt,'style','text', ...
                'backgroundcolor',[0.94 0.94 0.94],'fontsize',12, ...
                'position',[590,725-25*ii,340,30],'string','', ...
                'tooltipstring','', ...
                'horizontalalignment','left');
        end
        close(m1);
        fprintf('Hunt shown for %.2fs.\n',toc());
        drawnow;
        start(timer1);
        
        function calc(~, ~) % timer1
            [atime,stime] = hunttime(map,monster,ktime,rate,weather.ch,timezone);
            for i = 1:29
                set(s1(i),'string',monster(atime.id(i)).ch, ...
                    'tooltipstring',monster(atime.id(i)).descch);
                set(s2(i),'string',atime.str(i,:),'tooltipstring','');
                if i > 23
                    continue;
                end
                set(s3(i),'string',monster(stime.id(i)).ch, ...
                    'tooltipstring',monster(stime.id(i)).descch);
                set(s4(i),'string',stime.str(i,:),'tooltipstring','');
            end
        end
        
        function hHuntClose(~, ~)   % hunt window closed
            set(h_button2,'enable','on');
            stop(timer1);
            delete(timer1);
        end
    end

%% Fishing
    function fishing(~, ~)
        set(h_button3,'enable','off');
        pause(0.1);
        tic;
        m1 = figure(6);
        set(m1,'name','','menubar','none','numbertitle','off', ...
            'position',[350 520 120 60],'resize','off');
        uicontrol(m1,'style','text','backgroundcolor',[0.94 0.94 0.94], ...
            'fontsize',16,'position',[0 0 120 60],'string', ...
            char('请稍候...',strcat('（约',num2str(3+length(list)),'秒）')), ...
            'horizontalalignment','center');
        pause(0.1);
        timer1 = timer('Period',20,'TimerFcn',@showtime, ...
            'ExecutionMode','fixedrate','StartDelay',0,'BusyMode','queue');
        timer2 = timer('Period',700,'TimerFcn',@reflesh, ...
            'ExecutionMode','fixedrate', ...
            'StartDelay',fix(mod((adjust(now())-now())*24*3600,700))+1,'BusyMode','queue');
        timer3 = timer('Period',1,'TimerFcn',@nowtime, ...
            'ExecutionMode','fixedrate','StartDelay',0,'BusyMode','queue');
        h_fishing = figure(4);
        set(h_fishing,'name','钓鱼时钟','menubar','none','numbertitle','off', ...
            'position',[400 200 690 600],'resize','off','deletefcn',@hFishClose, ...
            'windowscrollwheelfcn',@slidepanel2);
        c1 = uicontrol(h_fishing,'style','text', ...
            'backgroundcolor',[0.94 0.94 0.94],'fontsize',12, ...
            'position',[60,565,250,20],'string','', ...
            'horizontalalignment','left');
        c2 = uicontrol(h_fishing,'style','text', ...
            'backgroundcolor',[0.94 0.94 0.94],'fontsize',12, ...
            'position',[350,565,250,20],'string','', ...
            'horizontalalignment','left');
        uicontrol(h_fishing,'style','pushbutton','fontsize',16, ...
            'position',[640 560 50 30],'string','设置','callback',@setFish);
        panel1 = uipanel(h_fishing,'unit','pixels', ...
            'position',[0 0 690 550],'backgroundcolor',[0.94 0.94 0.94]);
        panel2 = uipanel(panel1,'unit','pixels', ...
            'position',[0 0 660 550],'backgroundcolor',[0.94 0.94 0.94]);
        slider1 = uicontrol(panel1,'style','slider', ...
            'position',[660 0 30 550],'callback',@slidepanel);
        fishtime = struct([]);
        for id = 1:length(list)
            fishtime = fishingTimer(fishtime, allfish, now(), list(id), ...
                map, rate, weather.ch, timezone);
        end
        sortlist = sortfish(fishtime, list);
        
        s1 = gobjects(0);
        s2 = gobjects(0);
        s3 = gobjects(0);
        s4 = gobjects(0);
        s5 = gobjects(0);
        s6 = gobjects(0);
        s7 = gobjects(0);
        s8 = gobjects(0);
        update();
        close(m1);
        fprintf('Fishtimer shown for %.2fs.\n',toc());
        drawnow;
        start(timer1);
        start(timer2);
        start(timer3);
        
        function adjtime = adjust(time)
            % adjust time to o'clock
            
            [~, ~, ~, ~, past] = Eorzea(time,timezone);
            rest = mod(past, 8*3600);
            adjtime = (past-rest) / (24*3600) * (70*60) / (24*3600);
            adjtime = adjtime + datenum('1970-01-01 00:00:00') + timezone/24;
        end
        
        function setFish(~, ~)  % settings
            fishtable = figure(7);
            set(fishtable,'name','鱼类设置','menubar','none','numbertitle','off', ...
                'position',[250 150 700 600],'resize','off','windowscrollwheelfcn',@slidepanel3);
            ver = ['2.2    ';'2.3    ';'2.4    ';'2.5-3.2';'3.3    ';'3.4    ';'3.5    '];
            tver = 7;
            fishnum = [37 87 112 155 169 183 200];
            fishnum2 = [0 fishnum(1:end-1)]+1;
            fishdiff = [0 2 3 5 7 8 9];
            version = gobjects(1,tver);
            version1 = gobjects(1,tver);
            version2 = gobjects(1,tver);
            for t = 1:tver  % version
                version(t) = uicontrol(fishtable,'style','text', ...
                    'backgroundcolor',[0.94 0.94 0.94],'fontsize',12, ...
                    'position',[10,640-70*t,60,20],'string',ver(t,:), ...
                    'horizontalalignment','center');
                version1(t) = uicontrol(fishtable,'style','checkbox', ...
                    'backgroundcolor',[0.94 0.94 0.94],'fontsize',12, ...
                    'position',[10,620-70*t,60,20],'string','全选', ...
                    'horizontalalignment','center','callback',{@sAll,t});
                version2(t) = uicontrol(fishtable,'style','checkbox', ...
                    'backgroundcolor',[0.94 0.94 0.94],'fontsize',12, ...
                    'position',[10,600-70*t,60,20],'string','全否', ...
                    'horizontalalignment','center','callback',{@sNo,t});
            end
            uicontrol(fishtable,'style','pushbutton', ...
                'fontsize',16,'position',[15 50 50 30],'string','确定', ...
                'callback',@setFishOK);
            uicontrol(fishtable,'style','pushbutton', ...
                'fontsize',16,'position',[15 10 50 30],'string','取消', ...
                'callback','close(7)');
            panel3 = uipanel(fishtable,'unit','pixels', ...
                'position',[70 -1500 600 2100],'backgroundcolor',[0.94 0.94 0.94]);
            slider2 = uicontrol(fishtable,'style','slider', ...
                'position',[670 0 30 600],'max',50,'value',50, ...
                'sliderstep',[1/50 3/50],'callback',@sp);
            
            fish = gobjects(1,length(allfish));
            for t = 1:length(allfish)
                p = t + fishdiff(find(fishnum-t>=0,1));
                fish(t) = uicontrol(panel3,'style','checkbox', ...
                    'backgroundcolor',[0.94 0.94 0.94],'fontsize',12, ...
                    'position',[200*mod(p-1,3),2100-30*ceil(p/3),210,30], ...
                    'string',allfish(t).name,'value',double(~isempty(find(sortlist==t,1))), ...
                    'horizontalalignment','left','callback',@selectF);
            end
            updateSelect();
            
            function sAll(~, ~, t)
                if get(version1(t),'value') == 1
                    set(version2(t),'value',0);
                    for k = fishnum2(t):fishnum(t)
                        set(fish(k),'value',1);
                    end
                end
            end
            
            function sNo(~, ~, t)
                if get(version2(t),'value') == 1
                    set(version1(t),'value',0);
                    for k = fishnum2(t):fishnum(t)
                        set(fish(k),'value',0);
                    end
                end
            end
            
            function selectF(~, ~)
                updateSelect();
            end
            
            function updateSelect()
                y = ones(1,tver);
                n = ones(1,tver);
                for k = 1:tver
                    if length(allfish) >= fishnum(k)
                        set(version1(k),'enable','on');
                        set(version2(k),'enable','on');
                    else
                        set(version1(k),'enable','off');
                        set(version2(k),'enable','off');
                        y(k) = 0;
                        n(k) = 0;
                    end
                end
                
                for tt = 1:length(allfish)
                    pp = find(fishnum-tt>=0,1);
                    y(pp) = y(pp) * (get(fish(tt),'value'));
                    n(pp) = n(pp) * (1-get(fish(tt),'value'));
                end
                
                for k = 1:tver
                    set(version1(k),'value',y(k));
                    set(version2(k),'value',n(k));
                end
            end
            
            function setFishOK(~, ~)	% confirm select
                stop(timer1);
                stop(timer2);
                temp = sortlist;
                sortlist = [];
                for i = 1:length(allfish)
                    if get(fish(i),'value') == 1
                        sortlist = cat(1,sortlist,i);
                    end
                end
                close(fishtable);
                pause(0.1);
                tic;
                m1 = figure(6);
                temp = setdiff(sortlist, temp);
                set(m1,'name','','menubar','none','numbertitle','off', ...
                    'position',[350 520 120 60],'resize','off');
                uicontrol(m1,'style','text','backgroundcolor',[0.94 0.94 0.94], ...
                    'fontsize',16,'position',[0 0 120 60],'string', ...
                    char('请稍候...',strcat('（约',num2str(3+length(temp)),'秒）')), ...
                    'horizontalalignment','center');
                pause(0.1);
                for i = 1:length(temp)
                    fishtime = fishingTimer(fishtime, allfish, now(), temp(i), ...
                        map, rate, weather.ch, timezone);
                end
                sortlist = sortfish(fishtime, sortlist);
                update();
                close(m1);
                fprintf('Updated for %.2fs.\n',toc());
                drawnow;
                start(timer1);
                start(timer2);
            end
            
            function sp(~, ~)
                temp = get(panel3,'position');
                sh = get(slider2,'max') - get(slider2,'value');
                temp(2) = -1500+30*sh;
                set(panel3,'position',temp);
            end
            
            function slidepanel3(~, event)
                temp = get(slider2,'value');
                sh = event.VerticalScrollCount;
                temp = min(max(temp-sh,get(slider2,'min')),get(slider2,'max'));
                set(slider2,'value',temp);
                sp();
            end
            
        end
        
        function update()
            if ishghandle(s1)
                delete(s1);
            end
            if ishghandle(s2)
                delete(s2);
            end
            if ishghandle(s3)
                delete(s3);
            end
            if ishghandle(s4)
                delete(s4);
            end
            if ishghandle(s5)
                delete(s5);
            end
            if ishghandle(s6)
                delete(s6);
            end
            if ishghandle(s7)
                delete(s7);
            end
            if ishghandle(s8)
                delete(s8);
            end
            set(panel2,'position',[0 540-30*length(sortlist) 680 30*length(sortlist)+10]);
            
            s1 = gobjects(length(sortlist),1); % icon
            s2 = gobjects(length(sortlist),1); % name
            s3 = gobjects(length(sortlist),1); % mapname
            s4 = gobjects(length(sortlist),1); % starttime
            s5 = gobjects(length(sortlist),1); % endtime
            s6 = gobjects(length(sortlist),1); % progress
            s7 = gobjects(length(sortlist),1); % nexttime
            s8 = gobjects(length(sortlist),1); % description
            temp = get(panel2,'position');
            height = temp(4)-10;
            img = 0.94*ones(128,128,3);
            for i = 1:length(sortlist)
                s1(i) = axes(panel2,'color',[0.94 0.94 0.94], ...
                    'unit','pixels','position',[0,height+2-i*30,30,30], ...
                    'xlim',[0.5 128.5],'ylim',[0.5 128.5],'xticklabel','','yticklabel','');
                image(s1(i),img);
                axis(s1(i),'off');
                s2(i) = uicontrol(panel2,'style','text', ...
                    'backgroundcolor',[0.94 0.94 0.94],'fontsize',12, ...
                    'position',[30,height-i*30,190,30], ...
                    'string','','horizontalalignment','left');
                s3(i) = uicontrol(panel2,'style','text', ...
                    'backgroundcolor',[0.94 0.94 0.94],'fontsize',12, ...
                    'position',[210,height-i*30,140,30], ...
                    'string','','horizontalalignment','left');
                s4(i) = uicontrol(panel2,'style','text', ...
                    'backgroundcolor',[0.94 0.94 0.94],'fontsize',8, ...
                    'position',[350,height-i*30+15,80,15], ...
                    'string','','horizontalalignment','left');
                s5(i) = uicontrol(panel2,'style','text', ...
                    'backgroundcolor',[0.94 0.94 0.94],'fontsize',8, ...
                    'position',[510,height-i*30+15,80,15], ...
                    'string','','horizontalalignment','right');
                s6(i) = uicontrol(panel2,'style','text', ...
                    'backgroundcolor',[0.94 0.94 0.94], ...
                    'position',[350,height-i*30+6,240,6], ...
                    'string','');
                s7(i) = uicontrol(panel2,'style','text', ...
                    'backgroundcolor',[0.94 0.94 0.94],'fontsize',12, ...
                    'position',[590,height-i*30,40,30], ...
                    'string','预测','horizontalalignment','center');
                s8(i) = uicontrol(panel2,'style','text', ...
                    'backgroundcolor',[0.94 0.94 0.94],'fontsize',12, ...
                    'position',[630,height-i*30,30,30], ...
                    'string','','horizontalalignment','center');
            end
            showtime();
            if length(sortlist) <= 18
                set(slider1,'max',0,'value',0,'enable','off');
            else
                set(slider1,'max',length(sortlist)-18, ...
                    'value',length(sortlist)-18,'enable','on', ...
                    'sliderstep',[1/(length(sortlist)-18),3/(length(sortlist)-18)]);
            end
        end
        
        function showtime(~, ~)	% timer1
            for i = 1:length(sortlist)
                if now()>datenum(fishtime(sortlist(i)).time(2,:))
                    fishtime = fishingTimer(fishtime, allfish, now(), sortlist(i), ...
                        map, rate, weather.ch, timezone);
                end
            end
            sortlist = sortfish(fishtime, sortlist);
            
            for i = 1:length(sortlist)
                [img,colormap] = imread(strcat('fish\',num2str(sortlist(i)),'.png'), ...
                    'backgroundcolor',[0.94 0.94 0.94]);
                if ~isempty(colormap)
                    img = ind2rgb(img,colormap);
                end
                set(get(s1(i),'children'),'cdata',img);
                set(s2(i),'string',allfish(sortlist(i)).name);
                set(s3(i),'string',allfish(sortlist(i)).map, ...
                    'foregroundcolor',fgc(allfish(sortlist(i)).map), ...
                    'tooltipstring',strcat('钓场：',allfish(sortlist(i)).spot));
                set(s4(i),'string',fscn(fishtime(sortlist(i)).time(1,:)));
                set(s5(i),'string',fscn(fishtime(sortlist(i)).time(2,:)));
                temp = get(s6(i),'position');
                temp(3) = progress(fishtime(sortlist(i)).time);
                set(s6(i),'backgroundcolor',pgs(fishtime(sortlist(i)).flag), ...
                    'position',temp);
                set(s7(i),'tooltipstring',sprintf(nextTime(fishtime(sortlist(i)))));
                set(s8(i),'string',state(fishtime(sortlist(i))), ...
                    'foregroundcolor',fgc2(fishtime(sortlist(i))), ...
                    'tooltipstring',sprintf(description(allfish(sortlist(i)))));
            end
        end
        
        function reflesh(~, ~)  % timer2
            stop(timer1);
            for i = 1:length(sortlist)
                if fishtime(sortlist(i)).flag == 1 || datenum(fishtime(sortlist(i)).time(6,:))-now()>1
                    fishtime = fishingTimer(fishtime, allfish, now(), sortlist(i), ...
                        map, rate, weather.ch, timezone);
                end
            end
            sortlist = sortfish(fishtime, sortlist);
            start(timer1);
        end
        
        function nowtime(~, ~)  % timer3
            set(c1,'string',strcat('本地时间：',datestr(now(),31)));
            [emonth, eday, ehour, eminute, ~] = Eorzea(now(),timezone);
            set(c2,'string',strcat('艾欧泽亚时间：',num2str(emonth),'月', ...
                num2str(eday),'日',num2str(ehour),'时',num2str(eminute),'分'));
        end
        
        function slidepanel(~, ~)
            temp = get(panel2,'position');
            sh = get(slider1,'max') - get(slider1,'value');
            temp(2) = 540-30*length(sortlist)+30*sh;
            set(panel2,'position',temp);
        end
        
        function slidepanel2(~, event)
            temp = get(slider1,'value');
            sh = event.VerticalScrollCount;
            temp = min(max(temp-sh,get(slider1,'min')),get(slider1,'max'));
            set(slider1,'value',temp);
            slidepanel();
        end
        
        function color = fgc(str)
            mapL = [24 1:6 25];
            mapS = [26 7:10 27];
            mapT = [28 11:15 29];
            mapI = [30 17 18];
            mapD = [31 20 21 19];
            mapA = [23 32:34 22];
%             mapM = 16;
            col = find(strcmp({map.zh},str),1);
            if ismember(col,mapL)
                color = 'b';
            elseif ismember(col,mapS)
                color = [0 0.5 0];
            elseif ismember(col,mapT)
                color = [1 0.6 0];
            elseif ismember(col,mapI)
                color = [0.6 0.85 1];
            elseif ismember(col,mapD)
                color = [0.85 0.5 0];
            elseif ismember(col,mapA)
                color = [0 0.85 0.85];
            else
                color = 'k';
            end
        end
        
        function str = fscn(time,~)
            if abs(now()-datenum(time)) > 1
                str = '---';
            else
                str = datestr(time,13);
            end
        end
        
        function l = progress(time)
            alpha = (now() - datenum(time(1,:))) / (datenum(time(2,:)) - datenum(time(1,:)));
            l = round(240 * alpha);
            if l == 0
                l = 1;
            end
        end
        
        function color = pgs(flag)
            if flag == 1
                color = 'g';
            else
                color = 'b';
            end
        end
        
        function str = nextTime(fishtime)
            if fishtime.flag == 1 && datenum(fishtime.time(2,:))-now()>1
                str = '持续至少一天';
            else
                str = '  下次：';
                if fishtime.flag == 1
                    k = 3;
                else
                    k = 2;
                end
                if datenum(fishtime.time(k,:))-now()>1
                    str = strcat(str,'至少一天后');
                    return;
                else
                    str = strcat(str,datestr(fishtime.time(k,:),13),' 至');
                end
                if datenum(fishtime.time(k+1,:))-now()>1
                    str = strcat(str,32,'至少一天后');
                    return;
                else
                    str = strcat(str,32,datestr(fishtime.time(k+1,:),13),'\n下下次：');
                end
                if datenum(fishtime.time(k+2,:))-now()>1
                    str = strcat(str,'至少一天后');
                    return;
                else
                    str = strcat(str,datestr(fishtime.time(k+2,:),13),' 至');
                end
                if datenum(fishtime.time(k+3,:))-now()>1
                    str = strcat(str,32,'至少一天后');
                    return;
                else
                    str = strcat(str,32,datestr(fishtime.time(k+3,:),13));
                end
            end
        end
        
        function s = state(fishtime)
            if fishtime.best == 1
                s = '优';
            elseif fishtime.flag == 1
                s = '良';
            else
                s = '未';
            end
        end
        
        function color = fgc2(fishtime)
            if fishtime.best == 1
                color = 'g';
            elseif fishtime.flag == 1
                color = 'b';
            else
                color = 'k';
            end
        end
        
        function des = description(fish)
            des = strcat('鱼饵：',fish.lure,'\n获得力：',num2str(fish.gather), ...
                '\n钓法：',fish.description);
        end
        
        function hFishClose(~, ~)   % fish window closed
            set(h_button3,'enable','on');
            stop(timer1);
            delete(timer1);
            stop(timer2);
            delete(timer2);
            stop(timer3);
            delete(timer3);
            list = sortlist;
            save('fishlist.mat','list');
        end
    end

%% Sightseeing
    function sightseeing(~, ~)
        set(h_button4,'enable','off');
        pause(0.1);
        tic;
        m1 = figure(6);
        set(m1,'name','','menubar','none','numbertitle','off', ...
            'position',[350 520 120 60],'resize','off');
        uicontrol(m1,'style','text','backgroundcolor',[0.94 0.94 0.94], ...
            'fontsize',16,'position',[0 0 120 60],'string', ...
            char('请稍候...',strcat('（约',num2str(3+length(list2)),'秒）')), ...
            'horizontalalignment','center');
        pause(0.1);
        timer1 = timer('Period',20,'TimerFcn',@showtime, ...
            'ExecutionMode','fixedrate','StartDelay',0,'BusyMode','queue');
        timer2 = timer('Period',3600,'TimerFcn',@reflesh, ...
            'ExecutionMode','fixedrate','StartDelay',1800,'BusyMode','queue');
        timer3 = timer('Period',1,'TimerFcn',@nowtime, ...
            'ExecutionMode','fixedrate','StartDelay',0,'BusyMode','queue');
        h_sightseeing = figure(5);
        set(h_sightseeing,'name','探索笔记','menubar','none','numbertitle','off', ...
            'position',[500 200 600 600],'resize','off','deletefcn',@hSightseeingClose, ...
            'windowscrollwheelfcn',@slidepanel2);
        c1 = uicontrol(h_sightseeing,'style','text', ...
            'backgroundcolor',[0.94 0.94 0.94],'fontsize',12, ...
            'position',[20,565,250,20],'string','', ...
            'horizontalalignment','left');
        c2 = uicontrol(h_sightseeing,'style','text', ...
            'backgroundcolor',[0.94 0.94 0.94],'fontsize',12, ...
            'position',[270,565,250,20],'string','', ...
            'horizontalalignment','left');
        uicontrol(h_sightseeing,'style','pushbutton','fontsize',16, ...
            'position',[550 560 50 30],'string','设置','callback',@setSight);
        panel1 = uipanel(h_sightseeing,'unit','pixels', ...
            'position',[0 0 600 550],'backgroundcolor',[0.94 0.94 0.94]);
        panel2 = uipanel(panel1,'unit','pixels', ...
            'position',[0 0 570 550],'backgroundcolor',[0.94 0.94 0.94]);
        slider1 = uicontrol(panel1,'style','slider', ...
            'position',[570 0 30 550],'callback',@slidepanel);
        sighttime = struct([]);
        for id = 1:length(list2)
            sighttime = fishingTimer(sighttime, allsight, now(), list2(id), ...
                map, rate, weather.ch, timezone);
        end
        sortlist = sortfish(sighttime, list2);
        s1 = gobjects(0);
        s2 = gobjects(0);
        s3 = gobjects(0);
        s4 = gobjects(0);
        s5 = gobjects(0);
        s6 = gobjects(0);
        s7 = gobjects(0);
        s8 = gobjects(0);
        update();
        close(m1);
        fprintf('Sightseeingtimer shown for %.2fs.\n',toc());
        drawnow;
        start(timer1);
        start(timer2);
        start(timer3);
        
        function setSight(~, ~)
            sighttable = figure(8);
            set(sighttable,'name','探索设置','menubar','none','numbertitle','off', ...
                'position',[250 150 460 600],'resize','off','windowscrollwheelfcn',@slidepanel3);
            version1 = gobjects(1,2);
            version2 = gobjects(1,2);
            uicontrol(sighttable,'style','text', ...
                'backgroundcolor',[0.94 0.94 0.94],'fontsize',12, ...
                'position',[10,490,60,20],'string','1-20', ...
                'horizontalalignment','center');
            version1(1) = uicontrol(sighttable,'style','checkbox', ...
                'backgroundcolor',[0.94 0.94 0.94],'fontsize',12, ...
                'position',[10,470,60,20],'string','全选', ...
                'horizontalalignment','center','callback',{@sAll,1});
            version2(1) = uicontrol(sighttable,'style','checkbox', ...
                'backgroundcolor',[0.94 0.94 0.94],'fontsize',12, ...
                'position',[10,450,60,20],'string','全否', ...
                'horizontalalignment','center','callback',{@sNo,1});
            uicontrol(sighttable,'style','text', ...
                'backgroundcolor',[0.94 0.94 0.94],'fontsize',12, ...
                'position',[10,230,60,20],'string','21-80', ...
                'horizontalalignment','center');
            version1(2) = uicontrol(sighttable,'style','checkbox', ...
                'backgroundcolor',[0.94 0.94 0.94],'fontsize',12, ...
                'position',[10,210,60,20],'string','全选', ...
                'horizontalalignment','center','callback',{@sAll,2});
            version2(2) = uicontrol(sighttable,'style','checkbox', ...
                'backgroundcolor',[0.94 0.94 0.94],'fontsize',12, ...
                'position',[10,190,60,20],'string','全否', ...
                'horizontalalignment','center','callback',{@sNo,2});
            uicontrol('parent',sighttable,'style','pushbutton', ...
                'fontsize',16,'position',[15 50 50 30],'string','确定', ...
                'callback',@setSightOK);
            uicontrol('parent',sighttable,'style','pushbutton', ...
                'fontsize',16,'position',[15 10 50 30],'string','取消', ...
                'callback','close(8)');
            panel3 = uipanel('parent',sighttable,'unit','pixels', ...
                'position',[70 -210 360 810],'backgroundcolor',[0.94 0.94 0.94]);
            slider2 = uicontrol('parent',sighttable,'style','slider', ...
                'position',[430 0 30 600],'max',7,'value',7, ...
                'sliderstep',[1/7 3/7],'callback',@sp);
            
            sight = gobjects(1,length(allsight));
            for t = 1:length(allsight)
                if t > 20
                    p = t + 1;
                else
                    p = t;
                end
                sight(t) = uicontrol('parent',panel3,'style','checkbox', ...
                    'backgroundcolor',[0.94 0.94 0.94],'fontsize',12, ...
                    'position',[120*mod(p-1,3),810-30*ceil(p/3),120,30], ...
                    'string',num2str(t,'%.3d'),'value',double(~isempty(find(sortlist==t,1))), ...
                    'horizontalalignment','left','callback',{@selectF,t});
            end
            updateSelect();
            
            function sAll(~, ~, t)
                if get(version1(t),'value') == 1
                    set(version2(t),'value',0);
                    switch t
                        case 1
                            a = [1 20];
                        case 2
                            a = [21 80];
                    end
                    for k = a(1):a(2)
                        set(sight(k),'value',1);
                    end
                end
            end
            
            function sNo(~, ~, t)
                if get(version2(t),'value') == 1
                    set(version1(t),'value',0);
                    switch t
                        case 1
                            a = [1 20];
                        case 2
                            a = [21 80];
                    end
                    for k = a(1):a(2)
                        set(sight(k),'value',0);
                    end
                end
            end
            
            function selectF(~, ~, ~)
                updateSelect();
            end
            
            function updateSelect()
                y = ones(1,2);
                n = ones(1,2);
                if length(allsight) >= 20
                    set(version1(1),'enable','on');
                    set(version2(1),'enable','on');
                else
                    set(version1(1),'enable','off');
                    set(version2(1),'enable','off');
                    y(1) = 0;
                    n(1) = 0;
                end
                if length(allsight) >= 80
                    set(version1(2),'enable','on');
                    set(version2(2),'enable','on');
                else
                    set(version1(2),'enable','off');
                    set(version2(2),'enable','off');
                    y(2) = 0;
                    n(2) = 0;
                end
                
                for tt = 1:length(allsight)
                    if tt > 20
                        pp = 2;
                    else
                        pp = 1;
                    end
                    y(pp) = y(pp) * (get(sight(tt),'value'));
                    n(pp) = n(pp) * (1-get(sight(tt),'value'));
                end
                
                for k = 1:2
                    set(version1(k),'value',y(k));
                    set(version2(k),'value',n(k));
                end
            end
            
            function setSightOK(~, ~)
                stop(timer1);
                stop(timer2);
                temp = sortlist;
                sortlist = [];
                for i = 1:length(allsight)
                    if get(sight(i),'value') == 1
                        sortlist = cat(1,sortlist,i);
                    end
                end
                close(sighttable);
                pause(0.1);
                tic;
                m1 = figure(6);
                temp = setdiff(sortlist, temp);
                set(m1,'name','','menubar','none','numbertitle','off', ...
                    'position',[350 520 120 60],'resize','off');
                uicontrol('parent',m1,'style','text','backgroundcolor',[0.94 0.94 0.94], ...
                    'fontsize',16,'position',[0 0 120 60],'string', ...
                    char('请稍候...',strcat('（约',num2str(3+length(temp)),'秒）')), ...
                    'horizontalalignment','center');
                pause(0.1);
                for i = 1:length(temp)
                    sighttime = fishingTimer(sighttime, allsight, now(), temp(i), ...
                        map, rate, weather.ch, timezone);
                end
                sortlist = sortfish(sighttime, sortlist);
                update();
                close(m1);
                fprintf('Updated for %.2fs.\n',toc());
                drawnow;
                start(timer1);
                start(timer2);
            end
            
            function sp(~, ~)
                temp = get(panel3,'position');
                sh = get(slider2,'max') - get(slider2,'value');
                temp(2) = -210+30*sh;
                set(panel3,'position',temp);
            end
            
            function slidepanel3(~, event)
                temp = get(slider2,'value');
                sh = event.VerticalScrollCount;
                temp = min(max(temp-sh,get(slider2,'min')),get(slider2,'max'));
                set(slider2,'value',temp);
                sp();
            end
        end
        
        function update()
            if ishghandle(s1)
                delete(s1);
            end
            if ishghandle(s2)
                delete(s2);
            end
            if ishghandle(s3)
                delete(s3);
            end
            if ishghandle(s4)
                delete(s4);
            end
            if ishghandle(s5)
                delete(s5);
            end
            if ishghandle(s6)
                delete(s6);
            end
            if ishghandle(s7)
                delete(s7);
            end
            if ishghandle(s8)
                delete(s8);
            end
            set(panel2,'position',[0 540-30*length(sortlist) 570 30*length(sortlist)+10]);
            
            s1 = gobjects(length(sortlist),1); % icon
            s2 = gobjects(length(sortlist),1); % name
            s3 = gobjects(length(sortlist),1); % mapname
            s4 = gobjects(length(sortlist),1); % starttime
            s5 = gobjects(length(sortlist),1); % endtime
            s6 = gobjects(length(sortlist),1); % progress
            s7 = gobjects(length(sortlist),1); % nexttime
            s8 = gobjects(length(sortlist),1); % description
            temp = get(panel2,'position');
            height = temp(4)-10;
            img = 0.94*ones(32,32,3);
            for i = 1:length(sortlist)
                s1(i) = axes('parent',panel2,'color',[0.94 0.94 0.94], ...
                    'unit','pixels','position',[0,height+2-i*30,30,30], ...
                    'xlim',[0.5 32.5],'ylim',[0.5 32.5],'xticklabel','','yticklabel','');
                image(s1(i),img);
                axis(s1(i),'off');
                s2(i) = uicontrol('parent',panel2,'style','text', ...
                    'backgroundcolor',[0.94 0.94 0.94],'fontsize',12, ...
                    'position',[30,height-i*30,90,30], ...
                    'string','','horizontalalignment','left');
                s3(i) = uicontrol('parent',panel2,'style','text', ...
                    'backgroundcolor',[0.94 0.94 0.94],'fontsize',12, ...
                    'position',[120,height-i*30,140,30], ...
                    'string','','horizontalalignment','left');
                s4(i) = uicontrol('parent',panel2,'style','text', ...
                    'backgroundcolor',[0.94 0.94 0.94],'fontsize',8, ...
                    'position',[260,height-i*30+15,80,15], ...
                    'string','','horizontalalignment','left');
                s5(i) = uicontrol('parent',panel2,'style','text', ...
                    'backgroundcolor',[0.94 0.94 0.94],'fontsize',8, ...
                    'position',[420,height-i*30+15,80,15], ...
                    'string','','horizontalalignment','right');
                s6(i) = uicontrol('parent',panel2,'style','text', ...
                    'backgroundcolor',[0.94 0.94 0.94], ...
                    'position',[260,height-i*30+6,240,6], ...
                    'string','');
                s7(i) = uicontrol('parent',panel2,'style','text', ...
                    'backgroundcolor',[0.94 0.94 0.94],'fontsize',12, ...
                    'position',[500,height-i*30,40,30], ...
                    'string','预测','horizontalalignment','center');
                s8(i) = uicontrol('parent',panel2,'style','text', ...
                    'backgroundcolor',[0.94 0.94 0.94],'fontsize',12, ...
                    'position',[540,height-i*30,30,30], ...
                    'string','','horizontalalignment','center');
            end
            showtime();
            if length(sortlist) <= 18
                set(slider1,'max',0,'value',0,'enable','off');
            else
                set(slider1,'max',length(sortlist)-18, ...
                    'value',length(sortlist)-18,'enable','on', ...
                    'sliderstep',[1/(length(sortlist)-18) 3/(length(sortlist)-18)]);
            end
        end
        
        function showtime(~, ~)
            for i = 1:length(sortlist)
                if now()>datenum(sighttime(sortlist(i)).time(2,:))
                    sighttime = fishingTimer(sighttime, allsight, now(), sortlist(i), ...
                        map, rate, weather.ch, timezone);
                end
            end
            sortlist = sortfish(sighttime, sortlist);
            
            for i = 1:length(sortlist)
                [img,colormap] = imread(strcat('icons\',cell2mat(allsight(sortlist(i)).weather1(1)),'.png'), ...
                    'backgroundcolor',[0.94 0.94 0.94]);
                if ~isempty(colormap)
                    img = ind2rgb(img,colormap);
                end
                set(get(s1(i),'children'),'cdata',img);
                set(s2(i),'string',num2str(sortlist(i),'%.3d'));
                set(s3(i),'string',allsight(sortlist(i)).map, ...
                    'foregroundcolor',fgc(allsight(sortlist(i)).map), ...
                    'tooltipstring',strcat('坐标：',allsight(sortlist(i)).spot));
                set(s4(i),'string',fscn(sighttime(sortlist(i)).time(1,:)));
                set(s5(i),'string',fscn(sighttime(sortlist(i)).time(2,:)));
                temp = get(s6(i),'position');
                temp(3) = progress(sighttime(sortlist(i)).time);
                set(s6(i),'backgroundcolor',pgs(sighttime(sortlist(i)).flag), ...
                    'position',temp);
                set(s7(i),'tooltipstring',sprintf(nextTime(sighttime(sortlist(i)))));
                set(s8(i),'string',state(sighttime(sortlist(i))), ...
                    'foregroundcolor',fgc2(sighttime(sortlist(i))), ...
                    'tooltipstring',sprintf(description(allsight(sortlist(i)))));
            end
        end
        
        function reflesh(~, ~)
            stop(timer1);
            for i = 1:length(sortlist)
                sighttime = fishingTimer(sighttime, allsight, now(), sortlist(i), ...
                    map, rate, weather.ch, timezone);
            end
            sortlist = sortfish(sighttime, sortlist);
            start(timer1);
        end
        
        function nowtime(~, ~)
            set(c1,'string',strcat('本地时间：',datestr(now(),31)));
            [emonth, eday, ehour, eminute, ~] = Eorzea(now(),timezone);
            set(c2,'string',strcat('艾欧泽亚时间：',num2str(emonth),'月', ...
                num2str(eday),'日',num2str(ehour),'时',num2str(eminute),'分'));
        end
        
        function slidepanel(~, ~)
            temp = get(panel2,'position');
            sh = get(slider1,'max') - get(slider1,'value');
            temp(2) = 540-30*length(sortlist)+30*sh;
            set(panel2,'position',temp);
        end
        
        function slidepanel2(~, event)
            temp = get(slider1,'value');
            sh = event.VerticalScrollCount;
            temp = min(max(temp-sh,get(slider1,'min')),get(slider1,'max'));
            set(slider1,'value',temp);
            slidepanel();
        end
        
        function color = fgc(str)
            mapL = [24 1:6 25];
            mapS = [26 7:10 27];
            mapT = [28 11:15 29];
            mapI = [30 17 18];
            mapD = [31 20 21 19];
            mapA = [23 32:34 22];
%             mapM = 16;
            col = find(strcmp({map.zh},str),1);
            if ismember(col,mapL)
                color = 'b';
            elseif ismember(col,mapS)
                color = [0 0.5 0];
            elseif ismember(col,mapT)
                color = [1 0.6 0];
            elseif ismember(col,mapI)
                color = [0.6 0.85 1];
            elseif ismember(col,mapD)
                color = [0.85 0.5 0];
            elseif ismember(col,mapA)
                color = [0 0.85 0.85];
            else
                color = 'k';
            end
        end
        
        function str = fscn(time,~)
            if abs(now()-datenum(time)) > 1
                str = '---';
            else
                str = datestr(time,13);
            end
        end
        
        function l = progress(time)
            alpha = (now() - datenum(time(1,:))) / (datenum(time(2,:)) - datenum(time(1,:)));
            l = round(240 * alpha);
            if l == 0
                l = 1;
            end
        end
        
        function color = pgs(flag)
            if flag == 1
                color = 'g';
            else
                color = 'b';
            end
        end
        
        function str = nextTime(sighttime)
            if sighttime.flag == 1 && datenum(sighttime.time(2,:))-now()>1
                str = '持续至少一天';
            else
                str = '  下次：';
                if sighttime.flag == 1
                    k = 3;
                else
                    k = 2;
                end
                if datenum(sighttime.time(k,:))-now()>1
                    str = strcat(str,'至少一天后');
                    return;
                else
                    str = strcat(str,datestr(sighttime.time(k,:),13),' 至');
                end
                if datenum(sighttime.time(k+1,:))-now()>1
                    str = strcat(str,32,'至少一天后');
                    return;
                else
                    str = strcat(str,32,datestr(sighttime.time(k+1,:),13),'\n下下次：');
                end
                if datenum(sighttime.time(k+2,:))-now()>1
                    str = strcat(str,'至少一天后');
                    return;
                else
                    str = strcat(str,datestr(sighttime.time(k+2,:),13),' 至');
                end
                if datenum(sighttime.time(k+3,:))-now()>1
                    str = strcat(str,32,'至少一天后');
                    return;
                else
                    str = strcat(str,32,datestr(sighttime.time(k+3,:),13));
                end
            end
        end
        
        function s = state(sighttime)
            if sighttime.flag == 1
                s = '优';
            else
                s = '未';
            end
        end
        
        function color = fgc2(sighttime)
            if sighttime.flag == 1
                color = 'g';
            else
                color = 'k';
            end
        end
        
        function des = description(sight)
            des = strcat('景点：',sight.name, ...
                '\n动作：',sight.lure, ...
                '\n备注：',sight.description);
        end
        
        function hSightseeingClose(~, ~)
            set(h_button4,'enable','on');
            stop(timer1);
            delete(timer1);
            stop(timer2);
            delete(timer2);
            stop(timer3);
            delete(timer3);
            list2 = sortlist;
            save('sightlist.mat','list2');
        end
    end
end
