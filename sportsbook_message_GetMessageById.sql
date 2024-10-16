/*<info serverAlias="DB05-bodb_message" executers="sportsbook_message"></info>*/

CREATE PROCEDURE [dbo].[sportsbook_message_GetMessageById]
    @messageId int = 0
AS
/*
-- 20240220@DavidHe(MessageDB): Create SP

*/
BEGIN
    SET NOCOUNT ON;

	SELECT 
        m.MessageId, m.Content_en, m.Content_cs, m.Content_ch,
        m.Content_jp, m.Content_th, m.Content_it, m.Content_ko,
        m.Content_es, m.Content_vn, m.Content_id, m.Content_el,
        m.Content_mx, m.Content_zhcn,
        m.PostTime, m.CreateTime, m.LastUpdateTime,
        m.MsgType, m.IsSticky, m.IsTest, m.MatchId, m.IsBatch,
        m.Creator, m.LastUpdator, 
        m.CreatorName, m.LastUpdateName, 
        mt.TargetName as UserName, mt.BettransID, mt.TargetId
    FROM dbo.Msg m with (nolock)
        INNER JOIN dbo.MsgTarget mt with (nolock)
        ON m.MessageId = mt.MessageId
    WHERE m.MessageId = @messageId
    AND m.isDeleted = 0
    AND mt.isDeleted =  0
END
