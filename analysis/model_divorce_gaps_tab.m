function model_divorce_gaps_tab(ftest0_m, ftest1_m, ftest0_f, ftest1_f, saveloc)
%-------------------------------------------------------------------------%
% model_divorce_gaps_tab.m
% Purpose:  Writes Table A.14 — the comparison of mean and percentile
%           divorce skill gaps in data vs. model — as a LaTeX tabular.
% Arguments:
%   ftest0_m  - 1x16 mean divorce gaps (data & model), boys
%   ftest1_m  - 1x16 percentile divorce gaps (data & model), boys
%   ftest0_f  - 1x16 mean divorce gaps (data & model), girls
%   ftest1_f  - 1x16 percentile divorce gaps (data & model), girls
%   saveloc   - full path for the output .tex file
%-------------------------------------------------------------------------%

% make the table
tab = fopen(saveloc,'w');
fprintf(tab, '\\begin{tabular}{lcccc} \n');
fprintf(tab, '\\toprule \n');
fprintf(tab, ' & (1) & (2) & (3) & (4) \\\\ \n');
fprintf(tab, ' & Age 3 & Age 5 & Age 7 & Age 11 \\\\ \n');
fprintf(tab, '\\cmidrule{1-5} \n');
fprintf(tab, '\\textit{a) Cognitive skills - Boys} & \\multicolumn{4}{c}{} \\\\ [5pt] \n');
didx = 1:4:13;
midx = 2:4:14;
fprintf(tab, 'Mean divorce gap (data) & %2.2f & %2.2f & %2.2f & %2.2f \\\\ \n',ftest0_m(didx));
fprintf(tab, 'Mean divorce gap (model) & %2.2f & %2.2f & %2.2f & %2.2f \\\\ \n', ftest0_m(midx));
fprintf(tab, '\\cmidrule{2-5} \n');
fprintf(tab, 'Percentile divorce gap (data) & %2.2f & %2.2f & %2.2f & %2.2f \\\\ \n',ftest1_m(didx));
fprintf(tab, 'Percentile divorce gap (model) & %2.2f & %2.2f & %2.2f & %2.2f \\\\ \n', ftest1_m(midx));
fprintf(tab, '\\cmidrule{1-5} \n');
fprintf(tab, '\\textit{b) Cognitive skills - Girls} & \\multicolumn{4}{c}{} \\\\ [5pt] \n');
didx = 1:4:13;
midx = 2:4:14;
fprintf(tab, 'Mean divorce gap (data) & %2.2f & %2.2f & %2.2f & %2.2f \\\\ \n',ftest0_f(didx));
fprintf(tab, 'Mean divorce gap (model) & %2.2f & %2.2f & %2.2f & %2.2f \\\\ \n', ftest0_f(midx));
fprintf(tab, '\\cmidrule{2-5} \n');
fprintf(tab, 'Percentile divorce gap (data) & %2.2f & %2.2f & %2.2f & %2.2f \\\\ \n',ftest1_f(didx));
fprintf(tab, 'Percentile divorce gap (model) & %2.2f & %2.2f & %2.2f & %2.2f \\\\ \n', ftest1_f(midx));
fprintf(tab, '\\cmidrule{1-5} \n');
fprintf(tab, '\\textit{c) Socio-emotional skills - Boys} & \\multicolumn{4}{c}{} \\\\ [5pt] \n');
didx = 3:4:15;
midx = 4:4:16;
fprintf(tab, 'Mean divorce gap (data) & %2.2f & %2.2f & %2.2f & %2.2f \\\\ \n',ftest0_m(didx));
fprintf(tab, 'Mean divorce gap (model) & %2.2f & %2.2f & %2.2f & %2.2f \\\\ \n', ftest0_m(midx));
fprintf(tab, '\\cmidrule{2-5} \n');
fprintf(tab, 'Percentile divorce gap (data) & %2.2f & %2.2f & %2.2f & %2.2f \\\\ \n',ftest1_m(didx));
fprintf(tab, 'Percentile divorce gap (model) & %2.2f & %2.2f & %2.2f & %2.2f \\\\ \n', ftest1_m(midx));
fprintf(tab, '\\cmidrule{1-5} \n');
fprintf(tab, '\\textit{d) Socio-emotional skills - Girls} & \\multicolumn{4}{c}{} \\\\ [5pt] \n');
didx = 3:4:15;
midx = 4:4:16;
fprintf(tab, 'Mean divorce gap (data) & %2.2f & %2.2f & %2.2f & %2.2f \\\\ \n',ftest0_f(didx));
fprintf(tab, 'Mean divorce gap (model) & %2.2f & %2.2f & %2.2f & %2.2f \\\\ \n', ftest0_f(midx));
fprintf(tab, '\\cmidrule{2-5} \n');
fprintf(tab, 'Percentile divorce gap (data) & %2.2f & %2.2f & %2.2f & %2.2f \\\\ \n',ftest1_f(didx));
fprintf(tab, 'Percentile divorce gap (model) & %2.2f & %2.2f & %2.2f & %2.2f \\\\ \n', ftest1_f(midx));
fprintf(tab, '\\bottomrule \n');
fprintf(tab, '\\end{tabular} \n');
fclose(tab);

end
