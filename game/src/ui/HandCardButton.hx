package ui;

class HandCardButton extends Region{
	private static inline var SHIFT_DISTANCE:Float = 50;
	private static inline var SHIFT_SPEED:Float = SHIFT_DISTANCE / 0.25;

	private var hand:Array<CardSprite>;
	public var cardIndex(default, null):Int;
	public function new(x:Float, y:Float, c:Array<CardSprite>, i:Int){
		super(x, y, CardSprite.WIDTH, CardSprite.HEIGHT);
		this.hand = c;
		this.cardIndex = i;
	}

	public override function update(s:Float=0){
		super.update();

		if(cardIndex >= hand.length){
			return;
		}

		var card = hand[cardIndex];
		var ty = this.state == Region.STATE_OVER ? y - SHIFT_DISTANCE : y;

		var td = ty - card.y;

		if(Math.abs(td) < 1){
			card.y = ty;
		}else if(td < 0){
			card.y -= SHIFT_SPEED * s;
		}else if(td > 0){
			card.y += SHIFT_SPEED * s;
		}
		
	}
}