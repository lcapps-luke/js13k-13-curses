package;

class EphemeralObjectManager{
	private var alive = new Array<AbstractEphemeralObject>();
	private var dead = new Array<AbstractEphemeralObject>();

	public function new(){}

	public function update(s:Float){
		dead = alive.copy();
		alive = new Array<AbstractEphemeralObject>();
		for(t in dead){
			t.update(s);
			if(t.alive){
				alive.push(t);
			}
		}
	}

	public function add(t:AbstractEphemeralObject) {
		alive.push(t);
	}

	public function hasAlive(){
		return alive.length > 0;
	}
}

