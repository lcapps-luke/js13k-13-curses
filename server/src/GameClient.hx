package;

import haxe.Log;
import Message.ClientMessage;
import Message.GameState;
import Message.MessageType;
import Message.ServerMessage;
import haxe.Json;
import haxe.io.Bytes;
import haxe.net.WebSocket;
import uuid.Uuid;

class GameClient {
	private var socket:WebSocket;
	public var id(default, null):String;
	public var waitingSince(default, null):Float;
	public var gamesStarted(default, null) = 0;
	public var gamesCompleted(default, null) = 0;

	private var game:Game;
	public var index(default, null):Int;

	//TODO ready state & lobby code to control matching?

	public function new(socket:WebSocket){
		this.socket = socket;
		socket.onopen = onSocketOpen;
		socket.onclose = onSocketClose;
		socket.onerror = onSocketError;
		socket.onmessageBytes = onSocketMessageBytes;
		socket.onmessageString = onSocketMessageString;

		id = Uuid.nanoId();
		waitingSince = Sys.time();
	}

	public function update():Bool {
		#if sys
		socket.process();
		#end
		return socket.readyState != Closed;
	}

	public function isConnected(){
		return !(socket.readyState == Closing || socket.readyState == Closed); 
	}

	public function isReady(){
		return socket.readyState == Open;
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
		socket.sendString(Json.stringify(message));
	}
	
	private function onSocketOpen(){
		Logger.debug('Socket Open: ${id}');
	}
	private function onSocketClose(){
		Logger.debug('Socket Close: ${id}');
	}
	private function onSocketError(message:String){
		Logger.debug('Socket Error: ${id} - ${message}');
	}
	private function onSocketMessageBytes(message:Bytes){
		Logger.debug('Socket Bytes: ${id} - ${message}');
	}

	private function onSocketMessageString(message:String){
		Logger.debug('Socket String: ${id} - ${message}');
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