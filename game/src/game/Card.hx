package game;

class Card{
	public var effects(default, null):Array<CardEffect>;
	public var cost(default, null):Int = 0;

	public function new(effects:Array<CardEffect>){
		this.effects = effects;
		for(e in effects){
			cost += CardEffectLibrary.getEffectCost(e);
		}
	};

	public function canPlay(self:Player, other:Player):Bool{
		var sc = self.copy();
		var oc = other.copy();

		for(e in effects){
			CardEffectLibrary.getEffectFunction(e)(sc, oc);
		}

		return sc.validState() && oc.validState();
	}

	public function getSerial():String{
		return StringTools.lpad(Std.string(effects[0].getIndex()), "0", 2) + "-x" + Std.string(effects.length);
	}
}