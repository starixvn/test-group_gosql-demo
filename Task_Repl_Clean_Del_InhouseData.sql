/*<info serverAlias="DBCUST-CustDB,DBACC-bodb02,DBAGE-bodb02,DBTXN-CustDB,DBBOF-bodb02,DBTP-bodb02,DBGLOB-GlobCustDB,DBCustRepl-ReplCustDB" executers="" viewers="" isFunction="0" isNested="0"></info>*/
ALTER PROCEDURE [dbo].[Task_Repl_Clean_Del_InhouseData] 
AS
/*
		Created: 20250820@Eden	
		Task: Job clean data replication of Del_Inhouse Tables
		DB: DBCUST-CustDB,DBACC-bodb02,DBAGE-bodb02,DBTXN-CustDB,DBBOF-bodb02,DBTP-bodb02,DBGLOB-GlobCustDB,DBCustRepl-ReplCustDB
		
		Revisions:
			- 20250826@Eden	: Initial Version [#236237]

		Parameters Explanation:	
*/
BEGIN
	DECLARE @DeleteDate_From DATETIME, 
		@DeleteDate_To DATETIME, 
		@DatabaseName VARCHAR(100), 
		@TableName VARCHAR(100), 
		@Version_Key VARCHAR(100), 
		@Unique_Key VARCHAR(100), 
		--Parameters: Dynamic query check valid object
		@msg_Err1 VARCHAR(500),
		@msg_Err2 VARCHAR(500),
		@ParmDefinition_Object NVARCHAR(500),
		@ExistObject BIT ,
		@HaveUpdateDB BIT,
		--Parameters: Dynamic query clean data
		@Batch_Num INT = 4000,
		@sql_str NVARCHAR(MAX) = '',
		@ParmDefinition NVARCHAR(500),
		@msg VARCHAR(500),
		@JoinCondition VARCHAR(500) = ''
	
	SET @DeleteDate_To = DATEADD(dd,-7, GETDATE())
	SET @ParmDefinition = N'@DeleteDate_To DATETIME, @DeleteDate_FROM DATETIME'
	SET @ParmDefinition_Object = N'@ExistObject BIT OUTPUT, @HaveUpdateDB BIT OUTPUT'
	SET @msg = 'DatabaseName: %s, TableName: %s, Version_Key: %s. '
	SET @msg_Err1 = 'This table does not exist on this database'
	SET @msg_Err2 = 'This database is not exist or Read-Only'

	DECLARE @Del_Inhouse_Tables TABLE (DatabaseName VARCHAR(100),TableName VARCHAR(100), Version_Key VARCHAR(100),CleanFromDate	DATETIME, Isfinish BIT DEFAULT 0)

	INSERT INTO @Del_Inhouse_Tables(DatabaseName,TableName,Version_Key,CleanFromDate)
	SELECT DatabaseName,TableName,Version_Key,ISNULL(CleanFromDate,'')
	FROM RepInfo_CleanData c WITH(NOLOCK) 
	WHERE EXISTS ( SELECT 1 FROM sys.databases d WITH(NOLOCK) WHERE c.DatabaseName = d.[name])
		AND c.TableName  LIKE '%[_]Del[_]Inhouse'
		AND c.Version_Key = 'RepUpdateTime'

	PRINT '----------------------------START CLEAN DATA Del_Inhouse-----------------------'

	WHILE 1 = 1
	BEGIN
		UPDATE TOP(1) t
		SET @DatabaseName = DatabaseName,
			@TableName= TableName,
			@Version_Key = Version_Key,
			@DeleteDate_From = CleanFromDate,
			Isfinish = 1
		FROM @Del_Inhouse_Tables t
		WHERE t.Isfinish = 0

		IF @@ROWCOUNT = 0
			BREAK;

		RAISERROR (@msg,10,1,@DatabaseName,@TableName,@Version_Key)

		SET @sql_str = '
		IF DATABASEPROPERTYEX('''+ @DatabaseName + ''', ''Updateability'')  = ''READ_WRITE''
		BEGIN
			SET @HaveUpdateDB = 1

			IF OBJECT_ID('''+ @DatabaseName + '.[dbo].' + @TableName +''', ''U'') IS NOT NULL
				SET @ExistObject = 1
			ELSE 
				SET @ExistObject = 0
		END
		ELSE
		BEGIN
			SET @HaveUpdateDB = 0
			SET @ExistObject = 0
		END
		'
		PRINT (@sql_str)
		EXECUTE sp_executesql 
			  @sql_str,
			  @ParmDefinition_Object,
			  @ExistObject = @ExistObject OUTPUT,
			  @HaveUpdateDB = @HaveUpdateDB OUTPUT

		IF @ExistObject = 1 AND @HaveUpdateDB = 1
		BEGIN
			
			SET @sql_str = '
			WHILE 1 = 1
			BEGIN
				DELETE TOP ('+ CONVERT(VARCHAR(10),@Batch_Num) + ') c
				FROM ' + @DatabaseName + '.[dbo].' + @TableName + ' c WITH(ROWLOCK,UPDLOCK)
				WHERE c.' +  @Version_Key + ' < @DeleteDate_To
					AND c.' +  @Version_Key + ' >= @DeleteDate_From 

				IF @@ROWCOUNT = 0
					BREAK;

				WAITFOR DELAY ''00:00:00.280''
			END
			'
			PRINT '@DeleteDate_From : ' + CONVERT(VARCHAR(20), @DeleteDate_From,120)
			PRINT '@DeleteDate_To : ' + CONVERT(VARCHAR(20), @DeleteDate_To,120)
			PRINT @sql_str

			EXECUTE sp_executesql 
				@sql_str,
				@ParmDefinition,
				@DeleteDate_To = @DeleteDate_To,
				@DeleteDate_From = @DeleteDate_From

			UPDATE TOP(1) t
			SET t.CleanFromDate =  DATEADD(hh,-1, @DeleteDate_To)  
			FROM RepInfo_CleanData t WITH(ROWLOCK,UPDLOCK)
			WHERE t.DatabaseName = @DatabaseName
				AND t.TableName = @TableName
		END
		ELSE
		BEGIN
			RAISERROR (@msg_Err1,10,1)
		END
	END
	PRINT '----------------------------END CLEAN DATA Del_Inhouse-----------------------'
END
GO
