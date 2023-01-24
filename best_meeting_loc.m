if ~exist('D');
		load optimal_desks.mat
		fprintf('loaded data.\n')
else 
		fprintf('D already in workspace.\n')
end

for d=1:length(D)
    for k=1:10000
        lab_m = randi([0, 1], [1, m]); %random order of lab meetings
        lab = repmat(lab_m, p, 1);
        matches = sum(D(d).setup' == lab');
        if std(matches) < 1.1
            D(d).lab_loc = lab_m;
        else
            D(d).lab_loc = [];
        end
    end
end

