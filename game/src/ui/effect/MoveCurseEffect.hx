package ui.effect;

import game.Player;
import game.Board;
import js.lib.Promise;

using ui.ContextUtils;

class MoveCurseEffect extends CardEffectSprite{
	private var self:Bool = false;
	private var sx:Float;
	private var sy:Float;
	private var tx:Float;
	private var ty:Float;

	public function new(playerIndex:Int, board:Board, effectFunction:Player->Player->Void, self:Bool, i:Int){
		super(playerIndex, board, effectFunction);
		this.self = self;

		var targetPlayerIndex = self ? playerIndex : (playerIndex == 0 ? 1 : 0);
		var sourcePlayerIndex = targetPlayerIndex == 0 ? 1 : 0;

		var tgtSlot = board.players[targetPlayerIndex].curses + i;
		var srcSlot = board.players[sourcePlayerIndex].curses - 1 - i;

		ty = (targetPlayerIndex == 0) ? (Main.HEIGHT - GameScreen.CURSE_SLOT_RADIUS - 13) : (GameScreen.CURSE_SLOT_RADIUS + 13);
		tx = GameScreen.CURSE_SLOT_SIZE * tgtSlot + GameScreen.CURSE_SLOT_MARGIN + GameScreen.CURSE_SLOT_RADIUS;

		sy = (sourcePlayerIndex == 0) ? (Main.HEIGHT - GameScreen.CURSE_SLOT_RADIUS - 13) : (GameScreen.CURSE_SLOT_RADIUS + 13);
		sx = GameScreen.CURSE_SLOT_SIZE * srcSlot + GameScreen.CURSE_SLOT_MARGIN + GameScreen.CURSE_SLOT_RADIUS;
		this.x = sx;
		this.y = sy;
	}

	public function update(s:Float) {
		Main.context.strokeStyle = "#000";
		Main.context.lineWidth = 3;
		Main.context.fillStyle = "#094";
		Main.context.beginPath();
		Main.context.circle(sx, sy, GameScreen.CURSE_SLOT_RADIUS);
		Main.context.stroke();
		Main.context.fill();

		Main.context.fillStyle = "#f0f";
		Main.context.beginPath();
		Main.context.circle(x, y, GameScreen.CURSE_SLOT_RADIUS);
		Main.context.fill();
	}
	
	public function play():Promise<CardEffectSprite> {
		return Tween.start(this, {
			x: tx,
			y: ty
		}, 0.5).then(t->{
			applyEffect();
			alive = false;
			return cast this;
		});
	}
}