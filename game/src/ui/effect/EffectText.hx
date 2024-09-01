package ui.effect;

using ui.ContextUtils;

class EffectText extends Sprite{
	private static inline var Y_SPEED = -80;
	private static inline var A_SPEED = 1;

	private var str:String;
	private var fnt:String;
	private var sty:String;

	public function new(x:Float, y:Float, str:String, fnt:String, sty:String){
		super(x, y, 1, 1);
		this.str = str;
		this.fnt = fnt;
		this.sty = sty;
	}

	public function update(s:Float) {
		y += Y_SPEED * s;
		a -= A_SPEED * s;

		Main.context.globalAlpha = a;
		Main.context.font = fnt;
		Main.context.fillStyle = sty;
		Main.context.centeredText(str, x, 0, y);
		Main.context.globalAlpha = 1;

		this.alive = a > 0;
	}
}