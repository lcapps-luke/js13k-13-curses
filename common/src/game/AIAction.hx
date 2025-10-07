package game;

typedef AIAction = {
	var type:ActionType;
	var index:Int;
}

enum ActionType{
	BUY;
	PLAY;
	END;
}