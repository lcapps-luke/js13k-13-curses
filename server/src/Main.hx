package;

import hx.ws.Log;
import haxe.MainLoop;
import hx.ws.WebSocketServer;

class Main {
	private static inline var PORT = 80;
	private static inline var MAX_CONNECTION_DEFAULT = 100;

	public static var isDebug(default, null) = false;
	public static var waitingRoom = new WaitingRoom();

	public static function main(){
		var logLevel = Sys.getEnv("LOG_LEVEL");
		isDebug = logLevel != null && logLevel == "DEBUG";

		if(isDebug){
			Log.mask = Log.INFO | Log.DEBUG;
		}else{
			Log.mask = Log.INFO;
		}

		var maxConnectionsEnv = Sys.getEnv("MAX_CONNECTIONS");
		var maxConnections = maxConnectionsEnv == null ? MAX_CONNECTION_DEFAULT : Std.parseInt(maxConnectionsEnv);

		var server = new WebSocketServer<ClientHandler>("0.0.0.0", PORT, maxConnections);
		server.start();

		var games = new List<Game>();
		var gamesToRemove = new Array<Game>();

		Logger.info('Startup:\n\tdebug: ${isDebug}\n\tmax connections: ${maxConnections}\n\tport: ${PORT}');

		MainLoop.add(function(){
			var game = waitingRoom.update();
			if(game != null){
				Logger.info('Game Started: ${game.id} | players: ${game.playerAId()}, ${game.playerBId()}');
				games.add(game);
			}

			for(game in games){
				if(!game.update()){
					Logger.info('Game Ended: ${game.id}');
					gamesToRemove.push(game);
				}
			}
			while(gamesToRemove.length > 0){
				var game = gamesToRemove.pop();

				//TODO add as not ready?
				//currently players can be matched before returning to the multiplayer start screen
				//game.addRemainingPlayersToWaitingRoom(waitingRoom); 
				
				games.remove(game);
			}

			Sys.sleep(games.length == 0 ? 0.5 : 0.1);
		}).delay;
	}
}