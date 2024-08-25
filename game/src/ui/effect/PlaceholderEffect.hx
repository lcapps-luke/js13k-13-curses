package ui.effect;

import js.lib.Promise;
import game.Board;

class PlaceholderEffect extends CardEffectSprite{
	private var result:Int->Board->Void;

	public function new(playerIndex:Int, board:Board, result:Int->Board->Void){
		super(playerIndex, board);
		this.result = result;
	}

	public function update(s:Float) {}

	public function play():Promise<CardEffectSprite> {
		return new Promise((res, rej) -> {
			result(playerIndex, board);

			res(cast this);
		});
	}
}