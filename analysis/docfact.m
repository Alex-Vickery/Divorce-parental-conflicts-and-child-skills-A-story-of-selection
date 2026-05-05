%-------------------------------------------------------------------------%
% docfact.m
% Purpose:  Runs the counterfactual simulations that decompose divorce
%           skill gaps across the skill distribution, and produces all
%           counterfactual figures (Figure 1 and Figures A.5-A.8).
% Inputs:   output/estimates/PF_0.mat ... PF_250.mat  (via estimates_dir)
%           output/estimates/DATAoriginal.mat          (via getdata)
%           output/estimates/DATAmodel.mat             (via getdata)
% Outputs:  output/figures/cog_cfact_age*.pdf
%           output/figures/emo_cfact_age*.pdf
%           output/figures/cog_cfact_1_age*.pdf, emo_cfact_1_age*.pdf
%           output/figures/cog_cfact_1_male_age*.pdf, _female_*.pdf
%           output/figures/cog_cfact_2_age*.pdf, emo_cfact_2_*.pdf
%           output/figures/cog_cfact_3_age*.pdf, emo_cfact_3_*.pdf
%-------------------------------------------------------------------------%
clearvars;
global root_dir

estimates_dir = fullfile(root_dir, 'output', 'estimates');
figures_dir   = fullfile(root_dir, 'output', 'figures');

rng(1);

%-----------------------------------------------
% Part 0: load in the data and the parameter estimates
%-----------------------------------------------
pf = cellstr(strcat({'translog '},string(1)));
D = getdata(0,1,pf{1}); % and the initial baseline data

% duplicate D for shocks
nshck = 50;
D.Y = repmat(D.Y, nshck, 1);
D.INPT = repmat(D.INPT, nshck, 1);
D.INPT2 = repmat(D.INPT2, nshck, 1);
D.typeX = repmat(D.typeX, nshck, 1);
for i = 1:8
    D.tfpX{1,i} = repmat(D.tfpX{1,i}, nshck, 1);
end

%-----------------------------------------------
% Part 1: Counterfactuals
%-----------------------------------------------
numcf = 5;
numbs = 250;
N = length(D.INPT(:,1));
numF = 8;
numQ = 4;
Q = [25, 50, 75, 90];

skillg = zeros(numQ*(numcf+1),numF,numbs); % og sample div gap (0 - 1 old)
skillg1 = zeros(numQ*(numcf+1),numF,numbs); % ond - od
skillg1_m = zeros(numQ*(numcf+1),numF,numbs); % ond - od
skillg1_f = zeros(numQ*(numcf+1),numF,numbs); % ond - od
skillg2 = zeros(numQ*(numcf+1),numF,numbs); % ond - od
skillg3 = zeros(numQ*(numcf+1),numF,numbs); % nnd - nd
fidx = [1 1+numcf+1 1+(2*(numcf+1)) 1+(3*(numcf+1))];

