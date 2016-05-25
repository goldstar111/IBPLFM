% DEMTOYIBPGGMDIM Variational LFM with IBP prior over latent forces
% MULTIGP

%% Initialization
clc
clear
close all
format short e

addpath('../sparsemodel','../toolbox/gpmat')

%% load data
load ../datasets/Toys/datasetD3Q2_IBP_GG_mdim.mat

nout = size(fd,2);
y = cell(nout,1);
x = cell(nout,1);
for d = 1:nout,
    y{d} = fd(:,d);
    x{d} = xTemp;
end
clear fd xTemp

%% Set IBPLFM Options 
options = ibpmultigpOptions('dtcvar');
options.sparsePriorType = 'ibp';
options.kernType = 'gg';
options.fixinducing = false;
options.IBPisInfinite = true;

%Maximum number of latent forces
options.nlf = 4;
%Number of inducing poitns
options.numActive = 100;
%Set IBP parameter value
options.alpha = 1;
%Maximum number of iterations for EM algorithm
options.NI = 200;
%Number of iteration for hyperparameters optimization
options.NIO = 20;
%Show hyperparameter optimization performance
options.DispOpt = 1;
%Initial value for precision of noises
options.beta = 1e-3;

%% Train IBPLFM
[model, ll, mae, mse, msmse , mmsll] = TrainIBPLFM(y, x, y, x, options);


%% Plot Output Estimation
close all
[ymean yvar]=ibpmultigpPosterior(model, x);
figure(1)
con = 1;
con2 = 4;
for k=1:size(x,1),
    subplot(2,3,con)
    mesh(reshape(x{k}(:,1),20,20),reshape(x{k}(:,2),20,20), reshape(y{k}(:,1),20,20))
    title(strcat('True Output',num2str(k)))
    con = con+1;
    subplot(2,3,con2);
    mesh(reshape(x{k}(:,1),20,20),reshape(x{k}(:,2),20,20), reshape(ymean{k}(:,1),20,20))
    title(strcat('Est. Output',num2str(k)))
    con2 = con2+1;
end

%% Plot Latent Forces estimation
[up qpv]=ibpmultigpPosteriorLatent(model,x{1});
figure(2)
con = 1;
con2 = 5;
uq2 = [uq , zeros(400,2)];
for k=1:4,
    subplot(2,4,con)
    mesh(reshape(x{1}(:,1),20,20),reshape(x{1}(:,2),20,20), reshape(uq2(:,k),20,20))
    title(strcat('True Latent ',num2str(k)))
    con = con+1;
    subplot(2,4,con2);
    mesh(reshape(x{1}(:,1),20,20),reshape(x{1}(:,2),20,20), reshape(up{k}(:,1),20,20))
    title(strcat('Est. Latent ',num2str(k)))
    con2 = con2+1;
end

%% Plot Hinton Diagram
hinton(Zdq.*Sdq)

hinton(model.etadq.*model.kern.sensitivity)