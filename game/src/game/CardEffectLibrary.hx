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
			case GAIN_POINT: (s, o) -> s.points++;
			case REMOVE_POINT: (s, o) -> o.points--;
			case SEAL_OWN_CURSE: (s, o) -> {};
			case SEAL_OTHER_CURSE: (s, o) -> {};
			case PROTECT_SELF: (s, o) -> {};
			case PROTECT_OTHER: (s, o) -> {};
		}
	}
}