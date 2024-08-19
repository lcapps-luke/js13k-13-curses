package;

import ui.Dice;
import ui.Button;
import ui.WaitTimer;
import ui.Tween;
import js.lib.Promise;
import ui.CardSprite;
import ui.Coin;
import game.Board;

class GameScreen extends AbstractScreen{
	private static inline var AI_PLAYER_INDEX = 1;
	private static inline var CHOOSE_LEADER_START = 0;
	private static inline var CHOOSE_LEADER_WAIT = 1;
	private static inline var CHOOSE_LEADER_FLIP = 2;
	private static inline var ROLL_DICE_START = 0;
	private static inline var ROLL_DICE_WAIT = 1;
	private static inline var ROLL_DICE = 2;
	private static inline var ROLL_DICE_END = 3;

	private var board = new Board();

	private var phaseFunc:Float->Void;
	private var phaseStep = CHOOSE_LEADER_START;

	private var round:Int = 1;
	private var roundTurn:Int = 0;

	private var playerTurn:Int = -1;

	private var playerHand = new Array<CardSprite>();
	private var aiHand = new Array<CardSprite>();

	private var coin = new Coin(Main.WIDTH + 420, Main.HEIGHT / 2 - 210, true);
	private var flipButton:Button;

	private var dice = new Dice(Main.WIDTH, Main.HEIGHT / 2 - 150);
	private var rollButton:Button;

	private var endTurnButton:Button;

	public function new(){
		super();
		phaseFunc = gameStartPhase;

		flipButton = new Button("Flip", "100px sans-serif", 0, Main.HEIGHT * 0.65, -1, 120);
		flipButton.x = Main.WIDTH / 2 - flipButton.w / 2;

		rollButton = new Button("Roll", "100px sans-serif", 0, Main.HEIGHT * 0.65, -1, 120);
		rollButton.x = Main.WIDTH / 2 - flipButton.w / 2;

		endTurnButton = new Button("End\nTurn", "40px sans-serif", 0, Main.HEIGHT / 2 + 10, -1, 130);
		endTurnButton.x = Main.WIDTH * 0.8 + Main.WIDTH / 10 - endTurnButton.w / 2;
	}

	override function update(s:Float) {
		super.update(s);

		//TODO render BG
		//TODO render round number
		//TODO render points
		//TODO render shop
		//TODO render player hands
		for(c in playerHand){
			c.update(s);
		}
		for(c in aiHand){
			c.update(s);
		}


		//TODO render curses
		//TODO render end turn button when relevent


		phaseFunc(s);
	}

	private function setPhase(p:Float->Void = null){
		phaseFunc = p == null ? s->{} : p;
		phaseStep = 0;
	}

	private function gameStartPhase(s:Float){
		setPhase();

		//draw cards
		var lastTween:Promise<Dynamic> = null;
		for(i in 0...6){
			var playerIndex = i % 2;

			var card = board.drawCard();
			board.players[playerIndex].cards.push(card);
			
			var spr = new CardSprite(card, Main.WIDTH, Main.HEIGHT / 2 - CardSprite.HEIGHT / 2);
			var hand = playerIndex == AI_PLAYER_INDEX ? aiHand : playerHand;
			hand.push(spr);

			var tx = (1080 / 5) * Math.floor(i / 2) + 20;
			var ty = playerIndex == AI_PLAYER_INDEX ? 120 : 1520;

			if(lastTween == null){
				lastTween = Tween.start(spr, {x:tx, y:ty}, 0.3);
			}else{
				lastTween = lastTween.then((t) -> {
					return Tween.start(spr, {x:tx, y:ty}, 0.3);
				});
			}
		}

		lastTween = lastTween.then((t) -> {
			return WaitTimer.sec(0.5);
		});

		for(p in playerHand){
			lastTween = lastTween.then((t) -> {
				return p.flip();
			});
		}

		lastTween = lastTween.then((t) -> {
			return WaitTimer.sec(0.5);
		}).then(t-> {
			setPhase(chooseLeaderPhase);
		});
	}

	private function chooseLeaderPhase(s:Float){
		coin.update(s);

		if(phaseStep == CHOOSE_LEADER_START){
			phaseStep = -1;
			Tween.start(coin, {x:Main.WIDTH / 2 - coin.w / 2}, 0.5).then(t->{
				phaseStep = CHOOSE_LEADER_WAIT;
			});
		}

		if(phaseStep == CHOOSE_LEADER_WAIT){
			flipButton.update();
			if(flipButton.clicked){
				phaseStep = CHOOSE_LEADER_FLIP;
	
				coin.flip().then(b -> {
					playerTurn = b ? 0 : 1;
					roundTurn = 0;
				}).then(t -> WaitTimer.sec(0.5)).then(t-> {
					return Tween.start(coin, {x:Main.WIDTH + coin.w}, 0.5);
				}).then((t) -> {
					setPhase(startTurnPhase);
				});
			}
		}
	}

	private function startTurnPhase(s:Float){
		dice.update(s);
		
		if(phaseStep == ROLL_DICE_START){
			phaseStep = -1;
			Tween.start(dice, {x:Main.WIDTH / 2 - dice.w / 2}, 0.5).then(t->{
				phaseStep = playerTurn == AI_PLAYER_INDEX ? ROLL_DICE : ROLL_DICE_WAIT;
			});
		}

		if(phaseStep == ROLL_DICE_WAIT){
			rollButton.update();
			if(rollButton.clicked){
				phaseStep = ROLL_DICE;
			}
		}

		if(phaseStep == ROLL_DICE){
			phaseStep = ROLL_DICE_END;

			dice.roll().then(p -> {
				board.players[playerTurn].points += p;
				return WaitTimer.sec(0.5);
			}).then(t -> {
				return Tween.start(dice, {x:Main.WIDTH}, 0.5);
			}).then(t -> {
				setPhase(mainTurnPhase);
			});
		}
	}

	private function mainTurnPhase(s:Float){
		if(playerTurn == AI_PLAYER_INDEX){
			aiTurnPhase(s);
		}else{
			playerTurnPhase(s);
		}
	}

	private function aiTurnPhase(s:Float){
		//TODO AI
		//TODO and turn
		nextTurn();
	}

	private function playerTurnPhase(s:Float){
		endTurnButton.update();
		if(endTurnButton.clicked){
			nextTurn();
		}
	}

	private function nextTurn(){
		roundTurn++;
		if(round < 2){
			playerTurn = playerTurn == 0 ? 1 : 0;
			setPhase(startTurnPhase);
		}else{
			nextRound();
		}
	}

	private function nextRound(){
		playerTurn = board.getTurnLeader();
		if(playerTurn == Board.TURN_DRAW){
			setPhase(chooseLeaderPhase);
		}
	}

}