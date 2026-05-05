%-------------------------------------------------------------------------%
% make_tabs.m
% Purpose:  Produces all parameter estimate tables (Tables 5, 6, A.11,
%           A.12, A.13) from the baseline and bootstrap estimates.
% Inputs:   output/estimates/PF_0.mat ... PF_250.mat
% Outputs:  output/tables/prod_f.tex
%           output/tables/tfp_cog.tex
%           output/tables/tfp_emo.tex
%           output/tables/unob_het.tex
%           output/tables/div_con.tex
%-------------------------------------------------------------------------%
clearvars;
global root_dir

estimates_dir = fullfile(root_dir, 'output', 'estimates');
tables_dir    = fullfile(root_dir, 'output', 'tables');

pf = cellstr(strcat({'translog '},string(1)));

%--------------------------------------------------------------------------
% production technology(s) - cog and emo
% 9 x 6, two skills, ages 5, 7, 11
%--------------------------------------------------------------------------

% load initial pars
saveloc = fullfile(estimates_dir, sprintf('PF_%d.mat', 0));
load(saveloc,'est'); % load initial estimates
temp = [est.inptelas(1:9,3:4),est.inptelas(10:18,5:6),est.inptelas(19:27,7:8)];

numbbs = 250;
temp_se = zeros(9,6,numbbs);
% load the rest for the bootstrap
for bs = 1:numbbs
    saveloc = fullfile(estimates_dir, sprintf('PF_%d.mat', bs));
    load(saveloc,'est');
    temp_se(:,:,bs) = [est.inptelas(1:9,3:4),est.inptelas(10:18,5:6),est.inptelas(19:27,7:8)];
end
temp_se = std(temp_se,[],3);

row_l = {'$\gamma^k_c$', '$\gamma^k_{cc}$', '$\gamma^k_{ce}$','$\gamma^k_{cp}$',...
    '$\gamma^k_{e}$', '$\gamma^k_{ee}$',' $\gamma^k_{ep}$', ...
    '$\gamma^k_{p}$','$\gamma^k_{pp}$'};
tab = fopen(fullfile(tables_dir, 'prod_f.tex'),'w');
fprintf(tab, '\\begin{tabular}{L{1.5cm}C{2cm}C{2cm}C{2cm}cC{2cm}C{2cm}C{2cm}} \n');
fprintf(tab, '\\toprule \n');
fprintf(tab, '& (1) & (2) & (3) & & (4) & (5) & (6) \\\\[5pt] \n');
fprintf(tab, ' & \\multicolumn{3}{c}{Cognitive skills} & & \\multicolumn{3}{c}{Socio-emotional skills} \\\\[5pt] \n');
fprintf(tab, ' & Age 5 & Age 7 & Age 11 & & Age 5 & Age 7 & Age 11 \\\\ \n');
fprintf(tab, '\\cmidrule{2-4} \\cmidrule{6-8}\\\\[-10pt] \n');
for i = 1:length(temp)
    fprintf(tab, '%s & %s & %s & %s & & %s & %s & %s \\\\ \n',row_l{i},AddCommaArr(temp(i,[1 3 5]),temp(i,[1 3 5])./temp_se(i,[1 3 5])), AddCommaArr(temp(i,[2 4 6]), temp(i,[2 4 6])./temp_se(i,[2 4 6])));
    fprintf(tab, ' & \\footnotesize (%3.2f) & \\footnotesize (%3.2f) & \\footnotesize (%3.2f) & & \\footnotesize (%3.2f) & \\footnotesize (%3.2f) & \\footnotesize (%3.2f) \\\\ \n',temp_se(i,[1 3 5]),temp_se(i,[2 4 6]));
end
fprintf(tab, '\\bottomrule \n');
fprintf(tab, '\\end{tabular} \n');
fclose(tab);
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% TFP equations - cog, emo, 30 rows
%--------------------------------------------------------------------------

