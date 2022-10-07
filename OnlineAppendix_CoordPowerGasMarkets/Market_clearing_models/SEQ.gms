sets
i dispatchable power production units  /i1*i10/
z(i) non-gas power plants /i1,i2,i3,i4,i5,i6/
g(i) gas-fired power plants /i7,i8,i9,i10/
s(i) slow-start power plants /i1,i2,i4,i5,i6,i7,i9,i10/
$onempty
f(i) fast-start power plants /i3,i8/
$offempty
n(i) non self-scheduling power plants /i1,i2,i3,i4,i5,i6,i7,i8,i9,i10/
j wind power units /j1/
k natural gas supply units /k1*k4/
omega wind power scenarios /omega1*omega5/
t time periods /t1*t24/
alias(i,ii)
;

table idata(i,*)
         P_min   P_max   Ramp    C_E     C_SU    U_ini   P_ini   phi
i1       0       40      20      22.18   17462   1       40      0
i2       0       152     50      33.20   13207   1       100     0
i3       0       300     195     37.14   22313   0       0       0
i4       100     591     230     38.20   28272   0       0       0
i5       400     400     400     22.34   50000   1       400     0
i6       0       350     80      20.92   33921   0       0       0
i7       0       155     100     0       21450   1       100     15.23
i8       0       60      60      0       10721   0       0       16.98
i9       0       310     200     0       42900   0       0       12.65
i10      0       300     150     0       10000   0       0       14.88
;

table kdata(k,*)
         G_max           C_G     G_R
k1       9000            2       1000
k2       6000            2.2     1000
k3       10000           2.5     1000
k4       6000            3.3     1000
;

parameters
D_E_max(t) electricity demand in period t [MW] /
t1 1937.24
t2 1813.64
t3 1733.46
t4 1695.37
t5 1703.37
t6 1778.02
t7 1924.37
t8 2088.53
t9 2230.08
t10 2356.62
t11 2484.56
t12 2590.55
t13 2678.40
t14 2762.65
t15 2822.55
t16 2869.18
t17 2900
t18 2893.72
t19 2806.07
t20 2689.94
t21 2606.56
t22 2531.78
t23 2352.35
t24 2147.76
/
D_E(t)
;
D_E(t)=D_E_max(t)*0.8;
parameter
D_G(t) gas demand in period t [kNm^3 per hour] /
t1 7000
t2 6700
t3 6400
t4 6500
t5 6600
t6 6700
t7 7750
t8 7800
t9 8550
t10 8700
t11 8700
t12 8550
t13 8550
t14 8550
t15 8400
t16 8550
t17 9000
t18 9000
t19 9000
t20 8700
t21 8250
t22 7500
t23 6600
t24 6700
/
C_sh_E value of electricity lost load [$ per MWh] /600/
C_sh_G value of gas lost load [$ per kNm^3] /300/
Wind(j,t,omega) wind power realization of unit j in period t scenario omega [MW]
Wind_omega(j,t)
Wind_DA(j,t) day-ahead wind power forecast for unit j in period t [MW]
W_cap(j) capacity of wind power unit j [MW] /j1 1000/
pi(omega) probability of scenario omega
pi_omega
;
table WF(j,t,omega) wind power realization factor of unit j in period t scenario omega [p.u.]
$ondelim
$include wind_5omega_24t.csv
$offdelim
;
parameter
forecast_error(t) /
t1 -0.05
t2 -0.08
t3 -0.12
t4 -0.07
t5 -0.01
t6 -0.02
t7 0.01
t8 0.03
t9 -0.03
t10 -0.04
t11 0.01
t12 0.03
t13 0.05
t14 0.06
t15 0.08
t16 0.1
t17 0.13
t18 0.15
t19 0.17
t20 0.16
t21 0.13
t22 0.1
t23 0.07
t24 0.19
/
;
Wind(j,t,omega)=WF(j,t,omega)*W_cap(j);
Wind_DA(j,t)= sum(omega, (WF(j,t,omega)+forecast_error(t))*W_cap(j))/card(omega);

loop(omega,
pi(omega) = 1 / card(omega);
);


parameter
exp_lambda_DA_G(t) expected day-ahead gas price in period t [$ per kNm^3]
exp_lambda_RT_G(t) expected probability-weighted real-time electricity price in period t in scenario omega [$ per MWh]
;
exp_lambda_DA_G(t)=sum(k, kdata(k,'C_G'))/card(k);
exp_lambda_RT_G(t)=sum(k, kdata(k,'C_G'))/card(k);

