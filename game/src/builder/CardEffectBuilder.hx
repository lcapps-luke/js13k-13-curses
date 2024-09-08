package builder;

#if macro
import sys.io.File;
import haxe.Json;
import haxe.macro.Context;
import haxe.macro.Expr;

import builder.CardJson.FaceItem;
#end

class CardEffectBuilder {
	macro static public function buildEnum():Array<Field> {
		var fields = Context.getBuildFields();

		var cards:Array<CardJson> = Json.parse(File.getContent("game/resources/cards.json"));
		var cost = new Array<Int>();
		var deck = new Array<Array<Int>>();
		var totalCards = 0;
		var colour = new Array<String>();
		var functions = new Array<String>();
		var face = new Array<Array<String>>();

		for (i in 0...cards.length) {
			var card = cards[i];
			if(card.deckQty[0] == 0){
				continue;
			}

			var newField = {
				name: card.name,
				doc: null,
				meta: [],
				access: [AStatic, APublic, AInline],
				kind: FVar(macro:Int, macro $v{i}),
				pos: Context.currentPos()
			};
			fields.push(newField);

			cost.push(card.cost);
			deck.push(card.deckQty);
			colour.push(card.colour);			
			functions.push(card.func);
			face.push(makeFaces(card.faces));

			for(q in card.deckQty){
				totalCards += q;
			}
		}

		var costField = {
			name: "COST",
			doc: null,
			meta: [],
			access: [AStatic, APublic],
			kind: FVar(macro:Array<Int>, macro $v{cost}),
			pos: Context.currentPos()
		};
		fields.push(costField);

		var deckField = {
			name: "DECK",
			doc: null,
			meta: [],
			access: [AStatic, APublic],
			kind: FVar(macro:Array<Array<Int>>, macro $v{deck}),
			pos: Context.currentPos()
		};
		fields.push(deckField);
		
		var qtyField = {
			name: "CARD_QTY",
			doc: null,
			meta: [],
			access: [AStatic, APublic, AInline],
			kind: FVar(macro:Int, macro $v{totalCards}),
			pos: Context.currentPos()
		};
		fields.push(qtyField);

		var colourField = {
			name: "COLOUR",
			doc: null,
			meta: [],
			access: [AStatic, APublic],
			kind: FVar(macro:Array<String>, macro $v{colour}),
			pos: Context.currentPos()
		};
		fields.push(colourField);

		var code = '[${functions.join(",")}]';
		var funcExpr = Context.parseInlineString(code, Context.currentPos());

		var funcField = {
			name: "FUNC",
			doc: null,
			meta: [],
			access: [AStatic, APublic],
			kind: FVar(macro:Array<Player->Player->Void>, funcExpr),
			pos: Context.currentPos()
		};
		fields.push(funcField);

		var deckField = {
			name: "FACE",
			doc: null,
			meta: [],
			access: [AStatic, APublic],
			kind: FVar(macro:Array<Array<String>>, macro $v{face}),
			pos: Context.currentPos()
		};
		fields.push(deckField);

		return fields;
	}

	private static function makeFaces(faces:Array<Array<FaceItem>>):Array<String> {
		return faces.map(makeFace);
	}
	private static function makeFace(items:Array<FaceItem>):String{
		return items.map(makeFaceItem).join("|");
	}
	private static function makeFaceItem(item:FaceItem):String{
		return switch(item.type){
			case "STRING": makeStringFaceItem(item);
			case "PATH": makePathFaceItem(item);
			default: throw 'Unknown face item type ${item.type}';
		}
	}

	private static function makeStringFaceItem(item:FaceItem):String{
		return 's${item.colour}${item.size}${item.x}${item.y}${item.value}';
	}
	private static function makePathFaceItem(item:FaceItem):String{
		return 'p${item.colour}${item.size}${item.path.join("")}';
	}
	
}
