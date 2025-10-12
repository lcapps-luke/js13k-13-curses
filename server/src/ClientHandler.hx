package;

import hx.ws.Buffer;
import hx.ws.SocketImpl;
import hx.ws.WebSocketHandler;
import Message.ClientMessage;
import Message.GameState;
import Message.MessageType;
import Message.ServerMessage;
import haxe.Json;
import uuid.Uuid;

class ClientHandler extends WebSocketHandler {
	public var clientId(default, null):String;
	public var waitingSince(default, null):Float;
	public var gamesStarted(default, null) = 0;
	public var gamesCompleted(default, null) = 0;

	private var game:Game;
	public var index(default, null):Int;

	//TODO ready state & lobby code to control matching?

	public function new(socket:SocketImpl){
		super(socket);

		this.onclose = onSocketClose;
		this.onerror = onSocketError;
		this.onopen = onSocketOpen;
		this.onmessage = onSocketMessage;

		clientId = Uuid.nanoId();
		waitingSince = Sys.time();
	}

	public function isConnected(){
		return state != Closed; 
	}

	public function isReady(){
		return isConnected() && state != Handshake;
	}

	public function onJoinWaitingRoom() {
		waitingSince = Sys.time(); //TODO only update after complete game?
		sendMessage({
			type: MessageType.JOIN_WAITING_ROOM
		});
	}

	public function onJoinGame(game:Game, index:Int, state:GameState, diceRoll:Int){
		this.game = game;
		this.index = index;
		gamesStarted++;
		sendMessage({
			type: MessageType.JOIN_GAME,
			state: state,
			roll: diceRoll
		});
	}

	public function gameDisconnected(){
		sendMessage({
			type: MessageType.LEFT_GAME,
			message: "Player Disconnected"
		});
	}

	public function cardPurchased(playerIndex:Int, cardIndex:Int){
		sendMessage({
			type: MessageType.ACTION_BUY,
			turn: playerIndex == this.index,
			index: cardIndex
		});
	}

	public function cardPlayed(playerIndex:Int, cardIndex:Int, cardSerial:String){
		sendMessage({
			type: MessageType.ACTION_PLAY,
			index: cardIndex,
			turn: playerIndex == this.index,
			card: cardSerial
		});
	}

	public function turnStart(playerIndex:Int, diceRoll:Int){
		sendMessage({
			type: MessageType.NEXT_TURN,
			turn: playerIndex == this.index,
			roll: diceRoll
		});
	}

	public function startRound(state:GameState, diceRoll:Int){
		sendMessage({
			type: MessageType.NEXT_ROUND,
			state: state,
			roll: diceRoll
		});
	}

	public function gameOver(winner:Int){
		gamesCompleted++;
		sendMessage({
			type: MessageType.GAME_OVER,
			turn: winner == index
		});
	}

	public function sendMessage(message:ServerMessage) {
		send(Json.stringify(message));
	}
	
	private function onSocketOpen(){
		Logger.debug('Socket Open: ${clientId}');
		Main.waitingRoom.add(this);
	}
	private function onSocketClose(){
		Logger.debug('Socket Close: ${clientId}');
		Main.waitingRoom.remove(this);
	}
	private function onSocketError(message:Dynamic){
		Logger.debug('Socket Error: ${clientId} - ${message}');
	}

	private function onSocketMessage(msg:hx.ws.Types.MessageType){
		switch(msg){
			case BytesMessage(content): onSocketMessageBytes(content);
			case StrMessage(content): onSocketMessageString(content);
		}
	}

	private function onSocketMessageBytes(message:Buffer){
		Logger.debug('Socket Bytes: ${clientId} - ${message}');
	}

	private function onSocketMessageString(message:String){
		Logger.debug('Socket String: ${clientId} - ${message}');
		var clientMessage:ClientMessage = Json.parse(message);
		
		try{
			switch(clientMessage.type){
				case MessageType.ACTION_BUY: game.buyCard(index, clientMessage.index);
				case MessageType.ACTION_PLAY: game.playCard(index, clientMessage.index);
				case MessageType.ACTION_END: game.endTurn(index);
				default: sendMessage({
					type: MessageType.ERROR,
					message: "Invalid message type"
				});
			}
		}catch(e:ActionException){
			sendMessage({
				type: MessageType.ERROR,
				message: e.message
			});
		}

	}
}