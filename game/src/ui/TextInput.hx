package ui;

import js.Browser;
import js.html.InputElement;

class TextInput{
	private var ele:InputElement;

	private var xp:Float;
	private var yp:Float;
	private var wp:Float;
	private var hp:Float;

	public function new(x:Float, y:Float, w:Float, h:Float){
		ele = Browser.document.createInputElement();
		Browser.document.body.append(ele);

		xp = x / Main.WIDTH;
		yp = y/ Main.HEIGHT;
		wp = w / Main.WIDTH;
		hp = h / Main.HEIGHT;
	}

	public function update(){
		var canvasRect = Main.canvas.getBoundingClientRect();
		var x = canvasRect.x + xp * canvasRect.width;
		var y = canvasRect.y + yp * canvasRect.height;
		var w = wp * canvasRect.width;
		var h = hp * canvasRect.height;

		ele.style.top = '${y}px';
		ele.style.left = '${x}px';
		ele.style.width = '${w}px';
		ele.style.height = '${h}px';
		ele.style.fontSize = '${h * 0.7}px';
	}

	public function destroy(){
		ele.remove();
	}

	public function set(val:String){
		ele.value = val;
	}

	public function get(){
		return ele.value;
	}

}