publish data
 where wh_id = 'WMD1'
|
[[
import com.redprairie.moca.*;
import com.redprairie.moca.MocaException;
import com.redprairie.moca.MocaResults;
import com.redprairie.moca.util.*;
import com.redprairie.wmd.WMDConstants;
import com.redprairie.moca.web.console.JobInformation;

// Custom PrintReport function - Override standard product ReportServer logic to Optimize network bandwidth and support a offsite ReportServer.
//  This routine prevents the document from being returned to WMS and consuming network bandwidth when ReportServer is not in the same datacenter.
private usrPrintReport(String rpt_id, String printer, String parms)
{
    MocaResults res = moca.newResults();
    
    // Don't usrFixInjection the input "parms" because it contains a where clause statement
    cmd = "publish data where reporting = 1 and is_archive_local = 1 and num_copies = 1 and dest_typ = 'printer' and dest = '" + usrFixInjection(printer) + "' and wh_id = '" + usrFixInjection(wh_id) + "' and gen_usr_id = '" + usrFixInjection(gen_usr_id) + "' and app_srv = '" + usrFixInjection(app_srv) + "' and " + parms + " | [select rpt_id, keep_days from rpt_config where rpt_id = '" + usrFixInjection(rpt_id) + "'] | remote('" + usrFixInjection(service) + "'){generate moca report server report | choose data where columns='archive_id,filename,archive_file,archive_size,keep_days,usr_id,descr,prod_id,dsp_rpt_id'}";
    
    if (is_archive_local) {
        cmd += " | if (@archive_file) { [insert into rpt_archive(rpt_id, descr, app_srv_host, gen_dt, expire_dt, filename, usr_id, file_size, prod_id, parm_val, dsp_rpt_id) values (@rpt_id, @descr, '(local)' , sysdate, sysdate + @keep_days, @archive_file, @usr_id, @archive_size, @prod_id, @parm_val, @dsp_rpt_id)] }";
    }
    
    res = moca.executeCommand(cmd);
}

private usrIsEmpty(String field)
{
    return (field == null || field.trim().length() == 0);
}

private usrIsDisabled(def field)
{
    return (field == null || (field != true && field != 1));
}

private usrFixInjection(def field)
{
    return (usrIsEmpty(field) ? "" : field.replaceAll("'", "''"));
}

private usrWriteLogMessage(def message)
{
    moca.trace(message);
    
    if (enable_logging != null && usrIsDisabled(enable_logging))
        return;
        
    def eol_char = System.getProperty("line.separator");
    def path = MocaUtils.expandEnvironmentVariables(moca, "\$LESDIR" + File.separator + "log");
    
    def filename = "$path" + File.separator + "UC-PRINT-progress-" + new Date().format('yyyy-MM-dd') + ".log";
    
    new File(filename).withWriterAppend { out -> out.println (new Date().format('yyyy-MM-dd HH:mm:ss.SSS') + ": " + message); }
}

def usrPrintDocuments()
{
    usrWriteLogMessage("#");
    usrWriteLogMessage("# Start Execution");
    usrWriteLogMessage("#");
    if (usrIsDisabled(test_mode) = = false) uc_reprint_flg = 1;
        def fld_sql = """distinct 
            pw.wrkref,
            pw.wrktyp,
            pw.wh_id,
            pw.srcloc,
            pw.subnum,
            pw.ordnum,
            substr(pw.srcloc, 1, 1) srcloc_prefix,
            decode((select sum(pw1.pckqty) 
                  from pckwrk_view pw1
                 where pw1.ctnnum = pw.subnum), 1, 0, null, 0, 1) multiple_picks_flg,
            decode((select count(1)
                      from poldat_view pv
                     where pv.polcod = 'USR-PRINTING'
                       and pv.polvar = 'MULTI-PART-ORD'
                       and pv.polval = 'ORDTYP'
                       and pv.wh_id = o.wh_id
                       and pv.rtstr1 = o.ordtyp
                       and pv.rtnum1 = 1), 0, 0, 1) multiple_sku_ordtyp_flg,
            decode(nvl(o.bto_seqnum, 0), 0, 0, 1) multi_qty_so_flg,
            s.carcod,
            s.srvlvl,
            o.ordtyp,
            o.cstms_addl_info,
            pw.ctncod
       from pckwrk_view pw
       join shipment s
         on s.ship_id = pw.ship_id
       join ord o
         on o.ordnum = pw.ordnum
        and o.wh_id = pw.wh_id
        and o.client_id = pw.client_id
    and ((o.ordtyp in ('SO', 'MP') and o.uc_exclude_rate_rs = '0') or (o.ordtyp = 'SO' and o.uc_exclude_rate_rs = '1' and exists(select 'x'
                                                                                                                                   from ord_line ol
                                                                                                                                  where ol.wh_id = o.wh_id
                                                                                                                                    and ol.client_id = o.client_id
                                                                                                                                    and ol.ordnum = o.ordnum
                                                                                                                                 having sum(ol.ordqty) > 1)))
      where (pw.wrktyp = 'K' or exists(select 'x'
                                         from prtftp_dtl pd
                                        where pd.prtnum = pw.prtnum
                                          and pd.prt_client_id = pw.prt_client_id
                                          and pd.wh_id = pw.wh_id
                                          and pd.ftpcod = pw.ftpcod
                                          and pd.uomcod = pw.pck_uom
                                          and pd.ctn_flg = 0))
        and pw.wrktyp in ('P', 'K') """ + (usrIsDisabled(uc_reprint_flg) || (usrIsEmpty(srcloc) && usrIsEmpty(subnum) && usrIsEmpty(ordnum) && usrIsEmpty(carcod) && usrIsEmpty(srvlvl) && usrIsEmpty(ordtyp) && usrIsEmpty(ctncod)) ? """
        and pw.pcksts = 'R'
        and pw.prtdte is null""" : "") + (usrIsEmpty(srcloc) ? "" : " and pw.srcloc = '" + usrFixInjection(srcloc) + "'") + (usrIsEmpty(subnum) ? "" : " and pw.subnum = '" + usrFixInjection(subnum) + "'") + (usrIsEmpty(ordnum) ? "" : " and pw.ordnum = '" + usrFixInjection(ordnum) + "'") + (usrIsEmpty(carcod) ? "" : " and s.carcod = '" + usrFixInjection(carcod) + "'") + (usrIsEmpty(srvlvl) ? "" : " and s.srvlvl = '" + usrFixInjection(srvlvl) + "'") + (usrIsEmpty(ordtyp) ? "" : " and o.ordtyp = '" + usrFixInjection(ordtyp) + "'") + (usrIsEmpty(ctncod) ? "" : " and pw.ctncod = '" + usrFixInjection(ctncod) + "'");
    if (!wh_id) throw new RequiredArgumentException('wh_id');
        MocaResults res = moca.newResults();
        MocaResults returnRes = moca.newResults();
        returnRes.addColumn("sort_id", MocaType.STRING);
        returnRes.addColumn("sort_id_field", MocaType.STRING);
        returnRes.addColumn("print_summary_page", MocaType.INTEGER);
        returnRes.addColumn("wrkref_list", MocaType.STRING);
        returnRes.addColumn("size", MocaType.INTEGER);
        returnRes.addColumn("criteria_dest", MocaType.STRING);
        returnRes.addColumn("queue", MocaType.STRING);
    if (usrIsEmpty(print_job_max_pages)) print_job_max_pages = 2000;
        res = moca.executeCommand("get moca report server information");
        res.next();
    if (service = = null || service = = '') service = res.getString("service");
        app_srv = res.getString("app_srv");
        is_local = res.getString("is_local");
        is_online = res.getString("is_online");
        is_archive_local = res.getString("is_archive_local");
        mocarpt_wh_id = res.getString("mocarpt_wh_id");
        ena_ems_flg = res.getString("ena_ems_flg");
        res = moca.executeSQL("""select distinct rtstr1 gen_usr_id,
                rtstr2 locale_id
           from poldat_view p
          where polcod = 'USR-PRINTING'
            and polvar = 'JOB'
            and polval = 'GEN-USR-ID'
            and wh_id = :wh_id
            and not exists(select 'x'
                             from poldat_view p1
                            where p1.polcod = 'USR-PRINTING'
                              and p1.polvar = 'JOB'
                              and p1.polval = 'MAINTENANCE-WINDOW'
                              and p1.wh_id = p.wh_id
                              and p1.rtnum1 = 1
                              and p1.rtflt1 <= ((sysdate - trunc(sysdate)) * 24)
                              and p1.rtflt2 > ((sysdate - trunc(sysdate)) * 24))
            and rownum < 2""", new MocaArgument("wh_id", wh_id));
        res.next();
        gen_usr_id = res.getString("gen_usr_id");
        locale_id = res.getString("locale_id");
        def match_only_dest = false;
    if (usrIsEmpty(dest) = = false)
    {
        try
        { / / rtnum2 must be set in addition to dest being passed. / / This forces the policy configuration to confirm that a seperate job(thread) will be used. moca.executeSQL("""select rtstr1
                   from poldat_view
                  where polcod = 'USR-PRINTING'
                    and polvar = 'JOB'
                    and polval = 'THREAD-CRITERIA'
                    and wh_id = :wh_id
                    and rtnum1 = 1
                    and rtnum2 = 1
                    and rtstr2 = :dest""", new MocaArgument("wh_id", wh_id), new MocaArgument("dest", dest));
            match_only_dest = true;
        } catch(NotFoundException e)
        { / / Ignore
        }
    }
    def fld_case = "";
    def default_dest = "";
    try
    {
        res = moca.executeSQL("""select rtstr1
               from poldat_view
              where polcod = 'USR-PRINTING'
                and polvar = 'JOB'
                and polval = 'DEFAULT-PRINTER'
                and wh_id = :wh_id
                and rtnum1 = 1""", new MocaArgument("wh_id", wh_id));
        res.next();
        default_dest = res.getString("rtstr1");
    } catch(NotFoundException e)
    { / / Ignore
    }
    try
    {
        res = moca.executeSQL("""select 'when (' || rtstr1 || ') then ''' || nvl(trim(rtstr2), '""" + default_dest + """') || '''' retstr,
                    rtstr1,
                    rtstr2
               from poldat_view
              where polcod = 'USR-PRINTING'
                and polvar = 'JOB'
                and polval = 'THREAD-CRITERIA'
                and wh_id = :wh_id
                and rtnum1 = 1
              order by srtseq""", new MocaArgument("wh_id", wh_id));
        fld_case = "case";
        while(res.next())
        {
            if (res.isNull("rtstr1"))
            {
                if (!res.isNull("rtstr2"))
                {
                    default_dest = res.getString("rtstr2");
                }
            }
            else
            {
                fld_case + = " " + res.getString("retstr");
            }
        }
    } catch(NotFoundException e)
    { / / Ignore
    }
    if (fld_case.length() = = 0)
    {
        fld_case = "'" + default_dest + "'";
    }
    else
    {
        fld_case = "/*#nobind*/" + fld_case.replaceAll("then ''", "then '" + default_dest + "'") + " else '" + default_dest + "' end/*#bind*/";
    }
    MocaResults resLocs;
    try
    {
        def sqlcmd = """select *
           from (select sort_id,
                        sort_id_field,
                        decode(multi_qty_so_flg, 1, 1, print_summary_page) print_summary_page,
                        wh_id,
                        """ + fld_case + """ criteria_dest,
                        count(1) cnt
                   from (select """ + (usrIsEmpty(pckwrk_order_by) ? "decode(multiple_sku_ordtyp_flg, '1', ordnum, srcloc)" : pckwrk_order_by) + """ sort_id,
                                """ + (usrIsEmpty(pckwrk_order_by) ? "decode(multiple_sku_ordtyp_flg, '1', 'ordnum', 'srcloc')" : "'" + pckwrk_order_by + "'") + """ sort_id_field,
                                """ + (print_summary_page = = null ? "decode(multiple_sku_ordtyp_flg, '0', decode(multiple_picks_flg, '0', 1, 0), 0)" :(usrIsDisabled(print_summary_page) ? 0 : 1)) + """ print_summary_page,
                                tmp3.*
                           from (select """ + fld_sql + """) tmp3) tmp2
                  group by sort_id,
                        sort_id_field,
                        multi_qty_so_flg,
                        print_summary_page,
                        wh_id,
                        """ + fld_case + """) tmp
          where not exists(select 'x'
                             from poldat_view
                            where polcod = 'USR-PRINTING'
                              and polvar = 'JOB'
                              and polval = 'THREAD-CRITERIA'
                              and wh_id = tmp.wh_id
                              and rtnum1 = 1
                              and rtnum2 = 1
                              and rtstr2 = tmp.criteria_dest""" + (usrIsEmpty(dest) ? "" : " and rtstr2 != '" + usrFixInjection(dest) + "'") + ")" + (usrIsEmpty(dest) || !match_only_dest ? "" : " and criteria_dest = '" + usrFixInjection(dest) + "'") + " order by sort_id" resLocs = moca.executeSQL(sqlcmd);
    } catch(MocaException ex)
    {
        usrWriteLogMessage("###");
        usrWriteLogMessage("### ERR: Finding records to print " + ex.getErrorCode());
        usrWriteLogMessage("###");
        throw ex;
    }
    while(resLocs.next())
    { / / sort_id and sort_id_field must pertain to columns from pckwrk_view sort_id = resLocs.getString("sort_id");
        sort_id_field = resLocs.getString("sort_id_field");
        print_summary_page = resLocs.getInt("print_summary_page");
        wh_id = resLocs.getString("wh_id");
        criteria_dest = resLocs.getString("criteria_dest");
        usrWriteLogMessage("SortID ($sort_id_field): $sort_id");
        def out = [];
        def print_seperate_summary = (usrIsEmpty(summary_rpt_id) ? 0 : 1);
        def printerDest = (usrIsEmpty(dest) ? criteria_dest : dest);
        MocaResults resWrkref;
        try
        {
            resWrkref = moca.executeSQL("""select ph.wrkref,
                        ph.wrktyp
                   from pckwrk_hdr ph
                  where ph.wrkref in (select wrkref
                                        from (select """ + fld_sql + """
                                                 and pw.""" + usrFixInjection(sort_id_field) + " = '" + usrFixInjection(sort_id) + """') tmp
                                       where """ + fld_case + """ = '""" + usrFixInjection(criteria_dest) + """')
                    and ph.wrktyp in ('P', 'K') """ + (usrIsDisabled(uc_reprint_flg) ? """
                    and ph.pcksts = 'R'
                    and ph.prtdte is null""" : "") + """
                  order by ph.wrkref
                  for update of ph.wrkref """ + (uc_reprint_flg = = 1 ? '' : 'nowait'));
        } catch(MocaException ex)
        {
            usrWriteLogMessage("###");
            usrWriteLogMessage("### ERR: Error geting work: " + ex.getErrorCode());
            usrWriteLogMessage("###");
            if (ex.getErrorCode() = = -54) / / Ingnore NOWAIT errors continue;
            if (ex.getErrorCode() = = -1403) / / Ingnore NoDataFound errors continue;
                throw ex;
        }
        try
        {
            while(resWrkref.next())
            {
                out << resWrkref.wrkref;
                if (resWrkref.hasNext() && out.size() < print_job_max_pages) continue;
                    def wrkref_list = out.join(",");
                    usrWriteLogMessage(" Queue: $printerDest (print summary: $print_summary_page" + (usrIsDisabled(uc_reprint_flg) ? "" : ", reprint mode enabled") + ") wrkref list: $wrkref_list");
                if (usrIsDisabled(test_mode))
                {
                    def wrkref_list_where_sql = "wrkref in ('" + out.join("','") + "')"; / / Need to update to re - aquire the lock released by the 'commit' further down when looping. moca.executeCommand("[update pckwrk_hdr " + "    set wrkref = wrkref," + "        devcod = decode(prtdte, null, '" + printerDest.substring(Math.max(0, printerDest.length() - 20)) + "', devcod), " + "        prtdte = nvl(prtdte, sysdate)" + " where " + wrkref_list_where_sql + "]");
                    if (print_seperate_summary = = 1)
                    {
                        usrWriteLogMessage(" Printing Seperate Summary ($summary_rpt_id)");
                        usrPrintReport(summary_rpt_id, printerDest, usrFixInjection(sort_id_field) + " = '" + usrFixInjection(sort_id) + "'");
                        print_seperate_summary = 0;
                    }
                    usrPrintReport((usrIsEmpty(rpt_id) ? "Usr-GRPN-PackSlip" : rpt_id), printerDest, "wrkref_list = '" + wrkref_list + "' and print_summary_page = '" + (usrIsDisabled(print_summary_page) ? "0" : "1") + "' and print_summary_by = '" + (usrIsEmpty(print_summary_by) ? usrFixInjection(sort_id_field) : print_summary_by) + "'");
                    usrWriteLogMessage("  Printing Complete");
                    moca.executeCommand("[commit]");
                }
                else
                {
                    usrWriteLogMessage(" TEST MODE - (print summary: $print_summary_page" + (usrIsDisabled(uc_reprint_flg) ? "" : ", reprint mode enabled") + ")" + (print_seperate_summary = = 1 ? " Printing Seperate Summary ($summary_rpt_id)" : ""));
                }
                returnRes.addRow();
                returnRes.setStringValue("sort_id", sort_id);
                returnRes.setStringValue("sort_id_field", sort_id_field);
                returnRes.setIntValue("print_summary_page", print_summary_page);
                returnRes.setStringValue("wrkref_list", wrkref_list);
                returnRes.setIntValue("size", out.size());
                returnRes.setStringValue("criteria_dest", criteria_dest);
                returnRes.setStringValue("queue", printerDest);
                out = [];
            }
        } catch(MocaException ex)
        {
            usrWriteLogMessage("   ###");
            usrWriteLogMessage("   ### ERR: Error printing ($printerDest): " + ex.getErrorCode());
            if (ex.getErrorCode() = = 809)
            {
                usrWriteLogMessage("   ### 809 TEMP FIX, commiting.");
                moca.executeCommand("[commit]");
                continue;
            }
            moca.executeCommand("[rollback]");
            if (ex.getErrorCode() = = 518) / / Fail on RPT server unavailable errors break;
                continue;
        }
    }
    return returnRes;
}
usrPrintDocuments();
]]
