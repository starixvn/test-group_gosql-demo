/*<info serverAlias="DBMSG - bodb_message" executers="sportsbook_message"></info>*/

CREATE procedure [dbo].[sportsbook_message_GetTopPubMessage]
	@messageType int,
	@site1 varchar(10),
	@site2 varchar(10) = '',
	@site3 varchar(10) = '',
	@site4 varchar(10) = '',
	@site5 varchar(10) = '',
	@LatestMsgID int = 0,  -- Check new msg count that newer than this messageid
	@isTest bit
AS

		
BEGIN
    /*
    Created: @TWTeam
    Task: 
    DB: DB07
    Original:
    Revisions:
		20120109@Scott(DB07): add condition for new flag column [isDeleted] to filter deleted data.
        	20170427@Tony Yu : add sort condition TopLevel
		20170602@Tony Yu : remove check MessageId condition 
		20180904@Scott(DB05.Bodb_Message): Add Content_zhcn
    Param's Explanation:
    */
	SET NOCOUNT ON;
	DECLARE @msgid int
	DECLARE @site6 CHAR(4)
	DECLARE @site7 CHAR(4)
	DECLARE @site8 CHAR(4)
	SET @site6=''
	SET @site7=''
	SET @site8=''

	-- select min(messageid) from msg (nolock) where posttime > DATEADD(month,-1,CURRENT_TIMESTAMP) 
	-- [Dot_Msg_GetTopPubMessage]/[Acc_Msg_GetTopPubMessage]
	IF @LatestMsgID in (0,212283) SET @LatestMsgID=578367 --522518

	IF @site1<>'' SET @site1=dbo.FixSiteID(@site1)
	IF @site2<>'' SET @site2=dbo.FixSiteID(@site2)
	IF @site3<>'' SET @site3=dbo.FixSiteID(@site3)
	IF @site4<>'' SET @site4=dbo.FixSiteID(@site4)
	IF @site5<>'' SET @site5=dbo.FixSiteID(@site5)

	IF @site1<>'' SET @site6=dbo.FixSiteID2(@site1)
	IF @site2<>'' SET @site7=dbo.FixSiteID2(@site2)
	IF @site3<>'' SET @site8=dbo.FixSiteID2(@site3)
	
	Declare @site1i int, @site2i int, @site3i int, @site4i int, @site5i int
	Declare @site6i int, @site7i int, @site8i int
	
	SELECT
		@site1i = @site1,
		@site2i = @site2,
		@site3i = @site3,
		@site4i = @site4,
		@site5i = @site5,
		@site6i = @site6,
		@site7i = @site7,
		@site8i = @site8
		

	IF @isTest = 0
	BEGIN
		-- Select Public Message(not include test message)
			;with cte as
			(
				select MessageId from dbo.MsgTarget with( nolock )
				where TargetId in  (@site1i,@site2i,@site3i,@site4i,@site5i,@site6i,@site7i,@site8i)
					AND isDeleted=0 
			)
			select top  1 @msgid = m.MessageId from Msg m with( nolock )
					inner join cte on m.MessageId = cte.MessageId 
			where  m.MsgType = @messageType
				aND m.IsTest = 0
				AND m.isDeleted=0 
			ORDER BY m.TopLevel,m.PostTime Desc


			SELECT	TOP 1 m.MessageId, m.Content_en, m.Content_cs, m.Content_ch,
						 m.Content_jp, m.Content_th, m.Content_it, m.Content_ko,
						 m.Content_es, m.Content_vn, m.Content_id, m.Content_el,
						 m.Content_mx, m.Content_zhcn,
						 m.PostTime, m.CreateTime, m.LastUpdateTime,
						 m.MsgType, m.IsSticky, m.IsTest, m.MatchId, m.IsBatch,
						 m.Creator, m.LastUpdator, 
						 m.CreatorName, m.LastUpdateName,
						 mt.TargetName as UserName, mt.BettransID, mt.TargetId
			FROM Msg m with(nolock)
				inner join dbo.MsgTarget mt with(nolock)
				on  m.MessageId = mt.MessageId
			WHERE m.MessageId = @msgid
				AND mt.TargetId in  (@site1i,@site2i,@site3i,@site4i,@site5i,@site6i,@site7i,@site8i)

	END
	ELSE
	BEGIN
		-- Select Public Message(include test message)
		;with cte as
		(
			select MessageId from dbo.MsgTarget with( nolock )
			where TargetId in  (@site1i,@site2i,@site3i,@site4i,@site5i,@site6i,@site7i,@site8i)
				AND isDeleted=0 
		)
		select top  1 @msgid = m.MessageId from Msg m with( nolock )
				inner join cte on m.MessageId = cte.MessageId 
		where  m.MsgType = @messageType
			aND m.IsTest IN ( 0 , 1)
			AND m.isDeleted=0 
		ORDER BY m.TopLevel,m.PostTime Desc


		SELECT	TOP 1 m.MessageId, m.Content_en, m.Content_cs, m.Content_ch,
					 m.Content_jp, m.Content_th, m.Content_it, m.Content_ko,
					 m.Content_es, m.Content_vn, m.Content_id, m.Content_el,
					 m.Content_mx, m.Content_zhcn,
					 m.PostTime, m.CreateTime, m.LastUpdateTime,
					 m.MsgType, m.IsSticky, m.IsTest, m.MatchId, m.IsBatch,
					 m.Creator, m.LastUpdator, 
					 m.CreatorName, m.LastUpdateName,
					 mt.TargetName as UserName, mt.BettransID, mt.TargetId
		FROM Msg m with(nolock)
			inner join dbo.MsgTarget mt with(nolock)
			on  m.MessageId = mt.MessageId
		WHERE m.MessageId = @msgid
			AND mt.TargetId in  (@site1i,@site2i,@site3i,@site4i,@site5i,@site6i,@site7i,@site8i)

	END
END




