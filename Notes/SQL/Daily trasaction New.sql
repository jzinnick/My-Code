[select *
   from dlytrn
  where trndte between to_date('20171010000000')
    and to_date('20171010235959')
    and ((actcod = 'CASPCK' and fr_arecod = 'RDTS') or (actcod = 'FL_XFR' and fr_arecod = 'RSTG') or actcod = 'IDNTFY' or actcod = 'KITPCK' or actcod = 'PALPCK' or actcod = 'PCEPCK')]