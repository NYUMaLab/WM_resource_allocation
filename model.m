% notes to self
% gneral uncertainty ranges from 1 to 4 ish (up to 5) in visual deg? (disk size?)
% general error 1 to 4 ish (up to 12) in vis deg? (saccade error?)

close all
clear all
clc

% locations
a1 = 10:10:80;
a2 = 100:10:170;
a3 = 190:10:260;
a4 = 280:10:350;
Sdistribution = [a1 a2 a3 a4];
nS = length(Sdistribution);

% parameters
<<<<<<< HEAD
sigmaVec = [5 7 9];
Jbar = 4;     % mean parameter of gamma distribution
tauVec = [1 0.0001];%0.008;        % scale parameter of gamma distribution
=======
JbarVec = [5 2 1];%1./([2 6 10].^2);       % mean parameter of gamma distribution
tau = 1;%.001;        % scale parameter of gamma distribution
>>>>>>> parent of 18d93b7... updates
beta = 1;%15;

nCond = length(tauVec); % number of conditions

% reward function
maxReward = 120;
slope = 0.4;
rewardFn = @(r)maxReward*exp(-slope*r);

nTrials = 1000;
nsamp = 100;
SVec = Sdistribution(ceil(rand(nCond,nTrials).*nS));

<<<<<<< HEAD

colors = [0 0 0; 0.5*ones(1,3)];
=======
colors = aspencolors(nCond,'pastel');%[127 0 0; 247 69 0; 247 148 30]./255; %
>>>>>>> parent of 18d93b7... updates
figure;
error_sacc = nan(nCond,nTrials);
D = nan(nCond,nTrials); Shat = nan(nCond,nTrials);
rho = nan(1,nCond); pval = nan(1,nCond);
for icond = 1:nCond;
    

    tau = tauVec(icond);
    
    % ===== get p(J|Jbar,tau) ======
    % make range small enough
    ind1 = []; ind2 = [];
    blah = 10;
    while isempty(ind2) || isempty(ind2); % make range smaller if nothing is above 1e-10
        blah = blah * 0.9;
        xx = linspace(0,blah,nsamp);
        yy = gampdf(xx,Jbar/tau,tau);
        ind1 = find(yy >= 1e-6,1,'first')-1;
        ind2 = find(yy >= 1e-6,1,'last')+1;
    end
    if ind1 == 0; ind1 = 1; end
    if ind2 == length(yy)+1; ind2 = length(yy); end
    xx = linspace(xx(ind1),xx(ind2),nsamp);
    yy = gampdf(xx,Jbar/tau,tau);
    p_sigma = yy./sum(yy);
    sigval = sqrt(1./xx);
%     figure; plot(xx,yy); 
    
    % samples
    sigmaVec = sqrt(1./gamrnd(Jbar/tau,tau,1,nTrials));
    X = SVec(icond,:) + randn(1,nTrials).*sigmaVec;
    Shat(icond,:) = X;
    
    p_SgivenX = @(r,sigma) (normcdf(r,0,sigma) - normcdf(-r,0,sigma));
%     p_SDgivenXsigma = @(r,sigma) 1./(1+exp(-beta.*rewardFn(r).*p_bringInsideDisk(r,sigma)));
%         p_SgivenX = @(r) sum(p_SDgivenXsigma(r,sigval).*p_sigma);
    for itrial = 1:nTrials;
        sigma = sigmaVec(itrial);
        
        
        % calculate expected utility across disk size range
        func = @(r) rewardFn(r).*p_SgivenX(r,sigma);
        x = linspace(0,10,1e5);
        EUpdf = exp(beta.*func(x));
        
        EUpdf = EUpdf./sum(EUpdf); % normalize   
        EUcdf = cumsum(EUpdf);% make cdf
        
%         figure;
%         subplot(3,1,1)
%         plot(x,func(x))
%         subplot(3,1,2)
%         plot(x,EUpdf)
%         subplot(3,1,3)
%         plot(x,EUcdf)
        
        % sample from icdf
        samp = rand;
        idx = find(abs(EUcdf-samp) == min(abs(EUcdf-samp)));
        D(icond,itrial) = x(idx);

    end
    
%     figure
    error_sacc(icond,:) = abs(SVec(icond,:) - Shat(icond,:));
<<<<<<< HEAD
    plot(D(icond,:),error_sacc(icond,:),'o','Color',colors(icond,:));hold on;
    %     blah = [0 10];
    %     plot(blah,b(1).*blah + b(2),colors(icond,:));
=======
    plot(error_sacc(icond,:),D(icond,:),'o','Color',colors(icond,:));hold on;
>>>>>>> parent of 18d93b7... updates
    
    % calculate correlation
    [rho(icond), pval(icond)] = corr(error_sacc(icond,:)',D(icond,:)');
    
    %     pause;
    
end
defaultplot
ylabel('saccadic error');
xlabel('disk size')


 
rho
pval

% plot data 
figure;
plot(D(1,:),error_sacc(1,:),'.','Color','k');hold on;


% ===== BINNED DISK SIZE AND ERROR SD PLOT =====
nQuants = 4;

figure;
sem_errorsacc = nan(nCond,nQuants); mean_errorsacc = sem_errorsacc;
med_disksize = nan(nCond,nQuants);
for icond = 1:nCond;
   
   % pair disk size and saccade error data.
   dataMat = [D(icond,:); error_sacc(icond,:)]';
   dataMat = sortrows(dataMat);
   
   quantileEnds = linspace(0,nTrials,nQuants+1);
   for iquant = 1:nQuants; % for each bin (by quantile)...
       
       % get appropriate quantile from dataMat
       quantMat = dataMat(quantileEnds(iquant)+1:quantileEnds(iquant+1),:); 
       
       % mean
       mean_errorsacc(icond,iquant) = mean(quantMat(:,2));
       
       % calculate SD of saccade error for this quantile
<<<<<<< HEAD
       sem_errorsacc(icond,iquant) = std(quantMat(:,2))/sqrt(length(quantMat(:,2)));
=======
       sd_errorsacc(icond,iquant) = std(quantMat(:,2));
>>>>>>> parent of 18d93b7... updates
       
       % median of disksizes
       med_disksize(icond,iquant) = median(quantMat(:,1));
       
   end
   
   errorbar(med_disksize(icond,:),mean_errorsacc(icond,:),sem_errorsacc(icond,:),'Color',colors(icond,:));
   hold on;
end

<<<<<<< HEAD

defaultplot
ylabel('error')
xlabel('disk size')
legend('variable precision','fixed precision')
=======
defaultplot;
xlabel('disk size')
ylabel('SD of saccade errors')
legend('0.6','0.3','0.1')

% ===== MAIN EFFECT PLOTS =====
sd_disksize = nan(1,nCond);
sd_error = nan(1,nCond);
for icond = 1:nCond;
    sd_disksize(icond) = std(D(icond,:));
    sd_error(icond) = std(error_sacc(icond,:));
end

condNumVec = [0.1 0.3 0.6];

% saccade error
figure;
plot(condNumVec,fliplr(sd_error),'k.','MarkerSize',14);
defaultplot;
xlim([0 0.7])
ax = gca;
ax.XTick = condNumVec;
xlabel('priority')
ylabel('SD of saccade errors')

% disksize
figure;
plot(condNumVec,fliplr(sd_disksize),'k.','MarkerSize',14);
defaultplot
xlim([0 0.7])
ax = gca;
ax.XTick = condNumVec;
xlabel('priority')
ylabel('SD of disk sizes')


>>>>>>> parent of 18d93b7... updates
