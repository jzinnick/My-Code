[select *
   from poldat]
   
excute os command
 where cmd = 'ls;cd log'
 
 execute os command
 where cmd = 'ls;cd log'
 
 read file
 where filename = '/opt/redprarie/LUNA1PRD/les/registry'
 
 read file
 where filename = '/opt/redprarie/LUNA1PRD/les/data/registry'
 
 list job
 
 list job
 where enable = 1
 
 [select min(gendte)
   from inv_snap]
   
   [select stoloc
   from locmst
  where useflg = 1
    and stoflg = 1]
|
validate location
 where stoloc = @stoloc
   and wh_id = 'WMD1'
|

[select stoloc
   from locmst
  where useflg = 1
    and stoflg = 1]
|
validate location
 where stoloc = @stoloc
   and wh_id = 'WMD1'
|
if (@action != '')
{
    execute server command
     where cmd = @action
    |
    commit;
}