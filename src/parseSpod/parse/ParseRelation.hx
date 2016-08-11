package parseSpod.parse;
import parseSpod.parse.ParseRelationHelper;
import promhx.Promise;

/**
 * ...
 * @author Thomas Byrne
 */
/*abstract ParseRelation<T>(String)
{
	static var addedLocal:Map<String, Array<String>> = new Map();
	static var removedLocal:Map<String, Array<String>> = new Map();
	static var local:Map<String, Array<String>> = new Map();
	static var remote:Map<String, Array<String>> = new Map();

	public function new(id:String) 
	{
		this = id;
	}
	
	function init() 
	{
		ParseRelationHelper.init(this, local, addedLocal, removedLocal);
	}
	
	public function get() : Array<T>
	{
		return untyped ParseRelationHelper.get(this, local);
	}
	
	public function add(entity:T) : ParseRelation<T>
	{
		ParseRelationHelper.add(this, local, addedLocal, removedLocal, untyped entity);
		return untyped this;
	}
	
	public function remove(entity:T) : ParseRelation<T>
	{
		ParseRelationHelper.remove(this, local, addedLocal, removedLocal, untyped entity);
		return untyped this;
	}
	
	public function save() : Promise<ParseRelation<T>>
	{
		return untyped ParseRelationHelper.save(this, local, addedLocal, removedLocal, remote);
	}
	public function load(overwriteChanges:Bool=false) : Promise<T>
	{
		return untyped ParseRelationHelper.load(this, local, addedLocal, removedLocal, remote, overwriteChanges);
	}
	
	public function toString() : String
	{
		return ParseRelationHelper.toString(this, local, remote);
	}
}*/