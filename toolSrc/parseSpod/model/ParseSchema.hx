package parseSpod.model;

/**
 * ...
 * @author Thomas Byrne
 */


typedef ParseAppInfo =
 {
	appName:String,
	applicationId:String,
	dashboardURL:String,
	
	javascriptKey:String,
	masterKey:String,
	restKey:String,
	webhookKey:String,
	windowsKey:String,
	
	clientPushEnabled: Bool,
	clientClassCreationEnabled:Bool,
	revokeSessionOnPasswordChange: Bool,
	requireRevocableSessions: Bool,
	
	serverHost:Null<String>,
	types:Array<ParseTypeSchema>
}

typedef ParseTypeSchema =
{
	className:String,
	fields:Dynamic
}
typedef ParseFieldSchema =
{
	type:String,
	?targetClass:String
}

typedef Result<T> =
{
	results:Array<T>
}