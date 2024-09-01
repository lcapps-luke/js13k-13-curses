package ui.effect;

using ui.ContextUtils;

class CurseParticle extends Sprite{
	private var xs:Float;
	private var ys:Float;
	private var alt:Float;

	public function new(x:Float, y:Float){
		super(x, y, GameScreen.CURSE_SLOT_RADIUS / 3, GameScreen.CURSE_SLOT_RADIUS / 3);

		var dir = Math.random() * (Math.PI * 2);
		var spd = GameScreen.CURSE_SLOT_RADIUS + Math.random() * GameScreen.CURSE_SLOT_RADIUS;
		this.xs = Math.cos(dir) * spd;
		this.ys = Math.sin(dir) * spd;

		this.alt = 1 / (.1 + Math.random() * .7);
	}

	public function update(s:Float) {
		this.a -= alt * s;
		this.x += xs * s;
		this.y += ys * s;

		Main.context.fillStyle = "#f0f";
		Main.context.globalAlpha = a;
		Main.context.beginPath();
		Main.context.circle(x, y, w / 2);
		Main.context.fill();
		Main.context.globalAlpha = 1;

		this.alive = this.a > 0;
	}
}