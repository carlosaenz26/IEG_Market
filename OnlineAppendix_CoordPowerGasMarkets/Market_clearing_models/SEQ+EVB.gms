sets
i dispatchable power production units  /i1*i10/
n(i) non self-scheduling power plants /i1,i2,i3,i4,i5,i6,i7,i8,i9,i10/
z(n) non-gas power plants /i1,i2,i3,i4,i5,i6/
g(n) gas-fired power plants /i7,i8,i9,i10/
s(i) slow-start power plants /i1,i2,i4,i5,i6,i7,i9,i10/
$onempty
f(i) fast-start power plants /i3,i8/
$offempty
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
vbr /r1/
$onempty
r(vbr) electricity virtual bidders /r1/
$offempty
vbq   /q1/
$onempty
q(vbq) gas virtual bidders /q1/
$offempty
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

*-------------------------------------------------------------------------------
*---------------primal variables------------------------------------------------
*-------------------------------------------------------------------------------
free variables
p_DA(i,t) day-ahead dispatch of unit i in period t [MW]
w_DA(j,t) day-ahead dispatch of unit j in period t [MW]
l_sh_E(t,omega) electricity load shedding under scenario omega in period t [MW]
l_sh_G(t,omega) gas load shedding under scenario omega in period t [kNm^3 perh]
g_DA(k,t) day-ahead dispatch of unit k in period t [kNm^3 per h]
c_DA(i,t) start-up cost of dispatchable unit i in period t [$]
c_RT(f,t,omega) start-up cost adjustment of dispatchable fast-start unit i in period t$ under scenario s [$]
u_DA(i,t) relaxed unit commitment status of dispatchable unit i in period t
u_RT(f,t,omega) relaxed unit commitment adjustment of fast-start unit i in period t in scenario omega
p_RT(i,t,omega) power production adjustment of unit i in scenario omega in period t [MW]
w_RT(j,t,omega) wind power production adjustment of unit j in scenario omega in period t [MW]
g_RT(k,t,omega) gas adjustment by unit k in scenario omega in period t [kNm^3 per h]
v_DA_E(r,t) day-ahead trade of electricity virtual bidder r in period t [MW]
v_RT_E(r,t) real-time trade of electricity virtual bidder r in period t [MW]
v_DA_G(q,t) day-ahead trade of natural gas virtual bidder q in period t [kNm^3 per h]
v_RT_G(q,t) real-time trade of natural gas virtual bidder q in period t [kNm^3 per h]
;

*-------------------------------------------------------------------------------
*---------------dual variables--------------------------------------------------
*-------------------------------------------------------------------------------
positive variables
mu_min_P(n,t)
mu_max_P(n,t)
mu_min_W(j,t)
mu_max_W(j,t)
mu_min_R(n,t)
mu_max_R(n,t)
mu_min_SU(i,t)
mu_max_SU(i,t)
mu_min_B(i,t)
mu_max_B(i,t)
mu_min_G(k,t)
mu_max_G(k,t)

nu_min_P(i,t,omega)
nu_max_P(i,t,omega)
nu_min_W(j,t,omega)
nu_max_W(j,t,omega)
nu_min_DE(t,omega)
nu_max_DE(t,omega)
nu_min_R(i,t,omega)
nu_max_R(i,t,omega)
nu_min_SU(f,t,omega)
nu_max_SU(f,t,omega)
nu_min_B(f,t,omega)
nu_max_B(f,t,omega)

nu_min_G(k,t,omega)
nu_max_G(k,t,omega)
nu_min_DG(t,omega)
nu_max_DG(t,omega)

*nu_min_GR(k,t,omega)
nu_max_GR(k,t,omega)
;
free variables
lambda_DA_E(t) day-ahead electricity price in period t [$ per MWh]
lambda_RT_E(t,omega) probability-weighted real-time electricity price in period t in scenario omega [$ per MWh]
lambda_DA_G(t) day-ahead gas price in period t [$ per kNm^3]
lambda_RT_G(t,omega) probability-weighted real-time gas price in period t in scenario omega [$ per kNm^3]
rho(r,t)
psi(q,t)
;

equations
El_bal
Gas_bal
RT_El_balance
RT_Gas_balance
VBE_bal
VBG_bal
;

*-------------------------------------------------------------------------------
*---------------equality constraints--------------------------------------------
*-------------------------------------------------------------------------------

*---------------electricity day-ahead balance-----------------------------------
El_bal(t).. sum(i, p_DA(i,t)) + sum(j, w_DA(j,t)) - D_E(t) + sum(r, v_DA_E(r,t)) =e= 0;

*---------------gas day-ahead balance-------------------------------------------
Gas_bal(t).. sum(k, g_DA(k,t)) - sum(g, idata(g,'phi')*p_DA.l(g,t)) - sum(ssg, idata(ssg,'phi')*p_DA.l(ssg,t))  + sum(q, v_DA_G(q,t)) - D_G(t) =e= 0;

*---------------electricity real-time balance-----------------------------------
RT_El_balance(t,omega).. sum(i, p_RT(i,t,omega)) + l_sh_E(t,omega) +  sum(r, v_RT_E(r,t)) + sum(j, w_RT(j,t,omega)) =e= 0;

*---------------gas real-time balance-------------------------------------------
RT_Gas_balance(t,omega).. sum(k, g_RT(k,t,omega)) - sum(g, idata(g,'phi')*p_RT.l(g,t,omega)) - sum(ssg, idata(ssg,'phi')*p_RT.l(ssg,t,omega)) + l_sh_G(t,omega) + sum(q, v_RT_G(q,t)) =e= 0;

*---------------electricity virtual bidder balance------------------------------
VBE_bal(r,t).. v_DA_E(r,t) + v_RT_E(r,t) =e= 0;

