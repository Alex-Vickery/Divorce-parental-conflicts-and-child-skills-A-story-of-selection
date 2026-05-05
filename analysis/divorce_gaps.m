function divorce_gaps(D, est, saveloc)
%-------------------------------------------------------------------------%
% divorce_gaps.m
% Purpose:  Computes mean and percentile divorce skill gaps in data and
%           model, then calls model_divorce_gaps_tab to write the table.
% Arguments:
%   D       - data struct from getdata (baseline sample)
%   est     - struct of estimated parameters (from PF_0.mat)
%   saveloc - full path for the output .tex table file
%-------------------------------------------------------------------------%

numbs = 1000;
numF = 8;
N = length(D.INPT(:,1));
test0_m = zeros(numbs,numF*2);
test0_f = zeros(numbs,numF*2);
test1_m = zeros(numbs,numF*2);
test1_f = zeros(numbs,numF*2);

tmp = [D.INPT(:,1) D.INPT(:,5) D.INPT(:,10) D.INPT(:,14) D.INPT(:,19) D.INPT(:,23) D.Y(:,7:8)];
div_gaps_d_m = bsxfun(@minus, mean(tmp(D.INPT2(:,2)==0 & D.tfpX{1,1}(:,2)==0,:)), mean(tmp(D.INPT2(:,2)==1 & D.tfpX{1,1}(:,2)==0,:)));
div_gaps_d_f = bsxfun(@minus, mean(tmp(D.INPT2(:,2)==0 & D.tfpX{1,1}(:,2)==1,:)), mean(tmp(D.INPT2(:,2)==1 & D.tfpX{1,1}(:,2)==1,:)));

for bs = 1:numbs
    sim = struct;
    sim.u_het = mnrnd(1, est.pr, N);
    sim.cshocks = normrnd(0, sqrt(est.eta), N,1);
    sim.pshocks = mvnrnd(zeros(1,8), diag(sqrt(est.var)), N);
    sim = sim_model(sim, D, est, N, numF, 0, [], [], 1);
    div_gaps_s_m = bsxfun(@minus, mean(sim.s(~sim.div1 & D.tfpX{1,1}(:,2)==0,:)), mean(sim.s(sim.div1 & D.tfpX{1,1}(:,2)==0,:)));
    div_gaps_s_f = bsxfun(@minus, mean(sim.s(~sim.div1 & D.tfpX{1,1}(:,2)==1,:)), mean(sim.s(sim.div1 & D.tfpX{1,1}(:,2)==1,:)));

    for i = 1:numF
        test0_m(bs,(2*i)-1) = div_gaps_d_m(i);
        test0_m(bs,2*i) = div_gaps_s_m(i);
        test0_f(bs,(2*i)-1) = div_gaps_d_f(i);
        test0_f(bs,2*i) = div_gaps_s_f(i);

        ptile0 = sum(tmp(D.tfpX{1,1}(:,2)==0,i) <= mean(tmp(D.INPT2(:,2)==0 & D.tfpX{1,1}(:,2)==0,i))) / numel(tmp(D.tfpX{1,1}(:,2)==0,i)) * 100;
        ptile1 = sum(tmp(D.tfpX{1,1}(:,2)==0,i) <= mean(tmp(D.INPT2(:,2)==1 & D.tfpX{1,1}(:,2)==0,i))) / numel(tmp(D.tfpX{1,1}(:,2)==0,i)) * 100;
        test1_m(bs,(2*i)-1) = ptile0 - ptile1;

        ptile0 = sum(tmp(D.tfpX{1,1}(:,2)==1,i) <= mean(tmp(D.INPT2(:,2)==0 & D.tfpX{1,1}(:,2)==1,i))) / numel(tmp(D.tfpX{1,1}(:,2)==1,i)) * 100;
        ptile1 = sum(tmp(D.tfpX{1,1}(:,2)==1,i) <= mean(tmp(D.INPT2(:,2)==1 & D.tfpX{1,1}(:,2)==1,i))) / numel(tmp(D.tfpX{1,1}(:,2)==1,i)) * 100;
        test1_f(bs,(2*i)-1) = ptile0 - ptile1;

        ptile0 = sum(sim.s(D.tfpX{1,1}(:,2)==0,i) <= mean(sim.s(~sim.div1 & D.tfpX{1,1}(:,2)==0,i))) / numel(sim.s(D.tfpX{1,1}(:,2)==0,i)) * 100;
        ptile1 = sum(sim.s(D.tfpX{1,1}(:,2)==0,i) <= mean(sim.s(sim.div1 & D.tfpX{1,1}(:,2)==0,i))) / numel(sim.s(D.tfpX{1,1}(:,2)==0,i)) * 100;
        test1_m(bs,2*i) = ptile0 - ptile1;

        ptile0 = sum(sim.s(D.tfpX{1,1}(:,2)==1,i) <= mean(sim.s(~sim.div1 & D.tfpX{1,1}(:,2)==1,i))) / numel(sim.s(D.tfpX{1,1}(:,2)==1,i)) * 100;
        ptile1 = sum(sim.s(D.tfpX{1,1}(:,2)==1,i) <= mean(sim.s(sim.div1 & D.tfpX{1,1}(:,2)==1,i))) / numel(sim.s(D.tfpX{1,1}(:,2)==1,i)) * 100;
        test1_f(bs,2*i) = ptile0 - ptile1;
    end
end

ftest0_m = mean(test0_m);
ftest1_m = mean(test1_m);
ftest0_f = mean(test0_f);
ftest1_f = mean(test1_f);

model_divorce_gaps_tab(ftest0_m, ftest1_m, ftest0_f, ftest1_f, saveloc);

disp("%-------------------------------------------------------------------")
fprintf('Part 1: Replicate observed divorce gaps is complete \n')
fprintf('Notice: Table(s) are saved in: %s \n', saveloc);
disp("%-------------------------------------------------------------------")

end
