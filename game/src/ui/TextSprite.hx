package ui;

class TextSprite extends Sprite{
	private var text:String;
	private var size:Float;
	private var fillStyle:String;
	
	public function new(x:Float, y:Float, text:String, size:Float, fill:String){
		super(x, y, 0, size);

		this.text = text;
		this.size = size;
		this.fillStyle = fill;

		Main.context.font = '${size}px sans-serif';
		w = Main.context.measureText(text).width;
	}

	public function update(s:Float) {
		Main.context.fillStyle = fillStyle;
		Main.context.font = '${size*scaleY}px sans-serif';
		Main.context.fillText(text, x, y + h);
	}
}