*---------------gas virtual bidder balance--------------------------------------
VBG_bal(q,t).. v_DA_G(q,t) + v_RT_G(q,t) =e= 0;


equations
L1_p_DAa
L1_p_DAb
L1_p_DAc
L1_p_DAd
L1_u_DAa
L1_u_DAb
L1_w_DA
L1_c_DA
comp1
comp2
comp3
comp4
comp5
comp6
comp7
comp8
comp9
comp10
comp11
comp12
comp13
L2_g_DA
comp14
comp15
L3_p_RTa
L3_p_RTb
L3_p_RTc
L3_p_RTd
L3_w_RT
L3_l_sh_E
L3_u_RTa
L3_u_RTb
L3_c_RT
comp16
comp17
comp18
comp19
comp20
comp21
comp22a
comp22b
comp23
comp24
comp25
comp26
comp27
comp28
comp29
comp30
comp31
comp32
comp33
comp34
comp35
L4_g_RT
L4_l_sh_G
comp36
comp37
comp38
comp39

L5_v_DA
L5_v_RT
L5_v

L6_v_DA
L6_v_RT
L6_v

L8_p_DAa
L8_p_DAb
L8_u_DAa
L8_u_DAb
L8_c_DA
L8_p_RTa
L8_p_RTb

L9_p_DAa
L9_p_DAb
L9_p_RTa
L9_p_RTb

comp46
comp47

comp53
comp54
comp55
comp56
*compGRmin
compGRmax
;

*-------------------------------------------------------------------------------
*----------------KKT day-ahead electricity market-------------------------------
*-------------------------------------------------------------------------------
L1_p_DAa(z,t)$(ord(t)<card(t)).. idata(z,'C_E') + mu_max_P(z,t) - mu_min_P(z,t) - lambda_DA_E(t) + mu_max_R(z,t) - mu_max_R(z,t+1) - mu_min_R(z,t)  + mu_min_R(z,t+1) =e= 0;
L1_p_DAb(z,t)$(ord(t)=card(t)).. idata(z,'C_E') + mu_max_P(z,t) - mu_min_P(z,t) - lambda_DA_E(t)+ mu_max_R(z,t) - mu_min_R(z,t) =e= 0;
L1_p_DAc(g,t)$(ord(t)<card(t)).. exp_lambda_DA_G(t)*idata(g,'phi') + mu_max_P(g,t) - mu_min_P(g,t) - lambda_DA_E(t) + mu_max_R(g,t) - mu_max_R(g,t+1) - mu_min_R(g,t) + mu_min_R(g,t+1) =e= 0;
L1_p_DAd(g,t)$(ord(t)=card(t)).. exp_lambda_DA_G(t)*idata(g,'phi') + mu_max_P(g,t) - mu_min_P(g,t) - lambda_DA_E(t) + mu_max_R(g,t) - mu_min_R(g,t) =e= 0;
L1_u_DAa(n,t)$(ord(t)<card(t)).. - idata(n,'P_max')*mu_max_P(n,t) + idata(n,'P_min')*mu_min_P(n,t) - idata(n,'Ramp')*mu_max_R(n,t) - idata(n,'Ramp')*mu_min_R(n,t+1) + idata(n,'C_SU')*(mu_max_SU(n,t) - mu_max_SU(n,t+1)) + mu_max_B(n,t) - mu_min_B(n,t) =e= 0;
L1_u_DAb(n,t)$(ord(t)=card(t)).. - idata(n,'P_max')*mu_max_P(n,t) + idata(n,'P_min')*mu_min_P(n,t) - idata(n,'Ramp')*mu_max_R(n,t) + idata(n,'C_SU')*(mu_max_SU(n,t)) + mu_max_B(n,t) - mu_min_B(n,t) =e= 0;
L1_w_DA(j,t).. mu_max_W(j,t) - mu_min_W(j,t) - lambda_DA_E(t) =e= 0;
L1_c_DA(n,t).. 1 - mu_max_SU(n,t) - mu_min_SU(n,t) =e= 0;

comp1(n,t).. (p_DA(n,t) - u_DA(n,t)*idata(n,'P_min')) =g= 0;
comp2(n,t).. (u_DA(n,t)*idata(n,'P_max') - p_DA(n,t)) =g= 0;
comp3(j,t).. w_DA(j,t) =g= 0;
comp4(j,t).. (Wind_DA(j,t) - w_DA(j,t)) =g= 0;
comp5(n,t)$(ord(t)>1).. [(p_DA(n,t) - p_DA(n,t-1)) + u_DA(n,t-1)*idata(n,'Ramp')] =g= 0;
comp6(n,t)$(ord(t)>1).. [u_DA(n,t)*idata(n,'Ramp') -(p_DA(n,t) - p_DA(n,t-1))] =g= 0;
comp7(n,t)$(ord(t)=1).. [(p_DA(n,t) - idata(n,'P_ini')) + idata(n,'U_ini')*idata(n,'Ramp')] =g= 0;
comp8(n,t)$(ord(t)=1).. [u_DA(n,t)*idata(n,'Ramp') - (p_DA(n,t) - idata(n,'P_ini'))] =g= 0;
comp9(i,t)$(ord(t)>1).. [c_DA(i,t) - idata(i,'C_SU')*(u_DA(i,t) - u_DA(i,t-1))] =g= 0;
comp10(i,t)$(ord(t)=1).. [c_DA(i,t) - idata(i,'C_SU')*(u_DA(i,t) - idata(i,'U_ini'))] =g= 0;
comp11(i,t).. c_DA(i,t) =g= 0;
comp12(i,t).. u_DA(i,t) =g= 0;
comp13(i,t).. (1 - u_DA(i,t)) =g= 0;

