sets
i dispatchable power production units  /i1*i10/
z(i) non-gas power plants /i1,i2,i3,i4,i5,i6/
g(i) gas-fired power plants /i7,i8,i9,i10/
s(i) slow-start power plants /i1,i2,i4,i5,i6,i7,i9,i10/
$onempty
f(i) fast-start power plants /i3,i8/
$offempty
n(i) non self-scheduling power plants /i1,i2,i3,i4,i5,i6,i7,i8,i9,i10/
$onempty
ss(i) self-scheduling power plants / /
$offempty
$onempty
ssz(ss) self-scheduling non-gas power plants / /
$offempty
$onempty
ssg(ss) self-scheduling gas-fired power plants / /
$offempty
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
exp_lambda_RT_G(t,omega) expected probability-weighted real-time electricity price in period t in scenario omega [$ per MWh]
;
exp_lambda_DA_G(t)=sum(k, kdata(k,'C_G'))/card(k);
exp_lambda_RT_G(t,omega)=sum(k, kdata(k,'C_G'))/card(k);

positive variables
p_DA(i,t) day-ahead dispatch of unit i in period t [MW]
w_DA(j,t) day-ahead dispatch of unit j in period t [MW]
l_sh_E(t,omega) electricity load shedding under scenario omega in period t [MW]
l_sh_G(t,omega) gas load shedding under scenario omega in period t [kNm^3 perh]
g_DA(k,t) day-ahead dispatch of unit k in period t [kNm^3 per h]

c_DA(i,t) start-up cost of dispatchable unit i in period t [$]
c_RT(f,t,omega) start-up cost adjustment of dispatchable fast-start unit i in period t$ under scenario s [$]
u_DA(i,t) relaxed unit commitment status of dispatchable unit i in period t
u_RT(f,t,omega) relaxed unit commitment adjustment of fast-start unit i in period t in scenario omega
;

variables
p_RT(i,t,omega) power production adjustment of unit i in scenario omega in period t [MW]
w_RT(j,t,omega) wind power production adjustment of unit j in scenario omega in period t [MW]
g_RT(k,t,omega) gas adjustment by unit k in scenario omega in period t [kNm^3 per h]
;

free variable
obj
time
;

equations
stochastic
El_max_min_lo
El_max_min_up
Wind_max_min_lo
Wind_max_min_up
El_ramp_lo
El_ramp_up
El_ramp_ini_lo
El_ramp_ini_up
El_csu
El_csu_ini
El_c
El_u_lo
El_u_up
El_bal
Gas_max_min_lo
Gas_max_min_up
Gas_bal
EL_max_min_RT_slow_lo
EL_max_min_RT_slow_up
EL_max_min_RT_fast_lo
EL_max_min_RT_fast_up
Wind_max_min_RT_lo
Wind_max_min_RT_up
RT_Lsh_lo
RT_Lsh_up
RT_El_ramp_slow_lo
RT_El_ramp_slow_up
RT_El_ramp_ini_slow_lo
RT_El_ramp_ini_slow_up
RT_El_ramp_fast_lo
RT_El_ramp_fast_up
RT_El_ramp_fast_ini_lo
RT_El_ramp_fast_ini_up
RT_El_csu
RT_El_csu_ini
RT_El_c
RT_El_balance
El_u_RT_lo
El_u_RT_up
Gas_max_min_RT_lo
Gas_max_min_RT_up
RT_Gsh_up
RT_Gsh_lo
RT_G_adj_up
*RT_G_adj_lo
RT_Gas_balance
;
*-------------------------------------------------------------------------------
*---------------objective function----------------------------------------------
*-------------------------------------------------------------------------------

