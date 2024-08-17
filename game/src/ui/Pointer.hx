package ui;

import js.html.Touch;
import js.html.TouchEvent;
import js.html.MouseEvent;
import js.Browser;

@:native("Ptr")
class Pointer{
	public static var X(default, null):Float = 0;
	public static var Y(default, null):Float = 0;

	@:native("C")
	public static var CLICK:Bool = false;

	@:native("D")
	public static var DOWN:Bool = false;

	private static var mTouch:Int = -1;

	@:native("i")
	public static function init() {
		Main.canvas.onmousemove = onMouseMove;
		Browser.window.onmousedown = onMouseDown;
		Browser.window.onmouseup = onMouseUp;

		Browser.window.ontouchstart = onTouchStart;
		Browser.window.ontouchmove = onTouchMove;
		Browser.window.ontouchend = onTouchEnd;
		Browser.window.ontouchcancel = onTouchEnd;
	}

	@:native("m")
	private static inline function onMouseMove(e:MouseEvent) {
		X = (e.offsetX / Main.canvas.clientWidth) * Main.WIDTH;
		Y = (e.offsetY / Main.canvas.clientHeight) * Main.HEIGHT;
	}

	@:native("o")
	private static inline function onMouseDown(e:MouseEvent) {
		DOWN = true;
	}

	@:native("p")
	private static inline function onMouseUp(e:MouseEvent) {
		DOWN = false;
		CLICK = true;
	}

	@:native("ots")
	private static inline function onTouchStart(e:TouchEvent) {
		e.preventDefault();

		for (t in e.changedTouches) {
			var x = tpx(t);
			var y = tpy(t);

			if (mTouch < 0) {
				mTouch = t.identifier;
				X = x;
				Y = y;
				DOWN = true;
			}
		}
	}

	@:native("otm")
	private static inline function onTouchMove(e:TouchEvent) {
		e.preventDefault();

		for (t in e.changedTouches) {
			var x = tpx(t);
			var y = tpy(t);

			if (mTouch == t.identifier) {
				X = x;
				Y = y;
			}
		}
	}

	private static function tpx(t:Touch):Float {
		return ((t.clientX - Main.canvas.offsetLeft) / Main.canvas.clientWidth) * Main.WIDTH;
	}

	private static function tpy(t:Touch):Float {
		return ((t.clientY - Main.canvas.offsetTop) / Main.canvas.clientHeight) * Main.HEIGHT;
	}

	@:native("ote")
	private static function onTouchEnd(e:TouchEvent) {
		e.preventDefault();

		for (t in e.changedTouches) {
			if (t.identifier == mTouch) {
				CLICK = true;
				mTouch = -1;
				DOWN = false;
			}
		}
	}

	@:native("u")
	public static function update() {
		CLICK = false;
	}
}