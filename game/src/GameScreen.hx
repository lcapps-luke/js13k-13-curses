package;

import ui.effect.PlaceholderEffect;
import ui.effect.CurseEffect;
import game.CardEffect;
import ui.effect.CardEffectSprite;
import ui.HandCardButton;
import ui.Dice;
import ui.Button;
import ui.WaitTimer;
import ui.Tween;
import js.lib.Promise;
import ui.CardSprite;
import ui.Coin;
import game.Board;

using ui.ContextUtils;

class GameScreen extends AbstractScreen{
	private static inline var AI_PLAYER_INDEX = 1;
	private static inline var CHOOSE_LEADER_START = 0;
	private static inline var CHOOSE_LEADER_WAIT = 1;
	private static inline var CHOOSE_LEADER_FLIP = 2;
	private static inline var ROLL_DICE_START = 0;
	private static inline var ROLL_DICE_WAIT = 1;
	private static inline var ROLL_DICE = 2;
	private static inline var ROLL_DICE_END = 3;
	private static inline var PLAYER_TURN_WAIT = 0;
	private static inline var PLAYER_TURN_SHOW_HAND = 1;
	private static inline var PLAYER_TURN_SHOW_SHOP = 2;

	private static inline var PLAYER_HAND_Y:Float = 1520;

	private var board = new Board();

	private var phaseFunc:Float->Void;
	private var phaseStep = CHOOSE_LEADER_START;

	private var round:Int = 0;
	private var roundTurn:Int = 0;

	private var playerTurn:Int = -1;

	private var playerHand = new Array<CardSprite>();
	private var aiHand = new Array<CardSprite>();
	private var shop = new Array<CardSprite>();

	private var coin = new Coin(Main.WIDTH + 420, Main.HEIGHT / 2 - 210, true);
	private var flipButton:Button;

	private var dice = new Dice(Main.WIDTH, Main.HEIGHT / 2 - 150);
	private var rollButton:Button;

	private var endTurnButton:Button;
	private var handButtons = new Array<HandCardButton>();
	private var selectedHandIndex = -1;
	private var playButton:Button;
	private var backButton:Button;

	private var currentEffect:CardEffectSprite = null;

	public function new(){
		super();
		phaseFunc = gameStartPhase;

		flipButton = new Button("Flip", "100px sans-serif", 0, Main.HEIGHT * 0.65, -1, 120);
		flipButton.x = Main.WIDTH / 2 - flipButton.w / 2;

		rollButton = new Button("Roll", "100px sans-serif", 0, Main.HEIGHT * 0.65, -1, 120);
		rollButton.x = Main.WIDTH / 2 - flipButton.w / 2;

		endTurnButton = new Button("End Turn", "40px sans-serif", 0, Main.HEIGHT / 2 + 10, -1, 130);
		endTurnButton.x = Main.WIDTH * 0.8 + Main.WIDTH / 10 - endTurnButton.w / 2;

		for(i in 0...5){
			var tx = (1080 / 5) * i + 20;

			handButtons.push(new HandCardButton(tx, PLAYER_HAND_Y, playerHand, i));
		}

		var playBackSpace = (Main.WIDTH / 2 - (CardSprite.WIDTH * 3) / 2);

		backButton = new Button("Back", "40px sans-serif", 0, Main.HEIGHT * 0.6, -1, 130);
		backButton.x = playBackSpace / 2 - backButton.w / 2;

		playButton = new Button("Play", "40px sans-serif", 0, Main.HEIGHT * 0.6, -1, 130);
		playButton.x = Main.WIDTH - (playBackSpace / 2 - playButton.w / 2) - playButton.w;
	}

