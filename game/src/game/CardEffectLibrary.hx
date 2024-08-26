package game;

class CardEffectLibrary{
	public static function getEffectCost(e:CardEffect):Int{
		return switch(e){
			case ADD_CURSE_OTHER: 2;
			case ADD_CURSE_SELF: 1;
			case REMOVE_CURSE_OTHER: 1;
			case REMOVE_CURSE_SELF: 2;
			case TAKE_CURSE: 1;
			case GIVE_CURSE: 3;
			case GAIN_POINT: 1;
			case REMOVE_POINT: 2;
			case SEAL_OWN_CURSE: 1;
			case SEAL_OTHER_CURSE: 2;
			case PROTECT_SELF: 3;
			case PROTECT_OTHER: 1;
		}
	}

	public static function getEffectFunction(e:CardEffect):Player->Player->Void{
		return switch(e){
			case ADD_CURSE_OTHER: (s, o) -> o.curses++;
			case ADD_CURSE_SELF: (s, o) -> s.curses++;
			case REMOVE_CURSE_OTHER: (s, o) -> o.curses--;
			case REMOVE_CURSE_SELF: (s, o) -> s.curses--;
			case TAKE_CURSE: (s, o) -> {o.curses--; s.curses++;}
			case GIVE_CURSE: (s, o) -> {o.curses++; s.curses--;}
			case GAIN_POINT: (s, o) -> s.points += 2;
			case REMOVE_POINT: (s, o) -> o.points -= 2;
			case SEAL_OWN_CURSE: (s, o) -> {};
			case SEAL_OTHER_CURSE: (s, o) -> {};
			case PROTECT_SELF: (s, o) -> {};
			case PROTECT_OTHER: (s, o) -> {};
		}
	}

	private static function getDeck():Map<CardEffect,Array<Int>>{
		return [
			ADD_CURSE_OTHER => [30, 20, 10],
			ADD_CURSE_SELF => [15, 7, 3],
			REMOVE_CURSE_OTHER => [15, 7, 3],
			REMOVE_CURSE_SELF => [20, 10, 5],
			TAKE_CURSE => [15, 7, 3],
			GIVE_CURSE => [20, 10, 5],
			GAIN_POINT => [20, 10, 5],
			REMOVE_POINT => [20, 10, 5],
			SEAL_OWN_CURSE => [0, 0, 0],
			SEAL_OTHER_CURSE => [0, 0, 0],
			PROTECT_SELF => [0, 0, 0],
			PROTECT_OTHER => [0, 0, 0],
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

		return new Card([ADD_CURSE_OTHER]);
	}
}