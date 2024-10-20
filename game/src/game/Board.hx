package game;

class Board{
	public static inline var TURN_DRAW = -1;
	public static inline var TURN_PLAYER = 0;
	public static inline var TURN_AI = 1;
	public static inline var SHOP_SIZE = 3;

	public var players(default, null):Array<Player>;
	public var shop(default, null):Array<Card>;
	private var round:Int;

	public var cardQueue = new Array<Card>();

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
		if(cardQueue.length > 0){
			return cardQueue.shift();
		}
		return CardEffectLibrary.getRandomCard();
	}

	public function enqueueCard(card:Card = null){
		if(card != null){
			cardQueue.push(card);
		}else{
			card = CardEffectLibrary.getRandomCard();
			cardQueue.push(card);
		}
		return card;
	}

	public function resetShop(){
		shop = new Array<Card>();
		for(i in 0...SHOP_SIZE){
			shop.push(drawCard());
		}
	}

	public function gameOver(){
		return players[0].curses == 13 || players[1].curses == 13;
	}

	public function getWinner(){
		if(players[0].curses == 13){
			return 1;
		}else if(players[1].curses == 13){
			return 0;
		}else{
			return -1;
		}
	}
}