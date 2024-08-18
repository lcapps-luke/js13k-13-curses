package ui;

import js.lib.Promise;
import TimerManager.Timer;

class WaitTimer extends Timer{
	private var s:Float;
	private var c:WaitTimer->Void;

	public static function sec(s:Float){
		return new Promise((res, ref) -> {
			TimerManager.add(new WaitTimer(s, res));
		});
	}

	private function new(s:Float, c:WaitTimer->Void){
		this.s = s;
		this.c = c;
	}

	public function update(s:Float){
		this.s -= s;
		if(this.s <= 0){
			alive = false;
			c(this);
		}
	}
}