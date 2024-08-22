package ui;

using ui.ContextUtils;

class Button extends Region{
	private var label:String;
	private var font:String;

	private var textWidth:Float;

	public function new(label:String, font:String, x:Float, y:Float, w:Float, h:Float){
		super(x, y, w, h);

		Main.context.font = font;
		textWidth = Main.context.measureText(label).width;

		if(this.w <= 0){
			this.w = textWidth + 40;
		}

		this.label = label;
		this.font = font;
	}

	override function update(s:Float=0) {
		super.update(s);

		Main.context.lineWidth = 3;

		Main.context.strokeStyle = "#000";
		Main.context.fillStyle= switch(state){
			case Region.STATE_OVER: "#aaa";
			case Region.STATE_DOWN: "#555";
			default: "#fff";
		}
		Main.context.roundRect(x, y, w, h, 10, true, true);

		Main.context.font = font;
		Main.context.lineWidth = 10;
		Main.context.lineJoin="round";

		Main.context.fillStyle = "#000";
		Main.context.strokeStyle = "#fff";
		Main.context.strokeText(label, x + (w / 2 - textWidth / 2), y + h * 0.7, w);
		Main.context.fillText(label, x + (w / 2 - textWidth / 2), y + h * 0.7, w);
	}
}