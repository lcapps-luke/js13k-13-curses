package;

import ui.Button;
import TimerManager.Timer;
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

	private var board = new Board();

	private var phaseFunc:Float->Void;
	private var playerTurn:Int = -1;

	private var playerHand = new Array<CardSprite>();
	private var aiHand = new Array<CardSprite>();

	private var chooseLeaderStep = CHOOSE_LEADER_START;
	private var coin = new Coin(Main.WIDTH + 420, Main.HEIGHT / 2 - 210, true);
	private var flipButton:Button;

	public function new(){
		super();
		phaseFunc = gameStartPhase;

		flipButton = new Button("Flip", "100px sans-serif", 0, Main.HEIGHT * 0.65, -1, 120);
		flipButton.x = Main.WIDTH / 2 - flipButton.w / 2;
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

	private function gameStartPhase(s:Float){
		phaseFunc = s->{};// set to blank phase to wait for this one to complete

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
			phaseFunc = chooseLeaderPhase;
		});
	}

	private function chooseLeaderPhase(s:Float){
		coin.update(s);

		if(chooseLeaderStep == CHOOSE_LEADER_START){
			Tween.start(coin, {x:Main.WIDTH / 2 - coin.w / 2}, 0.5).then(t->{
				chooseLeaderStep = CHOOSE_LEADER_WAIT;
			});
		}

		if(chooseLeaderStep == CHOOSE_LEADER_WAIT){
			flipButton.update();
			if(flipButton.clicked){
				chooseLeaderStep = CHOOSE_LEADER_FLIP;
	
				coin.flip().then(b -> {
					playerTurn = b ? 0 : 1;
				}).then(t -> WaitTimer.sec(0.5)).then(t-> {
					return Tween.start(coin, {x:Main.WIDTH + coin.w}, 0.5);
				}).then((t) -> {
					chooseLeaderStep = 0;
					phaseFunc = chooseLeaderPhase; //TODO turn start phase
				});
			}
		}
	}

}