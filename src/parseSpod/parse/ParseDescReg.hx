package parseSpod.parse;
import parseSpod.parse.ParseObjectHelper.EntityDesc;

/**
 * ...
 * @author Thomas Byrne
 */
class ParseDescReg
{
	
	static var inner:Map<String, EntityDesc> = new Map();

	
	static public function set(classpath:String, entityDesc:EntityDesc) 
	{
		inner.set(classpath, entityDesc);
	}
	static public function get(classpath:String) : EntityDesc
	{
		return inner.get(classpath);
	}
	static public function exists(classpath:String) : Bool
	{
		return inner.exists(classpath);
	}
	
}