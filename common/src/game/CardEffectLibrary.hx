package game;

class CardEffectLibrary{
	public static inline var POINTS_EFFECT_QTY = 4;
	public static inline var POINTS_EFFECT_REMOVE_QTY = 8;

	public static inline function getEffectCost(e:Int):Int{
		return CardEffect.COST[e];
	}

	public static inline function getEffectFunction(e:Int):Player->Player->Void{
		return CardEffect.FUNC[e];
	}

	public static inline function getDeck():Array<Array<Int>>{
		return CardEffect.DECK;
	}

	public static function getRandomCard():Card{
		var deckMap = getDeck();

		var deckIndex = Math.floor(Math.random() * CardEffect.CARD_QTY);
		for(d in 0...deckMap.length){
			for(q in 0...deckMap[d].length){
				deckIndex -= deckMap[d][q];
				if(deckIndex <= 0){
					return new Card([for (i in 0...(q+1)) d]);
				}
			}
		}

		return new Card([CardEffect.ADD_CURSE_OTHER]);
	}
}