parameter
Wind_omega(j,t)
pi_omega
p_DA_fix(i,t)
w_DA_fix(j,t)
g_DA_fix(k,t)
u_DA_fix(i,t)
c_DA_fix(i,t)
p_RT_omega_fix(i,t)
lambda_DA_E(t) day-ahead electricity price in period t [$ per MWh]
lambda_RT_E(t,omega) probability-weighted real-time electricity price in period t in scenario omega [$ per MWh]
lambda_DA_G(t) day-ahead gas price in period t [$ per kNm^3]
lambda_RT_G(t,omega) probability-weighted real-time gas price in period t in scenario omega [$ per kNm^3]
;
p_DA_fix(i,t)=0;
w_DA_fix(j,t)=0;
g_DA_fix(k,t)=0;
u_DA_fix(i,t)=0;
c_DA_fix(i,t)=0;
p_RT_omega_fix(i,t)=0;

variables
l_sh_E(t,omega) electricity load shedding under scenario omega in period t [MW]
l_sh_G(t,omega) gas load shedding under scenario omega in period t [kNm^3 perh]
c_RT(f,t,omega) start-up cost adjustment of dispatchable fast-start unit i in period t$ under scenario s [$]
u_RT(f,t,omega) relaxed unit commitment adjustment of fast-start unit i in period t in scenario omega
p_RT(i,t,omega) power production adjustment of unit i in scenario omega in period t [MW]
w_RT(j,t,omega) wind power production adjustment of unit j in scenario omega in period t [MW]
g_RT(k,t,omega) gas adjustment by unit k in scenario omega in period t [kNm^3 per h]
;

positive variables
p_DA(i,t) day-ahead dispatch of unit i in period t [MW]
w_DA(j,t) day-ahead dispatch of unit j in period t [MW]
l_sh_E_omega(t) electricity load shedding under scenario omega in period t [MW]
l_sh_G_omega(t) gas load shedding under scenario omega in period t [kNm^3 perh]
g_DA(k,t) day-ahead dispatch of unit k in period t [kNm^3 per h]
c_DA(i,t) start-up cost of dispatchable unit i in period t [$]
c_RT_omega(f,t) start-up cost adjustment of dispatchable fast-start unit i in period t$ under scenario s [$]
u_DA(i,t) relaxed unit commitment status of dispatchable unit i in period t
u_RT_omega(f,t) relaxed unit commitment adjustment of fast-start unit i in period t in scenario omega
;

variables
p_RT_omega(i,t) power production adjustment of unit i in scenario omega in period t [MW]
w_RT_omega(j,t) wind power production adjustment of unit j in scenario omega in period t [MW]
g_RT_omega(k,t) gas adjustment by unit k in scenario omega in period t [kNm^3 per h]
;

free variable
cost_E_DA
cost_G_DA
cost_E_RT(omega)
cost_G_RT(omega)
cost_E_RT_omega
cost_G_RT_omega
;


equations
El_DA1
El_DA2
El_DA3
El_DA4
El_DA5
El_DA6
El_DA7
El_DA8
El_DA9
El_DA10
El_DA11
El_DA12
El_DA13
iEl_DA_bal

Gas_DA1
Gas_DA2
iGas_DA_bal

iEl_RT1
iEl_RT2
iEl_RT3
iEl_RT4
iEl_RT5
iEl_RT6
iEl_RT7
iEl_RT8
iEl_RT9
iEl_RT10
iEl_RT11
iEl_RT12
iEl_RT13
iEl_RT14
iEl_RT15
iEl_RT16
iEl_RT17
iEl_RT18
iEl_RT19
iEl_RT20
iEl_RT21
iEl_RT_bal


iGas_RT1
iGas_RT2
iGas_RT3
iGas_RT4
*iGas_RT5
iGas_RT6
iGas_RT_bal


obj_E_DA
obj_G_DA
iobj_E_RT
iobj_G_RT
;


