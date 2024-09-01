package;

import game.CardEffectLibrary;
import game.CardEffect;
import js.lib.Promise;
import ui.CardSprite;
import js.Browser;
import js.html.CanvasRenderingContext2D;
import js.html.ImageBitmap;
import js.lib.Map;
import game.Card;

using ui.ContextUtils;

class CardImageRepository {
	private static inline var WIDTH:Int = 3 * CardSprite.WIDTH;
	private static inline var HEIGHT:Int = 3 * CardSprite.HEIGHT;
	private static inline var COST_SIZE:Int = Math.floor(WIDTH * 0.3);

	private static inline var FACE_WIDTH:Float = WIDTH - 80;
	private static inline var FACE_HEIGHT:Float = FACE_WIDTH;
	private static inline var FACE_X:Float = 40;
	private static inline var FACE_Y:Float = 570 - FACE_HEIGHT;
	private static inline var FACE_XY_DIFF:Float = FACE_Y - FACE_X;


	private static var repo = new Map<String, ImageBitmap>();

	private static var d:CanvasRenderingContext2D = null;

	private static function init() {
		if (d == null) {
			var c = Browser.document.createCanvasElement();
			c.width = WIDTH;
			c.height = HEIGHT;
			d = c.getContext2d();
		}
	}

	public static function getBack():ImageBitmap {
		return repo.get("");
	}

	public static function getImage(c:Card):ImageBitmap {
		return repo.get(c.getSerial());
	}

	public static function createImage(c:Card):Promise<ImageBitmap> {
		init();

		d.clearRect(0, 0, WIDTH, HEIGHT);

		// border background
		d.lineWidth = 9;
		d.strokeStyle = "#000";
		d.fillStyle = "#" + getColour(c.effects[0]);
		d.roundRect(5, 5, WIDTH-10, HEIGHT-10, 30, true);

		// background
		d.fillStyle = "#fff";
		d.roundRect(40, 40, WIDTH-80, HEIGHT-80, 15, true, false);

		// image
		renderFace(CardEffect.FACE[c.effects[0]][c.effects.length-1]);

		// cost
		d.lineWidth = 6;
		d.strokeStyle = "#000";
		d.fillStyle = "#fff";
		d.roundRect(4, 4, COST_SIZE, COST_SIZE, 15, true);
		d.font = "100px sans-serif";
		d.fillStyle = "#000";
		d.centeredText(Std.string(c.cost), 4, COST_SIZE, COST_SIZE * 0.7, true);

		// separator
		d.lineWidth = 6;
		d.strokeStyle = "#999";
		d.beginPath();
		d.moveTo(40, 570);
		d.lineTo(WIDTH - 40, 570);
		d.stroke();

		// description
		d.font = "45px sans-serif";
		d.fillStyle = "#000";
		var yAcc = 570 + 80;
		for(n in getDescription(c.effects[0], c.effects.length).split("_")){
			d.centeredText(n, 0, WIDTH, yAcc, true);
			yAcc += 45;
		}

		d.font = "20px sans-serif";
		d.fillStyle = "#999";
		var sw = d.measureText(c.getSerial()).width;
		d.fillText(c.getSerial(), WIDTH - 45 - sw, HEIGHT - 45);

		var b = d.getImageData(0, 0, WIDTH, HEIGHT);

		return Browser.window.createImageBitmap(b).then(i -> {
			repo.set(c.getSerial(), i);
			return i;
		});
	}

	private static inline function getColour(ce:Int) {
		return CardEffect.COLOUR[ce];
	}

