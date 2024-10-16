/*<info serverAlias="DBMSG-bodb_message" executers="sportsbook_message"></info>*/

CREATE PROCEDURE [dbo].[sportsbook_message_GetPriMsgCount]
	@UserId int,
	@UserName nvarchar(30)
AS
BEGIN
/*
Revisions:
	20120109@Scott : add condition for new flag column [isDeleted] to filter deleted data.
*/
	Select Count(*) As Count From dbo.MsgTarget with (nolock)
	Where IsRead =0 
	AND TargetId = @UserId
	AND TargetName = @UserName
	AND isDeleted=0
END

