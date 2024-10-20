package multiplayer;

import game.Card;

typedef MultiplayerData = {
	var type:MultiplayerDataType;
	var ?cardQueue:Array<Card>;
};

enum MultiplayerDataType{
	CARD_QUEUE;
}