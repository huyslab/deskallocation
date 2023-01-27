%Optimise amount of time spent in each office space
p = 9; %number of people
dm = 4; %desks mpc
dd = 5; %desks dop; add floating desk later
d = sum(dm, dd);
m = 12; %months

%----------------------------------------------------------------

kk = 0;
for k=1:1000000000
    setup = randi([0, 1], [p, m]); %initialising random desk allocation
    %reject samples where sum of desks in not equal to numbeer of desks in
    %dop
    if sum(sum(setup) == ones([1,m])*dd) == m
        disp(k)
        kk = kk + 1;
        opt_loc = best_location(d, setup);
        [opt_col,colgs] = each_colleague(p,setup);
        [opt_move, matches, lab_m] = lab_meetings(p, setup, m);
        D(kk).setup = setup;
        D(kk).opt_loc = opt_loc; %minimise
        D(kk).colgs = colgs;
        D(kk).opt_col = opt_col; %minimise
        D(kk).opt_move = opt_move; %minimise
        D(kk).matches = matches; 
        D(kk).lab_m = lab_m; 
        D(kk).total = opt_loc + opt_move + opt_col; %lowest total score - better allocation
    end
end

save optimal_desks.mat D;

%-------------------FUNCTIONS------------------------------------
%----------------------1-----------------------------------------
%optimise to make sure evryone spends equal amount of times in each
%office space over months

function l = best_location(d, setup)  
    l = std(sum(setup')-d/2);
end

%---------------------2-------------------------------------------
%function to make sure everyone's location is matched to lab meeting
%n/2 times

function [sd,matches,lab_m] = lab_meetings(p, setup, m)
    lab_m = randi([0, 1], [1, m]); %random order of lab meetings
    lab = repmat(lab_m, p, 1);
    matches = sum(setup' == lab');
    sd = std(matches); %want to minimise standard deviation
end

%----------------------3-----------------------------------------

%calculate how many times each person spends with other people - in colgs
function [opt_col,colgs] = each_colleague(p,setup)
    for pp=1:p
        for mp = 1:p
            matches = sum(setup(pp,:)== setup(mp,:));
            colgs(pp,mp) = matches;
        end
    end
    opt_col = sum(dot(colgs,colgs'))/4000;
end