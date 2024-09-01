package;

import ui.effect.AddPointsEffect;
import ui.effect.MoveCurseEffect;
import ui.effect.RemoveCurseEffect;
import game.Player;
import ui.TextSprite;
import ui.Sprite;
import game.AIPlayer;
import game.CardEffectLibrary;
import ui.effect.PlaceholderEffect;
import ui.effect.AddCurseEffect;
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
	private static inline var END_SETUP = 0;
	private static inline var END_WAIT = 1;

	private static inline var PLAYER_HAND_Y:Float = 1520;

	public static inline var SHOP_SLOT_WIDTH:Float = CardSprite.WIDTH + 25;
	public static inline var SHOP_START_X:Float = Main.WIDTH / 2 - (SHOP_SLOT_WIDTH * Board.SHOP_SIZE) / 2;
	public static inline var CURSE_SLOT_SIZE:Float = Main.WIDTH / 16;
	public static inline var CURSE_SLOT_MARGIN:Float = 3;
	public static inline var CURSE_SLOT_RADIUS:Float = (CURSE_SLOT_SIZE - CURSE_SLOT_MARGIN * 2) / 2;

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
	private var shopButtons = new Array<HandCardButton>();
	private var selectedHandIndex = -1;
	private var playButton:Button;
	private var backButton:Button;
	private var buyButton:Button;

	private var effectManager = new EphemeralObjectManager();

	private var gameOverSprites= new Array<Sprite>();
	private var endGameButton:Button;

	private var focusCard:CardSprite = null;

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

		for(i in 0...3){
			var tx = SHOP_START_X + SHOP_SLOT_WIDTH * i;
			var btn = new HandCardButton(tx, Main.HEIGHT / 2 - CardSprite.HEIGHT / 2, shop, i);
			shopButtons.push(btn);
		}

		var playBackSpace = (Main.WIDTH / 2 - (CardSprite.WIDTH * 3) / 2);

		backButton = new Button("Back", "40px sans-serif", 0, Main.HEIGHT * 0.6, -1, 130);
		backButton.x = playBackSpace / 2 - backButton.w / 2;

		playButton = new Button("Play", "40px sans-serif", 0, Main.HEIGHT * 0.6, -1, 130);
		playButton.x = Main.WIDTH - (playBackSpace / 2 - playButton.w / 2) - playButton.w;

		buyButton = new Button("Buy", "40px sans-serif", 0, Main.HEIGHT * 0.6, -1, 130);
		buyButton.x = Main.WIDTH - (playBackSpace / 2 - playButton.w / 2) - playButton.w;

		endGameButton = new Button("Restart", "100px sans-serif", 0, Main.HEIGHT * 0.65, -1, 120);
		endGameButton.x = Main.WIDTH / 2 - endGameButton.w / 2;
	}

	override function update(s:Float) {
		super.update(s);

		//render BG
		Main.context.strokeStyle = "#ccc";
		Main.context.fillStyle="#094";
		Main.context.lineWidth = 8;
		Main.context.beginPath();
		Main.context.moveTo(0, Main.HEIGHT / 2);
		Main.context.lineTo(Main.WIDTH, Main.HEIGHT / 2);
		Main.context.stroke();

		Main.context.lineWidth = 4;
		for(i in 0...3){
			Main.context.roundRect(SHOP_START_X + SHOP_SLOT_WIDTH * i, Main.HEIGHT / 2 - CardSprite.HEIGHT / 2, CardSprite.WIDTH, CardSprite.HEIGHT, 5, true, true);
		}

		//render round number
		Main.context.fillStyle="#000";
		Main.context.font = "40px sans-serif";
		Main.context.centeredText('Round $round', 0, SHOP_START_X, Main.HEIGHT / 2 - 60);

		//render points
		Main.context.font = "100px sans-serif";
		Main.context.centeredText(Std.string(board.players[0].points), 0, SHOP_START_X, Main.HEIGHT / 2 + 100);

		Main.context.font = "100px sans-serif";
		Main.context.centeredText(Std.string(board.players[1].points), SHOP_START_X + SHOP_SLOT_WIDTH * 3 - 12.5, SHOP_START_X, Main.HEIGHT / 2 - 30);

		//render shop
		for(c in shop){
			if(c != null && c != focusCard){
				c.update(s);
			}
		}

		//render player hands
		for(c in playerHand){
			if(c != focusCard){
				c.update(s);
			}
		}
		for(c in aiHand){
			if(c != focusCard){
				c.update(s);
			}
		}


		//render curses
		Main.context.strokeStyle = "#000";
		Main.context.fillStyle="#fff";
		Main.context.lineWidth = 3;

		for(i in 0...16){
			var e = i == 12;

			//AI
			Main.context.fillStyle = i < board.players[1].curses ? "#f0f" : "#094";
			Main.context.beginPath();
			Main.context.ellipse(CURSE_SLOT_SIZE * i + CURSE_SLOT_MARGIN + CURSE_SLOT_RADIUS, CURSE_SLOT_RADIUS + 13, CURSE_SLOT_RADIUS, CURSE_SLOT_RADIUS, 0, 0, Math.PI * 2);
			Main.context.stroke();
			Main.context.fill();

			//player
			Main.context.fillStyle = i < board.players[0].curses ? "#f0f" : "#094";
			Main.context.beginPath();
			Main.context.ellipse(CURSE_SLOT_SIZE * i + CURSE_SLOT_MARGIN + CURSE_SLOT_RADIUS, Main.HEIGHT - CURSE_SLOT_RADIUS - 13, CURSE_SLOT_RADIUS, CURSE_SLOT_RADIUS, 0, 0, Math.PI * 2);
			Main.context.stroke();
			Main.context.fill();

			Main.context.fillStyle = "#fff";
			var sz = CURSE_SLOT_RADIUS * 1.5;
			Main.context.font = '${sz}px sans-serif';
			var mult = Player.getPointsMultiplier(i + 1);

			if(i == 12){
				Main.context.font = '${sz}px sans-serif';
				Main.context.centeredText("☠", CURSE_SLOT_SIZE * i, CURSE_SLOT_SIZE, CURSE_SLOT_RADIUS + sz * 0.6);
				Main.context.centeredText("☠", CURSE_SLOT_SIZE * i, CURSE_SLOT_SIZE, Main.HEIGHT - CURSE_SLOT_RADIUS - sz * 0);
			}else if(mult > 1){
				Main.context.font = '${sz * 0.8}px sans-serif';
				Main.context.centeredText('${mult}X', CURSE_SLOT_SIZE * i, CURSE_SLOT_SIZE, CURSE_SLOT_RADIUS + sz * 0.6);
				Main.context.centeredText('${mult}X', CURSE_SLOT_SIZE * i, CURSE_SLOT_SIZE, Main.HEIGHT - CURSE_SLOT_RADIUS - sz * 0);
			}
			
		}

		phaseFunc(s);

		focusCard?.update(s);
		effectManager.update(s);

		for(gos in gameOverSprites){
			gos.update(s);
		}
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

	private static inline function cardShopX(i:Int):Float{
		return SHOP_START_X + SHOP_SLOT_WIDTH * i;
	}

	private static inline function cardShopY():Float{
		return Main.HEIGHT / 2 - CardSprite.HEIGHT / 2;
	}

	private function startRoundPhase(s:Float){
		setPhase();
		round++;
		board.resetShop();

		var lastTween:Promise<Dynamic> = Promise.resolve(null);
		for(c in shop){
			if(c == null){
				continue;
			}

			lastTween = lastTween.then(t -> {
				c.flip();
				return Tween.start(c, {x: -c.w}, 0.5);
			});
		}

		lastTween = lastTween.then(t -> {
			shop.resize(0);
			return Promise.resolve(shop);
		});

		var idx = 0;
		for(card in board.shop){
			var spr = new CardSprite(card, Main.WIDTH, Main.HEIGHT / 2 - CardSprite.HEIGHT / 2);

			var tx = SHOP_START_X + SHOP_SLOT_WIDTH * idx;
			idx++;
			
			lastTween = lastTween.then((t) -> {
				shop.push(spr);
				spr.flip();
				return Tween.start(spr, {x:tx}, 0.3);
			});
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
				board.players[playerTurn].addPoints(p);
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
		var lastPromise = Promise.resolve();
		var actions = AIPlayer.getActions(board);
		for(a in actions){
			switch(a.type){
				case BUY:
					lastPromise = lastPromise.then(n -> {
						var shopCard = shop[a.index];
						board.players[1].points -= shopCard.card.cost;
						return Tween.start(shopCard, {
							x: cardHandX(board.players[1].cards.length),
							y: cardHandY(1)
						}, 0.5);
					}).then(t -> {
						var cardSpr = shop[a.index];
						board.shop[a.index] = null;
						shop[a.index] = null;
						//add card to player
						board.players[1].cards.push(cardSpr.card);
						aiHand.push(cardSpr);

						return cardSpr.flip();
					});
				case PLAY:
					lastPromise = lastPromise.then(t -> {
						selectedHandIndex = a.index;
						return Promise.resolve(a.index);
					}).then(t -> {
						return aiHand[selectedHandIndex].flip().then(t -> {
							focusCard = aiHand[selectedHandIndex];
							return Tween.start(aiHand[selectedHandIndex], {
								scaleX: 3,
								scaleY: 3,
								x: Main.WIDTH / 2 - CardSprite.WIDTH / 2,
								y: Main.HEIGHT / 2 - (CardSprite.HEIGHT * 3) / 2
							}, 0.2);
						});
					}).then(t -> return WaitTimer.sec(0.5))
						.then(t -> {
							var cardSpr = aiHand[selectedHandIndex];
							return Tween.start(cardSpr, { scaleX: 0, scaleY: 0, y:Main.HEIGHT / 2 }, 0.5);
						})
						.then(t -> {
							var cardSpr = aiHand[selectedHandIndex];
							return playCard(1, cardSpr);
						});
				case END: lastPromise.then(r -> {
					if(board.gameOver()){
						setPhase(gameEndPhase);
					}else{
						nextTurn();
					}
				});
			}
		}

		setPhase();
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

					playButton.enabled = playerHand[selectedHandIndex].card.canPlay(board.players[0], board.players[1]);

					focusCard = playerHand[selectedHandIndex];
					Tween.start(playerHand[selectedHandIndex], {
						scaleX: 3,
						scaleY: 3,
						x: Main.WIDTH / 2 - CardSprite.WIDTH / 2,
						y: Main.HEIGHT / 2 - (CardSprite.HEIGHT * 3) / 2
					}, 0.2).then(t -> phaseStep = PLAYER_TURN_SHOW_HAND);
				}
			}
			
			//shop cards
			for(sb in shopButtons){
				if(shop[sb.cardIndex] == null){
					continue;
				}

				sb.update(s);
				if(sb.clicked){
					phaseStep = -1;
					selectedHandIndex = sb.cardIndex;

					buyButton.enabled = (shop[selectedHandIndex].card.cost <= board.players[0].points && board.players[0].cards.length < 5);

					focusCard = shop[selectedHandIndex];
					Tween.start(shop[selectedHandIndex], {
						scaleX: 3,
						scaleY: 3,
						x: Main.WIDTH / 2 - CardSprite.WIDTH / 2,
						y: Main.HEIGHT / 2 - (CardSprite.HEIGHT * 3) / 2
					}, 0.2).then(t -> phaseStep = PLAYER_TURN_SHOW_SHOP);
				}
			}
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
					.then(t -> {
						if(board.gameOver()){
							setPhase(gameEndPhase);
						}else{
							phaseStep = PLAYER_TURN_WAIT;
						}
					});
			}
		}

		if(phaseStep == PLAYER_TURN_SHOW_SHOP){
			buyButton.update();
			backButton.update();

			if(backButton.clicked){
				phaseStep = -1;

				Tween.start(shop[selectedHandIndex], {
					scaleX: 1,
					scaleY: 1,
					x: cardShopX(selectedHandIndex),
					y: cardShopY()
				}, 0.2).then(t -> phaseStep = PLAYER_TURN_WAIT);
			}

			if(buyButton.clicked){
				phaseStep = -1;
				board.players[0].points -= shop[selectedHandIndex].card.cost;

				var cardSpr = shop[selectedHandIndex];
				var nextPlayerHandIndex = playerHand.length;
				Tween.start(cardSpr, { 
					scaleX: 1, 
					scaleY: 1, 
					x: cardHandX(nextPlayerHandIndex),
					y: cardHandY(0)
				}, 0.5).then(t -> {
					//remove card from shop
					board.shop[selectedHandIndex] = null;
					shop[selectedHandIndex] = null;
					//add card to player
					board.players[0].cards.push(cardSpr.card);
					playerHand.push(cardSpr);

					phaseStep = PLAYER_TURN_WAIT;
				});
			}
		}
	}

	private function playCard(playerIndex:Int, spr:CardSprite):Promise<Dynamic>{
		// get change from card
		var lastEffect = Promise.resolve();
		var eQty = 0;
		for(i in spr.card.effects){
			var eff = createCardEffect(i, playerIndex, eQty);
			eQty++;
			lastEffect = lastEffect.then(r -> {
				effectManager.add(eff);
				return eff.play();
			});
		}
		
		return lastEffect.then(e -> {
			var ownHand = playerIndex == AI_PLAYER_INDEX ? aiHand : playerHand;
			ownHand.remove(spr);
			board.players[playerIndex].cards.remove(spr.card);

			var lastTween:Promise<Tween> = Promise.resolve();

			for(c in ownHand){
				lastTween = lastTween.then(t -> {
					var idx = board.players[playerIndex].cards.indexOf(c.card);
					return Tween.start(c, {
						x: cardHandX(idx)
					}, 0.2);
				});
			}

			return lastTween;
		});
	}
	
	function createCardEffect(eff:Int, playerIndex:Int, increment:Int):CardEffectSprite {
		var efunc = CardEffectLibrary.getEffectFunction(eff);
		return switch(eff){
			case CardEffect.ADD_CURSE_OTHER:
				return new AddCurseEffect(playerIndex, board, efunc, false, increment);
			case CardEffect.ADD_CURSE_SELF:
				return new AddCurseEffect(playerIndex, board, efunc, true, increment);
			case CardEffect.REMOVE_CURSE_OTHER:
				return new RemoveCurseEffect(playerIndex, board, efunc, false, increment);
			case CardEffect.REMOVE_CURSE_SELF:
				return new RemoveCurseEffect(playerIndex, board, efunc, true, increment);
			case CardEffect.TAKE_CURSE:
				return new MoveCurseEffect(playerIndex, board, efunc, true, increment);
			case CardEffect.GIVE_CURSE:
				return new MoveCurseEffect(playerIndex, board, efunc, false, increment);
			case CardEffect.GAIN_POINT:
				return new AddPointsEffect(playerIndex, board, efunc);
			case CardEffect.REMOVE_POINT:
				return new PlaceholderEffect(playerIndex, board, efunc);
				/*
			case CardEffect.SEAL_OWN_CURSE:
				return new PlaceholderEffect(playerIndex, board, efunc);
			case CardEffect.SEAL_OTHER_CURSE:
				return new PlaceholderEffect(playerIndex, board, efunc);
			case CardEffect.PROTECT_SELF:
				return new PlaceholderEffect(playerIndex, board, efunc);
			case CardEffect.PROTECT_OTHER:
				return new PlaceholderEffect(playerIndex, board, efunc);
				*/
			default: null;
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

	private function gameEndPhase(s:Float){
		if(phaseStep == END_SETUP){
			phaseStep = -1;
			var winner = board.getWinner();

			var sy = winner == 0 ? (CURSE_SLOT_RADIUS + 13) : (Main.HEIGHT - CURSE_SLOT_RADIUS - 13);
			var sx = CURSE_SLOT_SIZE * 12 + CURSE_SLOT_MARGIN;

			var skull = new TextSprite(sx, sy, "☠", CURSE_SLOT_RADIUS * 1.5, "#fff");
			gameOverSprites.push(skull);

			var text = new TextSprite(Main.WIDTH, Main.HEIGHT / 2 - 100, winner == 0 ? "You Win!" : "You Lose!", 150, "#000");
			gameOverSprites.push(text);

			Tween.start(skull, {
				scaleX: 3,
				scaleY: 3,
				a: 0,
				x: sx - skull.w * 0.8,
				//y: sy - skull.h * 1.5
			}, 1).then(t -> {
				return Tween.start(text, {x: Main.WIDTH / 2 - text.w / 2}, 0.5);
			}).then(t -> {
				phaseStep = END_WAIT;
			});
		}
		
		if(phaseStep == END_WAIT){
			endGameButton.update(s);
			if(endGameButton.clicked){
				phaseStep = -1;
				Main.currentScreen = new MainMenuScreen();
			}
		}
	}

}