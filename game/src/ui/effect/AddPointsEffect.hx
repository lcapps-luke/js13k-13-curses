package ui.effect;

import game.CardEffectLibrary;
import js.lib.Promise;
import game.Player;
import game.Board;

class AddPointsEffect extends CardEffectSprite{
	private var tx:Float;
	private var ty:Float;

	private var coinManager = new EphemeralObjectManager();
	private var callback:CardEffectSprite->Void = null;

	public function new(playerIndex:Int, board:Board, effectFunction:Player->Player->Void){
		super(playerIndex, board, effectFunction);

		ty = (playerIndex == 0) ? (Main.HEIGHT / 2 + 50) : (Main.HEIGHT / 2 - 80);
		tx = (playerIndex == 0) ? (GameScreen.SHOP_START_X / 2) : ((GameScreen.SHOP_START_X + GameScreen.SHOP_SLOT_WIDTH * 3 - 12.5) + GameScreen.SHOP_START_X / 2);
	}

	public function update(s:Float) {
		coinManager.update(s);

		if(callback != null && coinManager.count() < CardEffectLibrary.POINTS_EFFECT_QTY){
			applyEffect();
			callback(this);
			callback = null;

			coinManager.add(new EffectText(tx, ty, '+${CardEffectLibrary.POINTS_EFFECT_QTY}', "50px sans-serif", "#0F0"));
		}

		alive = coinManager.hasAlive();
	}

	public function play():Promise<CardEffectSprite> {
		for(i in 0...CardEffectLibrary.POINTS_EFFECT_QTY){
			coinManager.add(new AddCoin(x, y, tx, ty));
		}

		return new Promise((res, rej) -> {
			callback = res;
		});
	}
}