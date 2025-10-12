package multiplayer;

import Message.ClientMessage;
import Message.MessageType;
import haxe.Json;
import Message.ServerMessage;
import js.html.MessageEvent;
import js.html.WebSocket;

class ServerClient {
	//private static inline var SERVER_URL = "ws://localhost";
	private static inline var SERVER_URL = "wss://13curses.lc-apps.duckdns.org/ws/";

	private static var socket:WebSocket;
	public static var connected(default, null):Bool = false;
	public static var error(default, null):Null<String> = null;

	private static var messageQueue = new Array<ServerMessage>();

	public static function connect(){
		close();
		error = null;
		socket = new WebSocket(SERVER_URL);
		socket.onopen = onOpen;
		socket.onclose = onClose;
		socket.onmessage = onMessage;
		socket.onerror = onError;
	}
	
	public static function close(){
		if(socket != null){
			socket.close();
			connected = false;
			socket = null;
		}
	}

	private static function onOpen(){
		connected = true;
	}

	private static function onClose(){
		connected = false;
	}

	private static function onMessage(m:MessageEvent){
		messageQueue.push(Json.parse(m.data));
	}

	private static function onError(){
		error = "Connection Error";
	}

	public static function hasMessage(){
		return messageQueue.length > 0;
	}

	public static function nextMessage(){
		return messageQueue.shift();
	}

	private static function sendMessage(message:ClientMessage) {
		socket.send(Json.stringify(message));
	}

	public static function endTurn() {
		sendMessage({
			type: MessageType.ACTION_END
		});
	}

	public static function buy(idx:Int) {
		sendMessage({
			type: MessageType.ACTION_BUY,
			index: idx
		});
	}

	public static function play(idx:Int) {
		sendMessage({
			type: MessageType.ACTION_PLAY,
			index: idx
		});
	}
}