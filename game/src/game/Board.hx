package game;

import haxe.rtti.CType.Platforms;

class Board{
	public static inline var TURN_DRAW = 0;
	public static inline var TURN_PLAYER = 1;
	public static inline var TURN_AI = 2;

	public var players:Array<Player>;
	private var shop:Array<Card>;
	private var round:Int;

	public function new(){
		players = [
			new Player(),
			new Player()
		];
	}

	public function getTurnLeader(){
		var diff = players[0].curses - players[1].curses;
		if(diff == 0){
			return TURN_DRAW;
		}

		return diff > 0 ? TURN_PLAYER : TURN_AI;
	}

	public function drawCard(){
		return new Card();
	}
}