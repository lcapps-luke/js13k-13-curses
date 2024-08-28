package;

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

		// cost
		d.lineWidth = 6;
		d.fillStyle = "#fff";
		d.roundRect(4, 4, COST_SIZE, COST_SIZE, 15, true);
		d.font = "100px sans-serif";
		d.fillStyle = "#000";
		d.centeredText(Std.string(c.cost), 4, COST_SIZE, COST_SIZE * 0.7, true);

		// separator
		d.lineWidth = 6;
		d.fillStyle = "#999";
		d.moveTo(40, 570);
		d.lineTo(WIDTH - 40, 570);
		d.stroke();

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

	private static function getColour(ce:CardEffect) {
		return switch(ce){
			case ADD_CURSE_OTHER: "F70";
			case REMOVE_CURSE_OTHER: "CE0";
			case ADD_CURSE_SELF: "E48";
			case REMOVE_CURSE_SELF: "87E";
			case TAKE_CURSE: "E44";
			case GIVE_CURSE: "8C4";
			case GAIN_POINT: "FC0";
			case REMOVE_POINT: "04F";
			case SEAL_OWN_CURSE: "888";
			case SEAL_OTHER_CURSE: "888";
			case PROTECT_SELF: "888";
			case PROTECT_OTHER: "888";
		}
	}

	private static function getDescription(ce:CardEffect, qty:Int) {
		var p = qty > 1 ? "s":"";
		return switch(ce){
			case ADD_CURSE_OTHER: 'Add ${qty} Curse${p} to_your opponent'; //Add x Curses to your opponent
			case REMOVE_CURSE_OTHER: 'Remove ${qty} Curse${p}_from your opponent'; //Remove x Curses from your opponent
			case ADD_CURSE_SELF: 'Add ${qty} Curse${p} to_yourself'; //Add x Curses to yourself
			case REMOVE_CURSE_SELF: 'Remove ${qty} Curse${p}_from yourself'; //Remove x Curses from_yourself
			case TAKE_CURSE: 'Take ${qty} Curse${p} from_your opponent to_yourself'; //Take x Curses from your opponent to yourself
			case GIVE_CURSE: 'Give ${qty} of your_Curse${p} to your_opponent'; //Give x of your Curses to your opponent
			case GAIN_POINT: 'Gain ${qty} Point${p}'; //Gain x Points
			case REMOVE_POINT: 'Remove ${qty} Point${p}_from your opponent'; //Remove x Points from your opponent
			case SEAL_OWN_CURSE: ce.getName();
			case SEAL_OTHER_CURSE: ce.getName();
			case PROTECT_SELF: ce.getName();
			case PROTECT_OTHER: ce.getName();
		}
	}

	public static function createBack():Promise<ImageBitmap>{
		init();

		d.clearRect(0, 0, WIDTH, HEIGHT);

		d.lineWidth = 9;
		d.strokeStyle = "#000";
		d.fillStyle = "#888";
		d.roundRect(5, 5, WIDTH-10, HEIGHT-10, 15, true);

		var b = d.getImageData(0, 0, WIDTH, HEIGHT);

		return Browser.window.createImageBitmap(b).then(i -> {
			repo.set("", i);
			return i;
		});
	}
}