stochastic.. obj =e= sum(t, (sum(z, idata(z,'C_E')*p_DA(z,t)) + sum(i, c_DA(i,t))
                                 + sum(k, kdata(k,'C_G')*g_DA(k,t))
                                 + (sum(omega, pi(omega)* (sum(z, idata(z,'C_E')*p_RT(z,t,omega))
                                                         + sum(f, c_RT(f,t,omega))
                                                         + sum(k, kdata(k,'C_G')*g_RT(k,t,omega))
                                                         + C_sh_E*l_sh_E(t,omega) + C_sh_G*l_sh_G(t,omega) )))));

*-------------------------------------------------------------------------------
*---------------electricity day-ahead constraints-------------------------------
*-------------------------------------------------------------------------------
El_max_min_lo(i,t).. u_DA(i,t)*idata(i,'P_min') =l= p_DA(i,t);
El_max_min_up(i,t).. p_DA(i,t) =l= u_DA(i,t)*idata(i,'P_max');
Wind_max_min_lo(j,t).. 0 =l= w_DA(j,t);
Wind_max_min_up(j,t).. w_DA(j,t) =l= Wind_DA(j,t);
El_bal(t).. sum(i, p_DA(i,t)) + sum(j, w_DA(j,t)) - D_E(t) =e= 0;
El_ramp_lo(i,t)$(ord(t)>1).. - u_DA(i,t-1)*idata(i,'Ramp') =l= (p_DA(i,t) - p_DA(i,t-1));
El_ramp_up(i,t)$(ord(t)>1).. (p_DA(i,t) - p_DA(i,t-1)) =l= u_DA(i,t)*idata(i,'Ramp');
El_ramp_ini_lo(i,t)$(ord(t)=1).. - idata(i,'U_ini')*idata(i,'Ramp') =l= (p_DA(i,t) - idata(i,'P_ini'));
El_ramp_ini_up(i,t)$(ord(t)=1).. (p_DA(i,t) - idata(i,'P_ini')) =l= u_DA(i,t)*idata(i,'Ramp');
El_csu(i,t)$(ord(t)>1).. idata(i,'C_SU')*(u_DA(i,t) - u_DA(i,t-1)) =l= c_DA(i,t);
El_csu_ini(i,t)$(ord(t)=1).. idata(i,'C_SU')*(u_DA(i,t) - idata(i,'U_ini')) =l= c_DA(i,t);
El_c(i,t).. 0 =l= c_DA(i,t);
El_u_lo(i,t).. 0 =l= u_DA(i,t);
El_u_up(i,t).. u_DA(i,t) =l= 1;
*-------------------------------------------------------------------------------
*---------------gas day-ahead constraints---------------------------------------
*-------------------------------------------------------------------------------
Gas_max_min_lo(k,t).. 0 =l= g_DA(k,t);
Gas_max_min_up(k,t).. g_DA(k,t) =l= kdata(k,'G_max');
Gas_bal(t).. sum(k, g_DA(k,t)) - sum(g, idata(g,'phi')*p_DA(g,t)) - D_G(t) =e= 0;
*-------------------------------------------------------------------------------
*---------------electricity real-time constraints-------------------------------
*-------------------------------------------------------------------------------
EL_max_min_RT_slow_lo(s,t,omega).. u_DA(s,t)*idata(s,'P_min') =l= (p_DA(s,t) + p_RT(s,t,omega));
EL_max_min_RT_slow_up(s,t,omega).. (p_DA(s,t) + p_RT(s,t,omega)) =l= u_DA(s,t)*idata(s,'P_max');
EL_max_min_RT_fast_lo(f,t,omega).. (u_DA(f,t) + u_RT(f,t,omega))* idata(f,'P_min') =l= (p_DA(f,t) + p_RT(f,t,omega));
EL_max_min_RT_fast_up(f,t,omega).. (p_DA(f,t) + p_RT(f,t,omega)) =l= (u_DA(f,t) + u_RT(f,t,omega))*idata(f,'P_max');
Wind_max_min_RT_lo(j,t,omega).. 0 =l= (w_DA(j,t) + w_RT(j,t,omega));
Wind_max_min_RT_up(j,t,omega).. (w_DA(j,t) + w_RT(j,t,omega)) =l= Wind(j,t,omega);
RT_Lsh_lo(t,omega).. 0 =l= l_sh_E(t,omega);
RT_Lsh_up(t,omega).. l_sh_E(t,omega) =l= D_E(t);
RT_El_ramp_slow_lo(s,t,omega)$(ord(t)>1).. - u_DA(s,t-1)*idata(s,'Ramp') =l= (p_DA(s,t) + p_RT(s,t,omega) - p_DA(s,t-1) - p_RT(s,t-1,omega));
RT_El_ramp_slow_up(s,t,omega)$(ord(t)>1)..  (p_DA(s,t) + p_RT(s,t,omega) - p_DA(s,t-1) - p_RT(s,t-1,omega)) =l= u_DA(s,t)*idata(s,'Ramp');
RT_El_ramp_ini_slow_lo(s,t,omega)$(ord(t)=1).. - idata(s,'U_ini')*idata(s,'Ramp') =l= (p_DA(s,t) + p_RT(s,t,omega) - idata(s,'P_ini'));
RT_El_ramp_ini_slow_up(s,t,omega)$(ord(t)=1).. (p_DA(s,t) + p_RT(s,t,omega) - idata(s,'P_ini')) =l= u_DA(s,t)*idata(s,'Ramp');
RT_El_ramp_fast_lo(f,t,omega)$(ord(t)>1).. - (u_DA(f,t-1) + u_RT(f,t-1,omega))*idata(f,'Ramp') =l= (p_DA(f,t) + p_RT(f,t,omega) - p_DA(f,t-1) - p_RT(f,t-1,omega));
RT_El_ramp_fast_up(f,t,omega)$(ord(t)>1).. (p_DA(f,t) + p_RT(f,t,omega) - p_DA(f,t-1) - p_RT(f,t-1,omega)) =l= (u_DA(f,t) + u_RT(f,t,omega))*idata(f,'Ramp');
RT_El_ramp_fast_ini_lo(f,t,omega)$(ord(t)=1).. - idata(f,'U_ini')*idata(f,'Ramp') =l= (p_DA(f,t) + p_RT(f,t,omega) - idata(f,'P_ini'));
RT_El_ramp_fast_ini_up(f,t,omega)$(ord(t)=1).. (p_DA(f,t) + p_RT(f,t,omega) - idata(f,'P_ini')) =l= (u_DA(f,t) + u_RT(f,t,omega))*idata(f,'Ramp');
RT_El_csu(f,t,omega)$(ord(t)>1).. idata(f,'C_SU')*(u_DA(f,t) + u_RT(f,t,omega) - u_DA(f,t-1) - u_RT(f,t-1,omega)) =l= (c_DA(f,t) + c_RT(f,t,omega));
RT_El_csu_ini(f,t,omega)$(ord(t)=1).. idata(f,'C_SU')*(u_DA(f,t) + u_RT(f,t,omega) - idata(f,'U_ini')) =l= (c_DA(f,t) + c_RT(f,t,omega));
RT_El_c(f,t,omega).. 0 =l= (c_DA(f,t) + c_RT(f,t,omega));
RT_El_balance(t,omega).. sum(i, p_RT(i,t,omega)) + l_sh_E(t,omega) + sum(j, w_RT(j,t,omega)) =e= 0;
El_u_RT_lo(f,t,omega).. 0 =l= (u_DA(f,t) + u_RT(f,t,omega));
El_u_RT_up(f,t,omega).. (u_DA(f,t) + u_RT(f,t,omega)) =l= 1;
*-------------------------------------------------------------------------------
*---------------gas real-time constraints---------------------------------------
*-------------------------------------------------------------------------------
Gas_max_min_RT_lo(k,t,omega).. 0 =l= (g_DA(k,t) + g_RT(k,t,omega));
Gas_max_min_RT_up(k,t,omega).. (g_DA(k,t) + g_RT(k,t,omega)) =l= kdata(k,'G_max');
RT_Gsh_up(t,omega).. 0 =l= l_sh_G(t,omega);
RT_Gsh_lo(t,omega).. l_sh_G(t,omega) =l= D_G(t);
*RT_G_adj_lo(k,t,omega).. -kdata(k,'G_R') =l= g_RT(k,t,omega);
RT_G_adj_up(k,t,omega).. g_RT(k,t,omega) =l= kdata(k,'G_R');
RT_Gas_balance(t,omega).. sum(k, g_RT(k,t,omega)) - sum(g, idata(g,'phi')*p_RT(g,t,omega)) + l_sh_G(t,omega) =e= 0;

