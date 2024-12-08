#tag Class
Protected Class SyncDatabase
	#tag Method, Flags = &h0
		Function CreateTableSQL(tableName As String, columns() As String) As String
		  Var sql As String = "CREATE TABLE " + tableName + " ("
		  sql = sql + String.FromArray(columns, ", ") + ")"
		  Return sql
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function GetTablesAndColumns(db As SQLiteDatabase) As Dictionary
		  Var result As New Dictionary
		  Try
		    Var rs As RowSet = db.SelectSQL("SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'")
		    While Not rs.AfterLastRow
		      Var tableName As String = rs.Column("name").StringValue
		      Var columnRs As RowSet = db.SelectSQL("PRAGMA table_info(" + tableName + ")")
		      Var columns() As String
		      While Not columnRs.AfterLastRow
		        columns.Add(columnRs.Column("name").StringValue)
		        columnRs.MoveToNextRow
		      Wend
		      result.Value(tableName) = columns
		      rs.MoveToNextRow
		    Wend
		  Catch error As RuntimeException
		    MessageBox("Error on Database Schema : " + error.Message)
		  End Try
		  Return result
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub SynchronizeSQLiteDatabases(base1File As FolderItem, base2File As FolderItem)
		  Try
		    // Open and connect SQLite Databases
		    Var db1 As New SQLiteDatabase
		    db1.DatabaseFile = base1File
		    
		    Var db2 As New SQLiteDatabase
		    db2.DatabaseFile = base2File
		    
		    db1.Connect
		    db2.Connect
		    
		    // Get Table from tables
		    Var tablesBase1 As Dictionary = GetTablesAndColumns(db1)
		    Var tablesBase2 As Dictionary = GetTablesAndColumns(db2)
		    
		    // Sync tables and columns
		    For Each tableName As String In tablesBase1.Keys
		      If Not tablesBase2.HasKey(tableName) Then
		        
		        // Create table in table 2
		        Var createTableSQL As String = CreateTableSQL(tableName, tablesBase1.Value(tableName))
		        db2.ExecuteSQL(createTableSQL)
		        
		      Else
		        // Sync Column
		        Var columnsBase1() As String = tablesBase1.Value(tableName)
		        Var columnsBase2() As String = tablesBase2.Value(tableName)
		        
		        For Each column As String In columnsBase1
		          If Not columnsBase2.IndexOf(column) > -1 Then
		            
		            // Add the missing Column
		            db2.ExecuteSQL("ALTER TABLE " + tableName + " ADD COLUMN " + column)
		            
		          End If
		        Next
		      End If
		    Next
		    
		    db1.Close
		    db2.Close
		  Catch dberror as DatabaseException
		    MessageBox ("Database Error : " + dberror.Message)
		  Catch error As RuntimeException
		    MessageBox("Runtime Error: " + error.Message)
		    
		  End Try
		End Sub
	#tag EndMethod


End Class
#tag EndClass