for bs = 1:numbs+1

    saveloc = fullfile(estimates_dir, sprintf('PF_%d.mat', bs-1));
    load(saveloc,'est'); % load initial estimates

    if bs == 1
        shocks1 = mnrnd(1, est.pr, N);
        shocks2 = normrnd(0,sqrt(est.eta), N,1);
        shocks3 = mvnrnd(zeros(1,8), diag(sqrt(est.var)), N);
    end

    bline = struct;
    bline.u_het = shocks1;
    bline.cshocks = shocks2;
    bline.pshocks = shocks3;
    bline = sim_model(bline, D, est, N, numF, 0, [], [], 0);
    ccnt = 0; % cfact counter
    for q = 1:numQ
        skillg(fidx(q),:,bs) = bsxfun(@minus, prctile(bline.s(D.tfpX{1,1}(:,1)==0,:),Q(q)), prctile(bline.s(D.tfpX{1,1}(:,1)==1,:),Q(q)));
    end
    bline = sim_model(bline, D, est, N, numF, 0, [], [], 1);
    for q = 1:numQ
        skillg1(fidx(q),:,bs) = bsxfun(@minus, prctile(D.Y(D.tfpX{1,1}(:,1)==0,:),Q(q)), prctile(D.Y(D.tfpX{1,1}(:,1)==1,:),Q(q)));
        skillg1_m(fidx(q),:,bs) = bsxfun(@minus, prctile(D.Y(D.tfpX{1,1}(:,1)==0 & D.tfpX{1,1}(:,2)==0,:),Q(q)), prctile(D.Y(D.tfpX{1,1}(:,1)==1 & D.tfpX{1,1}(:,2)==0,:),Q(q)));
        skillg1_f(fidx(q),:,bs) = bsxfun(@minus, prctile(D.Y(D.tfpX{1,1}(:,1)==0 & D.tfpX{1,1}(:,2)==1,:),Q(q)), prctile(D.Y(D.tfpX{1,1}(:,1)==1 & D.tfpX{1,1}(:,2)==1,:),Q(q)));
        skillg2(fidx(q),:,bs) = bsxfun(@minus, prctile(D.Y(D.tfpX{1,1}(:,1)==0 & bline.div1==0,:),Q(q)), prctile(D.Y(D.tfpX{1,1}(:,1)==1 & bline.div1 == 0,:),Q(q)));
        skillg3(fidx(q),:,bs) = bsxfun(@minus, prctile(D.Y(D.tfpX{1,1}(:,1)==0,:),Q(q)), prctile(D.Y(D.tfpX{1,1}(:,1)==1 & bline.div1 == 1,:),Q(q)));
    end
    ccnt = ccnt + 1;

    % gaps in inputs - close gaps
    gaps = cell(1,5);

    % 1) pared
    % 2) par health
    % 3) fam financial resources
    % 4) conflicts
    % 5) divorce itself

    gaps{1} = [0 0 1 0 0 1];
    gaps{2} = [1 1];
    gaps{3} = bsxfun(@minus, prctile(D.tfpX{1}(D.tfpX{1,1}(:,1)==0,21:29),50), prctile(D.tfpX{1}(D.tfpX{1,1}(:,1)==1,21:29),50));
    gaps{3}(2:end) = [1 0 0 0 0 0 0 0];
    gaps{4} = bsxfun(@minus, prctile(D.INPT2(D.tfpX{1,1}(:,1)==0,1),50), prctile(D.INPT2(D.tfpX{1,1}(:,1)==1,1),50));
    gaps{5} = 1;

    % offset the gaps and simulate - pared
    cf1 = struct;
    cf1.pshocks = bline.pshocks;
    cf1.cshocks = bline.cshocks;
    cf1.u_het = bline.u_het;
    CD = D;
    for i = 1:numF
        CD.tfpX{i}(D.tfpX{1,1}(:,1)==1,13:18) = repmat(gaps{1},sum(D.tfpX{1,1}(:,1)==1),1);
    end
    cf1 = sim_model(cf1, CD, est, N, numF,0,[],[],0);
    for q = 1:numQ
        skillg(fidx(q)+ccnt,:,bs) = bsxfun(@minus, prctile(cf1.s(D.tfpX{1,1}(:,1)==0,:),Q(q)), prctile(cf1.s(D.tfpX{1,1}(:,1)==1,:),Q(q)));
    end
    cf1 = sim_model(cf1, CD, est, N, numF,0,[],[],1);
    for q = 1:numQ
        skillg1(fidx(q)+ccnt,:,bs) = bsxfun(@minus, prctile(cf1.s(D.tfpX{1,1}(:,1)==0,:),Q(q)), prctile(cf1.s(D.tfpX{1,1}(:,1)==1,:),Q(q)));
        skillg1_m(fidx(q)+ccnt,:,bs) = bsxfun(@minus, prctile(cf1.s(D.tfpX{1,1}(:,1)==0 & D.tfpX{1,1}(:,2)==0,:),Q(q)), prctile(cf1.s(D.tfpX{1,1}(:,1)==1 & D.tfpX{1,1}(:,2)==0,:),Q(q)));
        skillg1_f(fidx(q)+ccnt,:,bs) = bsxfun(@minus, prctile(cf1.s(D.tfpX{1,1}(:,1)==0 & D.tfpX{1,1}(:,2)==1,:),Q(q)), prctile(cf1.s(D.tfpX{1,1}(:,1)==1 & D.tfpX{1,1}(:,2)==1,:),Q(q)));
        skillg2(fidx(q)+ccnt,:,bs) = bsxfun(@minus, prctile(cf1.s(D.tfpX{1,1}(:,1)==0,:),Q(q)), prctile(cf1.s(D.tfpX{1,1}(:,1)==1 & cf1.div1==0,:),Q(q)));
        skillg3(fidx(q)+ccnt,:,bs) = bsxfun(@minus, prctile(cf1.s(D.tfpX{1,1}(:,1)==0,:),Q(q)), prctile(cf1.s(D.tfpX{1,1}(:,1)==1 & cf1.div1==1,:),Q(q)));
    end
    ccnt = ccnt+1;

    % offset the gaps and simulate - parhealth
    cf2 = struct;
    cf2.pshocks = bline.pshocks;
    cf2.cshocks = bline.cshocks;
    cf2.u_het = bline.u_het;
    CD = D;
    for i = 1:numF
        CD.tfpX{i}(D.tfpX{1,1}(:,1)==1,19:20) = repmat(gaps{2},sum(D.tfpX{1,1}(:,1)==1),1);
    end
    cf2 = sim_model(cf2, CD, est, N, numF,0,[],[],0);
    for q = 1:numQ
        skillg(fidx(q)+ccnt,:,bs) = bsxfun(@minus, prctile(cf2.s(D.tfpX{1,1}(:,1)==0,:),Q(q)), prctile(cf2.s(D.tfpX{1,1}(:,1)==1,:),Q(q)));
    end
     cf2 = sim_model(cf2, CD, est, N, numF,0,[],[],1);
    for q = 1:numQ
        skillg1(fidx(q)+ccnt,:,bs) = bsxfun(@minus, prctile(cf2.s(D.tfpX{1,1}(:,1)==0,:),Q(q)), prctile(cf2.s(D.tfpX{1,1}(:,1)==1,:),Q(q)));
        skillg1_m(fidx(q)+ccnt,:,bs) = bsxfun(@minus, prctile(cf2.s(D.tfpX{1,1}(:,1)==0 & D.tfpX{1,1}(:,2)==0,:),Q(q)), prctile(cf2.s(D.tfpX{1,1}(:,1)==1 & D.tfpX{1,1}(:,2)==0,:),Q(q)));
        skillg1_f(fidx(q)+ccnt,:,bs) = bsxfun(@minus, prctile(cf2.s(D.tfpX{1,1}(:,1)==0 & D.tfpX{1,1}(:,2)==1,:),Q(q)), prctile(cf2.s(D.tfpX{1,1}(:,1)==1 & D.tfpX{1,1}(:,2)==1,:),Q(q)));
        skillg2(fidx(q)+ccnt,:,bs) = bsxfun(@minus, prctile(cf2.s(D.tfpX{1,1}(:,1)==0,:),Q(q)), prctile(cf2.s(D.tfpX{1,1}(:,1)==1 & cf2.div1==0,:),Q(q)));
        skillg3(fidx(q)+ccnt,:,bs) = bsxfun(@minus, prctile(cf2.s(D.tfpX{1,1}(:,1)==0,:),Q(q)), prctile(cf2.s(D.tfpX{1,1}(:,1)==1 & cf2.div1==1,:),Q(q)));
    end
    ccnt = ccnt+1;

    % offset the gaps and simulate - finres
    cf3 = struct;
    cf3.pshocks = bline.pshocks;
    cf3.cshocks = bline.cshocks;
    cf3.u_het = bline.u_het;
    CD = D;
    for i = 1:numF
       CD.tfpX{i}(D.tfpX{1,1}(:,1)==1,21:29) = [D.tfpX{1,1}(D.tfpX{1,1}(:,1)==1,21) + gaps{3}(1),repmat(gaps{3}(2:end),sum(D.tfpX{1,1}(:,1)==1),1)];
    end
    cf3 = sim_model(cf3, CD, est, N, numF,0,[],[],0);
    for q = 1:numQ
        skillg(fidx(q)+ccnt,:,bs) = bsxfun(@minus, prctile(cf3.s(D.tfpX{1,1}(:,1)==0,:),Q(q)), prctile(cf3.s(D.tfpX{1,1}(:,1)==1,:),Q(q)));
    end
    cf3 = sim_model(cf3, CD, est, N, numF,0,[],[],1);
    for q = 1:numQ
        skillg1(fidx(q)+ccnt,:,bs) = bsxfun(@minus, prctile(cf3.s(D.tfpX{1,1}(:,1)==0,:),Q(q)), prctile(cf3.s(D.tfpX{1,1}(:,1)==1,:),Q(q)));
        skillg1_m(fidx(q)+ccnt,:,bs) = bsxfun(@minus, prctile(cf3.s(D.tfpX{1,1}(:,1)==0 & D.tfpX{1,1}(:,2)==0,:),Q(q)), prctile(cf3.s(D.tfpX{1,1}(:,1)==1 & D.tfpX{1,1}(:,2)==0,:),Q(q)));
        skillg1_f(fidx(q)+ccnt,:,bs) = bsxfun(@minus, prctile(cf3.s(D.tfpX{1,1}(:,1)==0 & D.tfpX{1,1}(:,2)==1,:),Q(q)), prctile(cf3.s(D.tfpX{1,1}(:,1)==1 & D.tfpX{1,1}(:,2)==1,:),Q(q)));
        skillg2(fidx(q)+ccnt,:,bs) = bsxfun(@minus, prctile(cf3.s(D.tfpX{1,1}(:,1)==0,:),Q(q)), prctile(cf3.s(D.tfpX{1,1}(:,1)==1 & cf3.div1==0,:),Q(q)));
        skillg3(fidx(q)+ccnt,:,bs) = bsxfun(@minus, prctile(cf3.s(D.tfpX{1,1}(:,1)==0,:),Q(q)), prctile(cf3.s(D.tfpX{1,1}(:,1)==1 & cf3.div1==1,:),Q(q)));
    end
    ccnt = ccnt+1;

    % offset the gaps and simulate - conf
    cf4 = struct;
    cf4.pshocks = bline.pshocks;
    cf4.cshocks = bline.cshocks;
    cf4.u_het = bline.u_het;
    cf4 = sim_model(cf4, D, est, N, numF, 1, gaps{4}, D.tfpX{1,1}(:,1)==1,0);
    for q = 1:numQ
        skillg(fidx(q)+ccnt,:,bs) = bsxfun(@minus, prctile(cf4.s(D.tfpX{1,1}(:,1)==0,:),Q(q)), prctile(cf4.s(D.tfpX{1,1}(:,1)==1,:),Q(q)));
    end
    cf4 = sim_model(cf4, D, est, N, numF, 1, gaps{4}, D.tfpX{1,1}(:,1)==1,1);
    for q = 1:numQ
        skillg1(fidx(q)+ccnt,:,bs) = bsxfun(@minus, prctile(cf4.s(D.tfpX{1,1}(:,1)==0,:),Q(q)), prctile(cf4.s(D.tfpX{1,1}(:,1)==1,:),Q(q)));
        skillg1_m(fidx(q)+ccnt,:,bs) = bsxfun(@minus, prctile(cf4.s(D.tfpX{1,1}(:,1)==0 & D.tfpX{1,1}(:,2)==0,:),Q(q)), prctile(cf4.s(D.tfpX{1,1}(:,1)==1 & D.tfpX{1,1}(:,2)==0,:),Q(q)));
        skillg1_f(fidx(q)+ccnt,:,bs) = bsxfun(@minus, prctile(cf4.s(D.tfpX{1,1}(:,1)==0 & D.tfpX{1,1}(:,2)==1,:),Q(q)), prctile(cf4.s(D.tfpX{1,1}(:,1)==1 & D.tfpX{1,1}(:,2)==1,:),Q(q)));
        skillg2(fidx(q)+ccnt,:,bs) = bsxfun(@minus, prctile(cf4.s(D.tfpX{1,1}(:,1)==0,:),Q(q)), prctile(cf4.s(D.tfpX{1,1}(:,1)==1 & cf4.div1==0,:),Q(q)));
        skillg3(fidx(q)+ccnt,:,bs) = bsxfun(@minus, prctile(cf4.s(D.tfpX{1,1}(:,1)==0,:),Q(q)), prctile(cf4.s(D.tfpX{1,1}(:,1)==1 & cf4.div1==1,:),Q(q)));
    end
    ccnt = ccnt+1;

    % offset the gaps and simulate - no div
    cf5 = struct;
    cf5.pshocks = bline.pshocks;
    cf5.cshocks = bline.cshocks;
    cf5.u_het = bline.u_het;
    cf5 = sim_model(cf5, D, est, N, numF, 2, [], D.tfpX{1,1}(:,1)==1,0);
    for q = 1:numQ
        skillg(fidx(q)+ccnt,:,bs) = bsxfun(@minus, prctile(cf5.s(D.tfpX{1,1}(:,1)==0,:),Q(q)), prctile(cf5.s(D.tfpX{1,1}(:,1)==1,:),Q(q)));
    end
    cf5 = sim_model(cf5, D, est, N, numF, 2, [], D.tfpX{1,1}(:,1)==1,1);
    for q = 1:numQ
        skillg1(fidx(q)+ccnt,:,bs) = bsxfun(@minus, prctile(cf5.s(D.tfpX{1,1}(:,1)==0,:),Q(q)), prctile(cf5.s(D.tfpX{1,1}(:,1)==1,:),Q(q)));
        skillg1_m(fidx(q)+ccnt,:,bs) = bsxfun(@minus, prctile(cf5.s(D.tfpX{1,1}(:,1)==0 & D.tfpX{1,1}(:,2)==0,:),Q(q)), prctile(cf5.s(D.tfpX{1,1}(:,1)==1 & D.tfpX{1,1}(:,2)==0,:),Q(q)));
        skillg1_f(fidx(q)+ccnt,:,bs) = bsxfun(@minus, prctile(cf5.s(D.tfpX{1,1}(:,1)==0 & D.tfpX{1,1}(:,2)==1,:),Q(q)), prctile(cf5.s(D.tfpX{1,1}(:,1)==1 & D.tfpX{1,1}(:,2)==1,:),Q(q)));
        skillg2(fidx(q)+ccnt,:,bs) = bsxfun(@minus, prctile(cf5.s(D.tfpX{1,1}(:,1)==0,:),Q(q)), prctile(cf5.s(D.tfpX{1,1}(:,1)==1,:),Q(q)));
        skillg3(fidx(q)+ccnt,:,bs) = bsxfun(@minus, prctile(cf5.s(D.tfpX{1,1}(:,1)==0,:),Q(q)), prctile(cf5.s(D.tfpX{1,1}(:,1)==1 & bline.div1==1,:),Q(q)));
    end
    fprintf('Bootstrap rep: %d complete \n',bs);
