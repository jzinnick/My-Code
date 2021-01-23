SELECT CPIToolTestResults_AWRE.UniqueID,
       CPIToolTestResults_AWRE.IMEI,
       CPIToolTestResults_AWRE.UsbSerial,
       CPIToolTestResults_AWRE.Vendor,
       CPIToolTestResults_AWRE.SoftwareVersion,
       CPIToolTestResults_AWRE.Model,
       CPIToolTestResults_AWRE.IMEI2,
       CPIToolTestResults_AWRE.SerialNumber,
       CPIToolTestResults_AWRE.Color,
       CPIToolTestResults_AWRE.Size,
       CPIToolTestResults_AWRE.ActLock,
       CPIToolTestResults_AWRE.MDMLock,
       CPIToolTestResults_AWRE.Pass,
       CPIToolTestResults_AWRE.DateTested,
       CPIToolTestResults_AWRE.Station,
       CPIToolTestResults_AWRE.Port,
       CPIToolTestResults_AWRE.User,
       CPIToolTestResults_AWRE.Manual,
       CPIToolTestResults_AWRE.WindowsUser,
       CPIToolTestResults_AWRE.UserChoice,
       CPIToolTestResults_AWRE.CpiToolVersion,
       CPIToolTestResults_AWRE.AutoTestSecs,
       CPIToolTestResults_AWRE.FullTestSecs,
       CPIToolTestResults_AWRE.ManualTestSecs
FROM (SELECT MAX(CPIToolTestResults_AWRE.UniqueID) AS UniqueID,
             CPIToolTestResults_AWRE.IMEI
      FROM pfprd.CPIToolTestResults_AWRE CPIToolTestResults_AWRE
      WHERE (    CPIToolTestResults_AWRE.DateTested >=
                 LAST_DAY(CURRENT_DATE) + INTERVAL 1 DAY - INTERVAL 1 MONTH
             AND CPIToolTestResults_AWRE.DateTested <
                 LAST_DAY(CURRENT_DATE) + INTERVAL 1 DAY)
      GROUP BY CPIToolTestResults_AWRE.IMEI) sub
     LEFT OUTER JOIN pfprd.CPIToolTestResults_AWRE CPIToolTestResults_AWRE
        ON (sub.UniqueID = CPIToolTestResults_AWRE.UniqueID)
ORDER BY CPIToolTestResults_AWRE.IMEI ASC