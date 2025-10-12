package;

import haxe.ds.ArraySort;

class WaitingRoom {
	private var pending:Array<ClientHandler>;
	private var ready:Array<ClientHandler>;
	private var waiting:Array<ClientHandler>;
	
	public function new(){
		pending = new Array<ClientHandler>();
		ready = new Array<ClientHandler>();
		waiting = new Array<ClientHandler>();
	}

	public function update():Null<Game>{
		for(p in pending){
			if(p.isReady()){
				Logger.info('[ROOM] Client Ready: ${p.clientId}');
				ready.push(p);
			}
		}
		while(ready.length > 0){
			var p = ready.pop();
			pending.remove(p);
			waiting.push(p);
			p.onJoinWaitingRoom();
			Logger.info('[ROOM] ${waiting.length} players waiting');
		}

		if(waiting.length > 1){
			return match();
		}
		
		return null;
	}

	private function removeDisconnected(dis:Array<ClientHandler>, set:Array<ClientHandler>){
		while(dis.length > 0){
			set.remove(dis.pop());
		}
		Logger.info('[ROOM] ${waiting.length} players waiting');
	}

	public function add(client:ClientHandler){
		pending.push(client);
	}

	public function remove(client:ClientHandler) {
		waiting.remove(client);
		ready.remove(client);
		pending.remove(client);

		Logger.info('[ROOM] ${waiting.length} players waiting');
	}

	private function match(){
		Logger.debug('matching...');
		ArraySort.sort(waiting, (a,b) -> (a.waitingSince - b.waitingSince) > 0 ? -1 : 1); // desc

		var a = waiting.pop();
		var b = waiting.pop();
		
		var game = new Game(a, b);
		game.init();

		Logger.info('[ROOM] ${waiting.length} players waiting');
		return game;
	}

	
}