param V_MOD=4;

set T=1..96; #set of epochs
set A ordered; #set of appliances
set L; # set of energy consumption levels 
set Lev {A} within L; #set of energy consumption levels of appliance A


var x{a in A, l in Lev[a], t in T}, binary;		#1 if appliance a operates at consumption level l at epoch t 
var y{A,T}, binary;		#1 if appliance changes consumption level at epoch t 
var active{A,T}, binary; # 1 if appliance a operates at non-zero consumption at epoch t
var day{A}, binary;		#1 if appliance operates at non-zero consumption for at least one epoch during the day
var end_w>=1; #last epoch of operation of washing machine
var st_dryer>=1; #first epoch of operation of dryer

param V_DAT >= 4;
param c{T} >=0; #total energy consumption at epoch t
param m{A} >=0; #max consumption of appliance a
param b{A} binary; #1 if user owns appliance a
param d{A}>=0; #max duration of appliance a in working status
param w{A}>=0; #min duration of appliance a in working status
param alpha=0.00001; #multiplicator weight

minimize error:
sum{t in T} (c[t]-sum{a in A, l in Lev[a]}x[a,l,t]*l*b[a])^2 + alpha*sum{t in T, a in A}y[a,t];#minimizes sum of quadratic errors along the set of epochs, the second summation penalizes consumption level changes

subject to one_level{t in T,a in A}:
sum{l in Lev[a]}x[a,l,t]=1; #each appliance operates at one consumption level per epoch

subject to detect_change1{t in T, a in A,l in Lev[a] : t>1}:
y[a,t]>=x[a,l,t]-x[a,l,t-1]; #sets y to 1 if appliance a changes consumption level

subject to detect_change2{t in T, a in A,l in Lev[a] : t>1}:
y[a,t]>=-x[a,l,t]+x[a,l,t-1];#sets y to 1 if appliance a changes consumption level


subject to consumption_limit{a in A}:
sum{t in T,l in Lev[a]}x[a,l,t]*l<=m[a];#sets to m the maximum daily consumption of appliance a 

subject to active_periods{a in A,t in T}:
sum{l in Lev[a]}x[a,l,t]*l<=(max{l in Lev[a]} l)*active[a,t]; #sets variable active to 1 if appliance a has non-zero consumption during at least one epoch

subject to max_duration_limit{a in A, t in T, ti in T:t>ti}:
active[a,t]*t-active[a,ti]*ti<=d[a]*(1- 96*(active[a,t]+active[a,ti]-2)); #sets to d the maximum daily activity duration of appliance a 

subject to coherence{a in A}:
day[a]*100>=sum{t in T,l in Lev[a]}x[a,l,t]*l; #ensures coherence between values of variable day and variable x

subject to min_duration_limit{a in A}:
sum{t in T}active[a,t]>=w[a]*day[a];  #sets to d the miminum daily activity duration of appliance a 

subject to end_wash{t in T}:
end_w>=active[member(2,A),t]*t; #imposes that the dryer starts after the washing machine ends

subject to start_dryer{t in T}:
st_dryer<=active[member(3,A),t]*t+100*(1-active[member(3,A),t]); #imposes that the dryer starts after the washing machine ends

subject to wash_order:
st_dryer>=end_w+1; #imposes that the dryer starts after the washing machine ends

subject to peak_wm{l in Lev[member(2,A)]:l=max{ll in Lev[member(2,A)]} ll}:
sum{t in T}x[member(2,A),l,t]>=day[member(2,A)]; #imposes that the washing machine works at peak consumption level for at least one epoch (if activated during the day)


subject to peak_td{l in Lev[member(3,A)]:l=max{ll in Lev[member(3,A)]} ll}:
sum{t in T}x[member(3,A),l,t]>=day[member(3,A)]; #imposes that the dryer works at peak consumption level for at least one epoch (if activated during the day)


subject to peak_dw{l in Lev[member(4,A)]:l=max{ll in Lev[member(4,A)]} ll}:
sum{t in T}x[member(4,A),l,t]>=day[member(4,A)]; #imposes that the dish washer works at peak consumption level for at least one epoch (if activated during the day)

subject to total_limit:
sum{a in A,t in T,l in Lev[a]}x[a,l,t]*l*b[a]<=sum{t in T}c[t]; #sum of total appliance consumption must not exceed the total daily consumption







