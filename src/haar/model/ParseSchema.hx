package haar.model;

/**
 * ...
 * @author Thomas Byrne
 */

typedef ParseSchema =
{
	host:String,
	serverId:String,
	appId:String,
	masterKey:String,
	types:Array<ParseTypeSchema>
}
typedef ParseTypeSchema =
{
	className:String,
	fields:Dynamic
}
typedef ParseFieldSchema =
{
	?i:Int,
	?first:Bool,
	?last:Bool,
	?name:String,
	type:String,
	?targetClass:String
}

typedef Result<T> =
{
	results:Array<T>
}