package game;

class Card{
	private var effects:Array<CardEffect>;

	public function new(effects:Array<CardEffect>){
		this.effects = effects;
	};

	public function getEffects():Array<CardEffect>{
		return effects;
	}
}