	override function update(s:Float) {
		super.update(s);

		//TODO render BG
		Main.context.strokeStyle = "#777";
		Main.context.fillStyle="#fff";
		Main.context.lineWidth = 3;
		Main.context.beginPath();
		Main.context.moveTo(0, Main.HEIGHT / 2);
		Main.context.lineTo(Main.WIDTH, Main.HEIGHT / 2);
		Main.context.stroke();

		var shopSlotWidth = CardSprite.WIDTH + 25;
		var startX = Main.WIDTH / 2 - (shopSlotWidth * Board.SHOP_SIZE) / 2;
		for(i in 0...3){
			Main.context.roundRect(startX + shopSlotWidth * i, Main.HEIGHT / 2 - CardSprite.HEIGHT / 2, CardSprite.WIDTH, CardSprite.HEIGHT, 5, true, true);
		}

		//TODO render round number
		Main.context.fillStyle="#000";
		Main.context.font = "40px sans-serif";
		Main.context.centeredText('Round $round', 0, startX, Main.HEIGHT / 2 - 60);

		//TODO render points
		Main.context.font = "100px sans-serif";
		Main.context.centeredText(Std.string(board.players[0].points), 0, startX, Main.HEIGHT / 2 + 100);

		Main.context.font = "100px sans-serif";
		Main.context.centeredText(Std.string(board.players[1].points), startX + shopSlotWidth * 3 - 12.5, startX, Main.HEIGHT / 2 - 30);

		//TODO render shop
		for(c in shop){
			c.update(s);
		}

		//TODO render player hands
		for(c in playerHand){
			c.update(s);
		}
		for(c in aiHand){
			c.update(s);
		}


		//TODO render curses
		Main.context.strokeStyle = "#000";
		Main.context.fillStyle="#fff";
		Main.context.lineWidth = 3;
		var curseSlotSize = Main.WIDTH / 16;
		var curseSlotRadius = (curseSlotSize - 6) / 2;
		for(i in 0...16){
			var e = i == 12;

			//AI
			Main.context.fillStyle = i < board.players[1].curses ? "#f0f" : "#fff";
			Main.context.beginPath();
			Main.context.ellipse(curseSlotSize * i + 3 + curseSlotRadius, curseSlotRadius + 13, curseSlotRadius, curseSlotRadius, 0, 0, Math.PI * 2);
			Main.context.stroke();
			Main.context.fill();

			//player
			Main.context.fillStyle = i < board.players[0].curses ? "#f0f" : "#fff";
			Main.context.beginPath();
			Main.context.ellipse(curseSlotSize * i + 3 + curseSlotRadius, Main.HEIGHT - curseSlotRadius - 13, curseSlotRadius, curseSlotRadius, 0, 0, Math.PI * 2);
			Main.context.stroke();
			Main.context.fill();
			
		}

		phaseFunc(s);

		currentEffect?.update(s);
	}

	private function setPhase(p:Float->Void = null){
		phaseFunc = p == null ? s->{} : p;
		phaseStep = 0;
	}

	private function gameStartPhase(s:Float){
		setPhase();

		//draw cards
		var lastTween:Promise<Dynamic> = null;
		for(i in 0...6){
			var playerIndex = i % 2;

			var card = board.drawCard();
			board.players[playerIndex].cards.push(card);
			
			var spr = new CardSprite(card, Main.WIDTH, Main.HEIGHT / 2 - CardSprite.HEIGHT / 2);
			var hand = playerIndex == AI_PLAYER_INDEX ? aiHand : playerHand;
			hand.push(spr);

			var tx = cardHandX(Math.floor(i / 2)); //(Main.WIDTH / 5) * Math.floor(i / 2) + 20;
			var ty = cardHandY(playerIndex);//playerIndex == AI_PLAYER_INDEX ? 120 : PLAYER_HAND_Y;

			if(lastTween == null){
				lastTween = Tween.start(spr, {x:tx, y:ty}, 0.3);
			}else{
				lastTween = lastTween.then((t) -> {
					return Tween.start(spr, {x:tx, y:ty}, 0.3);
				});
			}
		}

		lastTween = lastTween.then((t) -> {
			return WaitTimer.sec(0.5);
		});

		for(p in playerHand){
			lastTween = lastTween.then((t) -> {
				return p.flip();
			});
		}

		lastTween.then((t) -> {
			return WaitTimer.sec(0.5);
		}).then(t-> {
			setPhase(startRoundPhase);
		});
	}

	private static inline function cardHandX(i:Int):Float{
		return (Main.WIDTH / 5) * i + 20;
	}

	private static inline function cardHandY(p:Int):Float{
		return p == AI_PLAYER_INDEX ? 120 : PLAYER_HAND_Y;
	}

