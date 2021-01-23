publish data 
 where path = '$LESDIR/log' 
   and filename = 'groupon_daily_trans_<DAY>.csv' 
| 
{ 
    [select dlytrn_id,
        trndte,
        oprcod,
        actcod,
        subnum,
        to_subnum,
        prtnum,
        supnum,
        trnqty,
        traknm,
        fr_arecod,
        frstol,
        to_arecod,
        tostol,
        ship_id,
        ordnum,
        usr_id,
        devcod,
        ins_dt,
        last_upd_dt,
        ins_user_id,
        last_upd_user_id
   from dlytrn
  where trndte between to_date(trunc(sysdate) -1)
    and to_date(trunc(sysdate))
    and ((actcod = 'CASPCK' and fr_arecod = 'RDTS') or (actcod = 'FL_XFR' and fr_arecod = 'RSTG') or actcod = 'IDNTFY' or actcod = 'KITPCK' or actcod = 'PALPCK' or actcod = 'PCEPCK')]
} >> res 
| 
[[ 
// validate res exists on stack and at least has columns 
def MocaContext ctx = MocaUtils.currentContext(); 
if (!ctx.isVariableAvailable("res") || res.getColumnCount() == 0) 
{ 
    throw new RequiredArgumentException("res"); 
} 
 
if (filename == "" || path == "") 
{ 
    MocaResults resultSet = moca.newResults(); 
    def buffer = "[select rtstr1 path," + 
                        " rtstr2 filename" + 
                   " from poldat_view" + 
                  " where polcod = 'USR-REPORTS'" + 
                    " and polvar = @job_id" + 
                    " and polval = 'PATH-FILENAME'" + 
                    " and wh_id = nvl(@wh_id, nvl(@@wh_id, '----'))" + 
                    " and rtnum1 = 1 " + 
                    " and rownum < 2]"; 
    try 
    { 
        resultSet = moca.executeInline(buffer); 
    } 
    catch(MocaException ex) 
    { 
        if (ex.getErrorCode() != -1403) 
        { 
            throw mEx; 
        } 
    } 
    while(resultSet.next()) 
    { 
        if(filename == "") 
            filename = resultSet.getString("filename"); 
        if(path == "") 
            path = resultSet.getString("path"); 
    } 
    resultSet.reset(); 
    resultSet.close(); 
} 
if (filename.contains("<DAY>")) 
{ 
    def current_date = new Date(); 
    def formatted_date = current_date.format("yyMMddHHmm"); 
    filename = filename.replace("<DAY>", formatted_date); 
} 
if (path == "") 
{ 
    path = "\$LESDIR/log"; 
} 
path = MocaUtils.expandEnvironmentVariables(ctx, path); 
 
// delete existing file 
new File('$path/$filename').delete(); 
 
// get result column header and write it out 
def data = ""; 
def i = 0; 
while(i < res.getColumnCount()) 
{ 
    data = data + res.getColumnName(i) + ","; 
    i++; 
} 
def output_file = new File("$path/$filename"); 
data = data.substring(0, data.length() -1); 
output_file.write(data + "\n"); 
 
// for every row, get each value in every column 
res.reset(); 
while(res.next()) 
{ 
    data = ""; 
    i = 0; 
    while(i < res.getColumnCount()) 
    { 
        if(res.getColumnName(i) == 'owner_code') { 
            if(res.getString(i) == null || res.getString(i) == '000') { 
                data = data + '"",'; 
            } 
            else { 
                data = data + '"' + res.getString(i) + '",'; 
            } 
        } 
        else { 
            data = data + '"' + res.getString(i) + '",'; 
        } 
        i++; 
    } 
    data = data.substring(0, data.length() -1); 
    output_file.append(data + "\n"); 
} 
]] 
| 
{ 
    [select rtstr1 email 
       from poldat 
      where polcod = 'USR-REPORTS' 
        and polvar = 'DAILY-TRANS' 
        and polval = 'EMAIL'] 
    | 
    send email 
     where hostname = 'localhost' 
       and send_to = @email 
       and mail_from = 'no_reply@fedex.com' 
       and subject = 'Groupon Daily Trans' 
       and msg = 'Groupon Daily Trans included' 
       and attachment = @path || '/' || @filename 
}