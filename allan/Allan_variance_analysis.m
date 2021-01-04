function [AWLS, tau, RootAllanVar, AVARfit] = ...
                    Allan_variance_analysis(data, dataRate, noiseModel)
%% Allan variance analysis
%--------------------------------------------------------------------------
%  Created by   : Kshitij Jerath; Email: kshitij.jerath@wsu.edu
%  Dated        : 05 April 2010
%--------------------------------------------------------------------------
%
% INPUTS
%   data        : Data on which Allan variance analysis is to be 
%                 performed [nx1]
%   dataRate    : Sampling frequency (e.g. 25 Hz)
%   noiseModel  : Array indicating noise sources to include in model
%                 E.g.  [1 0 0 0 0] corresponds to quantization error
%                       [0 1 0 0 0] corresponds to angle random walk
%                       [0 0 1 0 0] corresponds to bias instability
%                       [0 0 0 1 0] corresponds to rate random walk
%                       [0 0 0 0 1] corresponds to rate ramp
%                       [0 0 0 1 1] corresponds to rate random walk and
%                       rate ramp in noise model, and so on;
% NOTE : Empty inputs such as tut_allanVariance([],[],[1 0 0 0 0]) sets the
% values of data and dataRate to default white noise and 100Hz respectively
%--------------------------------------------------------------------------
% OUTPUT
%   AWLS        : Weighted least squares estimate for coefficients
%--------------------------------------------------------------------------
%% STEP 1: Visualize the noise
disp('Performing Allan variance analysis...');
do_plot = 0;  %Plotting allan variance and weight least squares fit
do_debug = 1;
% Set tutorial to 1 for tutorial/demonstration of step-by-step calculation
tutorial = 0; 
N = 0.01;
if(isempty(data))
    warning('No data entered - setting default data to white noise');
    data = N.*randn(2^17,1);
end
if(isempty(dataRate))
    warning('Data rate not entered - default data rate = 100 Hz');
    dataRate = 100;
end
len = length(data);
time = linspace(0,len/dataRate,len);
h = figure(1);
set(h,'name','Measured noise')
plot(time,data,'.','Markersize',4);
grid on;
h = xlabel('Time (s)');
set(h,'FontSize',13);
h = ylabel('Noise amplitude');
set(h,'FontSize',13);
set(gca,'FontSize',13);
%% STEP 2: Determine 'reasonable' temporal correlation lengths 
%         (or correlation time (tau))
% Maximum possible correlation time based on data length
ordermax = numel(num2str(fix(len/dataRate)))-2;             
order = fix(log10(1/dataRate));
tau1 = [2, 3, 4, 5, 6, 7, 8, 9];
tau2 = [];
while(order < ordermax)
    tau2 = [tau2, (10^order).*tau1];
    order = order + 0.5;
end
tau = sort(tau2);
RootAllanVar = zeros(1,length(tau));
%% STEP 3: Calculate Allan Variance for each value of determined
%          correlation time
for(count = 1:1:length(tau))
    % Determine number of measurements per correlation time 'block'
    t = round(tau(count)*dataRate);                         
    
    % Determine number of 'blocks' of data with given correlation time
    numDivisions = floor(len/t);                            
    Avg = zeros(1,numDivisions);
    Diff = zeros(1, numDivisions-1);
    
    % Calculate average value within each 'block' of data
    for(index = 1:1:numDivisions)
        Avg(index) = (sum(data(t*(index-1)+1:t*index)))/t;  
    end
    
    % Calculate the difference between successive averaged 'block' values
    for(index = 1:1:numDivisions-1)
        Diff(index) = Avg(index+1) - Avg(index);            
    end
    
     % Calculate Root Allan Variance
    RootAllanVar(count) = sqrt(0.5*mean(Diff.*Diff ));
    if(mod(count,15) == 0)
        disp('Processing...');
    elseif(mod(count,10) == 0)
        disp('Processing..');
    elseif(mod(count,5) == 0)
        disp('Processing.');
    end
    
    if(tutorial == 1)
    %% STEP 3.1: Plotting the averages at every step (for in-class 
    %            explanation only)
        h = figure(5);
        set(h,'name','Visualizing averaged blocks of data')
        plot(time,data,'.','Markersize',4);
        grid on;
        hold on;
        for(index=1:t:len-t+1)
            plot_avg(index:(index+t-1)) = Avg(1 + floor((index)/t));
        end
        plot(time,plot_avg,'r.')
        h = xlabel('Time (s)');
        set(h,'FontSize',13);
        h = ylabel('Signal amplitude');
        set(h,'FontSize',13);
        set(gca,'FontSize',13);
        hold off;
        
        h = figure(7);
        set(h,'name','Visualizing averaged blocks of data (close-up)')
        plot(time,data,'.','Markersize',4);
        grid on;
        hold on;
        plot(time,plot_avg,'r.')
        xlim([0 50]);
        h = xlabel('Time (s)');
        set(h,'FontSize',13);
        h = ylabel('Signal amplitude');
        set(h,'FontSize',13);
        set(gca,'FontSize',13);
        hold off;
   
        %% STEP 3.2: Step-by-step generation of the Allan Variance plot 
        %            with calculated values
        h = figure(10);
        set(h,'name','Root Allan Variance vs. Correlation time')
        loglog(tau(count),RootAllanVar(count),'o','Markersize',3,...
            'Markerfacecolor',[0.5,0.5,0.95]);hold on;
        xlim([min(tau) max(tau)]);
        if(length(data)<1000000)
            %ylim([1e-4 1e-1]); %Different limits for detailed explanation
            ylim([1e-4 1e-2]);
        end
        grid on;
        hold on;
        h = xlabel('Correlation time (s)');
        set(h,'FontSize',13);
        h = ylabel('Root Allan Variance');
        set(h,'FontSize',13);
        set(gca,'FontSize',13);
        
        if(length(data)<100000)
            pause(0.5)          % Remove for long running code
        else
