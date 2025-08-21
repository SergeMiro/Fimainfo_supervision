WITH
	StatusList AS (
		SELECT
			'Y' AS GroupStatus,
			'Reçu par client' AS Description,
			1 AS SortOrder
		UNION ALL
		SELECT
			'E' AS Expr1,
			'Erreur définitive' AS Expr2,
			2 AS Expr3
		UNION ALL
		SELECT
			'S+R' AS Expr1,
			'En cours d''envoi' AS Expr2,
			3 AS Expr3
		UNION ALL
		SELECT
			'T' AS Expr1,
			'Envoyés au prestataire' AS Expr2,
			4 AS Expr3
		UNION ALL
		SELECT
			'A' AS Expr1,
			'Acceptés par prestataire' AS Expr2,
			5 AS Expr3
		UNION ALL
		SELECT
			'Z' AS Expr1,
			'Erreur temporaire, réessai 10 fois max' AS Expr2,
			6 AS Expr3
		UNION ALL
		SELECT
			'B' AS Expr1,
			'Bloqué par STOP code' AS Expr2,
			7 AS Expr3
	),
	Aggregated AS (
		SELECT
			CASE
				WHEN f.SENT IN ('S', 'R') THEN 'S+R'
				ELSE f.SENT
			END AS GroupStatus,
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
				WHEN f.SENT IN ('S', 'R') THEN 'S+R'
				ELSE f.SENT
			END
	)
SELECT
	30 AS id_customer,
	sl.GroupStatus AS Status,
	sl.Description AS StatusDescription,
	ISNULL (a.CountToday, 0) AS CountToday,
	ISNULL (a.CountCurrentWeek, 0) AS CountCurrentWeek,
	ISNULL (a.CountCurrentMonth, 0) AS CountCurrentMonth,
	ISNULL (a.CountPreviousMonth, 0) AS CountPreviousMonth,
	ISNULL (a.CountLast3Months, 0) AS CountLast3Months,
	ISNULL (a.CountCurrentYear, 0) AS CountCurrentYear,
	ISNULL (a.CountPreviousYear, 0) AS CountPreviousYear,
	ISNULL (a.SmsCountToday, 0) AS SmsCountToday,
	ISNULL (a.SmsCountCurrentWeek, 0) AS SmsCountCurrentWeek,
	ISNULL (a.SmsCountCurrentMonth, 0) AS SmsCountCurrentMonth,
	ISNULL (a.SmsCountPreviousMonth, 0) AS SmsCountPreviousMonth,
	ISNULL (a.SmsCountLast3Months, 0) AS SmsCountLast3Months,
	ISNULL (a.SmsCountCurrentYear, 0) AS SmsCountCurrentYear,
	ISNULL (a.SmsCountPreviousYear, 0) AS SmsCountPreviousYear
FROM
	StatusList AS sl
	LEFT OUTER JOIN Aggregated AS a ON sl.GroupStatus = a.GroupStatus