*-------------------------------------------------------------------------------
*---------------electricity day-ahead constraints-------------------------------
*-------------------------------------------------------------------------------
El_DA1(n,t).. u_DA(n,t)*idata(n,'P_min') =l= p_DA(n,t);
El_DA2(n,t).. p_DA(n,t) =l= u_DA(n,t)*idata(n,'P_max');
El_DA3(j,t).. 0 =l= w_DA(j,t);
El_DA4(j,t).. w_DA(j,t) =l= Wind_DA(j,t);
El_DA5(n,t)$(ord(t)>1).. - u_DA(n,t-1)*idata(n,'Ramp') =l= (p_DA(n,t) - p_DA(n,t-1));
El_DA6(n,t)$(ord(t)>1).. (p_DA(n,t) - p_DA(n,t-1)) =l= u_DA(n,t)*idata(n,'Ramp');
El_DA7(n,t)$(ord(t)=1).. - idata(n,'U_ini')*idata(n,'Ramp') =l= (p_DA(n,t) - idata(n,'P_ini'));
El_DA8(n,t)$(ord(t)=1).. (p_DA(n,t) - idata(n,'P_ini')) =l= u_DA(n,t)*idata(n,'Ramp');
El_DA9(n,t)$(ord(t)>1).. idata(n,'C_SU')*(u_DA(n,t) - u_DA(n,t-1)) =l= c_DA(n,t);
El_DA10(n,t)$(ord(t)=1).. idata(n,'C_SU')*(u_DA(n,t) - idata(n,'U_ini')) =l= c_DA(n,t);
El_DA11(n,t).. 0 =l= c_DA(n,t);
El_DA12(n,t).. 0 =l= u_DA(n,t);
El_DA13(n,t).. u_DA(n,t) =l= 1;
iEl_DA_bal(t).. sum(n, p_DA(n,t))  + sum(j, w_DA(j,t)) - D_E(t) =e= 0;

*-------------------------------------------------------------------------------
*---------------gas day-ahead constraints---------------------------------------
*-------------------------------------------------------------------------------
Gas_DA1(k,t).. 0 =l= g_DA(k,t);
Gas_DA2(k,t).. g_DA(k,t) =l= kdata(k,'G_max');
iGas_DA_bal(t).. sum(k, g_DA(k,t)) - sum(g, idata(g,'phi')*p_DA_fix(g,t)) - D_G(t) =e= 0;

