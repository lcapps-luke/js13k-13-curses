package ui;

import js.lib.Promise;

using ui.ContextUtils;

class Notice extends Sprite {
	private static inline var MARGIN = 40.0;

	private var text:TextSprite;

	public function new(cx:Float, cy:Float, text:String){
		super(0, 0, 1, 1);
		
		this.text = new TextSprite(0, 0, text, 50, "#000");
		this.w = this.text.w + MARGIN * 2;
		this.h = this.text.h + MARGIN * 2;
		this.x = cx - this.w / 2;
		this.y = cy - this.w / 2;
	}

	function update(s:Float) {
		Main.context.strokeStyle = "#000";
		Main.context.fillStyle = "#F00";
		Main.context.roundRect(x, y, w, h, 5, true, true);
		
		text.x = x + MARGIN;
		text.y = y + MARGIN * 0.7;
		text.update(s);
	}

	public function peek(toY:Float, holdTime:Float):Promise<Tween>{
		var startY = y;
		return Tween.start(this, {y: toY}, 0.2).then(t -> {
			return WaitTimer.sec(holdTime);
		}).then(w -> {
			return Tween.start(this, {y: startY}, 0.2);
		});
	}
}