%             pause(0.01)
        end
    end
end
%% STEP 3.3: Generate the Allan Variance plot with calculated values
if(do_plot == 1)
    figure(15);
    loglog(tau,RootAllanVar,'o','Markersize',3,'Markerfacecolor',...
        [0.5,0.5,0.95]);hold on;
    h = xlabel('Correlation Time (s)');
    set(h,'Fontsize',13);
    h = ylabel('Root Allan Variance (deg/sec)');
    set(h,'Fontsize',13);
    h = gca;
    set(h,'Fontsize',13)
    grid on;
end
%% STEP 4: Calculate the sensor noise parameters/coefficients from the 
%          Allan Variance data using Weighted Linear Regression
% NOTE: Choice of regression model plays a critical part in determining 
% noise model
AllanVar = RootAllanVar.^2;
weight = 1./AllanVar;  % Needed for performing weighted least squares
TAU = [];
TAU2 = [];
if(noiseModel(1) == 1)
    TAU = [TAU;tau.^(-2)];
end
if(noiseModel(2) == 1)
    TAU = [TAU;tau.^(-1)];
end
if(noiseModel(3) == 1)
    TAU = [TAU;tau.^(0)];
end
if(noiseModel(4) == 1)
    TAU = [TAU;tau.^(1)];
end
if(noiseModel(5) == 1)
    TAU = [TAU;tau.^(2)];
end
AVARwt = diag(weight)*AllanVar';
invTAU = (inv(TAU*diag(weight)*TAU'))*TAU;
AWLS = invTAU*AVARwt;
% [estimates, model] = fitcurvedemo(tau,RootAllanVar);
% [sse, FittedCurve] = model(estimates);
%% STEP 5: Plot the fitted curve obtained from Weighted Linear Regression
if(do_debug == 1)
    hold on;
    AVARfit = sqrt(AWLS'*TAU);
    %plot(tau,AVARfit,'r','Linewidth',3,'Color',[0.9,0.5,0.5]);
    %corr([RootAllanVar',(AWLS'*TAU)'])
    legend1 = '\sigma_{FIT} = ';
    flag = 0;
    
    if(noiseModel(1)==1)
        leg1 = ' A_{-2}\tau^{-1} ';
        legend1 = strcat(legend1,leg1);
        flag = 1;
    end
    if(noiseModel(2)==1)
        leg2 = ' A_{-1}\tau^{-0.5} ';
        if(flag == 0)
            legend1 = strcat(legend1,leg2);
            flag = 1;
        else
            legend1 = strcat(legend1,'+',leg2);
        end
    end
    if(noiseModel(3)==1)
        leg3 = ' A_{0}\tau^{0} ';
        if(flag == 0)
            legend1 = strcat(legend1,leg3);
            flag = 1;
        else
            legend1 = strcat(legend1,'+',leg3);
        end
    end
    if(noiseModel(4)==1)
        leg4 = ' A_{1}\tau^{0.5} ';
        if(flag == 0)
            legend1 = strcat(legend1,leg4);
            flag = 1;
        else
            legend1 = strcat(legend1,'+',leg4);
        end
    end
    if(noiseModel(5)==1)
        leg5 = ' A_{2}\tau^{1} ';
        if(flag == 0)
            legend1 = strcat(legend1,leg5);
            flag = 1;
        else
            legend1 = strcat(legend1,'+',leg5);
        end
    end
    %legend2 = legend('Root Allan Variance from data', legend1);
    %set(legend2,'FontSize',9,'FontName','Calibri');
    set(gca,'Children',flipud(get(gca,'children')));
end