*-------------------------------------------------------------------------------
*---------------electricity real-time constraints-------------------------------
*-------------------------------------------------------------------------------
iEl_RT1(s,t).. u_DA_fix(s,t)*idata(s,'P_min') =l= (p_DA_fix(s,t) + p_RT_omega(s,t));
iEl_RT2(s,t).. (p_DA_fix(s,t) + p_RT_omega(s,t)) =l= u_DA_fix(s,t)*idata(s,'P_max');
iEl_RT3(f,t).. (u_DA_fix(f,t) + u_RT_omega(f,t))* idata(f,'P_min') =l= (p_DA_fix(f,t) + p_RT_omega(f,t));
iEl_RT4(f,t).. (p_DA_fix(f,t) + p_RT_omega(f,t)) =l= (u_DA_fix(f,t) + u_RT_omega(f,t))*idata(f,'P_max');
iEl_RT5(j,t).. 0 =l= (w_DA_fix(j,t) + w_RT_omega(j,t));
iEl_RT6(j,t).. (w_DA_fix(j,t) + w_RT_omega(j,t)) =l= Wind_omega(j,t);
iEl_RT7(t).. 0 =l= l_sh_E_omega(t);
iEl_RT8(t).. l_sh_E_omega(t) =l= D_E(t);
iEl_RT9(s,t)$(ord(t)>1).. - u_DA_fix(s,t-1)*idata(s,'Ramp') =l= (p_DA_fix(s,t) + p_RT_omega(s,t) - p_DA_fix(s,t-1) - p_RT_omega(s,t-1));
iEl_RT10(s,t)$(ord(t)>1)..  (p_DA_fix(s,t) + p_RT_omega(s,t) - p_DA_fix(s,t-1) - p_RT_omega(s,t-1)) =l= u_DA_fix(s,t)*idata(s,'Ramp');
iEl_RT11(s,t)$(ord(t)=1).. - idata(s,'U_ini')*idata(s,'Ramp') =l= (p_DA_fix(s,t) + p_RT_omega(s,t) - idata(s,'P_ini'));
iEl_RT12(s,t)$(ord(t)=1).. (p_DA_fix(s,t) + p_RT_omega(s,t) - idata(s,'P_ini')) =l= u_DA_fix(s,t)*idata(s,'Ramp');
iEl_RT13(f,t)$(ord(t)>1).. - (u_DA_fix(f,t-1) + u_RT_omega(f,t-1))*idata(f,'Ramp') =l= (p_DA_fix(f,t) + p_RT_omega(f,t) - p_DA_fix(f,t-1) - p_RT_omega(f,t-1));
iEl_RT14(f,t)$(ord(t)>1).. (p_DA_fix(f,t) + p_RT_omega(f,t) - p_DA_fix(f,t-1) - p_RT_omega(f,t-1)) =l= (u_DA_fix(f,t) + u_RT_omega(f,t))*idata(f,'Ramp');
iEl_RT15(f,t)$(ord(t)=1).. - idata(f,'U_ini')*idata(f,'Ramp') =l= (p_DA_fix(f,t) + p_RT_omega(f,t) - idata(f,'P_ini'));
iEl_RT16(f,t)$(ord(t)=1).. (p_DA_fix(f,t) + p_RT_omega(f,t) - idata(f,'P_ini')) =l= (u_DA_fix(f,t) + u_RT_omega(f,t))*idata(f,'Ramp');
iEl_RT17(f,t)$(ord(t)>1).. idata(f,'C_SU')*(u_DA_fix(f,t) + u_RT_omega(f,t) - u_DA_fix(f,t-1) - u_RT_omega(f,t-1)) =l= (c_DA_fix(f,t) + c_RT_omega(f,t));
iEl_RT18(f,t)$(ord(t)=1).. idata(f,'C_SU')*(u_DA_fix(f,t) + u_RT_omega(f,t) - idata(f,'U_ini')) =l= (c_DA_fix(f,t) + c_RT_omega(f,t));
iEl_RT19(f,t).. 0 =l= (c_DA_fix(f,t) + c_RT_omega(f,t));
iEl_RT20(f,t).. 0 =l= (u_DA_fix(f,t) + u_RT_omega(f,t));
iEl_RT21(f,t).. (u_DA_fix(f,t) + u_RT_omega(f,t)) =l= 1;
iEl_RT_bal(t).. sum(n, p_RT_omega(n,t)) + l_sh_E_omega(t) + sum(j, w_RT_omega(j,t)) =e= 0;

*-------------------------------------------------------------------------------
*---------------gas real-time constraints---------------------------------------
*-------------------------------------------------------------------------------
iGas_RT1(k,t).. 0 =l= (g_DA_fix(k,t) + g_RT_omega(k,t));
iGas_RT2(k,t).. (g_DA_fix(k,t) + g_RT_omega(k,t)) =l= kdata(k,'G_max');
iGas_RT3(t).. 0 =l= l_sh_G_omega(t);
iGas_RT4(t).. l_sh_G_omega(t) =l= D_G(t);
*iGas_RT5(k,t).. -kdata(k,'G_R') =l= (g_RT_omega(k,t));
iGas_RT6(k,t).. (g_RT_omega(k,t)) =l= kdata(k,'G_R');
iGas_RT_bal(t).. sum(k, g_RT_omega(k,t)) - sum(g, idata(g,'phi')*p_RT_omega_fix(g,t)) + l_sh_G_omega(t) =e= 0;

*-------------------------------------------------------------------------------
*---------------objectives------------------------------------------------------
*-------------------------------------------------------------------------------
obj_E_DA.. cost_E_DA =e= sum(t, sum(z, idata(z,'C_E')*p_DA(z,t)) + sum(g, exp_lambda_DA_G(t)*idata(g,'phi')*p_DA(g,t)) + sum(n, c_DA(n,t)) );
obj_G_DA.. cost_G_DA =e= sum((t,k), kdata(k,'C_G')*g_DA(k,t));
iobj_E_RT.. cost_E_RT_omega =e=  pi_omega*(sum(t, sum(z, idata(z,'C_E')*p_RT_omega(z,t)) +sum(g, exp_lambda_RT_G(t)*idata(g,'phi')*p_RT_omega(g,t))  + C_SH_E*l_SH_E_omega(t) + sum(f, c_RT_omega(f,t))) );
iobj_G_RT.. cost_G_RT_omega =e=pi_omega*(sum((t,k), kdata(k,'C_G')*g_RT_omega(k,t) + C_SH_G*l_SH_G_omega(t)) );