row_l = {'divorce','female','birth weight (Kg)',...
    'Number of siblings','Cohabitation', 'Duration of relationship','Planned pregnancy','Mother''s religion','Mother''s age','Father''s age','Mother white','Father white',...
    'Mother GCSE', 'Mother A-level', 'Mother University degree','Father GCSE', 'Father A-level', 'Father University degree',...
    'Mother good health', 'Father good health',...
    'OECD equiv. income', 'Own house', 'Rent house', 'Mother managerial occ.', 'Mother intermediate occ.','Mother routine occ.',...
    'Father managerial occ.', 'Father intermediate occ.','Father routine occ.','constant'};

% load initial pars
saveloc = fullfile(estimates_dir, sprintf('PF_%d.mat', 0));
load(saveloc,'est'); % load initial estimates
temp = [cell2mat(est.tfpcoef);est.tfp];

temp_se = zeros(30,8,numbbs);
% load the rest for the bootstrap
for bs = 1:numbbs
    saveloc = fullfile(estimates_dir, sprintf('PF_%d.mat', bs));
    load(saveloc,'est');
    temp_se(:,:,bs) = [cell2mat(est.tfpcoef);est.tfp];
end
temp_se = std(temp_se,[],3);

tab = fopen(fullfile(tables_dir, 'tfp_cog.tex'),'w');
fprintf(tab, '\\begin{tabular}{L{4.5cm}C{2cm}C{2cm}C{2cm}C{2cm}} \n');
fprintf(tab, '\\toprule \n');
fprintf(tab, '& (1) & (2) & (3) & (4) \\\\[5pt] \n');
fprintf(tab, ' & Age 3 & Age 5 & Age 7 & Age 11 \\\\ \n');
fprintf(tab, '\\cmidrule{2-5} \\\\[-10pt] \n');
for i = 1:length(temp)
    fprintf(tab, '%s & %s & %s & %s & %s \\\\ \n',row_l{i},AddCommaArr(temp(i,[1 3 5 7]),temp(i,[1 3 5 7])./temp_se(i,[1 3 5 7])));
end
fprintf(tab, '\\bottomrule \n');
fprintf(tab, '\\end{tabular} \n');
fclose(tab);

tab = fopen(fullfile(tables_dir, 'tfp_emo.tex'),'w');
fprintf(tab, '\\begin{tabular}{L{4.5cm}C{2cm}C{2cm}C{2cm}C{2cm}} \n');
fprintf(tab, '\\toprule \n');
fprintf(tab, '& (1) & (2) & (3) & (4) \\\\[5pt] \n');
fprintf(tab, ' & Age 3 & Age 5 & Age 7 & Age 11 \\\\ \n');
fprintf(tab, '\\cmidrule{2-5} \\\\[-10pt] \n');
for i = 1:length(temp)
    fprintf(tab, '%s & %s & %s & %s & %s \\\\ \n',row_l{i},AddCommaArr(temp(i,[2 4 6 8]),temp(i,[2 4 6 8])./temp_se(i,[2 4 6 8])));
end
fprintf(tab, '\\bottomrule \n');
fprintf(tab, '\\end{tabular} \n');
fclose(tab);


%--------------------------------------------------------------------------
% Unob het and error var.
%--------------------------------------------------------------------------

