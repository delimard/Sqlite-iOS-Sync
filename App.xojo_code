#tag Class
Protected Class App
Inherits MobileApplication
	#tag CompatibilityFlags = TargetIOS
	#tag Event
		Sub Opening()
		  Var dbFile As FolderItem = SpecialFolder.Resource("data.sqlite")
		  
		  If Not SpecialFolder.Documents.Child("data.sqlite").Exists Then
		    // Only copy the file if it is not already there
		    Dim dest As FolderItem = SpecialFolder.Documents.Child("data.sqlite")
		    dbFile.CopyTo(dest)
		    
		  End If
		  
		  Dim dest As FolderItem = SpecialFolder.Documents.Child("data.sqlite")
		  
		  //Check Database Structure
		  
		  SynchronizeSQLiteDatabases(dbFile,dest)
		End Sub
	#tag EndEvent


	#tag Method, Flags = &h0
		Function CreateTableSQL(tableName As String, columns() As String) As String
		  Dim sql As String = "CREATE TABLE " + tableName + " ("
		  sql = sql + String.FromArray(columns, ", ") + ")"
		  Return sql
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function GetTablesAndColumns(db As SQLiteDatabase) As Dictionary
		  Dim result As New Dictionary
		  Try
		    Dim rs As RowSet = db.SelectSQL("SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'")
		    While Not rs.AfterLastRow
		      Dim tableName As String = rs.Column("name").StringValue
		      Dim columnRs As RowSet = db.SelectSQL("PRAGMA table_info(" + tableName + ")")
		      Dim columns() As String
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
		    Dim db1 As New SQLiteDatabase
		    db1.DatabaseFile = base1File
		    
		    Dim db2 As New SQLiteDatabase
		    db2.DatabaseFile = base2File
		    
		    db1.Connect
		    db2.Connect
		    
		    // Get Table from tables
		    Dim tablesBase1 As Dictionary = GetTablesAndColumns(db1)
		    Dim tablesBase2 As Dictionary = GetTablesAndColumns(db2)
		    
		    // Sync tables and columns
		    For Each tableName As String In tablesBase1.Keys
		      If Not tablesBase2.HasKey(tableName) Then
		        
		        // Create table in table 2
		        Dim createTableSQL As String = CreateTableSQL(tableName, tablesBase1.Value(tableName))
		        db2.ExecuteSQL(createTableSQL)
		        
		      Else
		        // Sync Column
		        Dim columnsBase1() As String = tablesBase1.Value(tableName)
		        Dim columnsBase2() As String = tablesBase2.Value(tableName)
		        
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
		    
		  Catch error As RuntimeException
		    MessageBox("Runtime Error: " + error.Message)
		  catch dberror as DatabaseException
		    MessageBox ("Database Error : " + dberror.Message)
		  End Try
		End Sub
	#tag EndMethod


End Class
#tag EndClass
