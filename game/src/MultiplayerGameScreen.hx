package;

import multiplayer.MultiplayerData;
import peerjs.DataConnection;

class MultiplayerGameScreen extends GameScreen {
	private var remoteConnection:DataConnection;
	private var isHost:Bool;
	
	public function new(remoteConnection:DataConnection, isHost:Bool){
		super();
		this.remoteConnection = remoteConnection;
		this.isHost = isHost;

		remoteConnection.on(DataConnectionEventType.Data, onRemoteData);
		remoteConnection.on(DataConnectionEventType.Close, onConnectionLost);

		phaseFunc = initGame;

		myDrawIndex = isHost ? 0 : 1;
	}

	private function onRemoteData(data:MultiplayerData){
		
	}

	private function onConnectionLost(){
		//TODO display error, re-try connection, back to menu
	}

	private function initGame(s:Float){
		setPhase();

		//start card queue
		if(isHost){
			for(i in 0...6){
				board.enqueueCard();
			}
			remoteConnection.send({
				type: MultiplayerDataType.CARD_QUEUE,
				cardQueue: board.cardQueue
			});
		}

		//TODO trigger next phase
	}
}