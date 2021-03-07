*THIS IS A DOMINANT FIRM MODEL
*PRODNETT ASSIGNMENT 2020 set 6.2 - Equil Mod 3.2
*AND ALSO TO MICRO EXAM DEC 2017

set i /'D','F'/;
alias (i,j);
parameter a      /100/
          b      /2/
          c(i)  /'D' 10 , 'F' 20/
          d(i)  /'D'  .5, 'F'  1/
          rep(*,*,*)
          p
          q(i)
;
positive variable Q_D;
variable Z;
equations def_z, stat_q;

def_z .. Z =E=  (c('D')-a+(b*(a-c('F'))/(b+2*d('F'))))*Q_D
               +(d('D')+b-b*b/(b+2*d('F')))*Q_D*Q_D
;
stat_q ..
         c('D')-a+b*(a-c('F'))/(b+2*d('F'))
         +2*(d('D')+b-b*b/(b+2*d('F')))*Q_D
         =G=0
;
model dom_opt /def_z/;
model dom_lcp /stat_q.Q_D/;

solve dom_opt min Z using qcp;
$SETGLOBAL run opt

q('D')=Q_D.l;
q('F')=(a-c('F')-b*Q_D.l)/(b+2*d('F'));
p=a - b*sum(j,q(j));

rep('q','%run%',i)=          q(i);
rep('price','%run%','TOT')=  p;
rep('MC','%run%',i)=         c(i)+2*d(i)*q(i);
rep('profit','%run%',i)=     (p-(c(i)+d(i)*q(i)))*q(i);

*MR more complicated because D realizes that F will reduce its supply
*So this gives the wrong result: rep('MR','D','%run%')=a - b*(sum(j,q(j))+q('D'));

solve dom_lcp using mcp;
$SETGLOBAL run lcp

q('D')=Q_D.l;
q('F')=(a-c('F')-b*Q_D.l)/(b+2*d('F'));

rep('q','%run%',i)=          q(i);
rep('price','%run%','TOT')=  a - b*sum(j,q(j));
rep('MC','%run%',i)=         c(i)+2*d(i)*q(i);
rep('profit','%run%',i)=     (p-(c(i)+d(i)*q(i)))*q(i);

display rep;
