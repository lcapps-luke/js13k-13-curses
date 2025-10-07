package;

import Message.GameState;
import Message.MessageType;
import Message.ServerMessage;
import game.Board;
import game.Card;
import js.lib.Promise;
import multiplayer.ServerClient;

class MultiplayerGameScreen extends GameScreen {

	private var lastServerState:GameState;

	private var remotePlayerActionQueue = new Array<ServerMessage>();
	private var thisPlayerActionResponse = new Array<ServerMessage>();
	private var acceptMessages = true;

	public function new(initialState:GameState, diceRoll:Int){
		super();
		phaseFunc = initGame;

		this.lastServerState = initialState;
		this.dice.rig(diceRoll);
	}

	private function initGame(s:Float){
		setPhase();

		//pre-populate board with cards for hand and shop
		for(i in 0...3){
			var cardA = lastServerState.myState.hand[i];
			var cardB = lastServerState.theirState.hand[i];

			board.enqueueCard(Card.fromSerial(cardA));
			board.enqueueCard(Card.fromSerial(cardB));
		}

		for(sc in lastServerState.shop){
			board.enqueueCard(Card.fromSerial(sc));
		}

		coin.rig(lastServerState.turn);

		setPhase(gameStartPhase);
	}

	override function update(s:Float) {
		super.update(s);

		if(acceptMessages && ServerClient.hasMessage()){
			var msg = ServerClient.nextMessage();

			switch(msg.type){
				case MessageType.NEXT_TURN: onServerNextTurn(msg.turn, msg.roll);
				case MessageType.NEXT_ROUND: onServerNextRound(msg.state, msg.roll);
				case MessageType.ACTION_BUY: onServerAction(msg);
				case MessageType.ACTION_PLAY: onServerAction(msg);
				case MessageType.ACTION_END: onServerAction(msg);
			}
		}
	}

	override function aiTurnPhase(s:Float) {
		if(remotePlayerActionQueue.length == 0){
			return;
		}

		var msg = remotePlayerActionQueue.shift();
		acceptMessages = false;

		var lastPromise = Promise.resolve();
		if(msg.type == MessageType.ACTION_BUY){
			lastPromise = onOtherTurnBuy(lastPromise, msg.index);
		}else if(msg.type == MessageType.ACTION_PLAY){
			lastPromise = onOtherTurnPlay(lastPromise, msg.index);
		}
		lastPromise.then(n -> {
			acceptMessages = true;
		});
	}

	private function onServerNextTurn(myTurn:Bool, diceRoll:Int){
		dice.rig(diceRoll);
		playerTurn = myTurn ? 0 : 1;
		setPhase(startTurnPhase);
	}

	private function onServerNextRound(state:GameState, diceRoll:Int){
		var isDraw = board.getTurnLeader() == Board.TURN_DRAW;
		if(isDraw){
			coin.rig(state.turn);
		}
		
		dice.rig(diceRoll);

		for(sc in lastServerState.shop){
			board.enqueueCard(Card.fromSerial(sc));
		}

		lastServerState = state; //TODO sync / validate state

		setPhase(startRoundPhase);
	}

	private function onServerAction(msg:ServerMessage){
		if(msg.turn){
			thisPlayerActionResponse.push(msg);
		}else{
			remotePlayerActionQueue.push(msg);
		}
	}

	override function onPlayerTurnEndTurnClicked() {
		phaseStep = -1;
		ServerClient.endTurn();
	}
}