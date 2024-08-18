package ui;

import js.lib.Promise;
import game.Card;

using ui.ContextUtils;

class CardSprite extends Sprite{
	public static inline var WIDTH = 180;
	public static inline var HEIGHT = 280;

	private var card:Card;

	private var faceDown:Bool = false;

	public function new(card:Card, x:Float, y:Float, faceDown:Bool = true){
		super(x, y, WIDTH, HEIGHT);
		this.card = card;
	}

	public function update(s:Float) {
		Main.context.lineWidth = 3;
		Main.context.strokeStyle = "#000";
		Main.context.fillStyle = faceDown ? "#f00" : "#00f";
		Main.context.roundRect(x + (w - scaleX * w) / 2, y, w * scaleX, h, 5, true);
	}

	public function flip():Promise<Tween>{
		return Tween.start(this, {scaleX:0}, 0.2).then((t) -> {
			faceDown = !faceDown;
			return Tween.start(this, {scaleX:1}, 0.2);
		});
	}
}