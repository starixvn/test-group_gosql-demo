/*<info serverAlias="DBLOG-bodb02" executers="wsv_nap"></info>*/
ALTER PROCEDURE [dbo].[TW_Test_SP1]
AS

/*
	Created: 20240827@Evan
	DB: DBLOG-bodb02
	Task: ...

	Revisions:
		- 20240827@Evan: Initialize SP [RemineID: #000001]
		- 20240910@TW_Mei: Alter for gosql demo test
*/

BEGIN
	
	SELECT 'Executing TW_Test_SP1...';
	SELECT 'Testing Part 2'
	EXEC TW_Test_SP3

END
GO