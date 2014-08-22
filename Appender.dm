Appender
	var/Layout/layout = null

	New(Layout/_layout)
		layout = _layout

	proc
		startLog() if(layout) append(layout.startLog(), 0, "", FALSE)
		endLog() if(layout) append(layout.endLog(), 0, "", FALSE)

		append(log, level, name, format = TRUE)
			if(!layout) layout = new/Layout/PlaintextLayout

		setLayout(Layout/_layout)
			ASSERT(_layout)
			layout = _layout

		getLayout() return layout

	FileAppender
		var/output_file = ""

		New(Layout/_layout, _output_file)
			layout = _layout
			output_file = _output_file

			..()

		append(log, level, name, format = TRUE)
			..(log, level, name, format)

			if(format) log = layout.formatLog(log, level, name)
			if(output_file)
				if (!fexists(output_file))
					var/preamble = layout.formatLog(layout.startLog(),  0, "")
					text2file(preamble, output_file)
				text2file(log, output_file)

			return log

		proc
			setOutputFile(_output_file) output_file = _output_file
			getOutputFile() return output_file

		DailyFileAppender
			append(log, level, name, format = TRUE)
				var/set_output = output_file
				var/time = time2text(world.realtime, "YYYY-MM-DD")
				output_file = "[set_output]/[time].[layout.getFileExtension()]"
				..(log, level, name, format)
				output_file = set_output

				return log

	WorldLogAppender
		append(log, level, name,  format = TRUE)
			..(log, level, name,  format)

			if(format) log = layout.formatLog(log, level, name)
			world.log << log

	SQLiteAppender
		var/database_file = ""

		New(Layout/_layout, _database_file)
			layout = _layout
			database_file = _database_file
			//if layout is missing, we need to create it for the extention.
			if(!layout) layout = new/Layout/SQLiteLayout


			var/database/database_db = new("[database_file].[layout.getFileExtension()]")
			var/database/query/query = new("CREATE TABLE IF NOT EXISTS logs (Id INTEGER PRIMARY KEY ASC, LogName TEXT, GmtDateTime INTEGER, Uptime INTEGER, Level INTEGER, LevelDescription TEXT, Message TEXT)")
			if(!query.Execute(database_db))
				CRASH(query.ErrorMsg())
			..()
		append(log, level, name,  format = TRUE)
			//call the parent anyway - to capture any future changes that may be
			//added
			..(log, level, name, format)
			//must use format for SQLite, so ignore format the param.
			var/list/fields = layout.formatLog(log, level, name)
			var/database/database_db = new("[database_file].[layout.getFileExtension()]")

			var/database/query/query = new("INSERT INTO logs (LogName,GmtDateTime,Uptime,Level,LevelDescription,Message) VALUES (?, CURRENT_TIMESTAMP, ?, ?, ?, ?)"
			                              ,fields["LogName"]
			                              ,fields["Uptime"]
			                              ,fields["Level"]
			                              ,fields["LevelDescription"]
			                              ,fields["Message"])

			if(!query.Execute(database_db))
				CRASH(query.ErrorMsg())
