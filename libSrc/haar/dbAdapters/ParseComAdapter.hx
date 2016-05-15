package haar.dbAdapters;
import haar.Schema;
import haxe.Json;
import haxe.macro.Expr;
import haxe.macro.Type;
import haxe.macro.TypeTools;
import promhx.Deferred;
import promhx.Promise;
import promhx.Stream;
import haxe.Http;

/**
 * ...
 * @author Thomas Byrne
 */
class ParseComAdapter
{
	var schemaLoad:Http;
	var schemaVal:Deferred<Schema>;
	var schemaStream:Stream<Schema>;
	
	var appId:String;
	var restKey:String;
	var host:String;
	var apiVersion:String;

	public function new(appId:String, restKey:String, host:String, apiVersion:String) 
	{
		this.appId = appId;
		this.restKey = restKey;
		this.host = host;
		this.apiVersion = apiVersion;
		
		trace(host + "/" + apiVersion + "/schemas");
		trace(appId);
		trace(restKey);
		
		schemaLoad = new Http(host + "/" + apiVersion + "/schemas");
		schemaLoad.setHeader("X-Parse-Application-Id", appId);
		schemaLoad.setHeader("X-Parse-Master-Key", restKey);
		schemaLoad.setHeader("Content-Type", "application/json");
		schemaLoad.onData = onSchema;
		schemaLoad.onError = onSchemaFail;
		
		schemaVal = new Deferred();
		schemaStream = new Stream(schemaVal);
	}
	
	function onSchema(str:String) 
	{
		var res:{results:Array<ParseType>} = Json.parse(str);
		for (type in res.results){
			var classType:ClassType = {
					pack:["user","parse"],
					name:type.className,
					module : "user.parse."+type.className,
					pos : {
						file : "",
						min : 0,
						max : 0
					},
					isPrivate : false,
					isExtern : false,
					params : [],
					meta : null,
					doc : null,
					exclude:function(){},
					kind : ClassKind.KNormal,
					isInterface : false,
					superClass : null,
					interfaces : [],
					fields : null,
					statics : null,
					constructor : null,
					init : null,
					overrides : []
				}
			var type = Type.TInst(new RefImpl(classType), []);
			var typeStr = TypeTools.toString(type);
		trace("type: "+type.className);
		}
	}
	
	function onSchemaFail(res:Dynamic) 
	{
		trace(res);
	}
	
	public function loadSchema() : Stream<Schema> 
	{
		schemaLoad.request();
		return schemaStream;
	}
	
	
}

class RefImpl<T>{
	var val:T;
	public function new(val:T) 
	{
		this.val = val;
	}
	public function get() : T
	{
		return val;
	}
	public function toString() 
	{
		return Std.string(val);
	}
}

typedef ParseType =
{
	className:String,
	fields:Dynamic
}
typedef ParseField =
{
	type:ParseFieldType,
	?targetClass:String
}

@:enum
abstract ParseFieldType(String){
	public var STRING = "String";
	public var DATE = "Date";
	public var NUMBER = "Number";
	public var BOOLEAN = "Boolean";
	public var POINTER = "Pointer";
	public var RELATION = "Relation";
}