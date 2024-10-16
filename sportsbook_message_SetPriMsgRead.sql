/*<info serverAlias="DB05-bodb_message" executers="sportsbook_message"></info>*/

CREATE PROCEDURE [dbo].[sportsbook_message_SetPriMsgRead]
	@UserId int,
	@UserName nvarchar(30)
AS
/*
Revisions:
	20241016@Infinity : Update revision history for GoSQL deploy
*/
BEGIN
	Update dbo.MsgTarget
	SET IsRead = 1
	WHERE IsRead = 0
		AND IsDeleted = 0
		AND TargetId = @UserId
		AND TargetName = @UserName
END

