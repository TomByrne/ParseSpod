package haar.parse;
import haar.parse.ParseIO;

/**
 * ...
 * @author Thomas Byrne
 */
class ParseServers
{
	
	// Should be built from the macro
	static var hosts:Map<String, String> = ["idm" => "https://api.parse.com/1"];
	static var appIds:Map<String, String> = ["idm" => "AAK1udIBuvyUXVVryw0F1ZRJqltS3m3GaaQmxIfj"];
	static var restKeys:Map<String, String> = ["idm" => "oEOKnhqSHKS0y70PafJyBwrq9ZzyUHxZqd9niyaX"];
	static var isSetup:Bool;

	public static function setup() 
	{
		if (isSetup) return;
		isSetup = true;
		
		for (server in  hosts.keys()){
			ParseIO.setServer(server, 1, 2);
		}
	}
	
	static inline function add(id:String, host:String, appId:String, restKey:String) : Void
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