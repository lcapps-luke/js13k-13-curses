package;

typedef ServerMessage = {
	var type:Int;
	var ?message:String;
	var ?state:GameState;
	var ?roll:Int;
	var ?turn:Bool;
	var ?index:Int;
	var ?card:String;
}

typedef ClientMessage = {
	var type:Int;
	var ?index:Int;
}

class MessageType{
	public static inline var JOIN_WAITING_ROOM = 0;
	public static inline var JOIN_GAME = 1;
	public static inline var LEFT_GAME = 2;
	public static inline var ACTION_BUY = 3;
	public static inline var ACTION_PLAY = 4;
	public static inline var ACTION_END = 5;
	public static inline var ERROR = 6;
	public static inline var NEXT_TURN = 7;
	public static inline var NEXT_ROUND = 8;
	public static inline var GAME_OVER = 9;
}

typedef GameState = {
	var turn:Bool; // this player's turn
	var myState:PlayerState;
	var theirState:PlayerState;
	var shop:Array<String>;
}

typedef PlayerState = {
	var hand:Array<String>;
	var curses:Int;
	var points:Int;
}