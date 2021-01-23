SELECT CPIToolTestResults_AWRE_RECV.IMEI,
       CPIToolTestResults_AWRE_RECV.UniqueID,
       CPIToolTestResults_AWRE_RECV.UsbSerial,
       CPIToolTestResults_AWRE_RECV.Vendor,
       CPIToolTestResults_AWRE_RECV.Model,
       CPIToolTestResults_AWRE_RECV.SoftwareVersion,
       CPIToolTestResults_AWRE_RECV.IMEI2,
       CPIToolTestResults_AWRE_RECV.SerialNumber,
       CPIToolTestResults_AWRE_RECV.ConfigCode,
       CPIToolTestResults_AWRE_RECV.ICCID,
       CPIToolTestResults_AWRE_RECV.Carrier,
       CPIToolTestResults_AWRE_RECV.CsnCsn2Eid,
       CPIToolTestResults_AWRE_RECV.Color,
       CPIToolTestResults_AWRE_RECV.Size,
       CPIToolTestResults_AWRE_RECV.ActLock,
       CPIToolTestResults_AWRE_RECV.MDMLock,
       CPIToolTestResults_AWRE_RECV.Pass,
	   CPIToolTestResults_AWRE_RECV.DateTested,
       CPIToolTestResults_AWRE_RECV.AuxTableId,
       CPIToolTestResults_AWRE_RECV.Station,
       CPIToolTestResults_AWRE_RECV.Port,
       CPIToolTestResults_AWRE_RECV.User,
       CPIToolTestResults_AWRE_RECV.WindowsUser,
       CPIToolTestResults_AWRE_RECV.Manual,
       CPIToolTestResults_AWRE_RECV.CpiToolVersion,
       CPIToolTestResults_AWRE_RECV.AutoTestSecs,
       CPIToolTestResults_AWRE_RECV.FullTestSecs,
       CPIToolTestResults_AWRE_RECV.ManualTestSecs
FROM
  (SELECT MAX(CPIToolTestResults_AWRE_RECV.UniqueID) AS UniqueID,
          CPIToolTestResults_AWRE_RECV.IMEI
    FROM pfprd.CPIToolTestResults_AWRE_RECV CPIToolTestResults_AWRE_RECV
    WHERE (    CPIToolTestResults_AWRE_RECV.DateTested >=
           LAST_DAY(CURRENT_DATE) + INTERVAL 1 DAY - INTERVAL 1 MONTH
       AND CPIToolTestResults_AWRE_RECV.DateTested <
           LAST_DAY(CURRENT_DATE) + INTERVAL 1 DAY)
  GROUP BY CPIToolTestResults_AWRE_RECV.IMEI) AS sub
LEFT JOIN
 pfprd.CPIToolTestResults_AWRE_RECV ON sub.UniqueID = CPIToolTestResults_AWRE_RECV.UniqueID
 ORDER BY CPIToolTestResults_AWRE_RECV.IMEI