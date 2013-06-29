#define LOG_OFF 6
#define LOG_FATAL 5
#define LOG_ERROR 4
#define LOG_WARN 3
#define LOG_INFO 2
#define LOG_DEBUG 1
#define LOG_TRACE 0
#define LOG_ALL -1

world
	hub = "Koil.log4dm"
	version = 6

proc/level2text(level)
	switch(level)
		if(LOG_OFF) return "OFF"
		if(LOG_FATAL) return "FATAL"
		if(LOG_ERROR) return "ERROR"
		if(LOG_WARN) return "WARN"
		if(LOG_INFO) return "INFO"
		if(LOG_DEBUG) return "DEBUG"
		if(LOG_TRACE) return "TRACE"
		if(LOG_ALL) return "ALL"