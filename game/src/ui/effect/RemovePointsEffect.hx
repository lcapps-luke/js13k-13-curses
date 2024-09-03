package ui.effect;

import js.lib.Promise;
import game.CardEffectLibrary;
import game.Player;
import game.Board;

class RemovePointsEffect extends CardEffectSprite {

	private var coinManager = new EphemeralObjectManager();
	
	public function new(playerIndex:Int, board:Board, effectFunction:Player->Player->Void){
		super(playerIndex, board, effectFunction);

		y = (playerIndex == 1) ? (Main.HEIGHT / 2 + 50) : (Main.HEIGHT / 2 - 80);
		x = (playerIndex == 1) ? (GameScreen.SHOP_START_X / 2) : ((GameScreen.SHOP_START_X + GameScreen.SHOP_SLOT_WIDTH * 3 - 12.5) + GameScreen.SHOP_START_X / 2);
	}

	public function update(s:Float) {
		coinManager.update(s);
		alive = coinManager.hasAlive();
	}

	public function play():Promise<CardEffectSprite> {
		applyEffect();
		Sound.loseCoin();
		for(i in 0...CardEffectLibrary.POINTS_EFFECT_REMOVE_QTY){
			coinManager.add(new RemoveCoin(x, y));
		}

		coinManager.add(new EffectText(x, y, '-${CardEffectLibrary.POINTS_EFFECT_REMOVE_QTY}', "50px sans-serif", "#F00"));

		return WaitTimer.sec(0.5).then(t -> {return cast this;});
	}
}