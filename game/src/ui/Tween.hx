package ui;

import js.lib.Promise;

class Tween extends AbstractEphemeralObject{
	private var p:Float = 0;
	private var sc:Float;
	private var props:Array<TweenProperty>;
	private var cb:Tween->Void;

	public static function start(obj:Dynamic, val:Dynamic, time:Float):Promise<Tween>{
		var sc = 1 / time;

		var props = new Array<TweenProperty>();
		for(f in Reflect.fields(val)){
			var s = Reflect.getProperty(obj, f);
			var e = Reflect.getProperty(val, f);

			if(s != e){
				props.push({
					tgt: obj,
					name: f,
					start: s,
					scale: e - s
				});
			}
		}

		return new Promise((res, rej) -> {
			if(props.length > 0){
				Main.timerManager.add(new Tween(sc, props, res));
			}else{
				res(null);
			}
		});
	}

	private function new(sc:Float, props:Array<TweenProperty>, cb:Tween->Void){
		this.sc = sc;
		this.props = props;
		this.cb = cb;
	}

	public function update(s:Float){
		p += s * sc;
		if(p >= 1){
			p = 1;
			alive = false;
			updateProps(1);
			cb(this);
		}

		updateProps(p);
	}

	private function updateProps(p:Float){
		for(pr in props){
			var val = pr.start + pr.scale * p;
			Reflect.setProperty(pr.tgt, pr.name, val);
		}
	}

}

typedef TweenProperty = {
	var tgt:Dynamic;
	var name:String;
	var start:Float;
	var scale:Float;
}