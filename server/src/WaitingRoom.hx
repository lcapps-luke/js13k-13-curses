package;

import haxe.ds.ArraySort;

class WaitingRoom {
	private var pending:Array<GameClient>;
	private var ready:Array<GameClient>;
	private var waiting:Array<GameClient>;
	
	public function new(){
		pending = new Array<GameClient>();
		ready = new Array<GameClient>();
		waiting = new Array<GameClient>();
	}

	public function update():Null<Game>{
		for(p in pending){
			if(p.isReady()){
				Logger.info('[ROOM] Client Ready: ${p.id}');
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

	public function add(client:GameClient){
		pending.push(client);
	}

	public function remove(client:GameClient) {
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