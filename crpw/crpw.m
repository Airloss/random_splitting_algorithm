clear

total_slot = 2e5;
theata = 0.99;
lambda = 0.02:0.02:0.6;
throughput = zeros(length(lambda),1);

tic
for ldx = 1:length(lambda)
    % Initialization
    mu = 10;
    scs = 0;
    prob = 1.8842 / mu;
    lambdaE = 0.5;
    queue = 0;
    slot = 1;
    % Simulation
    while slot <= total_slot
        queue = queue + poissrnd(lambda(ldx));
        trans_pkt = rand(queue,1) < prob;
        k = sum(trans_pkt);
        if k == 0
            lambdaE = lambdaE * theata;
            mu = max(mu - 1.8842 + lambdaE, 0.1);
        elseif k == 1
            scs = scs + 1;
            lambdaE = lambdaE * theata + 1 - theata;
            mu = max(mu - 1.8842 + lambdaE, 0.1);
        else
            tk = 0;
            % CRPW(k) Process
            k_list = zeros(k,1);
            k_list(1) = k;
            for kdx = 1:k
                if k_list(kdx) > 0
                    tkk = 0;
                    while k_list(kdx) > 0
                        crpw_prob = 1 / k_list(kdx);
                        crpw_trans = rand(k_list(kdx),1) < crpw_prob;
                        kj = sum(crpw_trans);
                        if kj == 1
                            k_list(kdx) = k_list(kdx) - 1;
                        elseif kj > 0 && kj < k_list(kdx)
                            k_0 = find(k_list == 0);
                            if k_0(1) < kdx
                                disp FALSE_FIND
                            end
                            k_list(k_0(1)) = k_list(kdx) - kj;
                            k_list(kdx) = kj;
                        end
                        tkk = tkk + 1;
                        queue = queue + poissrnd(lambda(ldx));
                    end
                    k_list(kdx) = -1;
                    tk = tk + tkk;
                else
                    break;
                end
            end
            scs = scs + k;
            lambdaE = (lambdaE * theata + (1-theata) * k) / (theata + (1-theata) * (1+tk));
            mu = max(mu - 1.8842 + lambdaE * (1 + tk), 0.1);
            slot = slot + tk;
        end
        queue = queue - k;
        slot = slot + 1;
        prob = min(1, 1.8842/mu);
    end
    throughput(ldx) = scs / slot;
end
toc

figure
plot(lambda,throughput,'LineWidth',1.5)
grid on
xlabel('$\lambda$ (packets/sec)','Interpreter','latex','FontSize',17.6)
ylabel('Throughput (packets/sec)','Interpreter','latex','FontSize',17.6)
title('Splitting with Collided Number','Interpreter','latex','FontSize',17.6)