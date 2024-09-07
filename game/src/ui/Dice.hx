package ui;

import js.lib.Promise;

using ui.ContextUtils;

class Dice extends Sprite{
	public static inline var HEIGHT = 400;

	private var t:Float = 1;
	private var c:Int->Void = null;
	private var f:Int = 1;
	private var r:Float = 0.1;

	public function new(x:Float, y:Float){
		super(x, y, HEIGHT, HEIGHT);
	}

	public function update(s:Float) {
		if(c != null){
			t -= s;
			r -= s;

			if(t < 0){
				c(f);
				c = null;
			}

			if(r < 0){
				r = 0.1;
				var nf = Math.ceil(Math.random() * 6);
				if(nf != f){
					Sound.roll();
					f = nf;
				}
			}
		}

		Main.context.lineWidth = 3;
		Main.context.strokeStyle = "#000";
		Main.context.fillStyle = "#f00";
		Main.context.roundRect(x, y, w, h, 40, true);

		Main.context.font = "300px sans-serif";
		Main.context.fillStyle = "#fff";
		var tx = Std.string(f);
		Main.context.centeredText(tx, x, w, y + (h / 2 - 300 * -0.35));
	}

	public function roll():Promise<Int>{
		return new Promise((res, rej) -> {
			c = res;
			t = 1;
		});
	}
}