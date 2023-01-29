clear all; 

%Optimise amount of time spent in each office space
p = 9; %number of people
dm = 4; %desks mpc
dd = 5; %desks dop; add floating desk later
d = dm + dd; 
fm = dm/d; 
m = 5; %months
npd = 4; % number of postdocs 
paccept = .95; 

fontsize=11;

mpcdesks = {'MPC-a','MPC-b','MPC-c','MPC-d'}; 
dopdesks = {'DoP-fix1','DoP-fix2','DoP-float','DoP-float','DoP-float'}; 
names = {'Agnes'  'Anahit' 'Roeland' 'Tore' 'Anna' 'Jakub' 'Jiazhou' 'Jolanda' 'Lana'};
mm = string(month(datetime(1,(1:m)+1,1),'shortname'));

names_nodesk = {'Kangxin/Mina','Daisy'}; 
nodesks = length(names_nodesk);

qmnames = {names{:}, names_nodesk{:}};
qmeetingslots{1} = {'Tue 9.00','Tue 9.45','Tue 10.30','Tue 11.15'};
qmeetingslots{2} = {'Tue 13.00','Tue 14.00','Tue 16.30','Tue 17.15'};
qmeetingslots{3} = {'Fri 9.30','Fri 10.15','Fri 11.00'};
nmeetingslots = [4 4 3];
nm = length(qmnames);

X = randi([0, 1], [p, m]); %initialising random desk allocation

w = [1 1 3 2]; 

X = [ones(dm,m); zeros(dd,m)];
M = X*X' + (1-X)*(1-X)';
M = triu(M,1);

fail=0; 
Xp = X; 
Mp = M; 
e  = w(1)*sum((sum(Xp)/d-fm).^2) ...			% totals match actual desks at DoP vs MPC
	+ w(2)*sum((sum(Xp,2)/m-fm).^2) ...			% fraction of time at MPC vs frac desks
	+ w(3)*sum(sum(triu(Mp/m-fm,1),2).^2) ...	% all matched up with all 
	+ w(4)*sum((sum(Xp(1:npd,:))/npd-.5).^2); % half the postdocs at each site 

for it=1:2000
	% propose a permutation in one random month 
	rd = randperm(p);
	rm = randi(m);
	Xp = X; 
	Xp(:,rm) = X(rd,rm);
	% compute how good that permutation would be 
	Mp = Xp*Xp' + (1-Xp)*(1-Xp)';
	Mp = triu(Mp,1);
	ep  = w(1)*sum((sum(Xp)/d-fm).^2) ...			% totals match actual desks at DoP vs MPC
		+ w(2)*sum((sum(Xp,2)/m-fm).^2) ...			% fraction of time at MPC vs frac desks
		+ w(3)*sum(sum(triu(Mp/m-fm,1),2).^2) ...	% all matched up with all 
		+ w(4)*sum((sum(Xp(1:npd,:))/npd-.5).^2); % half the postdocs at each site 

	r=rand> ((1-paccept)/(fail));
	if ep<e & r	% accept with paccept probabiliyt if it improves things 
		fprintf('success: %g\n',ep)
		X = Xp;
		M = Mp; 
		e = ep; 
		imagesc(X); drawnow;
	elseif ep>e & ~r 	% randomly accept some bad moves 
		fprintf('noisy  : %g\n',ep)
		X = Xp;
		M = Mp; 
		e = ep; 
		imagesc(X); drawnow;
	else
		fail=fail+1; 
%		fprintf('failure: %i\n',fail); 
	end
	ee(it)=ep;
	xx(:,:,it) = X;
end

[foo,i] = min(ee); 
X = xx(:,:,i);

% DESK ASSIGNMENT 
% 
D = cell(nm,m);
% @ MPC 
for k=1:m 
	D(X(:,k)==1,k) = mpcdesks(randperm(dm));
end
% @ DoP 
for k=1:m 
	D(X(:,k)==0,k) = dopdesks; 
end
X(end+1:end+nodesks,:) = NaN; 
D(isnan(X)) = {'-'};

% MEETING ASSIGNMENT 
labmeeting = sin((1:m)*pi)>0; % 1 is mpc
labmeetingtxt = cell(1,m);
labmeetingtxt(labmeeting==1) = {'MPC'};
labmeetingtxt(labmeeting==0) = {'DoP'};

% for now, have 4 at MPC, 5 at DoP, and 2 flexible. 
% so always see the flexible ones at DoP
% so make one of the 4-meeting sessions and the fri 3-meeting session @ MPC 
% and make one 4-meeting session at DoP
% for months when lab meeting is at MPC, have 4 @ DoP, then 4 MPC, then 3 @ MPC 
% for months when lab meeting is at DoP, have 4 @ MPC, then 4 DoP, then 3 @ MPC 

