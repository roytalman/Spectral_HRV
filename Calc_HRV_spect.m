function [ Spectral_HRV ] = Calc_HRV_spect(Good_IBI, Good_IBI_Time , varargin )

% This function calculate HRV in frequency domain from IBI indexes signal.
% Results can eather calculated for all the data at once , or by calculating using mooving
% windows in the size of 'Window_Size' secounds (deafult is 600 ), with
% 'Window_overlap' secounds between windows (deafult is 300 ).

% Power spectral analysis is calculting using Lomb-Scargle periodogram - a
% method for calculating spectral dencity for non-uniformed sample data

% Input:  Good_IBI      - N*1 Signal, were N is the number of Inter beat interval (IBI's) after filtering out outlayers.
%         Good_IBI_Time - N*1 coorisponding time stamp (in secounds) for each Good_IBI start. Notice that if there is no outlayers removal then:
%                         Good_IBI_Time = diff( Good_IBI ),
%                         but if there are some outlayers, 'Good_IBI_Time'
%                         need to be calculated before outlayers IBI removal
%         Segment_Time  - Time frame of each segment
% Output: Spectral_HRV  - Output struct with the field: Time - time stemp of the window, determind as the window end point, HF - sum of high frequencys energy, LF - sum of low
%                         frequencys energy, VLF -  sum of very low frequencys energy.


% Examples for function usege:

%  [ Spectral_HRV ] = Calc_HRV_spect(Good_IBI, Good_IBI_Time ) ;  %regular use, 10  minutes (600 secounds) window with 5 minutes overlap
%  [ Spectral_HRV ] = Calc_HRV_spect(Good_IBI, Good_IBI_Time ,'Window_Size',300,'Window_overlap',120) ;  %regular use, 5 minutes window with 2 minutes overlap
%  [ Spectral_HRV ] = Calc_HRV_spect(Good_IBI, Good_IBI_Time , 'One_Window', 1 ) ;  % All time points at ones

% Written by Roy Talman - Email roytalman@gmail.com
% Last edited Roy Talman 6.5.2017

if length(Good_IBI) == length(Good_IBI_Time)+1 % reduce last value in case that user provide time stemp for the last beat
    Good_IBI = Good_IBI(1:end-1);    
end

if length(Good_IBI) ~= length(Good_IBI_Time)
    disp('Error: "Good_IBI" ans "Good_IBI_Time" should be in the same length')
    return
end

%%%% calcibrate parameters
inargs = inputParser;
inargs.FunctionName = 'Calc_HRV_spect';

inargs.addRequired('Good_IBI');
inargs.addRequired('Good_IBI_Time') ;

inargs.addParameter('Window_Size', 600 , @isnumeric) ;
inargs.addParameter('Window_overlap', 300 , @isnumeric) ;
inargs.addParameter('One_Window', 0 , @isnumeric) ;

inargs.parse( Good_IBI, Good_IBI_Time , varargin{:}) ;

One_Window     = inargs.Results.One_Window ;
Window_overlap = inargs.Results.Window_overlap ;
Window_Size    = inargs.Results.Window_Size ;


%%%% set temporal windows frames
Good_IBI_Time = Good_IBI_Time - Good_IBI_Time(1); % start time at 0
if One_Window == 1 % only one temporal window
    Window_Size = max(Good_IBI_Time) ; 
end
% windows framing:
Windows_Start = 0 : Window_overlap : max(Good_IBI_Time) - Window_Size ;


%%%% set spectral limits of HF LF and VLF :
HF_limits  = [0.15 0.4]; % limits of high frequencies
LF_limits  = [0.04 0.15]; % limits of low frequencies
VLF_limits = [0.0033 0.04];% limits of very low frequencies


%%%% Iterative loop for each window
for k = 1 : length(Windows_Start)
    Good_IBI_Time_Seg = Good_IBI_Time(Good_IBI_Time > Windows_Start(k) & Good_IBI_Time < ( Windows_Start(k) + Window_Size ) ); % select values in current window
    Good_IBI_Seg      = Good_IBI(Good_IBI_Time > Windows_Start(k) & Good_IBI_Time < ( Windows_Start(k) + Window_Size ) ); % select values in current window
    
    Good_IBI_Time_Seg = Good_IBI_Time_Seg - Good_IBI_Time_Seg(1); % start time at 0
    Good_IBI_Seg      = Good_IBI_Seg - mean(Good_IBI_Seg) ; % DC removal 
    
    % claculte spectral dencity:
    [PSD,PSD_Freq] = plomb( Good_IBI_Seg , Good_IBI_Time_Seg ) ; 
    
    Spectral_HRV.HF(k)          = sum( PSD( PSD_Freq > HF_limits(1)  & PSD_Freq < HF_limits(2) )   ) ; % sum squere of energy for high frequencys
    Spectral_HRV.LF(k)          = sum( PSD( PSD_Freq > LF_limits(1)  & PSD_Freq < LF_limits(2) )   ) ; % sum squere of energy for low frequencys
    Spectral_HRV.VLF(k)         = sum( PSD( PSD_Freq > VLF_limits(1)  & PSD_Freq < VLF_limits(2) )   ) ; % sum squere of energy for very low frequencys
    Spectral_HRV.HF_LF_ratio(k) = Spectral_HRV.HF(k)./ Spectral_HRV.LF(k) ; 
    Spectral_HRV.Time(k)        = Windows_Start(k) + Window_Size ;
    
end

if isempty(Windows_Start)
    disp('Error: Window Size is longer then maximum time point')
       Spectral_HRV = [] ;
end


end






