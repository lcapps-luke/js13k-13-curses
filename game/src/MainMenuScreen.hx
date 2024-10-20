package;

import game.CardEffectLibrary;
import game.Card;
import ui.Button;

using ui.ContextUtils;

class MainMenuScreen extends AbstractScreen{
	private var playButton:Button;
	private var multiplayer:Button;
	
	private static var loaded:Bool = false;
	private static var cardLoadQueue = new Array<Card>();
	private static var loadNext = true;

	public function new(){
		super();

		playButton = new Button("Single-Player", 100, 0, Main.HEIGHT * 0.4, 0, 140);
		playButton.x = Main.WIDTH / 2 - playButton.w / 2;
		playButton.onClick = () -> Main.currentScreen = new GameScreen();

		multiplayer = new Button("Multiplayer", 100, 0, Main.HEIGHT * 0.6, 0, 140);
		multiplayer.x = Main.WIDTH / 2 - multiplayer.w / 2;
		multiplayer.onClick = () -> Main.currentScreen = new MultiplayerScreen();

		if(!loaded){
			for(d in 0...CardEffectLibrary.getDeck().length){
				for(i in 0...CardEffectLibrary.getDeck()[d].length){
					cardLoadQueue.push(new Card([for (q in 0...(i + 1)) d ]));
				}
			}

			CardImageRepository.createBack().then(c -> {
				loadNext = true;
			});
		}
	}

	override function update(s:Float) {
		super.update(s);

		Main.context.fillStyle = "#000";
		Main.context.font = "100px sans-serif";
		Main.context.centeredText(Main.TITLE, 0, Main.WIDTH, Main.HEIGHT * 0.25);

		if(loaded){
			playButton.update();
			multiplayer.update();
		}else if(loadNext){
			loadNext = false;
			Main.context.font = "70px sans-serif";
			Main.context.centeredText("Loading...", 0, Main.WIDTH, Main.HEIGHT / 2);
			
			var next = cardLoadQueue.pop();
			
			if(next == null){
				CardImageRepository.createCoinImages().then(c -> {
					loaded = true;
				});
				return;
			}

			CardImageRepository.createImage(next).then(c -> {
				loadNext = true;
			});
		}

	}
}