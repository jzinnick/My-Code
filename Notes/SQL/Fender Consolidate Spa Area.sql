/*Open orders email*/
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
    [/*Open order list*/
	[select aremst.arecod,
        locmst.stoloc,
        locmst.locsts,
        invdtl.prtnum,
        invdtl.invsts,
        invdtl.untqty
   from aremst
   join locmst
     on aremst.arecod = locmst.arecod
   join invlod
     on invlod.stoloc = locmst.stoloc
   join invsub
     on invlod.lodnum = invsub.lodnum
   join invdtl
     on invdtl.subnum = invsub.subnum
  where aremst.arecod = 'PCE010'
  order by invdtl.prtnum]
	]
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
    send email
     where hostname = 'localhost'
       and send_to = 'john.zinnick@fedex.com'
       and mail_from = 'no_reply@fedex.com'
       and subject = @user || ' Consolidation SPA Report'
       and message = 'See attachment.'
       and attachment = @path || '/' || @filename
}