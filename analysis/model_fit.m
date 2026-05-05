function model_fit(D, est, saveloc)
%-------------------------------------------------------------------------%
% model_fit.m
% Purpose:  Simulates model-predicted skill distributions and overlays
%           them with data distributions for divorced and non-divorced
%           families. Produces Figures A.3-A.4 via model_fit_fig.
% Arguments:
%   D       - data struct from getdata (baseline sample)
%   est     - struct of estimated parameters (from PF_0.mat)
%   saveloc - path to the output/ directory (figures saved to saveloc/figures/)
%-------------------------------------------------------------------------%

numF = 8;
N = length(D.INPT(:,1));
sim = struct;
sim.u_het = mnrnd(1, est.pr, N);
sim.cshocks = normrnd(0,sqrt(est.eta),N,1);
sim.pshocks = mvnrnd(zeros(1,8), diag(sqrt(est.var)), N);
sim = sim_model(sim, D, est, N, numF,0, [], [], 1);
data = [D.INPT(:,[1 5 10 14 19 23]) D.Y(:,7:8)];
% axes labels
xlabs =  repmat({'Cognitive skill','Socio-emotional skills'},1,4);

for i = 1:numF

    % save path - divorce
    fig_saveloc = fullfile(saveloc,'figures',cellstr(strcat({'model_fit_divorce'},string(i))));

    [f1, x1] = ksdensity(data(D.tfpX{1,1}(:,1)==1,i),'NumPoints',1000);
    [f2, x2] = ksdensity(sim.s(sim.div1 == 1,i),'NumPoints',1000);
    xlab = xlabs{i};
    model_fit_fig(x1,f1,x2,f2,xlab,fig_saveloc)

    % save path - no divorce
    fig_saveloc = fullfile(saveloc,'figures',cellstr(strcat({'model_fit_no_divorce'},string(i))));

    [f1, x1] = ksdensity(data(D.tfpX{1,1}(:,1)==0,i),'NumPoints',1000);
    [f2, x2] = ksdensity(sim.s(sim.div1 == 0,i),'NumPoints',1000);
    xlab = xlabs{i};
    model_fit_fig(x1,f1,x2,f2,xlab,fig_saveloc)

end

fprintf("Notice: figure(s) model_fit_%d.pdf - model_fit_%d.pdf created, \nPath: - %s. \n",1,numF,fullfile(saveloc,'figures'));
disp("%-------------------------------------------------------------------")

end
