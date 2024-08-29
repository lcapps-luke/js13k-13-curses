package ui;

import js.html.ImageBitmap;
import js.lib.Promise;
import game.Card;

using ui.ContextUtils;

class CardSprite extends Sprite{
	public static inline var WIDTH = 180;
	public static inline var HEIGHT = 280;

	public var card(default,null):Card;
	private var imgFront:ImageBitmap = null;
	private var imgBack:ImageBitmap = null;

	private var faceDown:Bool = true;

	public function new(card:Card, x:Float, y:Float, faceDown:Bool = true){
		super(x, y, WIDTH, HEIGHT);
		this.card = card;
		
		imgBack = CardImageRepository.getBack();
		imgFront = CardImageRepository.getImage(card);
	}

	public function update(s:Float) {
		if(imgBack != null && imgFront != null){
			Main.context.drawImage(faceDown ? imgBack : imgFront, 0, 0, imgBack.width, imgBack.height, x + (w - scaleX * w) / 2, y, w * scaleX, h * scaleY);
		}
	}

	public function flip():Promise<Tween>{
		return Tween.start(this, {scaleX:0}, 0.2).then((t) -> {
			faceDown = !faceDown;
			return Tween.start(this, {scaleX:1}, 0.2);
		});
	}
}