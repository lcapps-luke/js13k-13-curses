abstract class AbstractEphemeralObject{
	public var alive(default, null):Bool = true;
	public abstract function update(s:Float):Void;
}