*-------------------------------------------------------------------------------
*---------------electricity day-ahead market clearing---------------------------
*-------------------------------------------------------------------------------
model E_DA /
El_DA1
El_DA2
El_DA3
El_DA4
El_DA5
El_DA6
El_DA7
El_DA8
El_DA9
El_DA10
El_DA11
El_DA12
El_DA13
iEl_DA_bal
obj_E_DA/;
solve E_DA using lp minimizing cost_E_DA;
p_DA_fix(n,t)=p_DA.l(n,t);
u_DA_fix(n,t)=u_DA.l(n,t);
w_DA_fix(j,t)=w_DA.l(j,t);
c_DA_fix(n,t)=c_DA.l(n,t);
lambda_DA_E(t)=iEl_DA_bal.m(t);
parameter
TimeE_DA;
TimeE_DA=E_DA.resusd;
display TimeE_DA;

*-------------------------------------------------------------------------------
*---------------gas day-ahead market clearing-----------------------------------
*-------------------------------------------------------------------------------
model Gas_DA /
Gas_DA1
Gas_DA2
iGas_DA_bal
obj_G_DA/;
solve Gas_DA using lp minimizing cost_G_DA;
g_DA_fix(k,t)=g_DA.l(k,t);
lambda_DA_G(t)=iGas_DA_bal.m(t);
parameter
TimeG_DA;
TimeG_DA=Gas_DA.resusd;
display TimeG_DA;

*-------------------------------------------------------------------------------
*---------------electricity real-time market clearing---------------------------
*-------------------------------------------------------------------------------
model E_RT /iEl_RT1
iEl_RT2
iEl_RT3
iEl_RT4
iEl_RT5
iEl_RT6
iEl_RT7
iEl_RT8
iEl_RT9
iEl_RT10
iEl_RT11
iEl_RT12
iEl_RT13
iEl_RT14
iEl_RT15
iEl_RT16
iEl_RT17
iEl_RT18
iEl_RT19
iEl_RT20
iEl_RT21
iEl_RT_bal
iobj_E_RT
/
;

*-------------------------------------------------------------------------------
*---------------gas real-time market clearing-----------------------------------
*-------------------------------------------------------------------------------
model Gas_RT /
iGas_RT1
iGas_RT2
iGas_RT3
iGas_RT4
*iGas_RT5
iGas_RT6
iGas_RT_bal
iobj_G_RT /
;

parameter
TimeE_RT(omega)
TimeG_RT(omega);

*-------------------------------------------------------------------------------
*---------------real-time scenarios---------------------------------------------
*-------------------------------------------------------------------------------
loop(omega,
Wind_omega(j,t)=Wind(j,t,omega);
pi_omega=pi(omega);

solve E_RT using lp minimizing cost_E_RT_omega;
cost_E_RT.l(omega)=cost_E_RT_omega.l;
lambda_RT_E(t,omega)=iEl_RT_bal.m(t);
p_RT.l(n,t,omega)=p_RT_omega.l(n,t);
p_RT_omega_fix(n,t)=p_RT_omega.l(n,t);
u_RT.l(f,t,omega)=u_RT_omega.l(f,t);
c_RT.l(f,t,omega)=c_RT_omega.l(f,t);
l_SH_E.l(t,omega)=l_SH_E_omega.l(t);
TimeE_RT(omega)=E_RT.resusd;

solve Gas_RT using lp minimizing cost_G_RT_omega;
cost_G_RT.l(omega)=cost_G_RT_omega.l;
lambda_RT_G(t,omega)=iGas_RT_bal.m(t);
g_RT.l(k,t,omega)=g_RT_omega.l(k,t);
l_SH_G.l(t,omega)=l_SH_G_omega.l(t);
TimeG_RT(omega)=Gas_RT.resusd;
);

parameter
TimeRT;
TimeRT=sum(omega, TimeE_RT(omega)+TimeG_RT(omega));
display TimeE_DA, TimeG_DA, TimeRT, lambda_DA_E, lambda_DA_G, lambda_RT_E, lambda_RT_G;

display
cost_E_DA.l
cost_G_DA.l
cost_E_RT.l
cost_G_RT.l
lambda_DA_E
lambda_DA_G
lambda_RT_E
lambda_RT_G
;
parameter totalcost;

