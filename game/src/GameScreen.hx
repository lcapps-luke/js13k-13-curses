package;

import TimerManager.Timer;
import ui.WaitTimer;
import ui.Tween;
import js.lib.Promise;
import ui.CardSprite;
import game.Board;

class GameScreen extends AbstractScreen{
	private static inline var AI_PLAYER_INDEX = 1;

	private var board = new Board();

	private var phaseFunc:Float->Void;
	private var playerTurn:Int = -1;

	private var playerHand = new Array<CardSprite>();
	private var aiHand = new Array<CardSprite>();

	public function new(){
		super();
		phaseFunc = gameStartPhase;
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

		//TODO draw cards
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
		//TODO flip coin
		//TODO move to player / ai roll phase
	}

}