*-------------------------------------------------------------------------------
*----------------KKT day-ahead gas market---------------------------------------
*-------------------------------------------------------------------------------
L2_g_DA(k,t).. kdata(k,'C_G') +  mu_max_G(k,t) - mu_min_G(k,t) - lambda_DA_G(t) =e= 0;
comp14(k,t).. g_DA(k,t) =g= 0;
comp15(k,t).. (kdata(k,'G_max') - g_DA(k,t)) =g= 0;

*-------------------------------------------------------------------------------
*----------------KKT real-time electricity market-------------------------------
*-------------------------------------------------------------------------------
L3_p_RTa(z,t,omega)$(ord(t)<card(t)).. pi(omega) * idata(z,'C_E') + nu_max_P(z,t,omega) - nu_min_P(z,t,omega) - lambda_RT_E(t,omega) + nu_max_R(z,t,omega)   - nu_max_R(z,t+1,omega) - nu_min_R(z,t,omega) + nu_min_R(z,t+1,omega) =e= 0;
L3_p_RTb(z,t,omega)$(ord(t)=card(t)).. pi(omega) * idata(z,'C_E') + nu_max_P(z,t,omega) - nu_min_P(z,t,omega)   - lambda_RT_E(t,omega) + nu_max_R(z,t,omega) - nu_min_R(z,t,omega) =e= 0;
L3_p_RTc(g,t,omega)$(ord(t)<card(t)).. pi(omega) * (exp_lambda_RT_G(t,omega))*idata(g,'phi') + nu_max_P(g,t,omega) - nu_min_P(g,t,omega) - lambda_RT_E(t,omega)+ nu_max_R(g,t,omega) - nu_max_R(g,t+1,omega) - nu_min_R(g,t,omega) + nu_min_R(g,t+1,omega) =e= 0;
L3_p_RTd(g,t,omega)$(ord(t)=card(t)).. pi(omega) * (exp_lambda_RT_G(t,omega))*idata(g,'phi') + nu_max_P(g,t,omega) - nu_min_P(g,t,omega) - lambda_RT_E(t,omega)   + nu_max_R(g,t,omega) - nu_min_R(g,t,omega) =e=  0;
L3_w_RT(j,t,omega).. nu_max_W(j,t,omega) - nu_min_W(j,t,omega) - lambda_RT_E(t,omega) =e= 0;
L3_l_sh_E(t,omega).. pi(omega) * C_sh_E + nu_max_DE(t,omega) - nu_min_DE(t,omega)  - lambda_RT_E(t,omega) =e= 0;
L3_u_RTa(f,t,omega)$(ord(t)<card(t)).. -idata(f,'P_max')*nu_max_P(f,t,omega)  + idata(f,'P_min')*nu_min_P(f,t,omega) - idata(f,'Ramp')*nu_max_R(f,t,omega) - idata(f,'Ramp')*nu_min_R(f,t+1,omega)+ idata(f,'C_SU')*(nu_max_SU(f,t,omega) - nu_max_SU(f,t+1,omega)) + nu_max_B(f,t,omega) - nu_min_B(f,t,omega) =e= 0;
L3_u_RTb(f,t,omega)$(ord(t)=card(t)).. -idata(f,'P_max')*nu_max_P(f,t,omega) + idata(f,'P_min')*nu_min_P(f,t,omega) - idata(f,'Ramp')*nu_max_R(f,t,omega) + idata(f,'C_SU')*(nu_max_SU(f,t,omega)) + nu_max_B(f,t,omega) - nu_min_B(f,t,omega) =e= 0;
L3_c_RT(f,t,omega).. pi(omega) - nu_max_SU(f,t,omega) - nu_min_SU(f,t,omega) =e= 0;

comp16(s,t,omega).. [(p_DA(s,t) + p_RT(s,t,omega)) - u_DA(s,t)*idata(s,'P_min')] =g= 0;
comp17(s,t,omega).. [u_DA(s,t)*idata(s,'P_max') - (p_DA(s,t) + p_RT(s,t,omega))] =g= 0;
comp18(f,t,omega).. [(p_DA(f,t) + p_RT(f,t,omega)) - (u_DA(f,t) + u_RT(f,t,omega))*idata(f,'P_min')] =g= 0;
comp19(f,t,omega).. [(u_DA(f,t) + u_RT(f,t,omega))*idata(f,'P_max') - (p_DA(f,t) + p_RT(f,t,omega))] =g= 0;
comp20(j,t,omega).. (w_DA(j,t) + w_RT(j,t,omega)) =g= 0;
comp21(j,t,omega).. [Wind(j,t,omega) - (w_DA(j,t) + w_RT(j,t,omega))] =g= 0;
comp22a(t,omega).. l_sh_E(t,omega) =g= 0;
comp22b(t,omega).. (D_E(t) - l_sh_E(t,omega)) =g= 0;
comp23(s,t,omega)$(ord(t)>1).. [(p_DA(s,t) + p_RT(s,t,omega) - p_DA(s,t-1)  - p_RT(s,t-1,omega)) + u_DA(s,t-1)*idata(s,'Ramp')] =g= 0;
comp24(s,t,omega)$(ord(t)>1).. [u_DA(s,t)*idata(s,'Ramp') - (p_DA(s,t) + p_RT(s,t,omega)  - p_DA(s,t-1) - p_RT(s,t-1,omega))] =g= 0;
comp25(s,t,omega)$(ord(t)=1).. [(p_DA(s,t) + p_RT(s,t,omega) - idata(s,'P_ini'))  + idata(s,'U_ini')*idata(s,'Ramp')] =g= 0;
comp26(s,t,omega)$(ord(t)=1).. [u_DA(s,t)*idata(s,'Ramp') - (p_DA(s,t) + p_RT(s,t,omega)  - idata(s,'P_ini'))] =g= 0;
comp27(f,t,omega)$(ord(t)>1).. [(p_DA(f,t) + p_RT(f,t,omega) - p_DA(f,t-1)  - p_RT(f,t-1,omega)) + (u_DA(f,t-1) + u_RT(f,t-1,omega))*idata(f,'Ramp')] =g= 0;
comp28(f,t,omega)$(ord(t)>1).. [(u_DA(f,t) + u_RT(f,t,omega))*idata(f,'Ramp') - (p_DA(f,t) + p_RT(f,t,omega) - p_DA(f,t-1) - p_RT(f,t-1,omega))] =g= 0;
comp29(f,t,omega)$(ord(t)=1).. [p_DA(f,t) + p_RT(f,t,omega) - idata(f,'P_ini') + idata(f,'U_ini')*idata(f,'Ramp')] =g= 0;
comp30(f,t,omega)$(ord(t)=1).. [(u_DA(f,t) + u_RT(f,t,omega))*idata(f,'Ramp') - (p_DA(f,t) + p_RT(f,t,omega) - idata(f,'P_ini'))] =g= 0;
comp31(f,t,omega)$(ord(t)>1).. [(c_DA(f,t) + c_RT(f,t,omega))  - idata(f,'C_SU')*(u_DA(f,t) + u_RT(f,t,omega) - u_DA(f,t-1) - u_RT(f,t-1,omega))] =g= 0;
comp32(f,t,omega)$(ord(t)=1).. [(c_DA(f,t) + c_RT(f,t,omega))  - idata(f,'C_SU')*(u_DA(f,t) + u_RT(f,t,omega) - idata(f,'U_ini'))] =g= 0;
comp33(f,t,omega).. (c_DA(f,t) + c_RT(f,t,omega)) =g= 0;
comp34(f,t,omega).. (u_DA(f,t) + u_RT(f,t,omega)) =g= 0;
comp35(f,t,omega).. [1- (u_DA(f,t) + u_RT(f,t,omega))] =g= 0;