end

%-----------------------------------------------
% Part 2: Plot
%-----------------------------------------------

se = std(skillg,[],3);
diffs = skillg(:,:,1);

% plot the fig, by age

yidx = [1 3 5 7;2 4 6 8];
xidx = [1:6:19;2:6:20;3:6:21;...
    4:6:22;5:6:23;6:6:24];
func = {'cog','emo'};
age = {'age3','age5','age7','age11'};
pt = [2 6 10 14];
j = [pt-.75;pt-.25;pt+.25;pt+.75];

for sk = 1:numel(func)
    for s = 1:numel(age)
        saveloc = char(fullfile(figures_dir, strcat(func(sk),'_cfact_',age(s))));

        fontsz = 20;
        fig = figure('Name','Cog counterfactuals');
        set(gcf, 'color','w')
        set(1,'units','centimeters','pos',[0 0 16 12])
        set(fig,'units','Inches');
        pos = get(fig,'Position');
        set(fig,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)]);
        hold on
        tmp = diffs(xidx(2,:),yidx(sk,s));
        fill([j(1,1)-0.25 j(1,1)+0.25 j(1,1)+0.25 j(1,1)-0.25], [min(0,tmp(1)) min(0,tmp(1)) max(0,tmp(1)) max(0,tmp(1))], [0.6 0.6 1],'EdgeColor','none');
        rectangle('Position', [j(1,1)-0.25, min(0,tmp(1)), 0.5, abs(tmp(1))], 'FaceColor', '#9999ff','EdgeColor','none','HandleVisibility','on');
        rectangle('Position', [j(1,2)-0.25, min(0,tmp(2)) 0.5, abs(tmp(2))], 'FaceColor', '#9999ff','EdgeColor','none','HandleVisibility','off');
        rectangle('Position', [j(1,3)-0.25, min(0,tmp(3)) 0.5, abs(tmp(3))], 'FaceColor', '#9999ff','EdgeColor','none','HandleVisibility','off');
        rectangle('Position', [j(1,4)-0.25, min(0,tmp(4)) 0.5, abs(tmp(4))], 'FaceColor', '#9999ff','EdgeColor','none','HandleVisibility','off');
        errorbar(j(1,:), diffs(xidx(2,:),yidx(sk,s)), se(xidx(2,:),yidx(sk,s)).*1.645,'bo', 'LineWidth', 2.5,'Color','#3a6183','CapSize',8,'Marker','_','MarkerSize',4,'HandleVisibility','off');

        tmp = diffs(xidx(4,:),yidx(sk,s));
        fill([j(2,1)-0.25 j(2,1)+0.25 j(2,1)+0.25 j(2,1)-0.25], [min(0,tmp(1)) min(0,tmp(1)) max(0,tmp(1)) max(0,tmp(1))], [1 0.6 0.6],'EdgeColor','none');
        rectangle('Position', [j(2,1)-0.25, min(0,tmp(1)), 0.5, abs(tmp(1))], 'FaceColor', '#ff9999','EdgeColor','none');
        rectangle('Position', [j(2,2)-0.25, min(0,tmp(2)) 0.5, abs(tmp(2))], 'FaceColor', '#ff9999','EdgeColor','none');
        rectangle('Position', [j(2,3)-0.25, min(0,tmp(3)) 0.5, abs(tmp(3))], 'FaceColor', '#ff9999','EdgeColor','none');
        rectangle('Position', [j(2,4)-0.25, min(0,tmp(4)) 0.5, abs(tmp(4))], 'FaceColor', '#ff9999','EdgeColor','none');
        errorbar(j(2,:), diffs(xidx(4,:),yidx(sk,s)), se(xidx(4,:),yidx(sk,s)).*1.645,'bo', 'LineWidth', 2.5,'Color','#a3575c','CapSize',8,'Marker','_','MarkerSize',4,'HandleVisibility','off');

        tmp = diffs(xidx(5,:),yidx(sk,s));
        fill([j(3,1)-0.25 j(3,1)+0.25 j(3,1)+0.25 j(3,1)-0.25], [min(0,tmp(1)) min(0,tmp(1)) max(0,tmp(1)) max(0,tmp(1))], [0.7333 0.784313 0.674509],'EdgeColor','none');
        rectangle('Position', [j(3,1)-0.25, min(0,tmp(1)), 0.5, abs(tmp(1))], 'FaceColor', '#bbc8ac','EdgeColor','none');
        rectangle('Position', [j(3,2)-0.25, min(0,tmp(2)) 0.5, abs(tmp(2))], 'FaceColor', '#bbc8ac','EdgeColor','none');
        rectangle('Position', [j(3,3)-0.25, min(0,tmp(3)) 0.5, abs(tmp(3))], 'FaceColor', '#bbc8ac','EdgeColor','none');
        rectangle('Position', [j(3,4)-0.25, min(0,tmp(4)) 0.5, abs(tmp(4))], 'FaceColor', '#bbc8ac','EdgeColor','none');
        errorbar(j(3,:), diffs(xidx(5,:),yidx(sk,s)), se(xidx(5,:),yidx(sk,s)).*1.645,'bo', 'LineWidth', 2.5,'Color','#678445','CapSize',8,'Marker','_','MarkerSize',4,'HandleVisibility','off');

        tmp = diffs(xidx(6,:),yidx(sk,s));
        fill([j(4,1)-0.25 j(4,1)+0.25 j(4,1)+0.25 j(4,1)-0.25], [min(0,tmp(1)) min(0,tmp(1)) max(0,tmp(1)) max(0,tmp(1))], [1 0.81960 0.4],'EdgeColor','none');
        rectangle('Position', [j(4,1)-0.25, min(0,tmp(1)), 0.5, abs(tmp(1))], 'FaceColor', '#ffd166','EdgeColor','none');
        rectangle('Position', [j(4,2)-0.25, min(0,tmp(2)) 0.5, abs(tmp(2))], 'FaceColor', '#ffd166','EdgeColor','none');
        rectangle('Position', [j(4,3)-0.25, min(0,tmp(3)) 0.5, abs(tmp(3))], 'FaceColor', '#ffd166','EdgeColor','none');
        rectangle('Position', [j(4,4)-0.25, min(0,tmp(4)) 0.5, abs(tmp(4))], 'FaceColor', '#ffd166','EdgeColor','none');
        errorbar(j(4,:), diffs(xidx(6,:),yidx(sk,s)), se(xidx(6,:),yidx(sk,s)).*1.645,'bo', 'LineWidth', 2.5,'Color','#ffb55a','CapSize',8,'Marker','_','MarkerSize',4,'HandleVisibility','off');

        line([0 pt 16], [0,0,0, 0, 0, 0], 'Color', 'k', 'LineStyle', '-', 'LineWidth', 1.5);
        line([j(1,1)-0.75 j(4,1)+0.75], [diffs(1,yidx(sk,s)) diffs(1,yidx(sk,s))], 'Color', '#bd7ebe', 'LineStyle', '-.', 'LineWidth', 2);
        line([j(1,2)-0.75 j(4,2)+0.75], [diffs(7,yidx(sk,s)) diffs(7,yidx(sk,s))], 'Color', '#bd7ebe', 'LineStyle', '-.', 'LineWidth', 2);
        line([j(1,3)-0.75 j(4,3)+0.75], [diffs(13,yidx(sk,s)) diffs(13,yidx(sk,s))], 'Color', '#bd7ebe', 'LineStyle', '-.', 'LineWidth', 2);
        line([j(1,4)-0.75 j(4,4)+0.75], [diffs(19,yidx(sk,s)) diffs(19,yidx(sk,s))], 'Color', '#bd7ebe', 'LineStyle', '-.', 'LineWidth', 2);

        set(gca, 'LineWidth', 1.5)
        ylim([-0.45, 0.85]);
        xlim([0, 16]);
        xlabel('Skill quantile','Interpreter','latex','FontSize',fontsz);
        ylabel('Divorce skill gap','Interpreter','latex','FontSize',fontsz);
        set(get(gca, 'ylabel'),'Units','Normalized','Position', [-0.1, 0.5, 0])
        set(gca, 'XtickLabel', get(gca, 'XtickLabel'), 'TickLabelInterpreter','latex','fontsize', fontsz)
        xticks(pt);
        xticklabels({'25', '50', '75', '90'});
        yticks(-0.4:0.2:0.8);
        yticklabels({'-.4','-.2','0','.2','.4','.6','.8'});
        grid on
        box on
        set(gca,'GridAlpha',0.05)
        l = legend({'$\;$Parental edu.$\;$', '$\;$Financial res.$\;$', '$\;$Conflicts$\;$', '$\;$Divorce$\;$'}, 'Interpreter','latex');
        l.FontSize = fontsz-5;
        l.Orientation = 'horizontal';
        set(l,'units','normalized');
        l.Position = [0.6,0.19,0.001,0.09];
        l.NumColumns = 2;
        l.LineWidth = 1.5;
        print(fig, saveloc,'-dpdf','-r0');
        close;
    end
