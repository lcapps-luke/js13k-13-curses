package;

import game.CardEffectLibrary;
import game.Card;
import ui.Button;

using ui.ContextUtils;

class MainMenuScreen extends AbstractScreen{
	private var playButton:Button;
	
	private static var loaded:Bool = false;
	private static var cardLoadQueue = new Array<Card>();
	private static var loadNext = true;

	public function new(){
		super();

		playButton = new Button("Play", "100px sans-serif", 0, Main.HEIGHT * 0.5, 0, 140);
		playButton.x = Main.WIDTH / 2 - playButton.w / 2;
		playButton.onClick = () -> Main.currentScreen = new GameScreen();

		if(!loaded){
			for(d in CardEffectLibrary.getDeck().keyValueIterator()){
				for(i in 0...d.value.length){
					if(d.value[i] == 0){
						continue;
					}
					cardLoadQueue.push(new Card([for (q in 0...(i + 1)) d.key ]));
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
		}else if(loadNext){
			Main.context.font = "70px sans-serif";
			Main.context.centeredText("Loading...", 0, Main.WIDTH, Main.HEIGHT / 2);
			var next = cardLoadQueue.pop();
			if(next == null){
				loaded = true;
				return;
			}

			loadNext = false;
			CardImageRepository.createImage(next).then(c -> {
				loadNext = true;
			});
		}

	}
}