*-------------------------------------------------------------------------------
*----------------KKT real-time gas market---------------------------------------
*-------------------------------------------------------------------------------
L4_g_RT(k,t,omega).. pi(omega) * kdata(k,'C_G') + nu_max_G(k,t,omega) - nu_min_G(k,t,omega) +nu_max_GR(k,t,omega)
*- nu_min_GR(k,t,omega)
- lambda_RT_G(t,omega) =e= 0;
L4_l_sh_G(t,omega).. pi(omega) * C_sh_G + nu_max_DG(t,omega) - nu_min_DG(t,omega) - lambda_RT_G(t,omega) =e= 0;

comp36(k,t,omega).. (g_DA(k,t) + g_RT(k,t,omega)) =g= 0;
comp37(k,t,omega).. [kdata(k,'G_max') - (g_DA(k,t) + g_RT(k,t,omega))] =g= 0;
comp38(t,omega).. l_sh_G(t,omega) =g= 0;
comp39(t, omega).. (D_G(t) - l_sh_G(t,omega)) =g= 0;
*compGRmin(k,t,omega).. (kdata(k,'G_R')+g_RT(k,t,omega)) =g= 0;
compGRmax(k,t,omega).. (kdata(k,'G_R')-g_RT(k,t,omega)) =g= 0;

*-------------------------------------------------------------------------------
*----------------KKT virtual bidder electricity---------------------------------
*-------------------------------------------------------------------------------
L5_v_DA(r,t).. lambda_DA_E(t) - rho(r,t) =e= 0;
L5_v_RT(r,t).. sum(omega, (lambda_RT_E(t,omega))) - rho(r,t) =e= 0;
L5_v(r,t).. lambda_DA_E(t) - sum(omega, (lambda_RT_E(t,omega))) =e= 0;

*-------------------------------------------------------------------------------
*----------------KKT virtual bidder gas-----------------------------------------
*-------------------------------------------------------------------------------
L6_v_DA(q,t).. lambda_DA_G(t) - psi(q,t) =e= 0;
L6_v_RT(q,t).. sum(omega, (lambda_RT_G(t,omega))) - psi(q,t) =e= 0;
L6_v(q,t).. lambda_DA_G(t) - sum(omega, (lambda_RT_G(t,omega))) =e= 0;

*-------------------------------------------------------------------------------
*----------------KKT self-scheduling PPs----------------------------------------
*-------------------------------------------------------------------------------
L8_u_DAa(ss,t)$(ord(t)<card(t))..
*- idata(ss,'P_max')*mu_max_P(ss,t) + idata(ss,'P_min')*mu_min_P(ss,t) - idata(ss,'Ramp')*mu_max_R(ss,t) - idata(ss,'Ramp')*mu_min_R(ss,t+1) +
idata(ss,'C_SU')*(mu_max_SU(ss,t) - mu_max_SU(ss,t+1)) + mu_max_B(ss,t) - mu_min_B(ss,t)+ sum(omega,  - idata(ss,'P_max')*nu_max_P(ss,t,omega) + idata(ss,'P_min')*nu_min_P(ss,t,omega)- idata(ss,'Ramp')*nu_max_R(ss,t,omega) - idata(ss,'Ramp')*nu_min_R(ss,t+1,omega) ) =e= 0;
L8_u_DAb(ss,t)$(ord(t)=card(t))..
*- idata(ss,'P_max')*mu_max_P(ss,t) + idata(ss,'P_min')*mu_min_P(ss,t) - idata(ss,'Ramp')*mu_max_R(ss,t) +
idata(ss,'C_SU')*(mu_max_SU(ss,t)) + mu_max_B(ss,t) - mu_min_B(ss,t)+ sum(omega,  - idata(ss,'P_max')*nu_max_P(ss,t,omega) + idata(ss,'P_min')*nu_min_P(ss,t,omega)- idata(ss,'Ramp')*nu_max_R(ss,t,omega) ) =e= 0;
L8_c_DA(ss,t).. 1 - mu_max_SU(ss,t) - mu_min_SU(ss,t) =e= 0;

