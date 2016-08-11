package parseSpod.parse;
import parseSpod.parse.ParseFileHelper;
import promhx.Promise;

/**
 * ...
 * @author Thomas Byrne
 */
@:allow(parseSpod)
abstract ParseFile(String)
{
	inline static public function local(path:String, contentType:String="application/octet-stream") : ParseFile
	{
		contentTypes.set(path, contentType);
		untyped return path;
	}
	
	public var id(get, never):String;
	inline function get_id():String {
		return this;
	}
	
	public var url(get, never):String;
	inline function get_url():String {
		return urls.get(this);
	}
	
	public var uploaded(get, never):Bool;
	inline function get_uploaded():Bool {
		return ParseFileHelper.getUploaded(id, contentTypes);
	}
	
	public var contentType(get, never):String;
	inline function get_contentType():String {
		return ParseFileHelper.getContentType(id, contentTypes);
	}
	
	static var urls:Map<String, String> = new Map();
	static var contentTypes:Map<String, String> = new Map();
	
	inline function new(name:String, url:String) 
	{
		this = name;
		urls.set(name, url);
	}
	
	inline public function unload():Void
	{
		urls.remove(this);
		contentTypes.remove(this);
	}
	
	inline function upload(server:String):Promise<ParseFile>
	{
		return ParseFileHelper.upload(server, untyped this, contentTypes);
	}
	
	inline function uploadForEntity(server:String, objectId:String, local:Map<String, ParseFile>, ?thenSave:Void->Promise<Dynamic>):Promise<ParseFile>
	{
		return ParseFileHelper.uploadForEntity(server, objectId, local, untyped this, contentTypes, thenSave);
	}
}