end

se = std(skillg1,[],3);
diffs = skillg1(:,:,1);

for sk = 1:numel(func)
    for s = 1:numel(age)
        saveloc = char(fullfile(figures_dir, strcat(func(sk),'_cfact_1_',age(s))));

        fontsz = 20;
        fig = figure('Name','Cog counterfactuals');
        set(gcf, 'color','w')
        set(1,'units','centimeters','pos',[0 0 16 12])
        set(fig,'units','Inches');
        pos = get(fig,'Position');
        set(fig,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)]);
        hold on
        tmp = diffs(xidx(2,:),yidx(sk,s));
        fill([j(1,1)-0.25 j(1,1)+0.25 j(1,1)+0.25 j(1,1)-0.25], [min(0,tmp(1)) min(0,tmp(1)) max(0,tmp(1)) max(0,tmp(1))], [0.6 0.6 1],'EdgeColor','none');
        rectangle('Position', [j(1,1)-0.25, min(0,tmp(1)), 0.5, abs(tmp(1))], 'FaceColor', '#9999ff','EdgeColor','none','HandleVisibility','on');
        rectangle('Position', [j(1,2)-0.25, min(0,tmp(2)) 0.5, abs(tmp(2))], 'FaceColor', '#9999ff','EdgeColor','none','HandleVisibility','off');
        rectangle('Position', [j(1,3)-0.25, min(0,tmp(3)) 0.5, abs(tmp(3))], 'FaceColor', '#9999ff','EdgeColor','none','HandleVisibility','off');
        rectangle('Position', [j(1,4)-0.25, min(0,tmp(4)) 0.5, abs(tmp(4))], 'FaceColor', '#9999ff','EdgeColor','none','HandleVisibility','off');
        errorbar(j(1,:), diffs(xidx(2,:),yidx(sk,s)), se(xidx(2,:),yidx(sk,s)).*1.645,'bo', 'LineWidth', 2.5,'Color','#3a6183','CapSize',8,'Marker','_','MarkerSize',4,'HandleVisibility','off');

        tmp = diffs(xidx(4,:),yidx(sk,s));
        fill([j(2,1)-0.25 j(2,1)+0.25 j(2,1)+0.25 j(2,1)-0.25], [min(0,tmp(1)) min(0,tmp(1)) max(0,tmp(1)) max(0,tmp(1))], [1 0.6 0.6],'EdgeColor','none');
        rectangle('Position', [j(2,1)-0.25, min(0,tmp(1)), 0.5, abs(tmp(1))], 'FaceColor', '#ff9999','EdgeColor','none');
        rectangle('Position', [j(2,2)-0.25, min(0,tmp(2)) 0.5, abs(tmp(2))], 'FaceColor', '#ff9999','EdgeColor','none');
        rectangle('Position', [j(2,3)-0.25, min(0,tmp(3)) 0.5, abs(tmp(3))], 'FaceColor', '#ff9999','EdgeColor','none');
        rectangle('Position', [j(2,4)-0.25, min(0,tmp(4)) 0.5, abs(tmp(4))], 'FaceColor', '#ff9999','EdgeColor','none');
        errorbar(j(2,:), diffs(xidx(4,:),yidx(sk,s)), se(xidx(4,:),yidx(sk,s)).*1.645,'bo', 'LineWidth', 2.5,'Color','#a3575c','CapSize',8,'Marker','_','MarkerSize',4,'HandleVisibility','off');

        tmp = diffs(xidx(5,:),yidx(sk,s));
        fill([j(3,1)-0.25 j(3,1)+0.25 j(3,1)+0.25 j(3,1)-0.25], [min(0,tmp(1)) min(0,tmp(1)) max(0,tmp(1)) max(0,tmp(1))], [0.7333 0.784313 0.674509],'EdgeColor','none');
        rectangle('Position', [j(3,1)-0.25, min(0,tmp(1)), 0.5, abs(tmp(1))], 'FaceColor', '#bbc8ac','EdgeColor','none');
        rectangle('Position', [j(3,2)-0.25, min(0,tmp(2)) 0.5, abs(tmp(2))], 'FaceColor', '#bbc8ac','EdgeColor','none');
        rectangle('Position', [j(3,3)-0.25, min(0,tmp(3)) 0.5, abs(tmp(3))], 'FaceColor', '#bbc8ac','EdgeColor','none');
        rectangle('Position', [j(3,4)-0.25, min(0,tmp(4)) 0.5, abs(tmp(4))], 'FaceColor', '#bbc8ac','EdgeColor','none');
        errorbar(j(3,:), diffs(xidx(5,:),yidx(sk,s)), se(xidx(5,:),yidx(sk,s)).*1.645,'bo', 'LineWidth', 2.5,'Color','#678445','CapSize',8,'Marker','_','MarkerSize',4,'HandleVisibility','off');

        tmp = diffs(xidx(6,:),yidx(sk,s));
        fill([j(4,1)-0.25 j(4,1)+0.25 j(4,1)+0.25 j(4,1)-0.25], [min(0,tmp(1)) min(0,tmp(1)) max(0,tmp(1)) max(0,tmp(1))], [1 0.81960 0.4],'EdgeColor','none');
        rectangle('Position', [j(4,1)-0.25, min(0,tmp(1)), 0.5, abs(tmp(1))], 'FaceColor', '#ffd166','EdgeColor','none');
        rectangle('Position', [j(4,2)-0.25, min(0,tmp(2)) 0.5, abs(tmp(2))], 'FaceColor', '#ffd166','EdgeColor','none');
        rectangle('Position', [j(4,3)-0.25, min(0,tmp(3)) 0.5, abs(tmp(3))], 'FaceColor', '#ffd166','EdgeColor','none');
        rectangle('Position', [j(4,4)-0.25, min(0,tmp(4)) 0.5, abs(tmp(4))], 'FaceColor', '#ffd166','EdgeColor','none');
        errorbar(j(4,:), diffs(xidx(6,:),yidx(sk,s)), se(xidx(6,:),yidx(sk,s)).*1.645,'bo', 'LineWidth', 2.5,'Color','#ffb55a','CapSize',8,'Marker','_','MarkerSize',4,'HandleVisibility','off');

        line([0 pt 16], [0,0,0, 0, 0, 0], 'Color', 'k', 'LineStyle', '-', 'LineWidth', 1.5);
        line([j(1,1)-0.5 j(4,1)+0.5], [diffs(1,yidx(sk,s)) diffs(1,yidx(sk,s))], 'Color', '#bd7ebe', 'LineStyle', '-.', 'LineWidth', 2);
        line([j(1,2)-0.5 j(4,2)+0.5], [diffs(7,yidx(sk,s)) diffs(7,yidx(sk,s))], 'Color', '#bd7ebe', 'LineStyle', '-.', 'LineWidth', 2);
        line([j(1,3)-0.5 j(4,3)+0.5], [diffs(13,yidx(sk,s)) diffs(13,yidx(sk,s))], 'Color', '#bd7ebe', 'LineStyle', '-.', 'LineWidth', 2);
        line([j(1,4)-0.5 j(4,4)+0.5], [diffs(19,yidx(sk,s)) diffs(19,yidx(sk,s))], 'Color', '#bd7ebe', 'LineStyle', '-.', 'LineWidth', 2);

        set(gca, 'LineWidth', 1.5)
        ylim([-0.45, 0.85]);
        xlim([0, 16]);
        xlabel('Skill quantile','Interpreter','latex','FontSize',fontsz);
        ylabel('Divorce skill gap','Interpreter','latex','FontSize',fontsz);
        set(get(gca, 'ylabel'),'Units','Normalized','Position', [-0.1, 0.5, 0])
        set(gca, 'XtickLabel', get(gca, 'XtickLabel'), 'TickLabelInterpreter','latex','fontsize', fontsz)
        xticks(pt);
        xticklabels({'25', '50', '75', '90'});
        yticks(-0.4:0.2:0.8);
         yticklabels({'-.4','-.2','0','.2','.4','.6','.8'});
        grid on
        box on
        set(gca,'GridAlpha',0.05)
        l = legend({'$\;$Parental edu.$\;$', '$\;$Financial res.$\;$', '$\;$Conflicts$\;$', '$\;$Divorce$\;$'}, 'Interpreter','latex');
        l.FontSize = fontsz-5;
        l.Orientation = 'horizontal';
        set(l,'units','normalized');
        l.Position = [0.6,0.19,0.001,0.09];
        l.NumColumns = 2;
        l.LineWidth = 1.5;
        print(fig, saveloc,'-dpdf','-r0');
        close;
    end
