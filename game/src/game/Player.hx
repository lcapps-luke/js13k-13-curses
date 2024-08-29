package game;

class Player{
	public var curses:Int = 0;
	public var cards = new Array<Card>();
	public var points:Int = 3;

	public function new(){}

	public function copy():Player{
		var c = new Player();
		c.curses = curses;
		c.cards = cards.copy();
		c.points = points;
		return c;
	}

	public function validState(){
		return curses >= 0 && curses <= 16 && points >= 0 && cards.length <= 5;
	}

	public function addPoints(p:Int) {
		points += p * getPointsMultiplier();
	}

	public function getPointsMultiplier():Int{
		if(curses > 13){
			return 4;
		}else if(curses > 9){
			return 3;
		}else if(curses > 6){
			return 2;
		}
		return 1;
	}
}