	private function startRoundPhase(s:Float){
		setPhase();
		round++;
		board.resetShop();

		var lastTween:Promise<Dynamic> = null;
		for(c in shop){
			if(lastTween == null){
				c.flip();
				lastTween = Tween.start(c, {x: -c.w}, 0.5);
			}else{
				lastTween = lastTween.then(t -> {
					c.flip();
					return Tween.start(c, {x: -c.w}, 0.5);
				});
			}
		}

		if(lastTween != null){
			lastTween = lastTween.then(t -> {
				shop = new Array<CardSprite>();
				return Promise.resolve(shop);
			});
		}

		var shopSlotWidth = CardSprite.WIDTH + 25;
		var startX = Main.WIDTH / 2 - (shopSlotWidth * Board.SHOP_SIZE) / 2;

		var idx = 0;
		for(card in board.shop){
			var spr = new CardSprite(card, Main.WIDTH, Main.HEIGHT / 2 - CardSprite.HEIGHT / 2);

			var tx = startX + shopSlotWidth * idx;
			idx++;

			if(lastTween == null){
				shop.push(spr);
				spr.flip();
				lastTween = Tween.start(spr, {x:tx}, 0.3);
			}else{
				lastTween = lastTween.then((t) -> {
					shop.push(spr);
					spr.flip();
					return Tween.start(spr, {x:tx}, 0.3);
				});
			}
		}

		lastTween.then((t) -> {
			return WaitTimer.sec(0.5);
		}).then(t-> {
			nextRound();
		});
	}

	private function chooseLeaderPhase(s:Float){
		coin.update(s);

		if(phaseStep == CHOOSE_LEADER_START){
			phaseStep = -1;
			Tween.start(coin, {x:Main.WIDTH / 2 - coin.w / 2}, 0.5).then(t->{
				phaseStep = CHOOSE_LEADER_WAIT;
			});
		}

		if(phaseStep == CHOOSE_LEADER_WAIT){
			flipButton.update();
			if(flipButton.clicked){
				phaseStep = CHOOSE_LEADER_FLIP;
	
				coin.flip().then(b -> {
					playerTurn = b ? 0 : 1;
				}).then(t -> WaitTimer.sec(0.5)).then(t-> {
					return Tween.start(coin, {x:Main.WIDTH + coin.w}, 0.5);
				}).then((t) -> {
					setPhase(startTurnPhase);
				});
			}
		}
	}

	private function startTurnPhase(s:Float){
		dice.update(s);
		
		if(phaseStep == ROLL_DICE_START){
			phaseStep = -1;
			Tween.start(dice, {x:Main.WIDTH / 2 - dice.w / 2}, 0.5).then(t->{
				phaseStep = playerTurn == AI_PLAYER_INDEX ? ROLL_DICE : ROLL_DICE_WAIT;
			});
		}

		if(phaseStep == ROLL_DICE_WAIT){
			rollButton.update();
			if(rollButton.clicked){
				phaseStep = ROLL_DICE;
			}
		}

		if(phaseStep == ROLL_DICE){
			phaseStep = ROLL_DICE_END;

			dice.roll().then(p -> {
				board.players[playerTurn].points += p;
				return WaitTimer.sec(0.5);
			}).then(t -> {
				return Tween.start(dice, {x:Main.WIDTH}, 0.5);
			}).then(t -> {
				setPhase(mainTurnPhase);
			});
		}
	}

	private function mainTurnPhase(s:Float){
		if(playerTurn == AI_PLAYER_INDEX){
			aiTurnPhase(s);
		}else{
			playerTurnPhase(s);
		}
	}

	private function aiTurnPhase(s:Float){
		//TODO AI
		//TODO end turn
		nextTurn();
	}

	private function playerTurnPhase(s:Float){
		if(phaseStep == PLAYER_TURN_WAIT){
			endTurnButton.update();
			if(endTurnButton.clicked){
				nextTurn();
			}

			for(hb in handButtons){
				if(hb.cardIndex >= playerHand.length){
					break;
				}

				hb.update(s);
				if(hb.clicked){
					phaseStep = -1;
					selectedHandIndex = hb.cardIndex;

					Tween.start(playerHand[hb.cardIndex], {
						scaleX: 3,
						scaleY: 3,
						x: Main.WIDTH / 2 - CardSprite.WIDTH / 2,
						y: Main.HEIGHT / 2 - (CardSprite.HEIGHT * 3) / 2
					}, 0.2).then(t -> phaseStep = PLAYER_TURN_SHOW_HAND);
				}
			}

			//TODO shop cards
		}

		if(phaseStep == PLAYER_TURN_SHOW_HAND){
			playButton.update();
			backButton.update();

			if(backButton.clicked){
				phaseStep = -1;

				Tween.start(playerHand[selectedHandIndex], {
					scaleX: 1,
					scaleY: 1,
					x: cardHandX(selectedHandIndex),
					y: cardHandY(0)
				}, 0.2).then(t -> phaseStep = PLAYER_TURN_WAIT);
			}

			if(playButton.clicked){
				phaseStep = -1;
				//TODO play card
				var cardSpr = playerHand[selectedHandIndex];
				Tween.start(cardSpr, { scaleX: 0, scaleY: 0, y:Main.HEIGHT / 2 }, 0.5)
					.then(t -> {return playCard(0, cardSpr);})
					.then(t -> {phaseStep = PLAYER_TURN_WAIT;});
			}
		}
	}

