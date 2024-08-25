package ui.effect;

import js.lib.Promise;

class CurseEffect extends CardEffectSprite{
	public function update(s:Float) {}

	
	public function play():Promise<CardEffectSprite> {
		return new Promise((res, rej) -> {
			board.players[playerIndex == 0 ? 1 : 0].curses++;

			res(cast this);
		});
	}
}