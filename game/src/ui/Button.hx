package ui;

using ui.ContextUtils;

class Button extends Region{
	private var label:String;
	private var fontSize:Int;

	private var textWidth:Float;

	public function new(label:String, fontSize:Int, x:Float, y:Float, w:Float, h:Float){
		super(x, y, w, h);

		Main.context.font = '${fontSize}px sans-serif';
		textWidth = Main.context.measureText(label).width;

		if(this.w <= 0){
			this.w = textWidth + 40;
		}

		this.label = label;
		this.fontSize = fontSize;
	}

	override function update(s:Float=0) {
		super.update(s);

		Main.context.lineWidth = 3;

		Main.context.strokeStyle = "#000";
		Main.context.fillStyle= switch(state){
			case Region.STATE_OVER: "#0c4";
			case Region.STATE_DOWN: "#084";
			default: "#094";
		}
		Main.context.roundRect(x, y, w, h, 10, true, true);

		Main.context.font = '${fontSize}px sans-serif';
		Main.context.lineWidth = 10;
		Main.context.lineJoin="round";

		Main.context.fillStyle = "#000";
		Main.context.strokeStyle = "#fff";
		Main.context.centeredText(label, x, w, y + (h / 2 - fontSize * -0.35));

		if(!enabled){
			Main.context.strokeStyle = "#000";
			Main.context.moveTo(x, y + h / 2);
			Main.context.lineTo(x + w, y + h / 2);
			Main.context.stroke();
		}
	}
}