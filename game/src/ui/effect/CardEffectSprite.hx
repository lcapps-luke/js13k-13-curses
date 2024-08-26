package ui.effect;

import game.Player;
import game.Board;
import js.lib.Promise;

abstract class CardEffectSprite extends Sprite{
	private var playerIndex:Int;
	private var board:Board;
	private var effectFunction:Player->Player->Void;

	public function new(playerIndex:Int, board:Board, effectFunction:Player->Player->Void){
		super(Main.WIDTH / 2, Main.HEIGHT / 2, 10, 10);

		this.playerIndex = playerIndex;
		this.board = board;
		this.effectFunction = effectFunction;
	}

	public abstract function play():Promise<CardEffectSprite>;

	private function applyEffect(){
		effectFunction(board.players[playerIndex], board.players[playerIndex == 0 ? 1 : 0]);
	}
}