% load initial pars
saveloc = fullfile(estimates_dir, sprintf('PF_%d.mat', 0));
load(saveloc,'est'); % load initial estimates
temp = [est.pr',est.tfperr(:,1),repmat(est.tfperr(:,2),1,3),est.tfperr(:,1),repmat(est.tfperr(:,3),1,3)];
row_l = {'Type 1', 'Type 2', 'Type 3', 'Type 4', 'Type 5'};

tab = fopen(fullfile(tables_dir, 'unob_het.tex'),'w');
fprintf(tab, '\\begin{tabular}{L{1.2cm}ccC{1.1cm}C{1.1cm}C{1.1cm}C{1.1cm}cC{1.1cm}C{1.1cm}C{1.1cm}C{1.1cm}} \n');
fprintf(tab, '\\toprule \n');
fprintf(tab, '& (1) & & (2) & (3) & (4) & (5) & & (6) & (7) & (8) & (9) \\\\[5pt] \n');
fprintf(tab, '& & & \\multicolumn{4}{c}{Cognitive skills} & & \\multicolumn{4}{c}{Socio-emotional skills} \\\\[5pt] \n');
fprintf(tab, '& type share & & Age 3 & Age 5 & Age 7 & Age 11 & & Age 3 & Age 5 & Age 7 & Age 11 \\\\[5pt] \n');
fprintf(tab, '\\cmidrule{2-2} \\cmidrule{4-7}  \\cmidrule{9-12} \\\\[-10pt] \n');
for i = 1:size(temp,1)-1
    fprintf(tab, '%s & %3.2f & & %3.2f & %3.2f & %3.2f & %3.2f & & %3.2f & %3.2f & %3.2f & %3.2f\\\\[2pt] \n',row_l{i},temp(i,:));
end
fprintf(tab, '%s & %3.2f & & 0 & 0 & 0 & 0 & & 0 & 0 & 0 & 0\\\\ \n',row_l{5},temp(5,1));
fprintf(tab, '\\cmidrule{2-12} \\\\[-10pt] \n');
 fprintf(tab, '$\\sigma^2_{\\eta^k_t}$ & & & %3.2f & %3.2f & %3.2f & %3.2f & & %3.2f & %3.2f & %3.2f & %3.2f\\\\[2pt] \n',est.var.^2);
fprintf(tab, '\\bottomrule \n');
fprintf(tab, '\\end{tabular} \n');
fclose(tab);

%--------------------------------------------------------------------------
% Conflicts and Divorce
%--------------------------------------------------------------------------

row_l = {'Inter-parental conflicts','female','birth weight (Kg)',...
    'Number of siblings','Cohabitation', 'Duration of relationship','Planned pregnancy','Mother''s religion','Mother''s age','Father''s age','Mother white','Father white',...
    'Mother GCSE', 'Mother A-level', 'Mother University degree','Father GCSE', 'Father A-level', 'Father University degree',...
    'Mother good health', 'Father good health',...
    'OECD equiv. income', 'Own house', 'Rent house', 'Mother managerial occ.', 'Mother intermediate occ.','Mother routine occ.',...
    'Father managerial occ.', 'Father intermediate occ.','Father routine occ.','constant'};

% load initial pars
saveloc = fullfile(estimates_dir, sprintf('PF_%d.mat', 0));
load(saveloc,'est'); % load initial estimates
temp = [[0;est.bta(2:end);est.bta(1)],[est.alpha(2:end);est.alpha(1)]];

temp_se = zeros(30,2,numbbs);
% load the rest for the bootstrap
for bs = 1:numbbs
    saveloc = fullfile(estimates_dir, sprintf('PF_%d.mat', bs));
    load(saveloc,'est');
    temp_se(:,:,bs) = [[0;est.bta(2:end);est.bta(1)],[est.alpha(2:end);est.alpha(1)]];
end
temp_se = std(temp_se,[],3);

tab = fopen(fullfile(tables_dir, 'div_con.tex'),'w');
fprintf(tab, '\\begin{tabular}{L{4.5cm}C{3.5cm}C{3.5cm}} \n');
fprintf(tab, '\\toprule \n');
fprintf(tab, '& (1) & (2) \\\\[5pt] \n');
fprintf(tab, '& Inter-parental conflicts & Divorce \\\\[5pt] \n');
fprintf(tab, '\\cmidrule{2-3} \\\\[-10pt] \n');
fprintf(tab, '%s & - & %s \\\\ \n',row_l{1},AddCommaArr(temp(1,2),temp(1,2)./temp_se(1,2)));
for i = 2:length(temp)
    fprintf(tab, '%s & %s & %s \\\\ \n',row_l{i},AddCommaArr(temp(i,:),temp(i,:)./temp_se(i,:)));
end
fprintf(tab, '\\bottomrule \n');
fprintf(tab, '\\end{tabular} \n');
fclose(tab);