	private function playCard(playerIndex:Int, spr:CardSprite):Promise<Dynamic>{
		// get change from card
		var lastEffect = Promise.resolve();
		for(i in spr.card.getEffects()){
			var eff = createCardEffect(i, playerIndex);
			lastEffect = lastEffect.then(r -> {
				currentEffect = eff;
				return eff.play();
			});
		}
		
		return lastEffect.then(e -> {
			currentEffect = null;

			var ownHand = playerIndex == AI_PLAYER_INDEX ? aiHand : playerHand;
			ownHand.remove(spr);
			board.players[playerIndex].cards.remove(spr.card);

			return new Promise((res, rej) -> {
				var lastTween:Promise<Tween> = Promise.resolve();

				for(c in ownHand){
					lastTween = lastTween.then(t -> {
						var idx = board.players[playerIndex].cards.indexOf(c.card);
						return Tween.start(c, {
							x: cardHandX(idx)
						}, 0.5);
					});
				}

				lastTween.then(t -> res(null));
			});
		});
	}
	
	function createCardEffect(eff:CardEffect, playerIndex:Int):CardEffectSprite {
		return switch(eff){
			case ADD_CURSE_OTHER:
				return new CurseEffect(playerIndex, board);
			case ADD_CURSE_SELF:
				return new CurseEffect(playerIndex == 0 ? 1 : 0, board);
			case REMOVE_CURSE_OTHER:
				return new PlaceholderEffect(playerIndex, board, (p,b) -> {
					b.players[p == 0 ? 1 : 0].curses--;
					trace(eff.getName());
				});
			case REMOVE_CURSE_SELF:
				return new PlaceholderEffect(playerIndex, board, (p,b) -> {
					b.players[p].curses--;
					trace(eff.getName());
				});
			case TAKE_CURSE:
				return new PlaceholderEffect(playerIndex, board, (p,b) -> {
					b.players[p == 0 ? 1 : 0].curses--;
					b.players[p].curses++;
					trace(eff.getName());
				});
			case GIVE_CURSE:
				return new PlaceholderEffect(playerIndex, board, (p,b) -> {
					b.players[p == 0 ? 1 : 0].curses++;
					b.players[p].curses--;
					trace(eff.getName());
				});
			case GAIN_POINT:
				return new PlaceholderEffect(playerIndex, board, (p,b) -> {
					b.players[p].points++;
					trace(eff.getName());
				});
			case REMOVE_POINT:
				return new PlaceholderEffect(playerIndex, board, (p,b) -> {
					b.players[p].points--;
					trace(eff.getName());
				});
			case SEAL_OWN_CURSE:
				return new PlaceholderEffect(playerIndex, board, (p,b) -> {
					trace(eff.getName());
				});
			case SEAL_OTHER_CURSE:
				return new PlaceholderEffect(playerIndex, board, (p,b) -> {
					trace(eff.getName());
				});
			case PROTECT_SELF:
				return new PlaceholderEffect(playerIndex, board, (p,b) -> {
					trace(eff.getName());
				});
			case PROTECT_OTHER:
				return new PlaceholderEffect(playerIndex, board, (p,b) -> {
					trace(eff.getName());
				});
		};
	}
	

	private function nextTurn(){
		roundTurn++;
		if(roundTurn < 2){
			playerTurn = playerTurn == 0 ? 1 : 0;
			setPhase(startTurnPhase);
		}else{
			setPhase(startRoundPhase);
		}
	}

	private function nextRound(){
		roundTurn = 0;
		playerTurn = board.getTurnLeader();
		if(playerTurn == Board.TURN_DRAW){
			setPhase(chooseLeaderPhase);
		}else{
			setPhase(startTurnPhase);
		}
	}

}