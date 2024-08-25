package ui.effect;

import game.Board;
import js.lib.Promise;

abstract class CardEffectSprite extends Sprite{
	private var playerIndex:Int;
	private var board:Board;

	public function new(playerIndex:Int, board:Board){
		super(Main.WIDTH / 2, Main.HEIGHT / 2, 10, 10);

		this.playerIndex = playerIndex;
		this.board = board;
	}

	public abstract function play():Promise<CardEffectSprite>;
}