comp46(ss,t,omega).. [(p_DA(ss,t) + p_RT(ss,t,omega)) - u_DA(ss,t)*idata(ss,'P_min')] =g= 0;
comp47(ss,t,omega).. [u_DA(ss,t)*idata(ss,'P_max') - (p_DA(ss,t) + p_RT(ss,t,omega))] =g= 0;
comp53(ss,t,omega)$(ord(t)>1).. [(p_DA(ss,t) + p_RT(ss,t,omega) - p_DA(ss,t-1)- p_RT(ss,t-1,omega)) + u_DA(ss,t-1)*idata(ss,'Ramp')] =g= 0;
comp54(ss,t,omega)$(ord(t)>1).. [u_DA(ss,t)*idata(ss,'Ramp') - (p_DA(ss,t) + p_RT(ss,t,omega)   - p_DA(ss,t-1) - p_RT(ss,t-1,omega))] =g= 0;
comp55(ss,t,omega)$(ord(t)=1).. [(p_DA(ss,t) + p_RT(ss,t,omega) - idata(ss,'P_ini'))  + idata(ss,'U_ini')*idata(ss,'Ramp')] =g= 0;
comp56(ss,t,omega)$(ord(t)=1).. [u_DA(ss,t)*idata(ss,'Ramp') - (p_DA(ss,t) + p_RT(ss,t,omega)  - idata(ss,'P_ini'))] =g= 0;

*-------------------------------------------------------------------------------
*----------------KKT self-scheduling non-gas PPs--------------------------------
*-------------------------------------------------------------------------------
L8_p_DAa(ssz,t)$(ord(t)<card(t)).. - lambda_DA_E(t) + idata(ssz,'C_E')
*+ mu_max_P(ssz,t) - mu_min_P(ssz,t) + mu_max_R(ssz,t) - mu_max_R(ssz,t+1) - mu_min_R(ssz,t) + mu_min_R(ssz,t+1)
+ sum(omega, [ nu_max_P(ssz,t,omega) - nu_min_P(ssz,t,omega) + nu_max_R(ssz,t,omega) - nu_max_R(ssz,t+1,omega) - nu_min_R(ssz,t,omega) + nu_min_R(ssz,t+1,omega) ]) =e= 0;
L8_p_DAb(ssz,t)$(ord(t)=card(t)).. - lambda_DA_E(t) + idata(ssz,'C_E')
*+ mu_max_P(ssz,t) - mu_min_P(ssz,t) + mu_max_R(ssz,t) - mu_min_R(ssz,t)
+ sum(omega, [ nu_max_P(ssz,t,omega) - nu_min_P(ssz,t,omega) + nu_max_R(ssz,t,omega) - nu_min_R(ssz,t,omega) ]) =e= 0;
L8_p_RTa(ssz,t,omega)$(ord(t)<card(t)).. - pi(omega)* ( (lambda_RT_E(t,omega)/pi(omega))  - idata(ssz,'C_E') ) + nu_max_P(ssz,t,omega) - nu_min_P(ssz,t,omega) + nu_max_R(ssz,t,omega)  - nu_max_R(ssz,t+1,omega) - nu_min_R(ssz,t,omega) + nu_min_R(ssz,t+1,omega) =e= 0;
L8_p_RTb(ssz,t,omega)$(ord(t)=card(t)).. - pi(omega)* ( (lambda_RT_E(t,omega)/pi(omega))  - idata(ssz,'C_E') ) + nu_max_P(ssz,t,omega) - nu_min_P(ssz,t,omega) + nu_max_R(ssz,t,omega) - nu_min_R(ssz,t,omega) =e= 0;

*-------------------------------------------------------------------------------
*----------------KKT self-scheduling gas-fired PPs------------------------------
*-------------------------------------------------------------------------------
L9_p_DAa(ssg,t)$(ord(t)<card(t)).. - lambda_DA_E(t) + lambda_DA_G(t)*idata(ssg,'phi')
*+ mu_max_P(ssg,t) - mu_min_P(ssg,t) + mu_max_R(ssg,t) - mu_max_R(ssg,t+1) - mu_min_R(ssg,t) + mu_min_R(ssg,t+1)
+ sum(omega, [ nu_max_P(ssg,t,omega) - nu_min_P(ssg,t,omega) + nu_max_R(ssg,t,omega) - nu_max_R(ssg,t+1,omega) - nu_min_R(ssg,t,omega) + nu_min_R(ssg,t+1,omega) ]) =e= 0;
L9_p_DAb(ssg,t)$(ord(t)=card(t)).. - lambda_DA_E(t) + lambda_DA_G(t)*idata(ssg,'phi')
*+ mu_max_P(ssg,t) - mu_min_P(ssg,t) + mu_max_R(ssg,t) - mu_min_R(ssg,t)
+ sum(omega, [ nu_max_P(ssg,t,omega) - nu_min_P(ssg,t,omega) + nu_max_R(ssg,t,omega)  - nu_min_R(ssg,t,omega) ]) =e= 0;
L9_p_RTa(ssg,t,omega)$(ord(t)<card(t)).. - pi(omega)* ( (lambda_RT_E(t,omega)/pi(omega))   - idata(ssg,'phi')*(lambda_RT_G(t,omega)/pi(omega)) ) + nu_max_P(ssg,t,omega) - nu_min_P(ssg,t,omega) + nu_max_R(ssg,t,omega)- nu_max_R(ssg,t+1,omega) - nu_min_R(ssg,t,omega) + nu_min_R(ssg,t+1,omega) =e= 0;
L9_p_RTb(ssg,t,omega)$(ord(t)=card(t)).. - pi(omega)* ( (lambda_RT_E(t,omega)/pi(omega))  - idata(ssg,'phi')*(lambda_RT_G(t,omega)/pi(omega)) ) + nu_max_P(ssg,t,omega) - nu_min_P(ssg,t,omega) + nu_max_R(ssg,t,omega)- nu_min_R(ssg,t,omega) =e= 0;

