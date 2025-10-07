package;

import haxe.net.WebSocketServer;

class Main {
	private static inline var PORT = 8000;
	private static inline var MAX_CONNECTION = 100;

	public static function main(){
		var server = WebSocketServer.create('0.0.0.0', PORT, MAX_CONNECTION, true);
		var clients = new List<GameClient>();
		var clientsToRemove = new Array<GameClient>();

		var waitingRoom = new WaitingRoom();
		var games = new List<Game>();
		var gamesToRemove = new Array<Game>();

		while(true){
			var newConnection = server.accept();

			if(newConnection != null){
				trace('New connection');
				var newClient = new GameClient(newConnection);
				waitingRoom.add(newClient);
				clients.add(newClient);
			}
			
			for (client in clients) {
				if (!client.update()) {
					clientsToRemove.push(client);
				}
			}
			while (clientsToRemove.length > 0){
				var client = clientsToRemove.pop();
				clients.remove(client);
				waitingRoom.remove(client);
			}

			var game = waitingRoom.update();
			if(game != null){
				games.add(game);
			}

			for(game in games){
				if(!game.update()){
					gamesToRemove.push(game);
				}
			}
			while(gamesToRemove.length > 0){
				var game = gamesToRemove.pop();
				game.addRemainingPlayersToWaitingRoom(waitingRoom);
				games.remove(game);
			}
		}
	}
}