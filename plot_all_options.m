if ~exist('D');
		load optimal_desks.mat
		fprintf('loaded data.\n')
else 
		fprintf('D already in workspace.\n')
end
m = 12;
p = 9;

for k=1:length(D)
    t = D(k);
    st = t.setup;
    st(10,:) = sum(st);
    st(:,13) = sum(st');
    st(10,13) = 0;
    testy = st(:,13);
    if (sum(testy >= m*(1/3) & testy <= m*(2/3)) == 9) & (min(min(t.colgs)) >= m/4)
            for j=1:100000
                lab_m = randi([0, 1], [1, m]); %random order of lab meetings
                lab = repmat(lab_m, p, 1);
                matches = sum(D(k).setup == lab);
                if std(matches) < 2
                    D(k).lab_loc = lab_m;
                else
                    D(k).lab_loc = [];
                end
            end
    end
end

lab_map = arrayfun(@(D) ~isempty(D.lab_loc), D);
D = D(lab_map);

for g=1:length(D)
    t_min = D(g);
    st = D(g).setup;
    st(10,:) = sum(st);
    st(:,13) = sum(st');
    st(10,13) = 0;
    
    %--------------------------------------------------------------
    % Top two plots
    tt = tiledlayout(2,2)
    nexttile
    ht = heatmap(st);
    mm = string(month(datetime(1,2:13,1),'shortname'));
    mm{1,13} = ['Total'];
    ht.XDisplayLabels = mm;
    ht.YDisplayLabels = ["Tore" "Anahit" "Agnes" "Roland" "Lana" "Anna" "Jakub" "Jiazhou" "Jolanda", "Total DOP"];
    title('Overall setup')
    nexttile
    hcol = heatmap(t.colgs);
    title('How many times each person spends with every other person')
    hcol.YDisplayLabels = ["Tore" "Anahit" "Agnes" "Roland" "Lana" "Anna" "Jakub" "Jiazhou" "Jolanda"];
    hcol.XDisplayLabels = ["Tore" "Anahit" "Agnes" "Roland" "Lana" "Anna" "Jakub" "Jiazhou" "Jolanda"];
    
    % Bottom 2 plots
    
    nexttile
    hmeet = heatmap(t_min.lab_loc);
    title('The Best Lab meeting location')
    nexttile
    hmat = heatmap(t_min.matches);
    title('How many times each persons location matches to lab meeting location')
    hmat.XDisplayLabels = ["Tore" "Anahit" "Agnes" "Roland" "Lana" "Anna" "Jakub" "Jiazhou" "Jolanda"];
        
    saveas(tt,sprintf('FIG%d.png',g));
end