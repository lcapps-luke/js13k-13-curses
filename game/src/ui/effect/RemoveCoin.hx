package ui.effect;

using ui.ContextUtils;

class RemoveCoin extends Sprite {
	private static inline var ACC = 1500;
	private static inline var RAD = 20;
	private static inline var A_SPD = 2;

	private var xs:Float;
	private var ys:Float;

	public function new(x:Float, y:Float){
		super(x, y, RAD * 2, RAD * 2);
		var dir = Math.random() * (Math.PI * 2);
		var spd = (RAD * 2) + Math.random() * (RAD * 10);
		this.xs = Math.cos(dir) * spd;
		this.ys = Math.sin(dir) * spd;
	}

	public function update(s:Float) {
		ys += ACC * s;

		x += xs * s;
		y += ys * s;

		a -= A_SPD * s;
		if(a <= 0){
			alive = false;
		}

		Main.context.fillStyle = "#ff0";
		Main.context.globalAlpha = Math.max(0, a);
		Main.context.beginPath();
		Main.context.circle(x, y, w / 2);
		Main.context.fill();
		Main.context.globalAlpha = 1;
	}
}