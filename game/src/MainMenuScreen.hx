package;

import ui.Button;

class MainMenuScreen extends AbstractScreen{

	private var playButton:Button;

	public function new(){
		super();

		playButton = new Button("Play", "100px sans-serif", 0, Main.HEIGHT * 0.5, 0, 140);
		playButton.x = Main.WIDTH / 2 - playButton.w / 2;
		playButton.onClick = () -> Main.currentScreen = new GameScreen();
	}

	override function update(s:Float) {
		super.update(s);

		Main.context.fillStyle = "#000";
		Main.context.font = "100px sans-serif";
		var textWidth = Main.context.measureText(Main.TITLE);
		Main.context.fillText(Main.TITLE, Main.WIDTH / 2 - textWidth.width / 2, Main.HEIGHT * 0.25);

		playButton.update();
	}
}