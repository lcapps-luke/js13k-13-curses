package builder;

typedef CardJson = {
	var name:String;
	var cost:Int;
	var deckQty:Array<Int>;
	var colour:String;
	var func:String;
	var faces:Array<Array<FaceItem>>;
}

typedef FaceItem = {
	var type:String;
	var ?value:String;
	var colour:String;
	var size:Int;
	var ?x:Int;
	var ?y:Int;
	var ?path:Array<Int>;
}
