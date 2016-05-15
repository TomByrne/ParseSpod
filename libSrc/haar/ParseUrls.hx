package haar;

/**
 * ...
 * @author Thomas Byrne
 */
class ParseUrls
{

	static inline public function getClassUrl(server:String, className:String) 
	{
		return ParseServers.getHost(server) + "/classes/" + className;
	}
	
	static inline public function getObjectUrl(server:String, className:String, objectId:String) 
	{
		return getClassUrl(server, className) + "/" + objectId;
	}
	
	static public function getBatchUrl(server:String) 
	{
		return ParseServers.getHost(server) + "/batch";
	}
	
	static public function getSchemaUrl(server:String) 
	{
		return ParseServers.getHost(server) + "/schema";
	}
	
}