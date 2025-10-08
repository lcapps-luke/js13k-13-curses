package ui;

using ui.ContextUtils;

class Alert extends Sprite {
	private static inline var MARGIN = 40.0;
	private var callback:Void->Void;

	private var message:TextSprite;
	private var btn:Button;

	public function new(message:String, callback:Void->Void){
		super(0, 0, 0, 0);
		this.message = new TextSprite(0, 0, message, 50, "#000");
		btn = new Button("OK", 40, 0, 0, -1, 130);
		btn.onClick = callback;

		w = Math.max(this.message.w, btn.w) + MARGIN * 2;
		h = this.message.h + btn.h + MARGIN * 4;
	}

	function update(s:Float) {
		message.x = x + w / 2 - message.w / 2;
		message.y = y + MARGIN;

		btn.x = x + w / 2 - btn.w / 2;
		btn.y = y + h - btn.h - MARGIN;

		Main.context.strokeStyle = "#000";
		Main.context.fillStyle = "#094";
		Main.context.roundRect(x, y, w, h, 5, true, true);

		message.update(s);
		btn.update(s);
	}
}