end

% Figure 1 by gender - males

se = std(skillg1_m,[],3);
diffs = skillg1_m(:,:,1);

for sk = 1:numel(func)
    for s = 1:numel(age)
        saveloc = char(fullfile(figures_dir, strcat(func(sk),'_cfact_1_male_',age(s))));

        fontsz = 20;
        fig = figure('Name','Cog counterfactuals');
        set(gcf, 'color','w')
        set(1,'units','centimeters','pos',[0 0 16 12])
        set(fig,'units','Inches');
        pos = get(fig,'Position');
        set(fig,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)]);
        hold on
        tmp = diffs(xidx(2,:),yidx(sk,s));
        fill([j(1,1)-0.25 j(1,1)+0.25 j(1,1)+0.25 j(1,1)-0.25], [min(0,tmp(1)) min(0,tmp(1)) max(0,tmp(1)) max(0,tmp(1))], [0.6 0.6 1],'EdgeColor','none');
        rectangle('Position', [j(1,1)-0.25, min(0,tmp(1)), 0.5, abs(tmp(1))], 'FaceColor', '#9999ff','EdgeColor','none','HandleVisibility','on');
        rectangle('Position', [j(1,2)-0.25, min(0,tmp(2)) 0.5, abs(tmp(2))], 'FaceColor', '#9999ff','EdgeColor','none','HandleVisibility','off');
        rectangle('Position', [j(1,3)-0.25, min(0,tmp(3)) 0.5, abs(tmp(3))], 'FaceColor', '#9999ff','EdgeColor','none','HandleVisibility','off');
        rectangle('Position', [j(1,4)-0.25, min(0,tmp(4)) 0.5, abs(tmp(4))], 'FaceColor', '#9999ff','EdgeColor','none','HandleVisibility','off');
        errorbar(j(1,:), diffs(xidx(2,:),yidx(sk,s)), se(xidx(2,:),yidx(sk,s)).*1.645,'bo', 'LineWidth', 2.5,'Color','#3a6183','CapSize',8,'Marker','_','MarkerSize',4,'HandleVisibility','off');

        tmp = diffs(xidx(4,:),yidx(sk,s));
        fill([j(2,1)-0.25 j(2,1)+0.25 j(2,1)+0.25 j(2,1)-0.25], [min(0,tmp(1)) min(0,tmp(1)) max(0,tmp(1)) max(0,tmp(1))], [1 0.6 0.6],'EdgeColor','none');
        rectangle('Position', [j(2,1)-0.25, min(0,tmp(1)), 0.5, abs(tmp(1))], 'FaceColor', '#ff9999','EdgeColor','none');
        rectangle('Position', [j(2,2)-0.25, min(0,tmp(2)) 0.5, abs(tmp(2))], 'FaceColor', '#ff9999','EdgeColor','none');
        rectangle('Position', [j(2,3)-0.25, min(0,tmp(3)) 0.5, abs(tmp(3))], 'FaceColor', '#ff9999','EdgeColor','none');
        rectangle('Position', [j(2,4)-0.25, min(0,tmp(4)) 0.5, abs(tmp(4))], 'FaceColor', '#ff9999','EdgeColor','none');
        errorbar(j(2,:), diffs(xidx(4,:),yidx(sk,s)), se(xidx(4,:),yidx(sk,s)).*1.645,'bo', 'LineWidth', 2.5,'Color','#a3575c','CapSize',8,'Marker','_','MarkerSize',4,'HandleVisibility','off');

        tmp = diffs(xidx(5,:),yidx(sk,s));
        fill([j(3,1)-0.25 j(3,1)+0.25 j(3,1)+0.25 j(3,1)-0.25], [min(0,tmp(1)) min(0,tmp(1)) max(0,tmp(1)) max(0,tmp(1))], [0.7333 0.784313 0.674509],'EdgeColor','none');
        rectangle('Position', [j(3,1)-0.25, min(0,tmp(1)), 0.5, abs(tmp(1))], 'FaceColor', '#bbc8ac','EdgeColor','none');
        rectangle('Position', [j(3,2)-0.25, min(0,tmp(2)) 0.5, abs(tmp(2))], 'FaceColor', '#bbc8ac','EdgeColor','none');
        rectangle('Position', [j(3,3)-0.25, min(0,tmp(3)) 0.5, abs(tmp(3))], 'FaceColor', '#bbc8ac','EdgeColor','none');
        rectangle('Position', [j(3,4)-0.25, min(0,tmp(4)) 0.5, abs(tmp(4))], 'FaceColor', '#bbc8ac','EdgeColor','none');
        errorbar(j(3,:), diffs(xidx(5,:),yidx(sk,s)), se(xidx(5,:),yidx(sk,s)).*1.645,'bo', 'LineWidth', 2.5,'Color','#678445','CapSize',8,'Marker','_','MarkerSize',4,'HandleVisibility','off');

        tmp = diffs(xidx(6,:),yidx(sk,s));
        fill([j(4,1)-0.25 j(4,1)+0.25 j(4,1)+0.25 j(4,1)-0.25], [min(0,tmp(1)) min(0,tmp(1)) max(0,tmp(1)) max(0,tmp(1))], [1 0.81960 0.4],'EdgeColor','none');
        rectangle('Position', [j(4,1)-0.25, min(0,tmp(1)), 0.5, abs(tmp(1))], 'FaceColor', '#ffd166','EdgeColor','none');
        rectangle('Position', [j(4,2)-0.25, min(0,tmp(2)) 0.5, abs(tmp(2))], 'FaceColor', '#ffd166','EdgeColor','none');
        rectangle('Position', [j(4,3)-0.25, min(0,tmp(3)) 0.5, abs(tmp(3))], 'FaceColor', '#ffd166','EdgeColor','none');
        rectangle('Position', [j(4,4)-0.25, min(0,tmp(4)) 0.5, abs(tmp(4))], 'FaceColor', '#ffd166','EdgeColor','none');
        errorbar(j(4,:), diffs(xidx(6,:),yidx(sk,s)), se(xidx(6,:),yidx(sk,s)).*1.645,'bo', 'LineWidth', 2.5,'Color','#ffb55a','CapSize',8,'Marker','_','MarkerSize',4,'HandleVisibility','off');

        line([0 pt 16], [0,0,0, 0, 0, 0], 'Color', 'k', 'LineStyle', '-', 'LineWidth', 1.5);
        line([j(1,1)-0.5 j(4,1)+0.5], [diffs(1,yidx(sk,s)) diffs(1,yidx(sk,s))], 'Color', '#bd7ebe', 'LineStyle', '-.', 'LineWidth', 2);
        line([j(1,2)-0.5 j(4,2)+0.5], [diffs(7,yidx(sk,s)) diffs(7,yidx(sk,s))], 'Color', '#bd7ebe', 'LineStyle', '-.', 'LineWidth', 2);
        line([j(1,3)-0.5 j(4,3)+0.5], [diffs(13,yidx(sk,s)) diffs(13,yidx(sk,s))], 'Color', '#bd7ebe', 'LineStyle', '-.', 'LineWidth', 2);
        line([j(1,4)-0.5 j(4,4)+0.5], [diffs(19,yidx(sk,s)) diffs(19,yidx(sk,s))], 'Color', '#bd7ebe', 'LineStyle', '-.', 'LineWidth', 2);

        set(gca, 'LineWidth', 1.5)
        ylim([-0.45, 0.85]);
        xlim([0, 16]);
        xlabel('Skill quantile','Interpreter','latex','FontSize',fontsz);
        ylabel('Divorce skill gap','Interpreter','latex','FontSize',fontsz);
        set(get(gca, 'ylabel'),'Units','Normalized','Position', [-0.1, 0.5, 0])
        set(gca, 'XtickLabel', get(gca, 'XtickLabel'), 'TickLabelInterpreter','latex','fontsize', fontsz)
        xticks(pt);
        xticklabels({'25', '50', '75', '90'});
        yticks(-0.4:0.2:0.8);
         yticklabels({'-.4','-.2','0','.2','.4','.6','.8'});
        grid on
        box on
        set(gca,'GridAlpha',0.05)
        l = legend({'$\;$Parental edu.$\;$', '$\;$Financial res.$\;$', '$\;$Conflicts$\;$', '$\;$Divorce$\;$'}, 'Interpreter','latex');
        l.FontSize = fontsz-5;
        l.Orientation = 'horizontal';
        set(l,'units','normalized');
        l.Position = [0.6,0.19,0.001,0.09];
        l.NumColumns = 2;
        l.LineWidth = 1.5;
        print(fig, saveloc,'-dpdf','-r0');
        close;
    end
