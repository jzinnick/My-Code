/* 9/3/15 RNS: modified code per CR12918 to display rimhdr.uc_vennam */
[select rl.trknum,
        ia.trndte,
        ri.orgref,
        ia.mod_usr_id,
        ri.po_num,
        ia.prtnum,
        ia.rcvqty,
        rl.rcvsts,
        ri.supnum,
        r.uc_vennam
   from invact ia,
        rimhdr r,
        rcvinv ri,
        rcvlin rl
  where ri.trknum = rl.trknum
    and ri.supnum = rl.supnum
    and ri.invnum = rl.invnum
    and ri.wh_id = rl.wh_id
    and ri.client_id = rl.client_id
    and ri.po_num = r.invnum
    and ri.client_id = r.client_id
    and ri.supnum = r.supnum
    and ri.wh_id = r.wh_id
    and rl.invsln = ia.invsln
    and rl.invlin = ia.invlin
    and rl.invnum = ia.invnum
    and rl.client_id = ia.client_id
    and rl.wh_id = ia.wh_id
    and ia.rcvqty > 0
    and ia.trndte between to_date('20180101000000')
    and to_date('20190101235959')]