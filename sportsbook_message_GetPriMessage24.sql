/*<info serverAlias="DBMSG-bodb_message" executers="sportsbook_message"></info>*/

CREATE PROCEDURE [dbo].[sportsbook_message_GetPriMessage24]
	@UserID int,
	@IsTest bit = 0,
	@LatestMsgID int = 0 -- Check new msg count that newer than this messageid
AS
    /*
    Created: Tony Yu
    Task: 
    DB: DB07
    Original:
    Revisions:
        20210812@Tony Yu(DB05.Bodb_Message):Create
    Param's Explanation:
    */
BEGIN

	SET NOCOUNT ON;
	
	IF @IsTest=0	
	BEGIN
		SELECT m.MessageId, m.Content_en, m.Content_cs, m.Content_ch,
				 m.Content_jp, m.Content_th, m.Content_it, m.Content_ko,
				 m.Content_es, m.Content_vn, m.Content_id, m.Content_el,
				 m.Content_mx, m.Content_zhcn,
				 m.PostTime, m.CreateTime, m.LastUpdateTime,
				 m.MsgType, m.IsSticky, m.IsTest, m.MatchId, m.IsBatch,
				 m.Creator, m.LastUpdator, 
				 m.CreatorName, m.LastUpdateName,
				 mt.TargetName as UserName, mt.BettransID, mt.TargetId
		FROM dbo.Msg m with (nolock)
			INNER JOIN  dbo.MsgTarget  mt with (Nolock) ON m.MessageId = mt.MessageId 
		WHERE m.posttime > dateadd(d,-1,getdate()) and m.MsgType=1 and mt.TargetId=@UserID
		AND m.MessageId = @LatestMsgID
		AND m.IsSticky = 0
		AND m.IsTest=0
		AND m.isDeleted=0 AND mt.isDeleted=0
		ORDER BY m.PostTime DESC
	END
	ELSE
	BEGIN
		SELECT m.MessageId, m.Content_en, m.Content_cs, m.Content_ch,
					 m.Content_jp, m.Content_th, m.Content_it, m.Content_ko,
					 m.Content_es, m.Content_vn, m.Content_id, m.Content_el,
					 m.Content_mx, m.Content_zhcn,
					 m.PostTime, m.CreateTime, m.LastUpdateTime,
					 m.MsgType, m.IsSticky, m.IsTest, m.MatchId, m.IsBatch,
					 m.Creator, m.LastUpdator, 
					 m.CreatorName, m.LastUpdateName,
					 mt.TargetName as UserName, mt.BettransID, mt.TargetId

		FROM dbo.Msg m with (nolock)
			INNER JOIN dbo.MsgTarget mt with (nolock) ON m.MessageId = mt.MessageId 
		WHERE m.posttime > dateadd(d,-1,getdate()) and m.MsgType=1 and mt.TargetId=@UserID
		AND m.MessageId = @LatestMsgID
		AND m.IsSticky = 0
		AND m.isDeleted=0 AND mt.isDeleted=0
		ORDER BY m.PostTime DESC
	END
END
