package;

import peerjs.DataConnection;
import peerjs.DataConnection.DataConnectionEventType;
import ui.TextInput;
import js.Browser;
import ui.Button;
import peerjs.Peer;
import peerjs.Peer.PeerEventType;

using ui.ContextUtils;

class MultiplayerScreen extends AbstractScreen{
	private static var peer:Peer = null;
	private static var myId:String = null;
	private static var incomingConnection:DataConnection = null;

	private var backButton:Button;
	private var copyButton:Button;

	private var idInput:TextInput;
	private var pasteButton:Button;
	private var joinButton:Button;

	public function new(){
		super();

		if(incomingConnection != null){
			incomingConnection.close();
			incomingConnection = null;
		}

		if(peer == null){
			peer = new Peer();
			peer.on(PeerEventType.Open, onOpen);
			peer.on(PeerEventType.Connection, onConnection);
		}

		backButton = new Button("Back", 100, 10, Main.HEIGHT - 150, 0, 140);
		backButton.onClick = () -> {
			Main.currentScreen = new MainMenuScreen();
			idInput.destroy();
		}

		copyButton = new Button("Copy Link", 30, 0, Main.HEIGHT * 0.35 + 50, 0, 50);
		copyButton.x = Main.WIDTH / 2 - copyButton.w / 2;
		copyButton.onClick = () -> {
			var link = Browser.location;
			link.hash = myId;
			Browser.navigator.clipboard.writeText(link.href);
		};

		idInput = new TextInput(20, Main.HEIGHT * 0.5, Main.WIDTH - 40, 70);
		pasteButton = new Button("Paste Link", 30, 0, Main.HEIGHT * 0.5 + 100, 0, 50);
		pasteButton.x = Main.WIDTH / 2 - pasteButton.w / 2;
		pasteButton.onClick = () -> {
			Browser.navigator.clipboard.readText().then((txt) -> {
				var hashIndex = txt.indexOf("#");
				if(hashIndex != -1){
					txt = txt.substr(hashIndex + 1);
				}
				idInput.set(txt);
			});
		};

		joinButton = new Button("Join", 60, 0, pasteButton.y + 200, 0, 80);
		joinButton.x = Main.WIDTH / 2 - joinButton.w / 2;
		joinButton.onClick = onJoinClicked;
	}

	private static function onOpen(id:String){
		myId = id;
	}
	private static function onConnection(conn:DataConnection){
		incomingConnection = conn;
	}

	override function update(s:Float) {
		super.update(s);

		Main.context.fillStyle = "#000";
		Main.context.font = "100px sans-serif";
		Main.context.centeredText("Multiplayer", 0, Main.WIDTH, Main.HEIGHT * 0.25);

		Main.context.font = "50px sans-serif";
		Main.context.centeredText('ID: $myId', 0, Main.WIDTH, Main.HEIGHT * 0.35);
		copyButton.update();

		idInput.update();
		pasteButton.update();
		joinButton.update();

		backButton.update(s);

		if(incomingConnection != null){
			startGame(incomingConnection, true);
		}
	}

	private function onJoinClicked(){
		joinButton.enabled = false;

		var conn = peer.connect(idInput.get());
		conn.on(DataConnectionEventType.Open, function(){
			startGame(conn, false);
		});
		conn.on(DataConnectionEventType.Error, function(err){
			//TODO display error
			Browser.console.error(err);
			joinButton.enabled = true;
		});
	}

	private function startGame(remoteConnection:DataConnection, host:Bool){

	}
}