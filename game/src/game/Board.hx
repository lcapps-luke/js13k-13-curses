package game;

class Board{
	public static inline var TURN_DRAW = 0;
	public static inline var TURN_PLAYER = 1;
	public static inline var TURN_AI = 2;
	public static inline var SHOP_SIZE = 3;

	public var players(default, null):Array<Player>;
	public var shop(default, null):Array<Card>;
	private var round:Int;

	public function new(){
		players = [
			new Player(),
			new Player()
		];
		shop = new Array<Card>();
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

	public function resetShop(){
		shop = new Array<Card>();
		for(i in 0...SHOP_SIZE){
			shop.push(drawCard());
		}
	}
}