package parseSpod.parse;
import parseSpod.parse.ParseIO;

/**
 * ...
 * @author Thomas Byrne
 */
class ParseServers
{
	
	static var hosts:Map<String, String> = new Map();
	static var appIds:Map<String, String> = new Map();
	static var restKeys:Map<String, String> = new Map();
	

	/*static var isSetup:Bool;
	
	public static function setup() 
	{
		if (isSetup) return;
		isSetup = true;
		
		for (server in  hosts.keys()){
			ParseIO.setServer(server, 1, 2);
		}
	}*/
	
	static public inline function add(id:String, host:String, appId:String, restKey:String) : Void
	{
		hosts[id] = host;
		appIds[id] = appId;
		restKeys[id] = restKey;
	}
	
	public static inline function getHost(id:String) : String
	{
		return hosts[id];
	}
	
	public static inline function getAppId(id:String) : String
	{
		return appIds[id];
	}
	
	public static inline function getRestKey(id:String) : String
	{
		return restKeys[id];
	}
	
}