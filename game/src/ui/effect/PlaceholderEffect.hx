package ui.effect;

import js.lib.Promise;

class PlaceholderEffect extends CardEffectSprite{
	public function update(s:Float) {}

	public function play():Promise<CardEffectSprite> {
		return new Promise((res, rej) -> {
			applyEffect();
			res(cast this);
		});
	}
}