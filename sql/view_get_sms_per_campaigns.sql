CREATE VIEW dbo.Fimainfo_FullFilSMS_Supervision_campaigns_Vistalid AS
WITH
	Categories AS (
		SELECT
			'PROSPECTION' AS CampaignDisplayName
		UNION ALL
		SELECT
			'LIVRAISON'
		UNION ALL
		SELECT
			'APPEL SUIVI'
		UNION ALL
		SELECT
			'RENOUVELLEMENT'
		UNION ALL
		SELECT
			'RECRUTEMENT (RH)'
	),
	Stats AS (
		SELECT
			CASE
				WHEN c.campagne_nom LIKE 'PROSPECT%' THEN 'PROSPECTION'
				WHEN c.campagne_nom LIKE 'LIVR%' THEN 'LIVRAISON'
				WHEN c.campagne_nom LIKE 'APPEL%' THEN 'APPEL SUIVI'
				WHEN c.campagne_nom LIKE 'RENOUV%' THEN 'RENOUVELLEMENT'
				WHEN c.campagne_nom LIKE 'RECRUT%' THEN 'RECRUTEMENT (RH)'
				ELSE 'AUTRE'
			END AS CampaignDisplayName,
			SUM(
				CASE
					WHEN f.SEND_DATE = CONVERT(VARCHAR(8), GETDATE (), 112) THEN 1
					ELSE 0
				END
			) AS CountToday,
			SUM(
				CASE
					WHEN DATEPART (ISO_WEEK, f.SEND_DATE) = DATEPART (ISO_WEEK, GETDATE ())
					AND DATEPART (YEAR, f.SEND_DATE) = DATEPART (YEAR, GETDATE ()) THEN 1
					ELSE 0
				END
			) AS CountCurrentWeek,
			SUM(
				CASE
					WHEN LEFT (f.SEND_DATE, 6) = CONVERT(VARCHAR(6), GETDATE (), 112) THEN 1
					ELSE 0
				END
			) AS CountCurrentMonth,
			SUM(
				CASE
					WHEN LEFT (f.SEND_DATE, 6) = CONVERT(VARCHAR(6), DATEADD (MONTH, -1, GETDATE ()), 112) THEN 1
					ELSE 0
				END
			) AS CountPreviousMonth,
			SUM(
				CASE
					WHEN LEFT (f.SEND_DATE, 6) >= CONVERT(VARCHAR(6), DATEADD (MONTH, -2, GETDATE ()), 112) THEN 1
					ELSE 0
				END
			) AS CountLast3Months,
			SUM(
				CASE
					WHEN LEFT (f.SEND_DATE, 4) = CONVERT(VARCHAR(4), GETDATE (), 112) THEN 1
					ELSE 0
				END
			) AS CountCurrentYear,
			SUM(
				CASE
					WHEN LEFT (f.SEND_DATE, 4) = CONVERT(VARCHAR(4), DATEADD (YEAR, -1, GETDATE ()), 112) THEN 1
					ELSE 0
				END
			) AS CountPreviousYear,
			SUM(
				CASE
					WHEN f.SEND_DATE = CONVERT(VARCHAR(8), GETDATE (), 112) THEN ISNULL (f.sms_count, 1)
					ELSE 0
				END
			) AS SmsCountToday,
			SUM(
				CASE
					WHEN DATEPART (ISO_WEEK, f.SEND_DATE) = DATEPART (ISO_WEEK, GETDATE ())
					AND DATEPART (YEAR, f.SEND_DATE) = DATEPART (YEAR, GETDATE ()) THEN ISNULL (f.sms_count, 1)
					ELSE 0
				END
			) AS SmsCountCurrentWeek,
			SUM(
				CASE
					WHEN LEFT (f.SEND_DATE, 6) = CONVERT(VARCHAR(6), GETDATE (), 112) THEN ISNULL (f.sms_count, 1)
					ELSE 0
				END
			) AS SmsCountCurrentMonth,
			SUM(
				CASE
					WHEN LEFT (f.SEND_DATE, 6) = CONVERT(VARCHAR(6), DATEADD (MONTH, -1, GETDATE ()), 112) THEN ISNULL (f.sms_count, 1)
					ELSE 0
				END
			) AS SmsCountPreviousMonth,
			SUM(
				CASE
					WHEN LEFT (f.SEND_DATE, 6) >= CONVERT(VARCHAR(6), DATEADD (MONTH, -2, GETDATE ()), 112) THEN ISNULL (f.sms_count, 1)
					ELSE 0
				END
			) AS SmsCountLast3Months,
			SUM(
				CASE
					WHEN LEFT (f.SEND_DATE, 4) = CONVERT(VARCHAR(4), GETDATE (), 112) THEN ISNULL (f.sms_count, 1)
					ELSE 0
				END
			) AS SmsCountCurrentYear,
			SUM(
				CASE
					WHEN LEFT (f.SEND_DATE, 4) = CONVERT(VARCHAR(4), DATEADD (YEAR, -1, GETDATE ()), 112) THEN ISNULL (f.sms_count, 1)
					ELSE 0
				END
			) AS SmsCountPreviousYear
		FROM
			dbo.FULLFILMENT_SMS AS f
			INNER JOIN CRCLONSQL.HN_VISTALID.dbo.campagnes AS c ON f.did_campaign = c.campagne_did
		WHERE
			f.SENT IN ('Y', 'E', 'S', 'R', 'T', 'A', 'Z', 'B')
			AND f.id_customer = 30
			AND (
				c.campagne_nom LIKE 'PROSPECT%'
				OR c.campagne_nom LIKE 'LIVR%'
				OR c.campagne_nom LIKE 'APPEL%'
				OR c.campagne_nom LIKE 'RENOUV%'
				OR c.campagne_nom LIKE 'RECRUT%'
			)
		GROUP BY
			CASE
				WHEN c.campagne_nom LIKE 'PROSPECT%' THEN 'PROSPECTION'
				WHEN c.campagne_nom LIKE 'LIVR%' THEN 'LIVRAISON'
				WHEN c.campagne_nom LIKE 'APPEL%' THEN 'APPEL SUIVI'
				WHEN c.campagne_nom LIKE 'RENOUV%' THEN 'RENOUVELLEMENT'
				WHEN c.campagne_nom LIKE 'RECRUT%' THEN 'RECRUTEMENT (RH)'
				ELSE 'AUTRE'
			END
	)
