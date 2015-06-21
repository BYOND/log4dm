var/Logger/logger = new

world
	New()
		..()

		//no extention needed for SQLiteConfig...adds .sqlite
		logger.SQLiteConfig("server")
		logger.htmlFileConfig("log.html")

		var/Logger/wlog = logger.getLogger("worldlog")
		wlog.plaintextWorldLogConfig()
		wlog.setLevel(LOG_WARN)

		logger.startLogging()

		logger.info("World startup.")

	Del()
		logger.info("World shutdown.")

		logger.endLogging()

		..()

mob
	Login()
		..()
		logger.trace("[key] ([ckey]) logged in.")

	Logout()
		logger.trace("[key] ([ckey]) logged out.")
		..()

	verb/warning_test() logger.warn("Something is afoot!")
	verb/fatal_test() logger.fatal("FATALITY!")


	//added for support of viewing sqlite database
	verb/OpenDatabase()
		var/SelectedDatabase = input("What database would you like to see?","dbselect","server.sqlite") as text
		var/SelectedTable = input("What table would you like to see?","dbselect","logs") as text
		var/database/database = new(SelectedDatabase)
		var/database/query/query = new("SELECT * FROM [SelectedTable]")
		if(!query.Execute(database))
			logger.error("Unable to connect to SQLite database '[SelectedDatabase]' with table '[SelectedTable]'.\nError: "+query.ErrorMsg())
		else
			var/htm_table = ""
			for(var/x in query.Columns())
				htm_table += "<th>[x]</th>"
			htm_table = "<tr>[htm_table]</tr>"
			while(query.NextRow())
				var/list/row = query.GetRowData()
				var/new_row = ""
				for(var/x in row)
					new_row += "<td>[row[x]]</td>"
				htm_table += "<tr>[new_row]</tr>"
			src << browse("<table border=1>[htm_table]</table>")