end

% Figure 1 by gender - females

se = std(skillg1_f,[],3);
diffs = skillg1_f(:,:,1);

for sk = 1:numel(func)
    for s = 1:numel(age)
        saveloc = char(fullfile(figures_dir, strcat(func(sk),'_cfact_1_female_',age(s))));

        fontsz = 20;
        fig = figure('Name','Cog counterfactuals');
        set(gcf, 'color','w')
        set(1,'units','centimeters','pos',[0 0 16 12])
        set(fig,'units','Inches');
        pos = get(fig,'Position');
        set(fig,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)]);
        hold on
        tmp = diffs(xidx(2,:),yidx(sk,s));
        fill([j(1,1)-0.25 j(1,1)+0.25 j(1,1)+0.25 j(1,1)-0.25], [min(0,tmp(1)) min(0,tmp(1)) max(0,tmp(1)) max(0,tmp(1))], [0.6 0.6 1],'EdgeColor','none');
        rectangle('Position', [j(1,1)-0.25, min(0,tmp(1)), 0.5, abs(tmp(1))], 'FaceColor', '#9999ff','EdgeColor','none','HandleVisibility','on');
        rectangle('Position', [j(1,2)-0.25, min(0,tmp(2)) 0.5, abs(tmp(2))], 'FaceColor', '#9999ff','EdgeColor','none','HandleVisibility','off');
        rectangle('Position', [j(1,3)-0.25, min(0,tmp(3)) 0.5, abs(tmp(3))], 'FaceColor', '#9999ff','EdgeColor','none','HandleVisibility','off');
        rectangle('Position', [j(1,4)-0.25, min(0,tmp(4)) 0.5, abs(tmp(4))], 'FaceColor', '#9999ff','EdgeColor','none','HandleVisibility','off');
        errorbar(j(1,:), diffs(xidx(2,:),yidx(sk,s)), se(xidx(2,:),yidx(sk,s)).*1.645,'bo', 'LineWidth', 2.5,'Color','#3a6183','CapSize',8,'Marker','_','MarkerSize',4,'HandleVisibility','off');

        tmp = diffs(xidx(4,:),yidx(sk,s));
        fill([j(2,1)-0.25 j(2,1)+0.25 j(2,1)+0.25 j(2,1)-0.25], [min(0,tmp(1)) min(0,tmp(1)) max(0,tmp(1)) max(0,tmp(1))], [1 0.6 0.6],'EdgeColor','none');
        rectangle('Position', [j(2,1)-0.25, min(0,tmp(1)), 0.5, abs(tmp(1))], 'FaceColor', '#ff9999','EdgeColor','none');
        rectangle('Position', [j(2,2)-0.25, min(0,tmp(2)) 0.5, abs(tmp(2))], 'FaceColor', '#ff9999','EdgeColor','none');
        rectangle('Position', [j(2,3)-0.25, min(0,tmp(3)) 0.5, abs(tmp(3))], 'FaceColor', '#ff9999','EdgeColor','none');
        rectangle('Position', [j(2,4)-0.25, min(0,tmp(4)) 0.5, abs(tmp(4))], 'FaceColor', '#ff9999','EdgeColor','none');
        errorbar(j(2,:), diffs(xidx(4,:),yidx(sk,s)), se(xidx(4,:),yidx(sk,s)).*1.645,'bo', 'LineWidth', 2.5,'Color','#a3575c','CapSize',8,'Marker','_','MarkerSize',4,'HandleVisibility','off');

        tmp = diffs(xidx(5,:),yidx(sk,s));
        fill([j(3,1)-0.25 j(3,1)+0.25 j(3,1)+0.25 j(3,1)-0.25], [min(0,tmp(1)) min(0,tmp(1)) max(0,tmp(1)) max(0,tmp(1))], [0.7333 0.784313 0.674509],'EdgeColor','none');
        rectangle('Position', [j(3,1)-0.25, min(0,tmp(1)), 0.5, abs(tmp(1))], 'FaceColor', '#bbc8ac','EdgeColor','none');
        rectangle('Position', [j(3,2)-0.25, min(0,tmp(2)) 0.5, abs(tmp(2))], 'FaceColor', '#bbc8ac','EdgeColor','none');
        rectangle('Position', [j(3,3)-0.25, min(0,tmp(3)) 0.5, abs(tmp(3))], 'FaceColor', '#bbc8ac','EdgeColor','none');
        rectangle('Position', [j(3,4)-0.25, min(0,tmp(4)) 0.5, abs(tmp(4))], 'FaceColor', '#bbc8ac','EdgeColor','none');
        errorbar(j(3,:), diffs(xidx(5,:),yidx(sk,s)), se(xidx(5,:),yidx(sk,s)).*1.645,'bo', 'LineWidth', 2.5,'Color','#678445','CapSize',8,'Marker','_','MarkerSize',4,'HandleVisibility','off');

        tmp = diffs(xidx(6,:),yidx(sk,s));
        fill([j(4,1)-0.25 j(4,1)+0.25 j(4,1)+0.25 j(4,1)-0.25], [min(0,tmp(1)) min(0,tmp(1)) max(0,tmp(1)) max(0,tmp(1))], [1 0.81960 0.4],'EdgeColor','none');
        rectangle('Position', [j(4,1)-0.25, min(0,tmp(1)), 0.5, abs(tmp(1))], 'FaceColor', '#ffd166','EdgeColor','none');
        rectangle('Position', [j(4,2)-0.25, min(0,tmp(2)) 0.5, abs(tmp(2))], 'FaceColor', '#ffd166','EdgeColor','none');
        rectangle('Position', [j(4,3)-0.25, min(0,tmp(3)) 0.5, abs(tmp(3))], 'FaceColor', '#ffd166','EdgeColor','none');
        rectangle('Position', [j(4,4)-0.25, min(0,tmp(4)) 0.5, abs(tmp(4))], 'FaceColor', '#ffd166','EdgeColor','none');
        errorbar(j(4,:), diffs(xidx(6,:),yidx(sk,s)), se(xidx(6,:),yidx(sk,s)).*1.645,'bo', 'LineWidth', 2.5,'Color','#ffb55a','CapSize',8,'Marker','_','MarkerSize',4,'HandleVisibility','off');

        line([0 pt 16], [0,0,0, 0, 0, 0], 'Color', 'k', 'LineStyle', '-', 'LineWidth', 1.5);
        line([j(1,1)-0.5 j(4,1)+0.5], [diffs(1,yidx(sk,s)) diffs(1,yidx(sk,s))], 'Color', '#bd7ebe', 'LineStyle', '-.', 'LineWidth', 2);
        line([j(1,2)-0.5 j(4,2)+0.5], [diffs(7,yidx(sk,s)) diffs(7,yidx(sk,s))], 'Color', '#bd7ebe', 'LineStyle', '-.', 'LineWidth', 2);
        line([j(1,3)-0.5 j(4,3)+0.5], [diffs(13,yidx(sk,s)) diffs(13,yidx(sk,s))], 'Color', '#bd7ebe', 'LineStyle', '-.', 'LineWidth', 2);
        line([j(1,4)-0.5 j(4,4)+0.5], [diffs(19,yidx(sk,s)) diffs(19,yidx(sk,s))], 'Color', '#bd7ebe', 'LineStyle', '-.', 'LineWidth', 2);

        set(gca, 'LineWidth', 1.5)
        ylim([-0.45, 0.85]);
        xlim([0, 16]);
        xlabel('Skill quantile','Interpreter','latex','FontSize',fontsz);
        ylabel('Divorce skill gap','Interpreter','latex','FontSize',fontsz);
        set(get(gca, 'ylabel'),'Units','Normalized','Position', [-0.1, 0.5, 0])
        set(gca, 'XtickLabel', get(gca, 'XtickLabel'), 'TickLabelInterpreter','latex','fontsize', fontsz)
        xticks(pt);
        xticklabels({'25', '50', '75', '90'});
        yticks(-0.4:0.2:0.8);
         yticklabels({'-.4','-.2','0','.2','.4','.6','.8'});
        grid on
        box on
        set(gca,'GridAlpha',0.05)
        l = legend({'$\;$Parental edu.$\;$', '$\;$Financial res.$\;$', '$\;$Conflicts$\;$', '$\;$Divorce$\;$'}, 'Interpreter','latex');
        l.FontSize = fontsz-5;
        l.Orientation = 'horizontal';
        set(l,'units','normalized');
        l.Position = [0.6,0.19,0.001,0.09];
        l.NumColumns = 2;
        l.LineWidth = 1.5;
        print(fig, saveloc,'-dpdf','-r0');
        close;
    end
