package;

class Logger {
	public static function info(msg:String){
		log("INFO", msg);
	}

	public static function warn(msg:String){
		log("WARN", msg);
	}

	public static function error(msg:String){
		log("ERROR", msg);
	}

	public static function debug(msg:String){
		if(Main.isDebug){
			log("DEBUG", msg);
		}
	}

	public static function log(lvl:String, msg:String){
		Sys.println('[${Date.now().toString()}] [$lvl] - $msg');
	}
}