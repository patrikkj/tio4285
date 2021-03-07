*Capacity-constrainted oligopoly on a single node. Solution assignment 4.1.d
*Ruud Egging-Bratseth, 2020. NTNU TIØ4285, Production and Network Economics.

set i suppliers /1*4/;
alias(i,j);

parameter a      intercept of the inv demand curve                       /20/
          b      negative slope of inverse demand curve                  / 1/
          c(i)   constant cost term in productoin cost   c*q + d*q^2 /1*3  2/
          d(i)   increasing cost term in productoin cost c*q + d*q^2 /1*4  0.5/
          cap(i) capacity of supplier i                              /1*3  5/
;
c('4')= 99;

positive variable Q(i)   quantity supplied by supplier i
                  lam(i) capacity dual price i
;
equations stat_q, eq_cap
;

stat_q(i) .. c(i) + 2*d(i)*Q(i) + lam(i) - (a - b*(sum(j,Q(j)) + Q(i))) =G= 0
;
eq_cap(i) ..  cap(i) - Q(i) =G= 0;
;
model olig / stat_q.Q
             eq_cap.lam
/
;
solve olig using mcp
;
parameter rep(*,*,*)  output report;

rep('p','mkt', '1')= a-b*sum(j,Q.l(j));
rep('q', i,    '1')= Q.l(i);
rep('lam',i,   '1')= lam.l(i);

c(i)$(ord(i)<4)= 1;
solve olig using mcp;
rep('p','mkt', '2')= a-b*sum(j,Q.l(j));
rep('q', i,    '2')= Q.l(i);
rep('lam',i,   '2')= lam.l(i);

cap(i)$(ord(i)<4)=3;
solve olig using mcp;
rep('p','mkt', '3')= a-b*sum(j,Q.l(j));
rep('q', i,    '3')= Q.l(i);
rep('lam',i,   '3')= lam.l(i);

cap('2')=4;
cap('3')=5;
solve olig using mcp;
rep('p','mkt', '4')= a-b*sum(j,Q.l(j));
rep('q', i,    '4')= Q.l(i);
rep('lam',i,   '4')= lam.l(i);

c('4')=1;
cap(i)=3;
solve olig using mcp;
rep('p','mkt', '5')= a-b*sum(j,Q.l(j));
rep('q', i,    '5')= Q.l(i);
rep('lam',i,   '5')= lam.l(i);

c(i)= 2;
solve olig using mcp;
rep('p','mkt', '6')= a-b*sum(j,Q.l(j));
rep('q', i,    '6')= Q.l(i);
rep('lam',i,   '6')= lam.l(i);

option rep:2:2:1
display rep;