function sim = sim_model(simdata, rawdata, pars, N, numF, cfact, gap, idx, endg)
%-------------------------------------------------------------------------%
% sim_model.m
% Purpose:  Simulates child skill trajectories from the estimated model.
%           Supports three counterfactual modes: baseline (cfact=0),
%           conflict shock (cfact=1), and no-divorce (cfact=2).
% Arguments:
%   simdata   - struct with pre-drawn shocks: u_het, cshocks, pshocks
%   rawdata   - data struct from getdata (baseline sample)
%   pars      - struct of estimated parameters (from PF_0.mat)
%   N         - sample size
%   numF      - number of skill equations (8)
%   cfact     - counterfactual type: 0=baseline, 1=conflict shock, 2=no divorce
%   gap       - conflict gap for cfact=1 (scalar)
%   idx       - index of treated observations for cfact=1,2
%   endg      - 1 to simulate endogenous divorce, 0 to use observed divorce
% Returns:
%   sim       - struct with simulated skills (sim.s) and divorce (sim.div1)
%-------------------------------------------------------------------------%

    in_idx = [zeros(1,2);1 2; 3 4; 5 6];
    in_idx = repelem(in_idx,2,1);
    est = pars;
    simdata.u = simdata.u_het*est.tfperr*est.tfperrcoef;

    if nargin < 9
        endg = 0;
    end

    if cfact == 0

        if endg == 1

            % conflict
            simdata.c1 = est.bta(1) + rawdata.tfpX{1,1}(:,2:end)*est.bta(2:29) + simdata.cshocks;
            % divorce
            d_prob = glmval(est.alpha,[simdata.c1 rawdata.tfpX{1,1}(:,2:end)],'logit','Size',1);
            simdata.div1 = d_prob >= 0.5;
            simdata.div = mean(simdata.div1);
            % initial skills
            simdata.s = zeros(N,numF);
            for t = 1:numF
                rawdata.tfpX{1,t}(:,1) = double(simdata.div1);
                if t <= 2
                    simdata.s(:,t) = est.tfp(t) + rawdata.tfpX{1,t}*est.tfpcoef{1,t} + simdata.c1*est.inptelas(8,t) + simdata.u(:,t) + simdata.pshocks(:,t);
                else
                    cog = [simdata.s(:,in_idx(t,1)), simdata.s(:,in_idx(t,1)).^2, simdata.s(:,in_idx(t,1)).*simdata.s(:,in_idx(t,2)), simdata.s(:,in_idx(t,1)).*simdata.c1];
                    emo = [simdata.s(:,in_idx(t,2)), simdata.s(:,in_idx(t,2)).^2, simdata.s(:,in_idx(t,2)).*simdata.c1];
                    conf = [simdata.c1, simdata.c1.^2];
                    tmpX = [cog emo conf];
                    simdata.s(:,t) = est.tfp(t) + rawdata.tfpX{1,t}*est.tfpcoef{1,t} + tmpX*est.inptelas(est.inptelas(:,t)~=0,t) + simdata.u(:,t) + simdata.pshocks(:,t);
                end
            end

        else
            % conflict
            simdata.c1 = rawdata.INPT2(:,1);
            simdata.div1 = rawdata.tfpX{1,1}(:,1);
            % initial skills
            simdata.s = zeros(N,numF);
            for t = 1:numF
                if t <= 2
                    simdata.s(:,t) = est.tfp(t) + rawdata.tfpX{1,t}*est.tfpcoef{1,t} + simdata.c1*est.inptelas(8,t) + simdata.u(:,t) + simdata.pshocks(:,t);
                else
                    cog = [simdata.s(:,in_idx(t,1)), simdata.s(:,in_idx(t,1)).^2, simdata.s(:,in_idx(t,1)).*simdata.s(:,in_idx(t,2)), simdata.s(:,in_idx(t,1)).*simdata.c1];
                    emo = [simdata.s(:,in_idx(t,2)), simdata.s(:,in_idx(t,2)).^2, simdata.s(:,in_idx(t,2)).*simdata.c1];
                    conf = [simdata.c1, simdata.c1.^2];
                    tmpX = [cog emo conf];
                    simdata.s(:,t) = est.tfp(t) + rawdata.tfpX{1,t}*est.tfpcoef{1,t} + tmpX*est.inptelas(est.inptelas(:,t)~=0,t) + simdata.u(:,t) + simdata.pshocks(:,t);
                end
            end
        end

        sim = simdata;

    elseif cfact == 1 % stim conflicts

        if endg == 1

            % conflict
            simdata.c1 = est.bta(1) + rawdata.tfpX{1,1}(:,2:end)*est.bta(2:29) + simdata.cshocks;
            simdata.c1(idx,1) = simdata.c1(idx,1) + gap;

            % divorce
            d_prob = glmval(est.alpha,[simdata.c1 rawdata.tfpX{1,1}(:,2:end)],'logit','Size',1);
            simdata.div1 = d_prob >= 0.5;
            simdata.div = mean(simdata.div1);
            % initial skills
            simdata.s = zeros(N,numF);
            for t = 1:numF
                rawdata.tfpX{1,t}(:,1) = double(simdata.div1);
                if t <= 2
                    simdata.s(:,t) = est.tfp(t) + rawdata.tfpX{1,t}*est.tfpcoef{1,t} + simdata.c1*est.inptelas(8,t) + simdata.u(:,t) + simdata.pshocks(:,t);
                else
                    cog = [simdata.s(:,in_idx(t,1)), simdata.s(:,in_idx(t,1)).^2, simdata.s(:,in_idx(t,1)).*simdata.s(:,in_idx(t,2)), simdata.s(:,in_idx(t,1)).*simdata.c1];
                    emo = [simdata.s(:,in_idx(t,2)), simdata.s(:,in_idx(t,2)).^2, simdata.s(:,in_idx(t,2)).*simdata.c1];
                    conf = [simdata.c1, simdata.c1.^2];
                    tmpX = [cog emo conf];
                    simdata.s(:,t) = est.tfp(t) + rawdata.tfpX{1,t}*est.tfpcoef{1,t} + tmpX*est.inptelas(est.inptelas(:,t)~=0,t) + simdata.u(:,t) + simdata.pshocks(:,t);
                end
            end

        else

            % conflict
            simdata.c1 = rawdata.INPT2(:,1);
            simdata.c1(idx,1) = simdata.c1(idx,1) + gap;
            simdata.div1 = rawdata.tfpX{1,1}(:,1);
            % initial skills
            simdata.s = zeros(N,numF);
            for t = 1:numF
                if t <= 2
                    simdata.s(:,t) = est.tfp(t) + rawdata.tfpX{1,t}*est.tfpcoef{1,t} + simdata.c1*est.inptelas(8,t) + simdata.u(:,t) + simdata.pshocks(:,t);
                else
                    cog = [simdata.s(:,in_idx(t,1)), simdata.s(:,in_idx(t,1)).^2, simdata.s(:,in_idx(t,1)).*simdata.s(:,in_idx(t,2)), simdata.s(:,in_idx(t,1)).*simdata.c1];
                    emo = [simdata.s(:,in_idx(t,2)), simdata.s(:,in_idx(t,2)).^2, simdata.s(:,in_idx(t,2)).*simdata.c1];
                    conf = [simdata.c1, simdata.c1.^2];
                    tmpX = [cog emo conf];
                    simdata.s(:,t) = est.tfp(t) + rawdata.tfpX{1,t}*est.tfpcoef{1,t} + tmpX*est.inptelas(est.inptelas(:,t)~=0,t) + simdata.u(:,t) + simdata.pshocks(:,t);
                end
            end

        end

        sim = simdata;

    elseif cfact == 2 % no divorce

        if endg == 1
            % conflict
            simdata.c1 = est.bta(1) + rawdata.tfpX{1,1}(:,2:end)*est.bta(2:29) + simdata.cshocks;
            % divorce
            d_prob = glmval(est.alpha,[simdata.c1 rawdata.tfpX{1,1}(:,2:end)],'logit','Size',1);
            simdata.div1 = d_prob >= 0.5;
            simdata.div = mean(simdata.div1);

            simdata.div1(idx) = 0;

            % initial skills
            simdata.s = zeros(N,numF);
            for t = 1:numF
                rawdata.tfpX{1,t}(:,1) = double(simdata.div1);
                if t <= 2
                    simdata.s(:,t) = est.tfp(t) + rawdata.tfpX{1,t}*est.tfpcoef{1,t} + simdata.c1*est.inptelas(8,t) + simdata.u(:,t) + simdata.pshocks(:,t);
                else
                    cog = [simdata.s(:,in_idx(t,1)), simdata.s(:,in_idx(t,1)).^2, simdata.s(:,in_idx(t,1)).*simdata.s(:,in_idx(t,2)), simdata.s(:,in_idx(t,1)).*simdata.c1];
                    emo = [simdata.s(:,in_idx(t,2)), simdata.s(:,in_idx(t,2)).^2, simdata.s(:,in_idx(t,2)).*simdata.c1];
                    conf = [simdata.c1, simdata.c1.^2];
                    tmpX = [cog emo conf];
                    simdata.s(:,t) = est.tfp(t) + rawdata.tfpX{1,t}*est.tfpcoef{1,t} + tmpX*est.inptelas(est.inptelas(:,t)~=0,t) + simdata.u(:,t) + simdata.pshocks(:,t);
                end
            end

        else

            % conflict
            simdata.c1 = rawdata.INPT2(:,1);
            simdata.div1 = rawdata.tfpX{1,1}(:,1);

            % initial skills
            simdata.s = zeros(N,numF);
            for t = 1:numF
                rawdata.tfpX{1,t}(idx,1) = 0;
                if t <= 2
                    simdata.s(:,t) = est.tfp(t) + rawdata.tfpX{1,t}*est.tfpcoef{1,t} + simdata.c1*est.inptelas(8,t) + simdata.u(:,t) + simdata.pshocks(:,t);
                else
                    cog = [simdata.s(:,in_idx(t,1)), simdata.s(:,in_idx(t,1)).^2, simdata.s(:,in_idx(t,1)).*simdata.s(:,in_idx(t,2)), simdata.s(:,in_idx(t,1)).*simdata.c1];
                    emo = [simdata.s(:,in_idx(t,2)), simdata.s(:,in_idx(t,2)).^2, simdata.s(:,in_idx(t,2)).*simdata.c1];
                    conf = [simdata.c1, simdata.c1.^2];
                    tmpX = [cog emo conf];
                    simdata.s(:,t) = est.tfp(t) + rawdata.tfpX{1,t}*est.tfpcoef{1,t} + tmpX*est.inptelas(est.inptelas(:,t)~=0,t) + simdata.u(:,t) + simdata.pshocks(:,t);
                end
            end

        end

        sim = simdata;

    end

end
