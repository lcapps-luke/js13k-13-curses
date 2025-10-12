package;

import haxe.net.WebSocketServer;

class Main {
	private static inline var PORT = 80;
	private static inline var MAX_CONNECTION_DEFAULT = 100;

	public static var isDebug(default, null) = false;

	public static function main(){
		var logLevel = Sys.getEnv("LOG_LEVEL");
		isDebug = logLevel != null && logLevel == "DEBUG";

		var maxConnectionsEnv = Sys.getEnv("MAX_CONNECTIONS");
		var maxConnections = maxConnectionsEnv == null ? MAX_CONNECTION_DEFAULT : Std.parseInt(maxConnectionsEnv);

		var server = WebSocketServer.create('0.0.0.0', PORT, maxConnections, isDebug);
		var clients = new List<GameClient>();
		var clientsToRemove = new Array<GameClient>();

		var waitingRoom = new WaitingRoom();
		var games = new List<Game>();
		var gamesToRemove = new Array<Game>();

		Logger.info('Startup:\n\tdebug: ${isDebug}\n\tmax connections: ${maxConnections}\n\tport: ${PORT}');

		while(true){
			var newConnection = server.accept();

			if(newConnection != null){
				var newClient = new GameClient(newConnection);

				Logger.info('New Connection: ${newClient.id}');
				
				waitingRoom.add(newClient);
				clients.add(newClient);
			}
			
			for (client in clients) {
				if (!client.update()) {
					clientsToRemove.push(client);
					Logger.info('Disconnected: ${client.id}');
				}
			}
			while (clientsToRemove.length > 0){
				var client = clientsToRemove.pop();
				clients.remove(client);
				waitingRoom.remove(client);
			}

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

			Sys.sleep(clients.length == 0 ? 0.5 : 0.1);
		}
	}
}