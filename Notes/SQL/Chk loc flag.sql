[select stoloc,
stoflg,
repflg,
useflg,
pckflg
from locmst
where (stoflg = '0' or repflg = '0' or useflg = '0'or pckflg = '0')
and stoloc like '1%']