SELECT
	30 AS id_customer,
	cat.CampaignDisplayName,
	ISNULL (s.CountToday, 0) AS CountToday,
	ISNULL (s.CountCurrentWeek, 0) AS CountCurrentWeek,
	ISNULL (s.CountCurrentMonth, 0) AS CountCurrentMonth,
	ISNULL (s.CountPreviousMonth, 0) AS CountPreviousMonth,
	ISNULL (s.CountLast3Months, 0) AS CountLast3Months,
	ISNULL (s.CountCurrentYear, 0) AS CountCurrentYear,
	ISNULL (s.CountPreviousYear, 0) AS CountPreviousYear,
	ISNULL (s.SmsCountToday, 0) AS SmsCountToday,
	ISNULL (s.SmsCountCurrentWeek, 0) AS SmsCountCurrentWeek,
	ISNULL (s.SmsCountCurrentMonth, 0) AS SmsCountCurrentMonth,
	ISNULL (s.SmsCountPreviousMonth, 0) AS SmsCountPreviousMonth,
	ISNULL (s.SmsCountLast3Months, 0) AS SmsCountLast3Months,
	ISNULL (s.SmsCountCurrentYear, 0) AS SmsCountCurrentYear,
	ISNULL (s.SmsCountPreviousYear, 0) AS SmsCountPreviousYear
FROM
	Categories AS cat
	LEFT OUTER JOIN Stats AS s ON cat.CampaignDisplayName = s.CampaignDisplayName;

