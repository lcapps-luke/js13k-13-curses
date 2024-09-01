package ui;

import js.html.CanvasRenderingContext2D;

class ContextUtils {
	public static function roundRect(ctx:CanvasRenderingContext2D, x:Float, y:Float, width:Float, height:Float, radius:Float = 5, fill:Bool = false,
			stroke:Bool = true) {
		ctx.beginPath();
		ctx.moveTo(x + radius, y);
		ctx.lineTo(x + width - radius, y);
		ctx.quadraticCurveTo(x + width, y, x + width, y + radius);
		ctx.lineTo(x + width, y + height - radius);
		ctx.quadraticCurveTo(x + width, y + height, x + width - radius, y + height);
		ctx.lineTo(x + radius, y + height);
		ctx.quadraticCurveTo(x, y + height, x, y + height - radius);
		ctx.lineTo(x, y + radius);
		ctx.quadraticCurveTo(x, y, x + radius, y);
		ctx.closePath();

		if (fill) {
			ctx.fill();
		}

		if (stroke) {
			ctx.stroke();
		}
	}

	public static function centeredText(ctx:CanvasRenderingContext2D, txt:String, x:Float, w:Float, y:Float, fill:Bool = true, stroke:Bool = false) {
		var tw = ctx.measureText(txt).width;
		if (fill) {
			ctx.fillText(txt, x + w / 2 - tw / 2, y);
		}

		if (stroke) {
			ctx.strokeText(txt, x + w / 2 - tw / 2, y);
		}
	}

	public static function circle(ctx:CanvasRenderingContext2D, x:Float, y:Float, r:Float, yr:Null<Float> = null){
		Main.context.ellipse(x, y, r, yr == null ? r : yr, 0, 0, Math.PI * 2);
	}
}
