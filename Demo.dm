var/Logger/logger = new

world
	New()
		..()
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