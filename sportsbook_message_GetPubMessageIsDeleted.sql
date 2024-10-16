/*<info serverAlias="DBMSG-bodb_message" executers="sportsbook_message"></info>*/

Create PROCEDURE [dbo].[sportsbook_message_GetPubMessageIsDeleted]
	@MessageId int,/*LatestPubMsgID*/
	@site1 varchar(10),
	@site2 varchar(10) = '',
	@site3 varchar(10) = '',
	@site4 varchar(10) = '',
	@site5 varchar(10) = ''
AS
/*
Revisions:
	20120416@Scott(DB07.bodb_message): Check message deleted or not.
*/
BEGIN
	DECLARE @site6 CHAR(4)
	DECLARE @site7 CHAR(4)
	DECLARE @site8 CHAR(4)
	SET @site6=''
	SET @site7=''
	SET @site8=''

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

	DECLARE @IsDeleted BIT
	SET @IsDeleted=1

	IF EXISTS(SELECT 1 FROM dbo.Msg m with (nolock)
		INNER JOIN dbo.MsgTarget mt with (nolock) ON m.MessageId = mt.MessageId
		WHERE mt.TargetID IN (@site1i,@site2i,@site3i,@site4i,@site5i,@site6i,@site7i,@site8i)
		AND m.MessageId = @MessageId
		AND m.isDeleted=0 AND mt.isDeleted=0)
			SET @IsDeleted=0

	SELECT @IsDeleted AS IsDeleted
END
