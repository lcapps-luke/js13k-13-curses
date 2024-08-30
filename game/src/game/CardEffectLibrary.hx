package game;

class CardEffectLibrary{
	public static inline var POINTS_EFFECT_QTY = 4;
	public static inline var POINTS_EFFECT_REMOVE_QTY = 8;

	public static function getEffectCost(e:Int):Int{
		return switch(e){
			case CardEffect.ADD_CURSE_OTHER: 3;
			case CardEffect.ADD_CURSE_SELF: 2;
			case CardEffect.REMOVE_CURSE_OTHER: 2;
			case CardEffect.REMOVE_CURSE_SELF: 3;
			case CardEffect.TAKE_CURSE: 2;
			case CardEffect.GIVE_CURSE: 4;
			case CardEffect.GAIN_POINT: 2;
			case CardEffect.REMOVE_POINT: 3;
			case CardEffect.SEAL_OWN_CURSE: 2;
			case CardEffect.SEAL_OTHER_CURSE: 3;
			case CardEffect.PROTECT_SELF: 4;
			case CardEffect.PROTECT_OTHER: 2;
			default: 0;
		}
	}

	public static function getEffectFunction(e:Int):Player->Player->Void{
		return switch(e){
			case CardEffect.ADD_CURSE_OTHER: (s, o) -> o.curses++;
			case CardEffect.ADD_CURSE_SELF: (s, o) -> s.curses++;
			case CardEffect.REMOVE_CURSE_OTHER: (s, o) -> o.curses--;
			case CardEffect.REMOVE_CURSE_SELF: (s, o) -> s.curses--;
			case CardEffect.TAKE_CURSE: (s, o) -> {o.curses--; s.curses++;}
			case CardEffect.GIVE_CURSE: (s, o) -> {o.curses++; s.curses--;}
			case CardEffect.GAIN_POINT: (s, o) -> s.points += POINTS_EFFECT_QTY;
			case CardEffect.REMOVE_POINT: (s, o) -> o.points -= POINTS_EFFECT_REMOVE_QTY;
			/*
			case CardEffect.SEAL_OWN_CURSE: (s, o) -> {};
			case CardEffect.SEAL_OTHER_CURSE: (s, o) -> {};
			case CardEffect.PROTECT_SELF: (s, o) -> {};
			case CardEffect.PROTECT_OTHER: (s, o) -> {};
			*/
			default: (s,o)->{};
		}
	}

	public static function getDeck():Map<Int,Array<Int>>{
		return [
			CardEffect.ADD_CURSE_OTHER => [30, 20, 10],
			CardEffect.ADD_CURSE_SELF => [15, 7, 3],
			CardEffect.REMOVE_CURSE_OTHER => [10, 5, 2],
			CardEffect.REMOVE_CURSE_SELF => [20, 10, 5],
			CardEffect.TAKE_CURSE => [15, 7, 3],
			CardEffect.GIVE_CURSE => [20, 10, 5],
			CardEffect.GAIN_POINT => [20, 10, 5],
			CardEffect.REMOVE_POINT => [20, 10, 5],
			/*
			CardEffect.SEAL_OWN_CURSE => [0, 0, 0],
			CardEffect.SEAL_OTHER_CURSE => [0, 0, 0],
			CardEffect.PROTECT_SELF => [0, 0, 0],
			CardEffect.PROTECT_OTHER => [0, 0, 0],
			*/
		];
	}

	public static function getRandomCard():Card{
		var deckMap = getDeck();
		var qty = 0;
		for(t in deckMap){
			qty += t[0];
			qty += t[1];
			qty += t[2];
		}

		var deckIndex = Math.floor(Math.random() * qty);
		for(t in deckMap.keyValueIterator()){
			for(q in 0...3){
				deckIndex -= t.value[q];
				if(deckIndex <= 0){
					return new Card([for (i in 0...(q+1)) t.key]);
				}
			}
		}

		return new Card([CardEffect.ADD_CURSE_OTHER]);
	}
}