end


se = std(skillg2,[],3);
diffs = skillg2(:,:,1);

for sk = 1:numel(func)
    for s = 1:numel(age)
        saveloc = char(fullfile(figures_dir, strcat(func(sk),'_cfact_2_',age(s))));

        fontsz = 20;
        fig = figure('Name','Cog counterfactuals');
        set(gcf, 'color','w')
        set(1,'units','centimeters','pos',[0 0 16 12])
        set(fig,'units','Inches');
        pos = get(fig,'Position');
        set(fig,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)]);
        hold on
        tmp = diffs(xidx(2,:),yidx(sk,s));
        fill([j(1,1)-0.25 j(1,1)+0.25 j(1,1)+0.25 j(1,1)-0.25], [min(0,tmp(1)) min(0,tmp(1)) max(0,tmp(1)) max(0,tmp(1))], [0.6 0.6 1],'EdgeColor','none');
        rectangle('Position', [j(1,1)-0.25, min(0,tmp(1)), 0.5, abs(tmp(1))], 'FaceColor', '#9999ff','EdgeColor','none','HandleVisibility','on');
        rectangle('Position', [j(1,2)-0.25, min(0,tmp(2)) 0.5, abs(tmp(2))], 'FaceColor', '#9999ff','EdgeColor','none','HandleVisibility','off');
        rectangle('Position', [j(1,3)-0.25, min(0,tmp(3)) 0.5, abs(tmp(3))], 'FaceColor', '#9999ff','EdgeColor','none','HandleVisibility','off');
        rectangle('Position', [j(1,4)-0.25, min(0,tmp(4)) 0.5, abs(tmp(4))], 'FaceColor', '#9999ff','EdgeColor','none','HandleVisibility','off');
        errorbar(j(1,:), diffs(xidx(2,:),yidx(sk,s)), se(xidx(2,:),yidx(sk,s)).*1.645,'bo', 'LineWidth', 2.5,'Color','#3a6183','CapSize',8,'Marker','_','MarkerSize',4,'HandleVisibility','off');

        tmp = diffs(xidx(4,:),yidx(sk,s));
        fill([j(2,1)-0.25 j(2,1)+0.25 j(2,1)+0.25 j(2,1)-0.25], [min(0,tmp(1)) min(0,tmp(1)) max(0,tmp(1)) max(0,tmp(1))], [1 0.6 0.6],'EdgeColor','none');
        rectangle('Position', [j(2,1)-0.25, min(0,tmp(1)), 0.5, abs(tmp(1))], 'FaceColor', '#ff9999','EdgeColor','none');
        rectangle('Position', [j(2,2)-0.25, min(0,tmp(2)) 0.5, abs(tmp(2))], 'FaceColor', '#ff9999','EdgeColor','none');
        rectangle('Position', [j(2,3)-0.25, min(0,tmp(3)) 0.5, abs(tmp(3))], 'FaceColor', '#ff9999','EdgeColor','none');
        rectangle('Position', [j(2,4)-0.25, min(0,tmp(4)) 0.5, abs(tmp(4))], 'FaceColor', '#ff9999','EdgeColor','none');
        errorbar(j(2,:), diffs(xidx(4,:),yidx(sk,s)), se(xidx(4,:),yidx(sk,s)).*1.645,'bo', 'LineWidth', 2.5,'Color','#a3575c','CapSize',8,'Marker','_','MarkerSize',4,'HandleVisibility','off');

        tmp = diffs(xidx(5,:),yidx(sk,s));
        fill([j(3,1)-0.25 j(3,1)+0.25 j(3,1)+0.25 j(3,1)-0.25], [min(0,tmp(1)) min(0,tmp(1)) max(0,tmp(1)) max(0,tmp(1))], [0.7333 0.784313 0.674509],'EdgeColor','none');
        rectangle('Position', [j(3,1)-0.25, min(0,tmp(1)), 0.5, abs(tmp(1))], 'FaceColor', '#bbc8ac','EdgeColor','none');
        rectangle('Position', [j(3,2)-0.25, min(0,tmp(2)) 0.5, abs(tmp(2))], 'FaceColor', '#bbc8ac','EdgeColor','none');
        rectangle('Position', [j(3,3)-0.25, min(0,tmp(3)) 0.5, abs(tmp(3))], 'FaceColor', '#bbc8ac','EdgeColor','none');
        rectangle('Position', [j(3,4)-0.25, min(0,tmp(4)) 0.5, abs(tmp(4))], 'FaceColor', '#bbc8ac','EdgeColor','none');
        errorbar(j(3,:), diffs(xidx(5,:),yidx(sk,s)), se(xidx(5,:),yidx(sk,s)).*1.645,'bo', 'LineWidth', 2.5,'Color','#678445','CapSize',8,'Marker','_','MarkerSize',4,'HandleVisibility','off');

        tmp = diffs(xidx(6,:),yidx(sk,s));
        fill([j(4,1)-0.25 j(4,1)+0.25 j(4,1)+0.25 j(4,1)-0.25], [min(0,tmp(1)) min(0,tmp(1)) max(0,tmp(1)) max(0,tmp(1))], [1 0.81960 0.4],'EdgeColor','none');
        rectangle('Position', [j(4,1)-0.25, min(0,tmp(1)), 0.5, abs(tmp(1))], 'FaceColor', '#ffd166','EdgeColor','none');
        rectangle('Position', [j(4,2)-0.25, min(0,tmp(2)) 0.5, abs(tmp(2))], 'FaceColor', '#ffd166','EdgeColor','none');
        rectangle('Position', [j(4,3)-0.25, min(0,tmp(3)) 0.5, abs(tmp(3))], 'FaceColor', '#ffd166','EdgeColor','none');
        rectangle('Position', [j(4,4)-0.25, min(0,tmp(4)) 0.5, abs(tmp(4))], 'FaceColor', '#ffd166','EdgeColor','none');
        errorbar(j(4,:), diffs(xidx(6,:),yidx(sk,s)), se(xidx(6,:),yidx(sk,s)).*1.645,'bo', 'LineWidth', 2.5,'Color','#ffb55a','CapSize',8,'Marker','_','MarkerSize',4,'HandleVisibility','off');

        line([0 pt 16], [0,0,0, 0, 0, 0], 'Color', 'k', 'LineStyle', '-', 'LineWidth', 1.5);

        set(gca, 'LineWidth', 1.5)
        ylim([-0.45, 0.85]);
        xlim([0, 16]);
        xlabel('Skill quantile','Interpreter','latex','FontSize',fontsz);
        ylabel('Divorce skill gap','Interpreter','latex','FontSize',fontsz);
        set(get(gca, 'ylabel'),'Units','Normalized','Position', [-0.1, 0.5, 0])
        set(gca, 'XtickLabel', get(gca, 'XtickLabel'), 'TickLabelInterpreter','latex','fontsize', fontsz)
        xticks(pt);
        xticklabels({'25', '50', '75', '90'});
        yticks(-0.4:0.2:0.8);
        yticklabels({'-.4','-.2','0','.2','.4','.6','.8'});
        grid on
        box on
        set(gca,'GridAlpha',0.05)
        l = legend({'$\;$Parental edu.$\;$', '$\;$Financial res.$\;$', '$\;$Conflicts$\;$', '$\;$Divorce$\;$'}, 'Interpreter','latex');
        l.FontSize = fontsz-5;
        l.Orientation = 'horizontal';
        set(l,'units','normalized');
        l.Position = [0.6,0.812,0.001,0.09];
        l.NumColumns = 2;
        l.LineWidth = 1.5;
        print(fig, saveloc,'-dpdf','-r0');
        close;
    end
