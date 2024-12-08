#tag Class
Protected Class App
Inherits MobileApplication
	#tag CompatibilityFlags = TargetIOS
	#tag Event
		Sub Opening()
		  Var dbFile As FolderItem = SpecialFolder.Resource("data.sqlite")
		  
		  If Not SpecialFolder.Documents.Child("data.sqlite").Exists Then
		    // Only copy the file if it is not already there
		    Var dest As FolderItem = SpecialFolder.Documents.Child("data.sqlite")
		    
		    try
		      dbFile.CopyTo(dest)
		    Catch error As IOException
		      MessageBox(error.Message)
		    End Try
		    
		  End If
		  
		  Var dest As FolderItem = SpecialFolder.Documents.Child("data.sqlite")
		  
		  //Check Database Structure
		  
		  Var Sync as new SyncDatabase
		  Sync.SynchronizeSQLiteDatabases(dbFile,dest)
		End Sub
	#tag EndEvent


End Class
#tag EndClass
