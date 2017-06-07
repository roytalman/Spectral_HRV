
% Written by Roy Talman - Email roytalman@gmail.com
% Last edited Roy Talman 6.5.2017

Git_Path = 'C:\Users\lab5\Documents\Spectral_HRV'; % path to your git folder
[Hour,IBI] = textread([Git_Path '\IBI_Data.txt'],'%s %d','delimiter',';'); % read text IBI's data
% translate hour to time (in secounds)
Time = cellfun(@(x) str2num(x(1:2))*3600 + str2num(x(4:5))*60 +  str2num(x(7:8)) + str2num(x(10:12))/1000,Hour) ;  
Time = Time - Time(1) ;
% run the function
[ Out_HF ] = Calc_HRV_spect( IBI , Time ,'Window_Size',600,'Window_overlap',120 );
