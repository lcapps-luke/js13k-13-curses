package ui;

class Region{
	private static inline var STATE_NORMAL = 0;
	private static inline var STATE_OVER = 1;
	private static inline var STATE_DOWN = 2;

	public var x:Float;
	public var y:Float;
	public var w:Float;
	public var h:Float;

	public var state(default, null):Int;
	public var clicked(default, null):Bool = false;

	public var onClick:Void->Void;
	public var enabled:Bool = true;

	public function new(x:Float, y:Float, w:Float, h:Float){
		this.x = x;
		this.y = y;
		this.w = w;
		this.h = h;
	}

	public function update(s:Float=0){
		state = STATE_NORMAL;
		clicked = false;

		if(enabled && !(Pointer.X < x || Pointer.Y < y || Pointer.X > x + w || Pointer.Y > y + h)){
			state = Pointer.DOWN ? STATE_DOWN : STATE_OVER;
			clicked = Pointer.CLICK;
			
			if(clicked && onClick != null){
				onClick();
			}
		}
	}
}