% flexible ones at MPC 
Xmeetings = X; Xmeetings(isnan(Xmeetings))=1; 
% choose a different random person at DoP to have meeting at MPC 
switched = []; 
Xswitch = zeros(size(X));
for j=1:m
	while 1 
		i = find(Xmeetings(:,j)==0);
		i = i(randi(dd));
		if ~any(i==switched)
			Xmeetings(i,j) = 1; 
			Xswitch(i,j) = 1; 
			switched = [switched i];
			Xmeetings
			break;
		end
	end
end

for j=1:m
	if labmeeting(j)==1
		mpcmeetings = [qmeetingslots{2}, qmeetingslots{3}];
		for k=1:length(mpcmeetings); mpcmeetings{k} = [mpcmeetings{k} ' @MPC'];end
		dopmeetings = qmeetingslots{1};
		for k=1:length(dopmeetings); dopmeetings{k} = [dopmeetings{k} ' @DoP'];end
		meetingtimeplace(find(Xmeetings(:,j)==1),j) = mpcmeetings;
		meetingtimeplace(find(Xmeetings(:,j)==0),j) = dopmeetings;
	else 
		mpcmeetings = [qmeetingslots{1}, qmeetingslots{3}];
		for k=1:length(mpcmeetings); mpcmeetings{k} = [mpcmeetings{k} ' @MPC'];end
		dopmeetings = qmeetingslots{2};
		for k=1:length(dopmeetings); dopmeetings{k} = [dopmeetings{k} ' @DoP'];end
		meetingtimeplace(find(Xmeetings(:,j)==1),j) = mpcmeetings;
		meetingtimeplace(find(Xmeetings(:,j)==0),j) = dopmeetings;
	end
end

cmap = [linspace(.9,0,256)', linspace(.9447,.447,256)', linspace(.9741,.741,256)'];
cmap = cmap(end:-1:1,:);


for k=1:length(D(:)); Dm{k} = [D{k} ' / ' meetingtimeplace{k}];end

subplot(3,1,1:2)
imagesc([X; labmeeting]);
colormap(gca, cmap);
set(gca,'yticklabels',[qmnames 'Lab meeting']);
set(gca,'xticklabels',mm)
set(gca,'ytick',1:nm+1)
set(gca,'xtick',1:m)
set(gca,'fontsize',fontsize);
[x,y] = ndgrid(1:nm,(1:m));
%text(y(:),x(:),num2str(x(:)),'fontsize',16,'horizontalalignment','center'); 
text(y(find(~Xswitch)),x(find(~Xswitch)),Dm(find(~Xswitch)),'color','k','fontsize',fontsize,'horizontalalignment','center'); 
text(y(find( Xswitch)),x(find( Xswitch)),Dm(find( Xswitch)),'color','r','fontsize',fontsize,'horizontalalignment','center'); 
text(1:m,ones(1,m)*nm+1,labmeetingtxt(:),'fontsize',fontsize,'horizontalalignment','center')

%subplot(2,3,[4:5 ])
%imagesc([Xmeetings; labmeeting]);
%colormap(gca, cmap);
%set(gca,'yticklabels',[qmnames 'Lab meeting']);
%set(gca,'xticklabels',mm)
%set(gca,'ytick',1:nm+1)
%set(gca,'fontsize',fontsize);
%[x,y] = ndgrid(1:nm,(1:m));
%%text(y(:),x(:),num2str(x(:)),'fontsize',16,'horizontalalignment','center'); 
%text(y(:),x(:),meetingtimeplace(:),'fontsize',fontsize,'horizontalalignment','center'); 
%text(1:m,ones(1,m)*nm+1,labmeetingtxt(:),'fontsize',fontsize,'horizontalalignment','center')

subplot(3,4,9)
hcol = heatmap(Mp);
title('Months each person spends with every other person')
set(gca,'fontsize',fontsize);
hcol.YDisplayLabels = names; 
hcol.XDisplayLabels = names; 

subplot(3,4,10)
barh(sum(X(1:p,:),2))
set(gca,'fontsize',fontsize);
set(gca,'yticklabels',names)
title('months @ MPC')

subplot(3,4,11)
bar(sum(X(1:npd,:)))
set(gca,'xticklabels',mm)
set(gca,'fontsize',fontsize);
title('postdocs @ MPC')

subplot(3,4,12)
bar([sum(X(1:p,:));sum(~X(1:p,:))].','stacked')
ylim([0 p])
set(gca,'xticklabels',mm)
set(gca,'fontsize',fontsize);
legend('MPC','DoP')
title('People at each site')
