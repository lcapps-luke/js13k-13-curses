package;

import Message.MessageType;
import multiplayer.ServerClient;
import ui.Button;

using ui.ContextUtils;

class MultiplayerScreen extends AbstractScreen{
	private var backButton:Button;
	
	private var hasConnected = false;
	private var statusText = "Connecting...";

	public function new(){
		super();

		backButton = new Button("Back", 100, 10, Main.HEIGHT - 150, 0, 140);
		backButton.onClick = () -> {
			ServerClient.close();
			Main.currentScreen = new MainMenuScreen();
		}

		ServerClient.connect();
	}

	override function update(s:Float) {
		super.update(s);

		Main.context.fillStyle = "#000";
		Main.context.font = "100px sans-serif";
		Main.context.centeredText("Multiplayer", 0, Main.WIDTH, Main.HEIGHT * 0.25);

		Main.context.font = "50px sans-serif";
		Main.context.centeredText(statusText, 0, Main.WIDTH, Main.HEIGHT * 0.5);

		backButton.update(s);

		if(ServerClient.connected && !hasConnected){
			hasConnected = true;
			statusText = "Connected";
		}
		if(!ServerClient.connected && hasConnected){
			statusText = "Connection Lost";
		}
		if(!ServerClient.connected && ServerClient.error != null){
			statusText = ServerClient.error;
		}

		if(ServerClient.hasMessage()){
			var msg = ServerClient.nextMessage();
			if(msg.type == MessageType.JOIN_WAITING_ROOM){
				statusText = "Finding Player...";
			}else if(msg.type ==  MessageType.JOIN_GAME){
				Main.currentScreen = new MultiplayerGameScreen(msg.state, msg.roll);
			}else{
				trace('Unexpected Message type: ${msg.type}');
			}
		}

		
	}
}