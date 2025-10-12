package;

import Message.GameState;
import Message.MessageType;
import Message.ServerMessage;
import game.Board;
import game.Card;
import js.lib.Promise;
import multiplayer.ServerClient;
import ui.Alert;
import ui.Notice;

class MultiplayerGameScreen extends GameScreen {

	private var lastServerState:GameState;

	private var remotePlayerActionQueue = new Array<ServerMessage>();
	private var thisPlayerActionResponse = new Array<ServerMessage>();
	private var acceptMessages = true;

	private var pendingAction:Int = -1;
	private var notice:Null<Notice> = null;
	private var alert:Null<Alert> = null;

	private var gameEnded = false;

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

		//handle disconnects
		if(!gameEnded && !ServerClient.connected){
			showAlert("Connection Lost", () -> {
				Main.currentScreen = new MainMenuScreen();
			});
		}

		if(acceptMessages && ServerClient.hasMessage()){
			var msg = ServerClient.nextMessage();

			switch(msg.type){
				case MessageType.NEXT_TURN: onServerNextTurn(msg.turn, msg.roll);
				case MessageType.NEXT_ROUND: onServerNextRound(msg.state, msg.roll);
				case MessageType.ACTION_BUY: onServerAction(msg);
				case MessageType.ACTION_PLAY: onServerAction(msg);
				case MessageType.ACTION_END: onServerAction(msg);
				case MessageType.ERROR: thisPlayerActionResponse.push(msg);
				case MessageType.LEFT_GAME: onGameQuit(msg.message);
				case MessageType.GAME_OVER: onGameOver(msg.turn);
			}
		}

		if(notice != null){
			notice.update(s);
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
			// Replace hidden card
			var revealedCard = Card.fromSerial(msg.card);
			board.players[1].cards[msg.index] = revealedCard;
			aiHand[msg.index].replace(revealedCard);
			lastPromise = onOtherTurnPlay(lastPromise, msg.index);
		}
		lastPromise.then(n -> {
			acceptMessages = true;
			if(board.gameOver()){
				setPhase(gameEndPhase);
			}
		});
	}

	override function playerTurnPhase(s:Float) {
		super.playerTurnPhase(s);

		if(thisPlayerActionResponse.length == 0){
			return;
		}

		var msg = thisPlayerActionResponse.shift();
		if(msg.type == MessageType.ERROR){
			onPlayerTurnInvalidAction(msg.message);
		}else if(msg.type == MessageType.ACTION_BUY){
			onPlayerTurnBuyAction(msg.index);
		}else if(msg.type == MessageType.ACTION_PLAY){
			onPlayerTurnPlayCardAction(msg.index);
		}

	}

	private function gameCancelledPhase(s:Float){
		alert.update(s);
	}

	private function onServerNextTurn(myTurn:Bool, diceRoll:Int){
		dice.rig(diceRoll);
		playerTurn = myTurn ? 0 : 1;
		setPhase(startTurnPhase);
	}

	private function onServerNextRound(state:GameState, diceRoll:Int){
		lastServerState = state; //TODO sync / validate cards
		board.players[0].curses = state.myState.curses;
		board.players[0].points = state.myState.points;
		board.players[1].curses = state.theirState.curses;
		board.players[1].points = state.theirState.points;

		var isDraw = board.getTurnLeader() == Board.TURN_DRAW;
		if(isDraw){
			coin.rig(state.turn);
		}
		
		dice.rig(diceRoll);

		for(sc in lastServerState.shop){
			board.enqueueCard(Card.fromSerial(sc));
		}

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

	override function onPlayerTurnBuy() {
		pendingAction = MessageType.ACTION_BUY;
		ServerClient.buy(selectedHandIndex);
	}

	override function onPlayerTurnPlayCard() {
		pendingAction = MessageType.ACTION_PLAY;
		ServerClient.play(selectedHandIndex);
	}

	private function onPlayerTurnInvalidAction(message:String){
		snowNotice(message);

		if(pendingAction == MessageType.ACTION_BUY){
			phaseStep = GameScreen.PLAYER_TURN_SHOW_SHOP;
		}else if(pendingAction == MessageType.ACTION_PLAY){
			phaseStep = GameScreen.PLAYER_TURN_SHOW_HAND;
		}else{
			phaseStep = GameScreen.PLAYER_TURN_WAIT;
		}

		pendingAction = -1;
	}

	private function onPlayerTurnBuyAction(idx:Int){
		selectedHandIndex = idx;
		super.onPlayerTurnBuy();
	}

	private function onPlayerTurnPlayCardAction(idx:Int){
		selectedHandIndex = idx;
		super.onPlayerTurnPlayCard();
	}

	private function onGameQuit(msg:String){
		showAlert(msg, () -> {
			ServerClient.close();
			Main.currentScreen = new MainMenuScreen();
		});
	}

	private function onGameOver(win:Bool){
		gameEnded = true;
		ServerClient.close();
	}

	private function showAlert(message:String, callback:Void->Void){
		alert = new Alert(message, callback);
		alert.x = Main.WIDTH / 2 - alert.w / 2;
		alert.y = Main.HEIGHT / 2 - alert.h / 2;

		Main.timerManager.killAll();
		setPhase(gameCancelledPhase);
	}

	private function snowNotice(message:String){
		notice = new Notice(Main.WIDTH / 2, 0, message);
		notice.peek(notice.h + 20, 1).then(t -> {
			notice = null;
		});
	}
}