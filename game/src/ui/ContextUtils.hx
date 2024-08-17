package ui;

import js.html.CanvasRenderingContext2D;

class ContextUtils{

	public static function roundRect(ctx:CanvasRenderingContext2D, x:Float, y:Float, width:Float, height:Float, radius:Float = 5, fill:Bool = false, stroke:Bool = true) {
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
}