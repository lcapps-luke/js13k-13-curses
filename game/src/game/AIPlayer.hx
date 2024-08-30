package game;

class AIPlayer{
	public static function getActions(board:Board):Array<AIAction>{
		var other = board.players[0].copy();
		var self = board.players[1].copy();
		
		var actions = new Array<AIAction>();
		for(c in board.shop){
			if(c != null && shouldBuy(c, self, other)){
				actions.push({
					type: BUY,
					index: board.shop.indexOf(c)
				});
				
				self.cards.push(c);
			}
		}
		
		var bestPlayScore:Int = getStateScore(self, other);
		var bestPlayCard:Card = null;
		for(h in self.cards){
			var thisScore = getPlayScore(h, self, other);
			if(thisScore > bestPlayScore){
				bestPlayScore = thisScore;
				bestPlayCard = h;
			}
		}

		if(bestPlayCard != null){
			actions.push({
				type: PLAY,
				index: self.cards.indexOf(bestPlayCard)
			});
		}

		actions.push({
			type: END,
			index: -1
		});
		return actions;
	}
	
	private static function shouldBuy(card:Card, self:Player, other:Player):Bool{
		if(card.cost > self.points || self.cards.length > 4){
			return false;
		}

		var haveDefensive = 0;
		var haveOffensive = 0;

		for(h in self.cards){
			if(isOffensive(h)){
				haveOffensive++;
			}else{
				haveDefensive++;
			}
		}

		if(isOffensive(card)){
			haveOffensive++;
		}else{
			haveDefensive++;
		}

		return (haveOffensive <= 2) && (haveDefensive <= 2);
	}

	private static function isOffensive(card:Card){
		return switch(card.effects[0]){
			case CardEffect.ADD_CURSE_OTHER: true;
			case CardEffect.GIVE_CURSE: true;
			case CardEffect.SEAL_OTHER_CURSE: true;
			case CardEffect.GAIN_POINT: true;
			case CardEffect.REMOVE_POINT: true;
			default: false;
		}
	}

	private static function getPlayScore(h:Card, self:Player, other:Player) {
		var sc = self.copy();
		var oc = other.copy();
		
		for(e in h.effects){
			CardEffectLibrary.getEffectFunction(e)(sc, oc);
		}

		return getStateScore(sc, oc);
	}
	
	private static function getStateScore(self:Player, other:Player) {
		if(self.curses == 13 || !(self.validState() && other.validState())){
			return -10000;
		}
		if(other.curses == 13){
			return 10000;
		}

		var score = self.points - other.points;

		if(self.curses < 13){
			score += 13 - self.curses;
		}else{
			score += (self.curses - 13) * 3;
		}

		if(other.curses < 13){
			score += other.curses;
		}else{
			score -= (other.curses - 13) * 3;
		}

		return score;
	}
}