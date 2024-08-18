package;

class TimerManager{
	private static var alive = new Array<Timer>();
	private static var dead = new Array<Timer>();

	public static function update(s:Float){
		dead = alive.copy();
		alive = new Array<Timer>();
		for(t in dead){
			t.update(s);
			if(t.alive){
				alive.push(t);
			}
		}
	}

	public static function add(t:Timer) {
		alive.push(t);
	}
}

abstract class Timer{
	public var alive(default, null):Bool = true;
	public abstract function update(s:Float):Void;
}