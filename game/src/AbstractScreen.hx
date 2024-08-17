package;


abstract class AbstractScreen{
	private var backgroundStyle:String = "#fff";

	public function new(){}

	public function update(s:Float){
		Main.context.fillStyle = backgroundStyle;
		Main.context.fillRect(0, 0, Main.WIDTH, Main.HEIGHT);
	}
}