package haar;

/**
 * ...
 * @author Thomas Byrne
 */
class ParseObjectId
{
	
	static var LOCAL_PREFIX:String = "Local:";

	static public function getLocal() : String
	{
		return LOCAL_PREFIX + Std.string(Math.round(Math.random() * 1000000000));
	}
	static public function isLocal(id:String) : Bool
	{
		return id.indexOf(LOCAL_PREFIX) == 0;
	}
	
}