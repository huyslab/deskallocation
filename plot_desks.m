if ~exist('D');
		load optimal_desks.mat
		fprintf('loaded data.\n')
else 
		fprintf('D already in workspace.\n')
end
m = 12;
p = 9;

%finding the most optimal lab meetings setup
for d=1:length(D)
    for k=1:100000
        lab_m = randi([0, 1], [1, m]); %random order of lab meetings
        lab = repmat(lab_m, p, 1);
        matches = sum(D(d).setup == lab);
        if std(matches) < 0.5
            D(d).lab_loc = lab_m;
        else
            D(d).lab_loc = [];
        end
    end
end

lab_map = arrayfun(@(D) ~isempty(D.lab_loc), D);
D = D(lab_map);

total_min = [D.total] == min([D.total]);
t_min = D(total_min);
st = t_min.setup;
st(10,:) = sum(st);
st(:,13) = sum(st');
st(10,13) = 0;
%--------------------------------------------------------------

% Top two plots
tiledlayout(2,2)
nexttile
ht = heatmap(st);
mm = string(month(datetime(1,2:13,1),'shortname'));
mm{1,13} = ['Total'];
ht.XDisplayLabels = mm;
ht.YDisplayLabels = ["Tore" "Anahit" "Agnes" "Roland" "Lana" "Anna" "Jakub" "Jiazhou" "Jolanda", "Total DOP"];
title('Overall setup')
nexttile
hcol = heatmap(t_min.colgs);
title('How many times each person spends with every other person')

% Bottom 2 plots

nexttile
hmeet = heatmap(t_min.lab_loc);
title('The Best Lab meeting location')
nexttile
hmat = heatmap(t_min.matches);
title('How many times each persons location matches to lab meeting location')