totalcost= sum(t, (sum(z, idata(z,'C_E')*p_DA.l(z,t)) + sum(i, c_DA.l(i,t))
                                 + sum(k, kdata(k,'C_G')*g_DA.l(k,t))
                                 + (sum(omega, pi(omega)* (sum(z, idata(z,'C_E')*p_RT.l(z,t,omega))
                                                         + sum(f, c_RT.l(f,t,omega))
                                                         + sum(k, kdata(k,'C_G')*g_RT.l(k,t,omega))
                                                         + C_sh_E*l_sh_E.l(t,omega) + C_sh_G*(l_sh_G.l(t,omega)))))));
display totalcost, l_sh_E.l, l_sh_G.l;


Parameters
profit(i)
profit2(i)
;
profit(z) = sum(t, (p_DA.l(z,t)*(lambda_DA_E(t) - idata(z,'C_E')) - c_DA.l(z,t) + sum(omega, pi(omega)*p_RT.l(z,t,omega)*((lambda_RT_E(t,omega)/pi(omega)) - idata(z,'C_E'))) ) );
*profit(g) = sum(t, (p_DA.l(g,t)*(lambda_DA_E.l(t) - idata(g,'phi')*lambda_DA_G.l(t)) - c_DA.l(g,t) + sum(omega, pi(omega)*p_RT.l(g,t,omega)*((lambda_RT_E.l(t,omega)/pi(omega)) - idata(g,'phi')*(lambda_RT_G.l(t,omega)))) ) );
profit(g) = sum(t, (p_DA.l(g,t)*(lambda_DA_E(t) - idata(g,'phi')*lambda_DA_G(t)) - c_DA.l(g,t) + sum(omega, pi(omega)*p_RT.l(g,t,omega)*((lambda_RT_E(t,omega)/pi(omega)) - idata(g,'phi')*(lambda_RT_G(t,omega)/pi(omega)))) ) );
*profit(ssz) = sum(t, (p_DA.l(ssz,t)*(lambda_DA_E(t) - idata(ssz,'C_E')) - c_DA.l(ssz,t) + sum(omega, pi(omega)*p_RT.l(ssz,t,omega)*((lambda_RT_E.l(t,omega)/pi(omega)) - idata(ssz,'C_E'))) ) );
*profit(ssg) = sum(t, (p_DA.l(ssg,t)*(lambda_DA_E(t) - idata(ssg,'phi')*lambda_DA_G(t)) - c_DA.l(ssg,t) + sum(omega, pi(omega)*p_RT.l(ssg,t,omega)*((lambda_RT_E(t,omega)/pi(omega)) - idata(ssg,'phi')*(lambda_RT_G(t,omega)/pi(omega)))) ) );

Display
profit
;
parameter
expectedrealtimepriceE(t)
expectedrealtimepriceG(t);
expectedrealtimepriceE(t)=sum(omega, lambda_RT_E(t,omega));
expectedrealtimepriceG(t)=sum(omega, lambda_RT_G(t,omega));
display
p_DA.l,lambda_DA_E,lambda_DA_G,expectedrealtimepriceE,expectedrealtimepriceG;
parameter
consumption(t);
consumption(t)=p_DA.l('i10',t)*idata('i10','phi');
display  consumption;

parameters
est_prof_DA(t)
est_prof_RT(t)
act_prof_DA(t)
act_prof_RT(t);

est_prof_DA(t)= p_DA.l('i10',t)*(lambda_DA_E(t) - idata('i10','phi')*exp_lambda_DA_G(t)) - c_DA.l('i10',t);
est_prof_RT(t)= sum(omega, pi(omega)*p_RT.l('i10',t,omega)*((lambda_RT_E(t,omega)/pi(omega)) - idata('i10','phi')*(exp_lambda_RT_G(t))));
act_prof_DA(t)= p_DA.l('i10',t)*(lambda_DA_E(t) - idata('i10','phi')*lambda_DA_G(t)) - c_DA.l('i10',t);
act_prof_RT(t)= sum(omega, pi(omega)*p_RT.l('i10',t,omega)*((lambda_RT_E(t,omega)/pi(omega)) - idata('i10','phi')*(lambda_RT_G(t,omega)/pi(omega))));


display
est_prof_DA,
est_prof_RT,
act_prof_DA,
act_prof_RT;