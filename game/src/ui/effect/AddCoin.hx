package ui.effect;

using ui.ContextUtils;

class AddCoin extends Sprite{
	private static inline var ACC = 1500;
	private static inline var RAD = 20;

	private var xs:Float;
	private var ys:Float;
	private var tx:Float;
	private var ty:Float;

	public function new(x:Float, y:Float, tx:Float, ty:Float){
		super(x, y, RAD * 2, RAD * 2);
		var dir = Math.random() * (Math.PI * 2);
		var spd = RAD + Math.random() * (RAD * 5);
		this.xs = Math.cos(dir) * spd;
		this.ys = Math.sin(dir) * spd;

		this.tx = tx;
		this.ty = ty;
	}

	public function update(s:Float) {
		var dir = Math.atan2(ty-y, tx-x);
		xs += Math.cos(dir) * ACC * s;
		ys += Math.sin(dir) * ACC * s;

		x += xs * s;
		y += ys * s;

		Main.context.fillStyle = "#ff0";
		Main.context.beginPath();
		Main.context.circle(x, y, w / 2);
		Main.context.fill();

		if(Math.abs(x - tx) < 60 && Math.abs(y - ty) < 40){
			Sound.gainCoin();
			alive = false;
		}
	}
}