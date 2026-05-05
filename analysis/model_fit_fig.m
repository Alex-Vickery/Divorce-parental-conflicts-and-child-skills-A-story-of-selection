function model_fit_fig(x1, f1, x2, f2, xlab, fig_saveloc)
%-------------------------------------------------------------------------%
% model_fit_fig.m
% Purpose:  Plots two kernel density estimates (data vs. model) and saves
%           the figure as a PDF.
% Arguments:
%   x1, f1      - evaluation points and density for the data series
%   x2, f2      - evaluation points and density for the model series
%   xlab        - x-axis label string
%   fig_saveloc - full path for the output PDF (without extension)
%-------------------------------------------------------------------------%

    fig_saveloc = string(fig_saveloc);

    fontsz = 20;
    fig = figure('Name','model_fit');
    set(gcf, 'color','w')
    set(1,'units','centimeters','pos',[0 0 16 12])
    set(fig,'units','Inches');
    pos = get(fig,'Position');
    set(fig,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)]);
    plot(x1,f1,'LineWidth', 3, 'Color', '#7eb0d5'); % Line 1
    hold on
    plot(x2,f2,'LineWidth', 3, 'Color', '#b2e061','LineStyle', ':'); % Line 2
    set(gca, 'LineWidth', 1.5)
    ylim([0, 0.7]);
    xlim([-5, 5]);
    xlabel(xlab,'Interpreter','latex','FontSize',fontsz);
    ylabel('density','Interpreter','latex','FontSize',fontsz);
    set(get(gca, 'ylabel'),'Units','Normalized','Position', [-0.1, 0.5, 0])
    set(gca, 'XtickLabel', get(gca, 'XtickLabel'), 'TickLabelInterpreter','latex','fontsize', fontsz)
    xticks(-5:1:5);
    xticklabels({'-5','-4','-3','-2','-1','0','1','2','3','4','5'});
    yticks(0:0.1:0.7);
    yticklabels({'0','0.1', '0.2', '0.3', '0.4', '0.5', '0.6', '0.7'});
    % legend
    l = legend({'$\;$data$\;$', '$\;$model$\;$'}, 'Interpreter','latex');
    l.FontSize = fontsz-5;
    l.Orientation = 'horizontal';
    set(l,'units','normalized');
    l.Position = [0.76,0.653,0.001,0.09];
    l.NumColumns = 1;
    l.LineWidth = 1.5;
    grid on
    set(gca,'GridAlpha',0.02)
    print(fig, fig_saveloc,'-dpdf','-r0');
    close;

end