*-------------------------------------------------------------------------------
*----------------equilibrium problem electricity--------------------------------
*-------------------------------------------------------------------------------
model KKT_E /
L1_p_DAa.p_DA
L1_p_DAb.p_DA
L1_p_DAc.p_DA
L1_p_DAd.p_DA
L1_u_DAa.u_DA
L1_u_DAb.u_DA
L1_w_DA.w_DA
L1_c_DA.c_DA
comp1.mu_min_P
comp2.mu_max_P
comp3.mu_min_W
comp4.mu_max_W
comp5.mu_min_R
comp6.mu_max_R
comp7.mu_min_R
comp8.mu_max_R
comp9.mu_max_SU
comp10.mu_max_SU
comp11.mu_min_SU
comp12.mu_min_B
comp13.mu_max_B

El_bal.lambda_DA_E

L3_p_RTa.p_RT
L3_p_RTb.p_RT
L3_p_RTc.p_RT
L3_p_RTd.p_RT
L3_w_RT.w_RT
L3_l_sh_E.l_sh_E
L3_u_RTa.u_RT
L3_u_RTb.u_RT
L3_c_RT.c_RT
comp16.nu_min_P
comp17.nu_max_P
comp18.nu_min_P
comp19.nu_max_P
comp20.nu_min_W
comp21.nu_max_W
comp22a.nu_min_DE
comp22b.nu_max_DE
comp23.nu_min_R
comp24.nu_max_R
comp25.nu_min_R
comp26.nu_max_R
comp27.nu_min_R
comp28.nu_max_R
comp29.nu_min_R
comp30.nu_max_R
comp31.nu_max_SU
comp32.nu_max_SU
comp33.nu_min_SU
comp34.nu_min_B
comp35.nu_max_B

RT_El_balance.lambda_RT_E

L5_v
VBE_bal

L8_u_DAa.u_DA
L8_u_DAb.u_DA
L8_c_DA.c_DA

L8_p_DAa.p_DA
L8_p_DAb.p_DA
L8_p_RTa.p_RT
L8_p_RTb.p_RT
comp46.nu_min_P
comp47.nu_max_P
comp53.nu_min_R
comp54.nu_max_R
comp55.nu_min_R
comp56.nu_max_R
L9_p_DAa.p_DA
L9_p_DAb.p_DA
L9_p_RTa.p_RT
L9_p_RTb.p_RT
/
;
*-------------------------------------------------------------------------------
*----------------equilibrium problem gas----------------------------------------
*-------------------------------------------------------------------------------
model KKT_G/

L2_g_DA.g_DA
comp14.mu_min_G
comp15.mu_max_G

Gas_bal.lambda_DA_G

L4_g_RT.g_RT
L4_l_sh_G.l_SH_G
comp36.nu_min_G
comp37.nu_max_G
comp38.nu_min_DG
comp39.nu_max_DG

RT_Gas_balance.lambda_RT_G

L6_v
VBG_bal

*compGRmin.nu_min_GR
compGRmax.nu_max_GR
/;
       file opt path option file /path.opt/;
       put opt;
*       put 'chen_lambda 1'/;
*       put 'convergence_tolerance 10e-1'/;
      put 'gradient_step_limit 500'/;
       put 'crash_iteration_limit 100'/;
       put 'major_iteration_limit 1000'/;
*      put 'gradient_searchtype line'/;
*      put 'nms_searchtype arc'/;
*      put 'crash_searchtype arc'/;
       putclose;
       KKT_E.OptFile = 1;
       KKT_G.OptFile = 1;

       option mcp=PATH;
       option optca=0.0;
       option optcr = 0.0;
       Option iterlim = 1e8;
       Option reslim = 1e10;
solve KKT_E using mcp;
parameter
Time;
Time=KKT_E.resusd;
display Time;
solve KKT_G using mcp;
Time=KKT_G.resusd;
display Time;


*-------------------------------------------------------------------------------
*----------------complementarity check------------------------------------------
*-------------------------------------------------------------------------------

