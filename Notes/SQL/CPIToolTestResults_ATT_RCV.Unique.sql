SELECT CPIToolTestResults_ATT_RCV.UniqueID,
       CPIToolTestResults_ATT_RCV.IMEI,
       CPIToolTestResults_ATT_RCV.UsbSerial,
       CPIToolTestResults_ATT_RCV.Vendor,
       CPIToolTestResults_ATT_RCV.SoftwareVersion,
       CPIToolTestResults_ATT_RCV.Model,
       CPIToolTestResults_ATT_RCV.Color,
       CPIToolTestResults_ATT_RCV.Size,
       CPIToolTestResults_ATT_RCV.ActLock,
       CPIToolTestResults_ATT_RCV.MDMLock,
       CPIToolTestResults_ATT_RCV.Pass,
       CPIToolTestResults_ATT_RCV.DateTested,
       CPIToolTestResults_ATT_RCV.Station,
       CPIToolTestResults_ATT_RCV.Port,
       CPIToolTestResults_ATT_RCV.User,
       CPIToolTestResults_ATT_RCV.Manual,
       CPIToolTestResults_ATT_RCV.WindowsUser,
       CPIToolTestResults_ATT_RCV.CpiToolVersion,
       CPIToolTestResults_ATT_RCV.AutoTestSecs,
       CPIToolTestResults_ATT_RCV.FullTestSecs,
       CPIToolTestResults_ATT_RCV.ManualTestSecs
FROM (SELECT MAX(CPIToolTestResults_ATT_RCV.UniqueID) AS UniqueID,
             CPIToolTestResults_ATT_RCV.IMEI
      FROM pfprd.CPIToolTestResults_ATT_RCV CPIToolTestResults_ATT_RCV
      WHERE (    CPIToolTestResults_ATT_RCV.DateTested >=
                 LAST_DAY(CURRENT_DATE) + INTERVAL 1 DAY - INTERVAL 1 MONTH
             AND CPIToolTestResults_ATT_RCV.DateTested <
                 LAST_DAY(CURRENT_DATE) + INTERVAL 1 DAY)
      GROUP BY CPIToolTestResults_ATT_RCV.IMEI) sub
     LEFT OUTER JOIN pfprd.CPIToolTestResults_ATT_RCV CPIToolTestResults_ATT_RCV
        ON (sub.UniqueID = CPIToolTestResults_ATT_RCV.UniqueID)
ORDER BY CPIToolTestResults_ATT_RCV.IMEI ASC
