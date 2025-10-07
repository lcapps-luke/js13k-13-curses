package;

import Message.ClientMessage;
import Message.GameState;
import Message.PlayerState;
import Message.ServerMessage;
import game.Board;
import game.CardEffectLibrary;

class Game {
	private var playerA:GameClient; // 0
	private var playerB:GameClient; // 1

	private var board:Board;
	private var playerTurn = -1;
	private var round:Int = 0;
	private var roundTurn:Int = 0;

	public function new(playerA:GameClient, playerB:GameClient){
		this.playerA = playerA;
		this.playerB = playerB;
	}

	public function init() {
		// create deck
		board = new Board();

		// deal hand
		for(i in 0...6){
			var drawIndex = i % 2;
			var playerIndex = drawIndex == 0 ? 0 : 1;
			var card = board.drawCard();
			board.players[playerIndex].cards.push(card);
		}
		board.resetShop();
		playerTurn = coinFlip() ? 0 : 1;

		// send initial state to all
		var diceRoll = rollDice();
		playerA.onJoinGame(this, 0, makeState(0), diceRoll);
		playerB.onJoinGame(this, 1, makeState(1), diceRoll);

		board.players[playerTurn].points += diceRoll;
	}

	public function update():Bool {
		// check game ended
		if(board.gameOver()){
			return false;
		}

		// check player disconnect
		if(!playerA.isConnected() || !playerB.isConnected()){

			if(playerA.isConnected()){
				playerA.gameDisconnected();
			}
			if(playerB.isConnected()){
				playerB.gameDisconnected();
			}

			return false; // one or more players disconnected, ending game
		}

		// check turn timeout
		return true;
	}

	public function buyCard(playerIndex:Int, cardIndex:Int){
		validateTurn(playerIndex);
		var player = board.players[playerIndex];
		if(player.cards.length >= 5){
			throw new ActionException("Too Many Cards");
		}

		var card = board.shop[cardIndex];

		if(player.points < card.cost){
			throw new ActionException("Cannot Afford");
		}

		player.points -= card.cost;
		player.cards.push(card);
		board.shop[cardIndex] = null;

		playerA.cardPurchased(playerIndex, cardIndex);
		playerB.cardPurchased(playerIndex, cardIndex);
	}

	public function playCard(playerIndex:Int, cardIndex:Int){
		validateTurn(playerIndex);
		var player = board.players[playerIndex];
		var other = board.players[playerIndex == 0 ? 1 : 0];
		var card = player.cards[cardIndex];
		if(!card.canPlay(player, other)){
			throw new ActionException("Cannot Play Card");
		}

		for(e in card.effects){
			CardEffectLibrary.getEffectFunction(e)(player, other);
		}

		player.cards.remove(card);
		
		playerA.cardPlayed(playerIndex, cardIndex, card.getSerial());
		playerB.cardPlayed(playerIndex, cardIndex, card.getSerial());

		if(board.gameOver()){
			playerA.gameOver(board.getWinner());
			playerB.gameOver(board.getWinner());
		}
	}

	public function endTurn(playerIndex:Int){
		validateTurn(playerIndex);

		roundTurn++;
		if(roundTurn < 2){
			playerTurn = playerTurn == 0 ? 1 : 0;
			startTurn();
		}else{
			startRound();
		}
	}

	public function addRemainingPlayersToWaitingRoom(waitingRoom:WaitingRoom) {
		if(playerA.isConnected()){
			waitingRoom.add(playerA);
		}
		if(playerB.isConnected()){
			waitingRoom.add(playerB);
		}
	}

	private function validateTurn(index:Int){
		if(index != playerTurn){
			throw new ActionException("Not Your Turn");
		}
	}

	private function startTurn(){
		var diceRoll = rollDice();
		board.players[playerTurn].points += diceRoll;
		playerA.turnStart(playerTurn, diceRoll);
		playerB.turnStart(playerTurn, diceRoll);
	}

	private function startRound(){
		board.resetShop();
		roundTurn = 0;
		playerTurn = board.getTurnLeader();
		if(playerTurn == Board.TURN_DRAW){
			playerTurn = coinFlip() ? 0 : 1;
		}
		var diceRoll = rollDice();
		playerA.startRound(makeState(0), diceRoll);
		playerB.startRound(makeState(1), diceRoll);
		board.players[playerTurn].points += diceRoll;
	}

	private function coinFlip():Bool{
		return Math.random() > 0.5;
	}

	private function rollDice():Int{
		return Math.ceil(Math.random() * 6);
	}

	private function makeState(playerIdx:Int):GameState{
		return {
			turn: playerTurn == playerIdx,
			shop: board.shop.map(c -> c.getSerial()),
			myState: makePlayerState(playerIdx, true),
			theirState: makePlayerState(playerIdx == 0 ? 1 : 0, false),
		}
	}

	private function makePlayerState(playerIdx:Int, show:Bool):PlayerState{
		return {
			curses: board.players[playerIdx].curses,
			points: board.players[playerIdx].points,
			hand: board.players[playerIdx].cards.map(c -> {
				return show ? c.getSerial() : "";
			})
		}
	}
}