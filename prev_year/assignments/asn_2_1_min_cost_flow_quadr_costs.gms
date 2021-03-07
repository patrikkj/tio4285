$ONTEXT
Minimum cost flow with quadratic costs.
Ruud Egging-Bratseth, 2020. Lecture notes NTNU TIØ4285, Production and Network Economics.
$OFFTEXT

set  n nodes /1*7/
;
alias (n,i,j);

table data_in(*,*) "unit transport costs, nodal supply or demand"
    cap   c    d     3    4    5    6     7
dmd                                 4     6
1    10   1    0.25  0.2  0.5       0.8
2    10   2    0.25       0.5  0.3       0.6
3                                   0.2
4                                   0.3  0.2
5                                        0.2
;
parameter c(i)   constant per unit prod cost
          d(i)   increasing part in prod cost
          cap(i) prod capacity
          dmd(i) dmd level
          f(i,j) flow cost
;
c(i)=    data_in(i,'c');
d(i)=    data_in(i,'d');
cap(i)=  data_in(i,'cap');
dmd(j)=  data_in('dmd',j);
f(i,j)=  data_in(i,j);

positive variable
     S(i)    production
     X(i,j)  flow
variable
     TC  total transport costs
;

X.fx(i,j)$(f(i,j)=0) =0;
equation
     def_obj
     eq_mb
     eq_cap
;

def_obj ..  TC =E= sum(i,(c(i)+d(i)*S(i)/2)*S(i))+sum((i,j),f(i,j)*X(i,j)*X(i,j));

*GAMS "accepts" SOURSES = SINKS
eq_mb(i)..  S(i) + sum(j,X(j,i)) =E= dmd(i) + sum(j,X(i,j));

*Need =G= in complementarity formulation
*eq_cap(i).. S(i)=L= cap(i) ;
eq_cap(i).. cap(i) - S(i) =G= 0  ;

model transp /all/;

solve transp using qcp min TC;

parameter report(*,*,*);

report(i,'OPT',j)=X.l(i,j);
report(i,'OPT','TS')=sum(j,X.l(i,j));
report(i,'OPT','TC')=sum(j,f(i,j)*X.l(i,j));
report('TD','OPT',j)=sum(i,X.l(i,j));
report('TC','OPT',j)=sum(i,f(i,j)*X.l(i,j));
report('TC','OPT','TC')=TC.l;

free variable
   phi
positive variable
   lam
;
equation
   stat_s
   stat_x
;
stat_s(i)..   c(i) + d(i)*S(i) - phi(i) + lam(i)  =G= 0
;
stat_x(i,j).. 2*f(i,j)*X(i,j) + phi(i) - phi(j) =G= 0
;

model trans_lcp / stat_s.S, stat_x.X, eq_mb.phi, eq_cap.lam/
;
solve trans_lcp using mcp
;

report(i,'LCP',j)=X.l(i,j);
report(i,'LCP','TS')=sum(j,X.l(i,j));
report(i,'LCP','TC')=sum(j,f(i,j)*X.l(i,j));
report('TD','LCP',j)=sum(i,X.l(i,j));
report('TC','LCP',j)=sum(i,f(i,j)*X.l(i,j));
report('TC','LCP','TC')=TC.l;


option report:2:2:1,X:3:0:2;
display report,X.l,phi.l;