*-------------------------------------------------------------------------------
*----------------linear stochastic program--------------------------------------
*-------------------------------------------------------------------------------

model benchmark /all/;
       option optcr = 0.0;
solve benchmark using LP minimizing obj;
time.l=benchmark.resusd;
variables
lambda_DA_E(t)
lambda_DA_G(t)
lambda_RT_E(t,omega)
lambda_RT_G(t,omega)
;
lambda_DA_E.l(t)=El_bal.m(t);
lambda_DA_G.l(t)=Gas_bal.m(t);
lambda_RT_E.l(t,omega)=RT_El_balance.m(t,omega);
lambda_RT_G.l(t,omega)=RT_Gas_balance.m(t,omega);

display obj.l,time.l;

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
profit(z) = sum(t, (p_DA.l(z,t)*(lambda_DA_E.l(t) - idata(z,'C_E')) - c_DA.l(z,t) + sum(omega, pi(omega)*p_RT.l(z,t,omega)*((lambda_RT_E.l(t,omega)/pi(omega)) - idata(z,'C_E'))) ) );
*profit(g) = sum(t, (p_DA.l(g,t)*(lambda_DA_E.l(t) - idata(g,'phi')*lambda_DA_G.l(t)) - c_DA.l(g,t) + sum(omega, pi(omega)*p_RT.l(g,t,omega)*((lambda_RT_E.l(t,omega)/pi(omega)) - idata(g,'phi')*(lambda_RT_G.l(t,omega)))) ) );
profit(g) = sum(t, (p_DA.l(g,t)*(lambda_DA_E.l(t) - idata(g,'phi')*lambda_DA_G.l(t)) - c_DA.l(g,t) + sum(omega, pi(omega)*p_RT.l(g,t,omega)*((lambda_RT_E.l(t,omega)/pi(omega)) - idata(g,'phi')*(lambda_RT_G.l(t,omega)/pi(omega)))) ) );
profit(ssz) = sum(t, (p_DA.l(ssz,t)*(lambda_DA_E.l(t) - idata(ssz,'C_E')) - c_DA.l(ssz,t) + sum(omega, pi(omega)*p_RT.l(ssz,t,omega)*((lambda_RT_E.l(t,omega)/pi(omega)) - idata(ssz,'C_E'))) ) );
profit(ssg) = sum(t, (p_DA.l(ssg,t)*(lambda_DA_E.l(t) - idata(ssg,'phi')*lambda_DA_G.l(t)) - c_DA.l(ssg,t) + sum(omega, pi(omega)*p_RT.l(ssg,t,omega)*((lambda_RT_E.l(t,omega)/pi(omega)) - idata(ssg,'phi')*(lambda_RT_G.l(t,omega)/pi(omega)))) ) );

Display
profit
;
parameter
expectedrealtimepriceE(t)
expectedrealtimepriceG(t);
expectedrealtimepriceE(t)=sum(omega, lambda_RT_E.l(t,omega));
expectedrealtimepriceG(t)=sum(omega, lambda_RT_G.l(t,omega));
display
p_DA.l,lambda_DA_E.l,lambda_DA_G.l,expectedrealtimepriceE,expectedrealtimepriceG;
parameter
consumption(t);
consumption(t)=p_DA.l('i10',t)*idata('i10','phi');
display  consumption;


