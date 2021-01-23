/*Consolidation Report SPA email*/
[select user,
        'ConsolidationSPA-' || to_char(sysdate, 'YYYY-MM-DD-HH24') || '.csv' filename,
        '$LESDIR/log' path
   from dual]
|
[[
def MocaContext ctx = MocaUtils.currentContext(); 
path = MocaUtils.expandEnvironmentVariables(ctx, path); 

// delete existing file 
new File("$path/$filename").delete(); 
]]
|
{
    format data
     where format_mode = 'CSV'
       and command =
    [/*Consolidation Data for SPA Area*/
    [select aremst.arecod Area,
        locmst.stoloc Location,
        locmst.locsts FullEmpty,
        invdtl.prtnum SKU,
        invdtl.invsts InventoryStatus,
        invdtl.untqty QTYOnHand,
        sum(dlytrn.trnqty) QTYShipped
   from aremst
   join locmst
     on aremst.arecod = locmst.arecod
   join invlod
     on invlod.stoloc = locmst.stoloc
   join invsub
     on invlod.lodnum = invsub.lodnum
   join invdtl
     on invdtl.subnum = invsub.subnum
   join dlytrn
     on invdtl.prtnum = dlytrn.prtnum
  where aremst.arecod = 'PCE010'
    and dlytrn.actcod = 'TRLR_LOAD'
    and dlytrn.trndte between to_date(sysdate - 30)
    and to_date(sysdate)
  group by aremst.arecod,
        locmst.stoloc,
        locmst.locsts,
        invdtl.prtnum,
        invdtl.invsts,
        invdtl.untqty
  order by sum(dlytrn.trnqty) desc]]
    |
    write output file
     where mode = 'A'
       and filename = @filename
       and path = @path
       and data = @formated_data
       and newline = 'Y'
} >> res
|
{
    [select rtstr1 email
       from poldat
      where polcod = 'USR-REPORTS'
        and polvar = 'SOLD-SPA'
        and polval = 'EMAIL']
    |
    send email
     where hostname = 'localhost'
       and send_to = @email
       and mail_from = 'no_reply@fedex.com'
       and subject = ' Sold Units in SPA Area Report'
       and message = 'See attachment.'
       and attachment = @path || '/' || @filename
}