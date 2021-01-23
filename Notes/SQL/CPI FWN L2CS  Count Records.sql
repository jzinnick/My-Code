SELECT COUNT(DISTINCT CPIToolTestResults_FWN_L2CS.IMEI)
          AS CountDistinct_IMEI,
       CPIToolTestResults_FWN_L2CS.Vendor,
       DATE_FORMAT(CPIToolTestResults_FWN_L2CS.DateTested, '%y')
          AS `Date`
FROM pfprd.CPIToolTestResults_FWN_L2CS CPIToolTestResults_FWN_L2CS
GROUP BY CPIToolTestResults_FWN_L2CS.Vendor,
         DATE_FORMAT(CPIToolTestResults_FWN_L2CS.DateTested, '%y')