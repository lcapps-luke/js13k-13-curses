package;

import js.Browser;
import js.html.CanvasRenderingContext2D;
import js.html.CanvasElement;

class Main{
	public static inline var WIDTH = 1080;
	public static inline var HEIGHT = 1920;
	public static var TITLE = "13 Curses";

	public static var canvas:CanvasElement;
	public static var context:CanvasRenderingContext2D;

	public static function main(){
		canvas = cast Browser.document.getElementById("c");
		context = canvas.getContext2d();

		Browser.window.onresize = onResize;
		onResize();

		Browser.window.requestAnimationFrame(update);
	}

	private static function update(s:Float){
		context.fillStyle = "#fff";
		context.fillRect(0, 0, WIDTH, HEIGHT);
		
		context.fillStyle = "#000";
		context.font = "100px sans-serif";
		var textWidth = context.measureText(TITLE);
		context.fillText(TITLE, WIDTH / 2 - textWidth.width / 2, HEIGHT * 0.25);

		Browser.window.requestAnimationFrame(update);
	}

	private static function onResize(){
		var w = Browser.window.innerWidth;
		var h = Browser.window.innerHeight;

		canvas.style.top = '${(h - canvas.clientHeight) / 2}px';
		canvas.style.left = '${(w - canvas.clientWidth) / 2}px';
	}
}