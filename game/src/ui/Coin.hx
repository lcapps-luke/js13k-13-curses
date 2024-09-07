package ui;

import js.html.ImageBitmap;
import js.lib.Promise;

class Coin extends Sprite{
	private var f:Float = 0;
	private var flipSpeed:Float = 0;
	private var flipTime:Float = 0;
	private var soundTimer:Float = 0;

	private var c:Bool->Void = null;

	private var face:Array<ImageBitmap>;

	public function new(x:Float, y:Float, side:Bool){
		super(x, y, 420, 420);
		scaleY = side ? 1 : -1;

		face = [
			CardImageRepository.get(CardImageRepository.COIN_A),
			CardImageRepository.get(CardImageRepository.COIN_B)
		];
	}

	public function update(s:Float) {
		if(flipTime > 0){
			flipTime -= s;
			
			f += flipSpeed * s;
			scaleY = Math.cos(f);

			soundTimer -= flipSpeed * s;
			if(soundTimer <= 0){
				soundTimer = Math.PI / 2;
				Sound.coinFlip();
			}
		}else if(c != null){
			scaleY = scaleY > 0 ? 1 : -1;
			c(scaleY > 0);
		}

		Main.context.drawImage(scaleY > 0 ? face[0] : face[1], 0, 0, w, h, 
			x, y + (h/2 - Math.abs(h * scaleY)/2), w, Math.abs(h * scaleY));
	}

	public function flip():Promise<Bool>{
		flipSpeed = (Math.random() * 2 * Math.PI) + (Math.PI * 5);
		flipTime = Math.random() * 0.2 + 0.8;
		soundTimer = Math.PI / 2;

		return new Promise((res,rej)->{c = res;});
	}
}