-- -------------------------------------------------------------------------------
-- -------------------------------------------------------------------------------
WITH
	Categories AS (
		SELECT
			'PROSPECTION' AS CampaignDisplayName
		UNION ALL
		SELECT
			'LIVRAISON' AS Expr1
		UNION ALL
		SELECT
			'APPEL SUIVI' AS Expr1
		UNION ALL
		SELECT
			'RENOUVELLEMENT' AS Expr1
		UNION ALL
		SELECT
			'RECRUTEMENT (RH)' AS Expr1
	),
	Stats AS (
		SELECT
			CASE
				WHEN c.campagne_nom LIKE 'PROSPECT%' THEN 'PROSPECTION'
				WHEN c.campagne_nom LIKE 'LIVR%' THEN 'LIVRAISON'
				WHEN c.campagne_nom LIKE 'APPEL%' THEN 'APPEL SUIVI'
				WHEN c.campagne_nom LIKE 'RENOUV%' THEN 'RENOUVELLEMENT'
				WHEN c.campagne_nom LIKE 'RECRUT%' THEN 'RECRUTEMENT (RH)'
				ELSE 'AUTRE'
			END AS CampaignDisplayName,
			SUM(
				CASE
					WHEN f.SEND_DATE = CONVERT(VARCHAR(8), GETDATE (), 112) THEN 1
					ELSE 0
				END
			) AS CountToday,
			SUM(
				CASE
					WHEN DATEPART (ISO_WEEK, f.SEND_DATE) = DATEPART (ISO_WEEK, GETDATE ())
					AND DATEPART (YEAR, f.SEND_DATE) = DATEPART (YEAR, GETDATE ()) THEN 1
					ELSE 0
				END
			) AS CountCurrentWeek,
			SUM(
				CASE
					WHEN LEFT (f.SEND_DATE, 6) = CONVERT(VARCHAR(6), GETDATE (), 112) THEN 1
					ELSE 0
				END
			) AS CountCurrentMonth,
			SUM(
				CASE
					WHEN LEFT (f.SEND_DATE, 6) = CONVERT(VARCHAR(6), DATEADD (MONTH, - 1, GETDATE ()), 112) THEN 1
					ELSE 0
				END
			) AS CountPreviousMonth,
			SUM(
				CASE
					WHEN LEFT (f.SEND_DATE, 6) >= CONVERT(VARCHAR(6), DATEADD (MONTH, - 2, GETDATE ()), 112) THEN 1
					ELSE 0
				END
			) AS CountLast3Months,
			SUM(
				CASE
					WHEN LEFT (f.SEND_DATE, 4) = CONVERT(VARCHAR(4), GETDATE (), 112) THEN 1
					ELSE 0
				END
			) AS CountCurrentYear,
			SUM(
				CASE
					WHEN LEFT (f.SEND_DATE, 4) = CONVERT(VARCHAR(4), DATEADD (YEAR, - 1, GETDATE ()), 112) THEN 1
					ELSE 0
				END
			) AS CountPreviousYear,
			SUM(
				CASE
					WHEN f.SEND_DATE = CONVERT(VARCHAR(8), GETDATE (), 112) THEN ISNULL (f.sms_count, 1)
					ELSE 0
				END
			) AS SmsCountToday,
			SUM(
				CASE
					WHEN DATEPART (ISO_WEEK, f.SEND_DATE) = DATEPART (ISO_WEEK, GETDATE ())
					AND DATEPART (YEAR, f.SEND_DATE) = DATEPART (YEAR, GETDATE ()) THEN ISNULL (f.sms_count, 1)
					ELSE 0
				END
			) AS SmsCountCurrentWeek,
			SUM(
				CASE
					WHEN LEFT (f.SEND_DATE, 6) = CONVERT(VARCHAR(6), GETDATE (), 112) THEN ISNULL (f.sms_count, 1)
					ELSE 0
				END
			) AS SmsCountCurrentMonth,
			SUM(
				CASE
					WHEN LEFT (f.SEND_DATE, 6) = CONVERT(VARCHAR(6), DATEADD (MONTH, - 1, GETDATE ()), 112) THEN ISNULL (f.sms_count, 1)
					ELSE 0
				END
			) AS SmsCountPreviousMonth,
			SUM(
				CASE
					WHEN LEFT (f.SEND_DATE, 6) >= CONVERT(VARCHAR(6), DATEADD (MONTH, - 2, GETDATE ()), 112) THEN ISNULL (f.sms_count, 1)
					ELSE 0
				END
			) AS SmsCountLast3Months,
			SUM(
				CASE
					WHEN LEFT (f.SEND_DATE, 4) = CONVERT(VARCHAR(4), GETDATE (), 112) THEN ISNULL (f.sms_count, 1)
					ELSE 0
				END
			) AS SmsCountCurrentYear,
			SUM(
				CASE
					WHEN LEFT (f.SEND_DATE, 4) = CONVERT(VARCHAR(4), DATEADD (YEAR, - 1, GETDATE ()), 112) THEN ISNULL (f.sms_count, 1)
					ELSE 0
				END
			) AS SmsCountPreviousYear
		FROM
			dbo.FULLFILMENT_SMS AS f
			INNER JOIN CRCLONSQL.HN_VISTALID.dbo.campagnes AS c ON f.did_campaign = c.campagne_did
		WHERE
			(
				f.SENT IN ('Y', 'E', 'S', 'R', 'T', 'A', 'Z', 'B')
			)
			AND (f.id_customer = 30)
			AND (
				c.campagne_nom LIKE 'PROSPECT%'
				OR c.campagne_nom LIKE 'LIVR%'
				OR c.campagne_nom LIKE 'APPEL%'
				OR c.campagne_nom LIKE 'RENOUV%'
				OR c.campagne_nom LIKE 'RECRUT%'
			)
		GROUP BY
			CASE
				WHEN c.campagne_nom LIKE 'PROSPECT%' THEN 'PROSPECTION'
				WHEN c.campagne_nom LIKE 'LIVR%' THEN 'LIVRAISON'
				WHEN c.campagne_nom LIKE 'APPEL%' THEN 'APPEL SUIVI'
				WHEN c.campagne_nom LIKE 'RENOUV%' THEN 'RENOUVELLEMENT'
				WHEN c.campagne_nom LIKE 'RECRUT%' THEN 'RECRUTEMENT (RH)'
				ELSE 'AUTRE'
			END
	)
