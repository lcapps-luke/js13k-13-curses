package game;

class Card{
	private var effects:Array<CardEffect>;
	public var cost(default, null):Int = 0;

	public function new(effects:Array<CardEffect>){
		this.effects = effects;
		for(e in effects){
			cost += CardEffectLibrary.getEffectCost(e);
		}
	};

	public function getEffects():Array<CardEffect>{
		return effects;
	}

	public function canPlay(self:Player, other:Player):Bool{
		var sc = self.copy();
		var oc = other.copy();

		for(e in effects){
			CardEffectLibrary.getEffectFunction(e)(sc, oc);
		}

		return sc.validState() && oc.validState();
	}
}