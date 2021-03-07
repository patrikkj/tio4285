*Capacity-constrainted oligopoly on small network.
*Solution assignment prodnett set 6. Equil mod 3.3
*Ruud Egging-Bratseth, 2020. NTNU TIØ4285, Production and Network Economics.

set  i suppliers /1*2/
     n nodes /1*3/
;
alias(i,j),(n,m)
;

parameter a(n)       intercept of the inv demand curve      /1*3  10/
          b(n)       negative slope of inverse demand curve /1*3   1/
          c_p(i,n)   constant unit production cost term     /1.1   2,   2.2 2/
          can_produce(i,n) auxiliary                        /1.1   1,   2.2 1/
          cap_a(n,m) capacity of pipeline                   /1.2 100,   2.3 4/
          c_a(n,m)   base unit cost pipeline                /1.2   1,   2.3 1/
          l_a(n,m)   loss in pipeline                       /1.2   0.1, 2.3 0.1/
;
positive variable Q_P(i,n)   quantity produced by supplier i
                  Q_S(i,n)   quantity sold by supplier i
                  F_P(i,n,m) supplier flow
                  F_A(n,m)   TSO flow
                  lam_a(n,m) arc capacity dual
                  phi_p(i,n)   nodal mass balance dual
;
variable          tau_a(n,m) dual on market clearing transport services
;
equations stat_q_p, stat_q_s, stat_f_p, eq_mb,
          stat_f_a, eq_cap_a,
          mcc_a
;
*SUPPLIER
*Ensure that producers do only produce where they can
Q_P.fx(i,n)$( NOT can_produce(i,n)) = 0;

stat_q_p(i,n) ..  c_p(i,n) - phi_p(i,n) =G= 0
;
stat_q_s(i,n) ..  - a(n) + b(n)*(sum(j,Q_S(j,n)) + Q_S(i,n)) + phi_p(i,n) =G= 0
;
stat_f_p(i,n,m).. c_a(n,m) + tau_a(n,m) + phi_p(i,n) - (1-l_a(n,m))*phi_p(i,m) =G= 0
;
eq_mb(i,n)..      Q_P(i,n) + sum(m,(1-l_a(m,n))*F_P(i,m,n)) - Q_S(i,n) - sum(m,F_P(i,n,m)) =G= 0
;
*TSO
stat_f_a(n,m)..  lam_a(n,m) - tau_a(n,m) =G=0
;
eq_cap_a(n,m) ..  cap_a(n,m) - F_A(n,m) =G= 0;
;
*MARKET CLEARING
mcc_a(n,m)..     F_A(n,m) - sum(i,F_P(i,n,m)) =E=0
;
model duop_nw /
         stat_q_p.Q_P
         stat_q_s.Q_S
         stat_f_p.F_P
         eq_mb.phi_p
         stat_f_a.F_A
         eq_cap_a.lam_A
         mcc_a.tau_a
/
;
solve duop_nw using mcp
;
*$ONTEXT
parameter rep_p_mb "nodal mass balance by producer (producer,node - values)",
          rep_n_mb "nodal mass balance aggregate (node - values"
;

rep_p_mb(i,n,'prod')=  Q_P.l(i,n);
rep_p_mb(i,n,'flow+')= sum(m,(1-l_a(m,n))*F_P.l(i,m,n));
rep_p_mb(i,n,'sales')= Q_S.l(i,n);
rep_p_mb(i,n,'flow-')= sum(m,F_P.l(i,n,m));

set aux /prod,flow+,sales,flow-/;

rep_n_mb(n,aux)=      sum(i,rep_p_mb(i,n,aux));
rep_n_mb(n,'price')=  a(n)-b(n)*rep_n_mb(n,'sales');

display rep_p_mb,rep_n_mb;