end

se = std(skillg3,[],3);
diffs = skillg3(:,:,1);
diffs(isnan(diffs)) = 0;

for sk = 1:numel(func)
    for s = 1:numel(age)
        saveloc = char(fullfile(figures_dir, strcat(func(sk),'_cfact_3_',age(s))));

        fontsz = 20;
        fig = figure('Name','Cog counterfactuals');
        set(gcf, 'color','w')
        set(1,'units','centimeters','pos',[0 0 16 12])
        set(fig,'units','Inches');
        pos = get(fig,'Position');
        set(fig,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)]);
        hold on
        tmp = diffs(xidx(2,:),yidx(sk,s));
        fill([j(1,1)-0.25 j(1,1)+0.25 j(1,1)+0.25 j(1,1)-0.25], [min(0,tmp(1)) min(0,tmp(1)) max(0,tmp(1)) max(0,tmp(1))], [0.6 0.6 1],'EdgeColor','none');
        rectangle('Position', [j(1,1)-0.25, min(0,tmp(1)), 0.5, abs(tmp(1))], 'FaceColor', '#9999ff','EdgeColor','none','HandleVisibility','on');
        rectangle('Position', [j(1,2)-0.25, min(0,tmp(2)) 0.5, abs(tmp(2))], 'FaceColor', '#9999ff','EdgeColor','none','HandleVisibility','off');
        rectangle('Position', [j(1,3)-0.25, min(0,tmp(3)) 0.5, abs(tmp(3))], 'FaceColor', '#9999ff','EdgeColor','none','HandleVisibility','off');
        rectangle('Position', [j(1,4)-0.25, min(0,tmp(4)) 0.5, abs(tmp(4))], 'FaceColor', '#9999ff','EdgeColor','none','HandleVisibility','off');
        errorbar(j(1,:), diffs(xidx(2,:),yidx(sk,s)), se(xidx(2,:),yidx(sk,s)).*1.645,'bo', 'LineWidth', 2.5,'Color','#3a6183','CapSize',8,'Marker','_','MarkerSize',4,'HandleVisibility','off');

        tmp = diffs(xidx(4,:),yidx(sk,s));
        fill([j(2,1)-0.25 j(2,1)+0.25 j(2,1)+0.25 j(2,1)-0.25], [min(0,tmp(1)) min(0,tmp(1)) max(0,tmp(1)) max(0,tmp(1))], [1 0.6 0.6],'EdgeColor','none');
        rectangle('Position', [j(2,1)-0.25, min(0,tmp(1)), 0.5, abs(tmp(1))], 'FaceColor', '#ff9999','EdgeColor','none');
        rectangle('Position', [j(2,2)-0.25, min(0,tmp(2)) 0.5, abs(tmp(2))], 'FaceColor', '#ff9999','EdgeColor','none');
        rectangle('Position', [j(2,3)-0.25, min(0,tmp(3)) 0.5, abs(tmp(3))], 'FaceColor', '#ff9999','EdgeColor','none');
        rectangle('Position', [j(2,4)-0.25, min(0,tmp(4)) 0.5, abs(tmp(4))], 'FaceColor', '#ff9999','EdgeColor','none');
        errorbar(j(2,:), diffs(xidx(4,:),yidx(sk,s)), se(xidx(4,:),yidx(sk,s)).*1.645,'bo', 'LineWidth', 2.5,'Color','#a3575c','CapSize',8,'Marker','_','MarkerSize',4,'HandleVisibility','off');

        tmp = diffs(xidx(5,:),yidx(sk,s));
        fill([j(3,1)-0.25 j(3,1)+0.25 j(3,1)+0.25 j(3,1)-0.25], [min(0,tmp(1)) min(0,tmp(1)) max(0,tmp(1)) max(0,tmp(1))], [0.7333 0.784313 0.674509],'EdgeColor','none');
        rectangle('Position', [j(3,1)-0.25, min(0,tmp(1)), 0.5, abs(tmp(1))], 'FaceColor', '#bbc8ac','EdgeColor','none');
        rectangle('Position', [j(3,2)-0.25, min(0,tmp(2)) 0.5, abs(tmp(2))], 'FaceColor', '#bbc8ac','EdgeColor','none');
        rectangle('Position', [j(3,3)-0.25, min(0,tmp(3)) 0.5, abs(tmp(3))], 'FaceColor', '#bbc8ac','EdgeColor','none');
        rectangle('Position', [j(3,4)-0.25, min(0,tmp(4)) 0.5, abs(tmp(4))], 'FaceColor', '#bbc8ac','EdgeColor','none');
        errorbar(j(3,:), diffs(xidx(5,:),yidx(sk,s)), se(xidx(5,:),yidx(sk,s)).*1.645,'bo', 'LineWidth', 2.5,'Color','#678445','CapSize',8,'Marker','_','MarkerSize',4,'HandleVisibility','off');

        tmp = diffs(xidx(6,:),yidx(sk,s));
        fill([j(4,1)-0.25 j(4,1)+0.25 j(4,1)+0.25 j(4,1)-0.25], [min(0,tmp(1)) min(0,tmp(1)) max(0,tmp(1)) max(0,tmp(1))], [1 0.81960 0.4],'EdgeColor','none');
        rectangle('Position', [j(4,1)-0.25, min(0,tmp(1)), 0.5, abs(tmp(1))], 'FaceColor', '#ffd166','EdgeColor','none');
        rectangle('Position', [j(4,2)-0.25, min(0,tmp(2)) 0.5, abs(tmp(2))], 'FaceColor', '#ffd166','EdgeColor','none');
        rectangle('Position', [j(4,3)-0.25, min(0,tmp(3)) 0.5, abs(tmp(3))], 'FaceColor', '#ffd166','EdgeColor','none');
        rectangle('Position', [j(4,4)-0.25, min(0,tmp(4)) 0.5, abs(tmp(4))], 'FaceColor', '#ffd166','EdgeColor','none');
        errorbar(j(4,:), diffs(xidx(6,:),yidx(sk,s)), se(xidx(6,:),yidx(sk,s)).*1.645,'bo', 'LineWidth', 2.5,'Color','#ffb55a','CapSize',8,'Marker','_','MarkerSize',4,'HandleVisibility','off');

        line([0 pt 16], [0,0,0, 0, 0, 0], 'Color', 'k', 'LineStyle', '-', 'LineWidth', 1.5);

        set(gca, 'LineWidth', 1.5)
        ylim([-0.45, 0.85]);
        xlim([0, 16]);
        xlabel('Skill quantile','Interpreter','latex','FontSize',fontsz);
        ylabel('Divorce skill gap','Interpreter','latex','FontSize',fontsz);
        set(get(gca, 'ylabel'),'Units','Normalized','Position', [-0.1, 0.5, 0])
        set(gca, 'XtickLabel', get(gca, 'XtickLabel'), 'TickLabelInterpreter','latex','fontsize', fontsz)
        xticks(pt);
        xticklabels({'25', '50', '75', '90'});
        yticks(-0.4:0.2:.85);
        yticklabels({'-.4','-.2','0','.2','.4','.6','.8'});
        grid on
        box on
        set(gca,'GridAlpha',0.05)
        l = legend({'$\;$Parental edu.$\;$', '$\;$Financial res.$\;$', '$\;$Conflicts$\;$', '$\;$Divorce$\;$'}, 'Interpreter','latex');
        l.FontSize = fontsz-5;
        l.Orientation = 'horizontal';
        set(l,'units','normalized');
        l.Position = [0.6,0.19,0.001,0.09];
        l.NumColumns = 2;
        l.LineWidth = 1.5;
        print(fig, saveloc,'-dpdf','-r0');
        close;
    end
end
