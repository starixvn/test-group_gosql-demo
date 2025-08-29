/*<info serverAlias="DBCUST-CustDB,DBACC-bodb02,DBAGE-bodb02,DBTXN-CustDB,DBBOF-bodb02,DBTP-bodb02,DBGLOB-GlobCustDB,DBCustRepl-ReplCustDB" executers="" viewers="" isFunction="0" isNested="0"></info>*/
ALTER PROCEDURE [dbo].[Task_Repl_CleanDeletedData] 
AS
/*
		Created: 20231227@Eden	
		Task: Job clean data replication in-house tables with isDeleted = 1
		DB: DBCUST-CustDB,DBACC-bodb02,DBAGE-bodb02,DBTXN-CustDB,DBBOF-bodb02,DBTP-bodb02,DBGLOB-GlobCustDB,DBCustRepl-ReplCustDB
		
		Revisions:
			- 20231227@Eden	: Initial Version #198589
			- 20250305@Tacy : Check object_id with table type [Redmine: #216870]
			- 20250826@Eden	: Initial Version [#236237]
		Parameters Explanation:	
*/
BEGIN
	--Step 1: Job clean data replication in-house tables with isDeleted = 1 
	EXEC [Task_Repl_CleanIsDeletedData]

	--Step 2: Job clean data replication of Del_Inhouse Tables
	EXEC [Task_Repl_Clean_Del_InhouseData]
END
GO