	private static function getDescription(ce:Int, qty:Int) {
		var p = qty > 1 ? "s":"";
		return switch(ce){
			case CardEffect.ADD_CURSE_OTHER: 'Add ${qty} Curse${p} to_your opponent'; //Add x Curses to your opponent
			case CardEffect.REMOVE_CURSE_OTHER: 'Remove ${qty} Curse${p}_from your opponent'; //Remove x Curses from your opponent
			case CardEffect.ADD_CURSE_SELF: 'Add ${qty} Curse${p} to_yourself'; //Add x Curses to yourself
			case CardEffect.REMOVE_CURSE_SELF: 'Remove ${qty} Curse${p}_from yourself'; //Remove x Curses from_yourself
			case CardEffect.TAKE_CURSE: 'Take ${qty} Curse${p} from_your opponent to_yourself'; //Take x Curses from your opponent to yourself
			case CardEffect.GIVE_CURSE: 'Give ${qty} of your_Curses to your_opponent'; //Give x of your Curses to your opponent
			case CardEffect.GAIN_POINT: 'Gain ${qty * CardEffectLibrary.POINTS_EFFECT_QTY} Points'; //Gain x Points
			case CardEffect.REMOVE_POINT: 'Remove ${qty * CardEffectLibrary.POINTS_EFFECT_REMOVE_QTY} Points_from your opponent'; //Remove x Points from your opponent
			default: "";
		}
	}

	public static function createBack():Promise<ImageBitmap>{
		init();

		d.clearRect(0, 0, WIDTH, HEIGHT);

		// border background
		d.lineWidth = 9;
		d.strokeStyle = "#000";
		d.fillStyle = "#888";
		d.roundRect(5, 5, WIDTH-10, HEIGHT-10, 30, true);

		// background
		d.fillStyle = "#bbb";
		d.roundRect(40, 40, WIDTH-80, HEIGHT-80, 15, true, false);

		// text
		d.font = "100px sans-serif";
		d.fillStyle = "#555";
		d.centeredText("13", 0, WIDTH, HEIGHT / 2 - 30, true);
		d.centeredText("Curses", 0, WIDTH, HEIGHT / 2 + 100, true);

		for(i in 0...13){
			var a = ((Math.PI * 2) / 13) * i;
			var cx = WIDTH / 2 + Math.cos(a) * (WIDTH * 0.4);
			var cy = HEIGHT / 2 + Math.sin(a) * (WIDTH * 0.4);

			d.fillStyle = "#85a";
			d.beginPath();
			d.ellipse(cx, cy, 20, 20, 0, 0, Math.PI * 2);
			d.fill();
		}

		var b = d.getImageData(0, 0, WIDTH, HEIGHT);

		return Browser.window.createImageBitmap(b).then(i -> {
			repo.set("", i);
			return i;
		});
	}

	private static function renderFace(s:String) {
		if(s == null){
			return;
		}
		for(i in s.split("|")){
			switch(i.charAt(0)){
				case "s": renderStringFace(i.substr(1));
				case "p": renderPathFace(i.substr(1));
			}
		}
	}

	private static function renderStringFace(s:String){
		//${item.colour}${item.size}${item.x}${item.y}${item.value}
		var c = s.substr(0, 3);
		var z = faceSize(Std.parseInt(s.substr(3,1)));
		var x = facePosX(Std.parseInt(s.substr(4,1)));
		var y = facePosY(Std.parseInt(s.substr(5,1)));
		var v = s.substr(6);

		d.font = '${z}px sans-serif';
		d.fillStyle = '#$c';
		var w = d.measureText(v).width;

		d.fillText(v, x-w/2, y+z/2);
	}

	private static function renderPathFace(s:String){
		//${item.colour}${item.size}${item.path.join()}
		var c = s.substr(0, 3);
		var z = faceSize(Std.parseInt(s.substr(3,1))) / 2;
		var p = s.substr(4).split("").map(Std.parseInt).map(facePosX);

		d.lineWidth = z;
		d.strokeStyle = '#$c';

		d.beginPath();
		d.moveTo(p.shift(), p.shift() + FACE_XY_DIFF);
		for(n in 0...Math.floor(p.length / 2)){
			d.lineTo(p.shift(), p.shift() + FACE_XY_DIFF);
		}
		d.stroke();
	}

	private static inline function facePosX(x:Int){
		return FACE_X + FACE_WIDTH * (x/10);
	}
	private static inline function facePosY(y:Int){
		return FACE_Y + FACE_HEIGHT * (y/10);
	}
	private static inline function faceSize(s:Int){
		return FACE_HEIGHT * (s / 10);
	}
}
