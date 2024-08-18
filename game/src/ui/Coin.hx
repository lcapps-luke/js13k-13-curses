package ui;

import js.lib.Promise;

class Coin extends Sprite{
	private var f:Float = 0;
	private var flipSpeed:Float = 0;
	private var flipTime:Float = 0;

	private var c:Bool->Void = null;

	public function new(x:Float, y:Float, side:Bool){
		super(x, y, 420, 420);
		scaleY = side ? 1 : -1;
	}

	public function update(s:Float) {
		if(flipTime > 0){
			flipTime -= s;
			f += flipSpeed * s;
			scaleY = Math.cos(f);
		}else if(c != null){
			scaleY = scaleY > 0 ? 1 : -1;
			c(scaleY > 0);
		}
		
		Main.context.lineWidth = 3;
		Main.context.strokeStyle = "#000";
		Main.context.fillStyle = scaleY > 0 ? "#f00" : "#00f";
		Main.context.beginPath();
		Main.context.ellipse(x + w/2, y + w/2, w/2, Math.abs((h/2) * scaleY), 0, 0, Math.PI * 2);
		Main.context.fill();
	}

	public function flip():Promise<Bool>{
		flipSpeed = (Math.random() * 2 * Math.PI) + (Math.PI * 5);
		flipTime = Math.random() * 0.2 + 0.8;

		return new Promise((res,rej)->{c = res;});
	}
}