[select inventory_view.prtnum,
        inventory_view.stoloc,
        prtmst.untcst,
        usr_grpn_inv_snap_lpn.lngdsc
   from prtmst,
        inventory_view,
        usr_grpn_inv_snap_lpn
  where (inventory_view.prtnum = prtmst.prtnum)
    and (inventory_view.prtnum = usr_grpn_inv_snap_lpn.prtnum)
    and (inventory_view.stoloc not like 'TRL%')]