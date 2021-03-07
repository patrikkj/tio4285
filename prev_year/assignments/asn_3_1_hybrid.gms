*THIS IS A HYBRID COMPETITION MODEL.
*PRODNETT ASSIGNMENT 2020 set 6.1 - Equil Mod 3.1

set i /'D','F'/;
alias (i,j)
positive variable Q(i);
parameter a /100/
          b /2/
          c(i)  /'D' 10 ,'F' 20/
          d(i)  /'D'  .5,'F'  1/
          cv(i) /'D'  1,'F'  0 /
          rep
          p
;
equations stat_q
;
stat_q(i) .. c(i)+2*d(i)*Q(i) =G= a-b*(sum(j,Q(j))+cv(i)*Q(i))
;

model dom /stat_q.Q/;
solve dom using mcp;

parameter mr(i), mc(i), p;

$SETGLOBAL run lcp

p=a - b*sum(j,Q.l(j));
rep('q','%run%',i)=          Q.l(i);
rep('price','%run%','TOT')=  p;
rep('MC','%run%',i)=         c(i)+2*d(i)*Q.l(i);
rep('MR','%run%',i)=         a - b*(sum(j,Q.l(j))+cv(i)*Q.l(i));
rep('profit','%run%',i)=     (p-(c(i)+d(i)*Q.l(i)))*Q.l(i);

display rep;
