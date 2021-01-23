SELECT Log.`Timestamp`,
       Log.Category,
       Log.UsbSerial,
       Log.IMEI,
       Log.OEM,
       Log.Model,
       Log.SWVersion,
       SUBSTRING_INDEX(Station, " : ", 1)
          AS `'Station'`,
       REVERSE(SUBSTRING_INDEX(REVERSE(Station), " : ", 1))
          AS `'IQToolVersion'`,
       Log.`Index`
          AS `'USBPort'`,
       Log.UserName,
       CASE WHEN Log.SessionID IS NULL THEN '-1' END
          AS SessionPass
FROM pfprd.Log Log
WHERE (    (    `Timestamp` BETWEEN DATE_SUB(Now(), INTERVAL 30 DAY)
                                AND NOW()
            AND `Group` LIKE 'AWRE_RECV%')
       AND Role LIKE 'Clear')
UNION
SELECT CPIToolTestResults_FWN_L2CS.DateTested,
       CPIToolTestResults_FWN_L2CS.FailureCategory,
       CPIToolTestResults_FWN_L2CS.UsbSerial,
       CPIToolTestResults_FWN_L2CS.IMEI,
       CPIToolTestResults_FWN_L2CS.Vendor,
       CPIToolTestResults_FWN_L2CS.Model,
       CPIToolTestResults_FWN_L2CS.SoftwareVersion,
       CPIToolTestResults_FWN_L2CS.Station,
       CPIToolTestResults_FWN_L2CS.CpiToolVersion,
       CPIToolTestResults_FWN_L2CS.Port,
       CPIToolTestResults_FWN_L2CS.User,
       CPIToolTestResults_FWN_L2CS.Pass
FROM pfprd.CPIToolTestResults_FWN_L2CS CPIToolTestResults_FWN_L2CS
WHERE `DateTested` BETWEEN DATE_SUB(Now(), INTERVAL 30 DAY) AND NOW()