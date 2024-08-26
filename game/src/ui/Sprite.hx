package ui;

abstract class Sprite{
	public var x:Float;
	public var y:Float;
	public var w:Float;
	public var h:Float;
	public var scaleX:Float = 1;
	public var scaleY:Float = 1;
	public var a:Float = 1;

	public function new(x:Float, y:Float, w:Float, h:Float){
		this.x = x;
		this.y = y;
		this.w = w;
		this.h = h;
	}

	public abstract function update(s:Float):Void;
}