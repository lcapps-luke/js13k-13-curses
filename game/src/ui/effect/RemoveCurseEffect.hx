package ui.effect;

import game.Player;
import game.Board;
import js.lib.Promise;

using ui.ContextUtils;

class RemoveCurseEffect extends CardEffectSprite{
	private var tx:Float;
	private var ty:Float;

	private var pt = new EphemeralObjectManager();
	private var done = false;

	public function new(playerIndex:Int, board:Board, effectFunction:Player->Player->Void, self:Bool, i:Int){
		super(playerIndex, board, effectFunction);

		var targetPlayerIndex = self ? playerIndex : (playerIndex == 0 ? 1 : 0);

		var slot = board.players[targetPlayerIndex].curses - 1 - i;

		ty = (targetPlayerIndex == 0) ? (Main.HEIGHT - GameScreen.CURSE_SLOT_RADIUS - 13) : (GameScreen.CURSE_SLOT_RADIUS + 13);
		tx = GameScreen.CURSE_SLOT_SIZE * slot + GameScreen.CURSE_SLOT_MARGIN + GameScreen.CURSE_SLOT_RADIUS;

		done = slot < 0;
	}

	public function update(s:Float) {
		Main.context.lineWidth = 3;
		Main.context.strokeStyle = "#FF0";
		Main.context.globalAlpha = Math.max(0, a);
		Main.context.beginPath();
		Main.context.moveTo(Main.WIDTH / 2, Main.HEIGHT / 2);
		Main.context.lineTo(x, y);
		Main.context.stroke();
		Main.context.globalAlpha = 1;

		pt.update(s);
		if(done && !pt.hasAlive()){
			this.alive = false;
		}
	}
	
	public function play():Promise<CardEffectSprite> {
		if(done){
			return cast Promise.resolve(this);
		}

		return Tween.start(this, {
			x: tx,
			y: ty
		}, 0.2).then(t->{
			applyEffect();
			Sound.uncurse();
			
			for(i in 0...13){
				var d = Math.random() * (Math.PI * 2);
				var s = Math.random() * GameScreen.CURSE_SLOT_RADIUS;
				pt.add(new CurseParticle(tx + Math.cos(d) * s, ty + Math.sin(d) * s));
			}

			return Tween.start(this, {a: 0}, 0.2);
		}).then(t -> {
			done = true;
			return cast this;
		});
	}
}