parameters
ccomp1
ccomp2
ccomp3
ccomp4
ccomp5
ccomp6
ccomp7
ccomp8
ccomp9
ccomp10
ccomp11
ccomp12
ccomp13
ccomp14
ccomp15
ccomp16
ccomp17
ccomp18
ccomp19
ccomp20
ccomp21
ccomp22a
ccomp22b
ccomp23
ccomp24
ccomp25
ccomp26
ccomp27
ccomp28
ccomp29
ccomp30
ccomp31
ccomp32
ccomp33
ccomp34
ccomp35
ccomp36
ccomp37
ccomp38
ccomp39
ccomp46
ccomp47
ccomp53
ccomp54
ccomp55
ccomp56
*ccompGRmin
ccompGRmax
;
*-------------------------------------------------------------------------------
*----------------KKT day-ahead electricity market-------------------------------
*-------------------------------------------------------------------------------
ccomp1=sum((n,t), (p_DA.l(n,t) - u_DA.l(n,t)*idata(n,'P_min')) * mu_min_P.l(n,t));
ccomp2=sum((n,t), (u_DA.l(n,t)*idata(n,'P_max') - p_DA.l(n,t)) * mu_max_P.l(n,t));
ccomp3=sum((j,t), w_DA.l(j,t) * mu_min_W.l(j,t));
ccomp4=sum((j,t), (Wind_DA(j,t) - w_DA.l(j,t)) * mu_max_W.l(j,t));
ccomp5=sum((n,t)$(ord(t)>1), [(p_DA.l(n,t) - p_DA.l(n,t-1)) + u_DA.l(n,t-1)*idata(n,'Ramp')] * mu_min_R.l(n,t));
ccomp6=sum((n,t)$(ord(t)>1), [u_DA.l(n,t)*idata(n,'Ramp') -(p_DA.l(n,t) - p_DA.l(n,t-1))] * mu_max_R.l(n,t));
ccomp7=sum((n,t)$(ord(t)=1), [(p_DA.l(n,t) - idata(n,'P_ini')) + idata(n,'U_ini')*idata(n,'Ramp')] * mu_min_R.l(n,t));
ccomp8=sum((n,t)$(ord(t)=1), [u_DA.l(n,t)*idata(n,'Ramp') - (p_DA.l(n,t) - idata(n,'P_ini'))]* mu_max_R.l(n,t));
ccomp9=sum((i,t)$(ord(t)>1), [c_DA.l(i,t) - idata(i,'C_SU')*(u_DA.l(i,t) - u_DA.l(i,t-1))] * mu_max_SU.l(i,t));
ccomp10=sum((i,t)$(ord(t)=1), [c_DA.l(i,t) - idata(i,'C_SU')*(u_DA.l(i,t) - idata(i,'U_ini'))]* mu_max_SU.l(i,t));
ccomp11=sum((i,t), c_DA.l(i,t) * mu_min_SU.l(i,t));
ccomp12=sum((i,t), u_DA.l(i,t) * mu_min_B.l(i,t));
ccomp13=sum((i,t), (1 - u_DA.l(i,t)) * mu_max_B.l(i,t));
*-------------------------------------------------------------------------------
*----------------KKT day-ahead gas market---------------------------------------
*-------------------------------------------------------------------------------
ccomp14=sum((k,t), g_DA.l(k,t) * mu_min_G.l(k,t) );
ccomp15=sum((k,t), (kdata(k,'G_max') - g_DA.l(k,t)) * mu_max_G.l(k,t));
*-------------------------------------------------------------------------------
*----------------KKT real-time electricity market-------------------------------
*-------------------------------------------------------------------------------
ccomp16=sum((s,t,omega), [(p_DA.l(s,t) + p_RT.l(s,t,omega)) - u_DA.l(s,t)*idata(s,'P_min')] * nu_min_P.l(s,t,omega));
ccomp17=sum((s,t,omega), [u_DA.l(s,t)*idata(s,'P_max') - (p_DA.l(s,t) + p_RT.l(s,t,omega))] * nu_max_P.l(s,t,omega));
ccomp18=sum((f,t,omega), [(p_DA.l(f,t) + p_RT.l(f,t,omega)) - (u_DA.l(f,t) + u_RT.l(f,t,omega))*idata(f,'P_min')] * nu_min_P.l(f,t,omega));
ccomp19=sum((f,t,omega), [(u_DA.l(f,t) + u_RT.l(f,t,omega))*idata(f,'P_max') - (p_DA.l(f,t) + p_RT.l(f,t,omega))] * nu_max_P.l(f,t,omega));
ccomp20=sum((j,t,omega), (w_DA.l(j,t) + w_RT.l(j,t,omega)) * nu_min_W.l(j,t,omega));
ccomp21=sum((j,t,omega), [Wind(j,t,omega) - (w_DA.l(j,t) + w_RT.l(j,t,omega))] * nu_max_W.l(j,t,omega));
ccomp22a=sum((t,omega), l_sh_E.l(t,omega) * nu_min_DE.l(t,omega));
ccomp22b=sum((t,omega), (D_E(t) - l_sh_E.l(t,omega)) * nu_max_DE.l(t,omega));
ccomp23=sum((s,t,omega)$(ord(t)>1), [(p_DA.l(s,t) + p_RT.l(s,t,omega) - p_DA.l(s,t-1) - p_RT.l(s,t-1,omega)) + u_DA.l(s,t-1)*idata(s,'Ramp')] * nu_min_R.l(s,t,omega));
ccomp24=sum((s,t,omega)$(ord(t)>1), [u_DA.l(s,t)*idata(s,'Ramp') - (p_DA.l(s,t) + p_RT.l(s,t,omega) - p_DA.l(s,t-1) - p_RT.l(s,t-1,omega))] * nu_max_R.l(s,t,omega));
ccomp25=sum((s,t,omega)$(ord(t)=1), [(p_DA.l(s,t) + p_RT.l(s,t,omega) - idata(s,'P_ini')) + idata(s,'U_ini')*idata(s,'Ramp')] * nu_min_R.l(s,t,omega) );
ccomp26=sum((s,t,omega)$(ord(t)=1), [u_DA.l(s,t)*idata(s,'Ramp') - (p_DA.l(s,t) + p_RT.l(s,t,omega) - idata(s,'P_ini'))] * nu_max_R.l(s,t,omega));
ccomp27=sum((f,t,omega)$(ord(t)>1), [(p_DA.l(f,t) + p_RT.l(f,t,omega) - p_DA.l(f,t-1) - p_RT.l(f,t-1,omega)) + (u_DA.l(f,t-1) + u_RT.l(f,t-1,omega))*idata(f,'Ramp')] * nu_min_R.l(f,t,omega));
ccomp28=sum((f,t,omega)$(ord(t)>1), [(u_DA.l(f,t) + u_RT.l(f,t,omega))*idata(f,'Ramp') - (p_DA.l(f,t) + p_RT.l(f,t,omega) - p_DA.l(f,t-1) - p_RT.l(f,t-1,omega))] * nu_max_R.l(f,t,omega));
ccomp29=sum((f,t,omega)$(ord(t)=1), [p_DA.l(f,t) + p_RT.l(f,t,omega) - idata(f,'P_ini') + idata(f,'U_ini')*idata(f,'Ramp')] * nu_min_R.l(f,t,omega));
ccomp30=sum((f,t,omega)$(ord(t)=1), [(u_DA.l(f,t) + u_RT.l(f,t,omega))*idata(f,'Ramp') - (p_DA.l(f,t) + p_RT.l(f,t,omega) - idata(f,'P_ini'))] * nu_max_R.l(f,t,omega));
ccomp31=sum((f,t,omega)$(ord(t)>1), [(c_DA.l(f,t) + c_RT.l(f,t,omega)) - idata(f,'C_SU')*(u_DA.l(f,t) + u_RT.l(f,t,omega) - u_DA.l(f,t-1) - u_RT.l(f,t-1,omega))] * nu_max_SU.l(f,t,omega));
ccomp32=sum((f,t,omega)$(ord(t)=1), [(c_DA.l(f,t) + c_RT.l(f,t,omega)) - idata(f,'C_SU')*(u_DA.l(f,t) + u_RT.l(f,t,omega) - idata(f,'U_ini'))] * nu_max_SU.l(f,t,omega));
ccomp33=sum((f,t,omega), (c_DA.l(f,t) + c_RT.l(f,t,omega)) * nu_min_SU.l(f,t,omega) );
ccomp34=sum((f,t,omega), (u_DA.l(f,t) + u_RT.l(f,t,omega)) * nu_min_B.l(f,t,omega) );
ccomp35=sum((f,t,omega), [1- (u_DA.l(f,t) + u_RT.l(f,t,omega))] * nu_max_B.l(f,t,omega));
*-------------------------------------------------------------------------------
*----------------KKT real-time gas market---------------------------------------
*-------------------------------------------------------------------------------
ccomp36=sum((k,t,omega), (g_DA.l(k,t) + g_RT.l(k,t,omega)) * nu_min_G.l(k,t,omega));
ccomp37=sum((k,t,omega), [kdata(k,'G_max') - (g_DA.l(k,t) + g_RT.l(k,t,omega))] * nu_max_G.l(k,t,omega));
ccomp38=sum((t,omega), l_sh_G.l(t,omega) * nu_min_DG.l(t,omega) );
ccomp39=sum((t, omega), (D_G(t) - l_sh_G.l(t,omega)) * nu_max_DG.l(t,omega) );
*-------------------------------------------------------------------------------
*----------------KKT self-scheduling non-gas PPs--------------------------------
*-------------------------------------------------------------------------------
ccomp46=sum((ss,t,omega), [(p_DA.l(ss,t) + p_RT.l(ss,t,omega)) - u_DA.l(ss,t)*idata(ss,'P_min')] * nu_min_P.l(ss,t,omega));
ccomp47=sum((ss,t,omega), [u_DA.l(ss,t)*idata(ss,'P_max') - (p_DA.l(ss,t) + p_RT.l(ss,t,omega))] * nu_max_P.l(ss,t,omega));
ccomp53=sum((ss,t,omega)$(ord(t)>1), [(p_DA.l(ss,t) + p_RT.l(ss,t,omega) - p_DA.l(ss,t-1) - p_RT.l(ss,t-1,omega)) + u_DA.l(ss,t-1)*idata(ss,'Ramp')] * nu_min_R.l(ss,t,omega));
ccomp54=sum((ss,t,omega)$(ord(t)>1), [u_DA.l(ss,t)*idata(ss,'Ramp') - (p_DA.l(ss,t) + p_RT.l(ss,t,omega) - p_DA.l(ss,t-1) - p_RT.l(ss,t-1,omega))] * nu_max_R.l(ss,t,omega));
ccomp55=sum((ss,t,omega)$(ord(t)=1), [(p_DA.l(ss,t) + p_RT.l(ss,t,omega) - idata(ss,'P_ini')) + idata(ss,'U_ini')*idata(ss,'Ramp')] * nu_min_R.l(ss,t,omega));
ccomp56=sum((ss,t,omega)$(ord(t)=1), [u_DA.l(ss,t)*idata(ss,'Ramp') - (p_DA.l(ss,t) + p_RT.l(ss,t,omega) - idata(ss,'P_ini'))] * nu_max_R.l(ss,t,omega));
*ccompGRmin=sum((k,t,omega), (kdata(k,'G_R')+g_RT.l(k,t,omega)) *nu_min_GR.l(k,t,omega));
ccompGRmax=sum((k,t,omega), (kdata(k,'G_R')-g_RT.l(k,t,omega)) *nu_max_GR.l(k,t,omega));

display
ccomp1
ccomp2
ccomp3
ccomp4
ccomp5
ccomp6
ccomp7
ccomp8
ccomp9
ccomp10
ccomp11
ccomp12
ccomp13
ccomp14
ccomp15
ccomp16
ccomp17
ccomp18
ccomp19
ccomp20
ccomp21
ccomp22a
ccomp22b
ccomp23
ccomp24
ccomp25
ccomp26
ccomp27
ccomp28
ccomp29
ccomp30
ccomp31
ccomp32
ccomp33
ccomp34
ccomp35
ccomp36
ccomp37
ccomp38
ccomp39

ccomp46
ccomp47

ccomp53
ccomp54
ccomp55
ccomp56

*ccompGRmin
ccompGRmax
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
p_DA.l,lambda_DA_E.l,lambda_DA_G.l,expectedrealtimepriceE,expectedrealtimepriceG,v_DA_E.l,v_DA_G.l;
parameter
consumption(t);
consumption(t)=p_DA.l('i10',t)*idata('i10','phi');
display  consumption;