SELECT
	30 AS id_customer,
	cat.CampaignDisplayName,
	ISNULL (s.CountToday, 0) AS CountToday,
	ISNULL (s.CountCurrentWeek, 0) AS CountCurrentWeek,
	ISNULL (s.CountCurrentMonth, 0) AS CountCurrentMonth,
	ISNULL (s.CountPreviousMonth, 0) AS CountPreviousMonth,
	ISNULL (s.CountLast3Months, 0) AS CountLast3Months,
	ISNULL (s.CountCurrentYear, 0) AS CountCurrentYear,
	ISNULL (s.CountPreviousYear, 0) AS CountPreviousYear,
	ISNULL (s.SmsCountToday, 0) AS SmsCountToday,
	ISNULL (s.SmsCountCurrentWeek, 0) AS SmsCountCurrentWeek,
	ISNULL (s.SmsCountCurrentMonth, 0) AS SmsCountCurrentMonth,
	ISNULL (s.SmsCountPreviousMonth, 0) AS SmsCountPreviousMonth,
	ISNULL (s.SmsCountLast3Months, 0) AS SmsCountLast3Months,
	ISNULL (s.SmsCountCurrentYear, 0) AS SmsCountCurrentYear,
	ISNULL (s.SmsCountPreviousYear, 0) AS SmsCountPreviousYear
FROM
	Categories AS cat
	LEFT OUTER JOIN Stats AS s ON cat.CampaignDisplayName = s.CampaignDisplayName