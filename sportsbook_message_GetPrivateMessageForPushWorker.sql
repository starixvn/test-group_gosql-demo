/*<info serverAlias="DB05-bodb_message" executers="sportsbook_message"></info>*/

CREATE PROCEDURE [dbo].[sportsbook_message_GetPrivateMessageForPushWorker]
	@sdate datetime,
	@edate datetime,
	@isTest bit = 0
AS
-- 執行頻率: 5秒執行一次
-- 20240102@Allen (bodb_Message): query private message by datetime range
BEGIN
	SET NOCOUNT ON;

	CREATE TABLE #MsgTmp(
		MessageId INT
	)
	CREATE TABLE #MsgTargetTmp (
		MessageId INT
		, Content_en NVARCHAR(4000)
		, Content_cs NVARCHAR(4000)
		, Content_ch NVARCHAR(4000)
		, Content_jp NVARCHAR(4000)
		, Content_th NVARCHAR(4000)
		, Content_it NVARCHAR(4000)
		, Content_ko NVARCHAR(4000)
		, Content_es NVARCHAR(4000)
		, Content_vn NVARCHAR(4000)
		, Content_id NVARCHAR(4000)
		, Content_el NVARCHAR(4000)
		, Content_mx NVARCHAR(4000)
		, Content_zhcn NVARCHAR(4000)
		, PostTime DATETIME
		, MsgType TINYINT
		, IsBatch BIT
		, TargetId INT
		, BetTransId VARCHAR(MAX)
	)
	CREATE TABLE #MsgTarget_dup (
		MessageId INT		
		, TargetId INT
	)

	INSERT INTO #MsgTmp(MessageId)
	SELECT MessageId
	FROM dbo.Msg m WITH (NOLOCK)
	WHERE m.MsgType = 1
		AND m.isDeleted = 0 
		AND m.PostTime BETWEEN @sdate AND @edate
		AND (@isTest = 1 OR m.IsTest = @isTest)

	INSERT INTO #MsgTargetTmp (MessageId
			, Content_en 
			, Content_cs 
			, Content_ch 
			, Content_jp
			, Content_th 
			, Content_it 
			, Content_ko 
			, Content_es 
			, Content_vn 
			, Content_id 
			, Content_el 
			, Content_mx 
			, Content_zhcn 
			, PostTime 
			, MsgType 
			, IsBatch 
			, TargetId 
			, BetTransId
		)
		SELECT m.MessageId
			, m.Content_en 
			, m.Content_cs 
			, m.Content_ch 
			, m.Content_jp
			, m.Content_th 
			, m.Content_it 
			, m.Content_ko 
			, m.Content_es 
			, m.Content_vn 
			, m.Content_id 
			, m.Content_el 
			, m.Content_mx 
			, m.Content_zhcn 
			, m.PostTime 
			, m.MsgType 
			, m.IsBatch 
			, mt.TargetId
			, mt.BetTransId
	FROM #MsgTmp tmp 
	INNER JOIN dbo.Msg m WITH (NOLOCK)
		ON tmp.MessageId = m.MessageId
	INNER JOIN dbo.MsgTarget mt WITH (NOLOCK) 
		ON m.MessageId = mt.MessageId
		AND mt.isDeleted=0

	--Return Data
	INSERT INTO #MsgTarget_dup (MessageId, TargetId)
	SELECT m.MessageId, m.TargetId
	FROM #MsgTargetTmp m
	GROUP BY m.MessageId, m.TargetId
	HAVING COUNT(1) > 1
	
	IF EXISTS (SELECT TOP 1 1 FROM #MsgTarget_dup)
	BEGIN
		SELECT  m.MessageId, m.Content_en, m.Content_cs, m.Content_ch,
							m.Content_jp, m.Content_th, m.Content_it, m.Content_ko,
							m.Content_es, m.Content_vn, m.Content_id, m.Content_el,
							m.Content_mx, m.Content_zhcn,
							m.PostTime, 
							m.MsgType,  m.IsBatch,
							STUFF(tmp.BettransID,1,1,'') as BettransID,
							m.TargetId
		FROM #MsgTarget_dup  mt
				CROSS APPLY (SELECT TOP 1  m.MessageId, m.Content_en, m.Content_cs, m.Content_ch,
									m.Content_jp, m.Content_th, m.Content_it, m.Content_ko,
									m.Content_es, m.Content_vn, m.Content_id, m.Content_el,
									m.Content_mx, m.Content_zhcn,
									m.PostTime,
									m.MsgType, m.IsBatch,
									m.TargetId
							FROM #MsgTargetTmp m 
							WHERE MessageId = mt.MessageId AND TargetId = mt.TargetId
						)m
				CROSS APPLY (SELECT  ',' + ISNULL(BetTransId ,'')
							FROM dbo.MsgTarget WITH (NOLOCK) 
							WHERE TargetId = m.TargetId AND MessageId = m.MessageId
							FOR XML PATH('')
							) AS tmp(BettransID)
		
		UNION ALL
		SELECT m.MessageId, m.Content_en, m.Content_cs, m.Content_ch,
							m.Content_jp, m.Content_th, m.Content_it, m.Content_ko,
							m.Content_es, m.Content_vn, m.Content_id, m.Content_el,
							m.Content_mx, m.Content_zhcn,
							m.PostTime,
							m.MsgType, m.IsBatch,
							m.BettransID,
							m.TargetId
		FROM #MsgTargetTmp m
		LEFT JOIN #MsgTarget_dup d 
			ON m.TargetId = d.TargetId and d.messageid = m.MessageId
		WHERE d.messageid IS NULL
	END
	ELSE
	BEGIN
		SELECT m.MessageId, m.Content_en, m.Content_cs, m.Content_ch,
							m.Content_jp, m.Content_th, m.Content_it, m.Content_ko,
							m.Content_es, m.Content_vn, m.Content_id, m.Content_el,
							m.Content_mx, m.Content_zhcn,
							m.PostTime,
							m.MsgType, m.IsBatch,
							m.BettransID,
							m.TargetId
		FROM #MsgTargetTmp m
	END

	DROP TABLE #MsgTarget_dup, #MsgTargetTmp, #MsgTmp
END
