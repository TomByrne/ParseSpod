package parseSpod.parse;
import parseSpod.parse.ParseObjectHelper;
import parseSpod.parse.ParseIO;
import parseSpod.parse.ParseIO.ParseQueryOps;
import parseSpod.parse.ParseIO.ParseQueryOptions;
import parseSpod.parse.ParseObjectHelper.EntityDesc;
import promhx.Deferred;
import promhx.Promise;

/**
 * ...
 * @author Thomas Byrne
 */
class ParseQuery<T>
{
	var _serverId:String;
	var _remoteType:String;
	var _options:ParseQueryOptions;
	var _desc:EntityDesc;
	var _resultWrapper:Promise<Array<String>> -> Promise<Array<T>>;

	public function new(serverId:String, remoteType:String, desc:EntityDesc, ?resultWrapper:Promise<Array<String>> -> Promise<Array<T>>) 
	{
		_serverId = serverId;
		_remoteType = remoteType;
		_desc = desc;
		_options = {};
		_resultWrapper = resultWrapper;
	}
	
	
	public function whereEq(prop:String, value:Dynamic) return where(prop, ParseQueryOps.Eq(value));
	public function whereNotEq(prop:String, value:Dynamic) return where(prop, ParseQueryOps.NotEq(value));
	
	public function whereLessThan(prop:String, value:Float) return where(prop, ParseQueryOps.LessThan(value));
	public function whereLessThanEq(prop:String, value:Float) return where(prop, ParseQueryOps.LessThanEq(value));
	public function whereGreaterThan(prop:String, value:Float) return where(prop, ParseQueryOps.GreaterThan(value));
	public function whereGreaterThanEq(prop:String, value:Float) return where(prop, ParseQueryOps.GreaterThanEq(value));
	
	public function whereEqAny(prop:String, value:Array<Dynamic>) return where(prop, ParseQueryOps.EqAny(value));
	public function whereNotEqAny(prop:String, value:Array<Dynamic>) return where(prop, ParseQueryOps.NotEqAny(value));
	public function whereAll(prop:String, value:Array<Dynamic>) return where(prop, ParseQueryOps.All(value));
	public function whereContains(prop:String, value:Dynamic) return where(prop, ParseQueryOps.Contains(value));
	
	public function whereExists(prop:String, ?value:Bool) return where(prop, ParseQueryOps.Exists(value));
	public function whereSelect(prop:String, value:Map<String, ParseQueryOps>) return where(prop, ParseQueryOps.Select(value));
	public function whereDontSelect(prop:String, value:Map<String, ParseQueryOps>) return where(prop, ParseQueryOps.DontSelect(value));
	public function whereRelatedTo(prop:String, className:String, objectId:String) return where(prop, ParseQueryOps.RelatedTo(className, objectId));
	
	public function whereRegex(prop:String, value:String) return where(prop, ParseQueryOps.Regex(value));
	public function whereText(prop:String, value:String) return where(prop, ParseQueryOps.Text(value));
	
	public function where(prop:String, queryOp:ParseQueryOps) : ParseQuery<T>
	{
		if (_options.where == null){
			_options.where = new Map();
		}
		_options.where.set(prop, queryOp);
		return this;
	}
	
	
	public function limit(value:Null<Int>) : ParseQuery<T>
	{
		if (value == null){
			Reflect.deleteField(_options, "limit");
		}else{
			_options.limit = value;
		}
		return this;
	}
	
	
	public function skip(value:Null<Int>) : ParseQuery<T>
	{
		if (value == null){
			Reflect.deleteField(_options, "skip");
		}else{
			_options.skip = value;
		}
		return this;
	}
	
	
	public function order(value:Null<String>, ?descending:Bool) : ParseQuery<T>
	{
		if (value == null){
			Reflect.deleteField(_options, "order");
		}else{
			_options.order = (descending ? "-" : "") + value;
		}
		return this;
	}
	
	
	public function keys(value:Null<Array<String>>) : ParseQuery<T>
	{
		if (value == null){
			Reflect.deleteField(_options, "keys");
		}else{
			_options.keys = value;
		}
		return this;
	}
	
	
	public function include(value:Null<Array<String>>) : ParseQuery<T>
	{
		if (value == null){
			Reflect.deleteField(_options, "include");
		}else{
			_options.include = value;
		}
		return this;
	}
	
	
	public function send() : Promise<Array<T>>
	{
		var prom:Promise<Array<String>> = ParseObjectHelper.query(_serverId, _remoteType, _desc, _options);
		if (_resultWrapper != null){
			return _resultWrapper(prom);
		}else{
			return untyped prom;
		}
	}
	
	
	public function sendSingle() : Promise<T>
	{
		var deferred:Deferred<T> = new Deferred();
		var promise:Promise<T> = new Promise(deferred);
		send().then(
			function(results){
				if (results.length == 0){
					deferred.throwError("Failed to find object matching query");
				}else if (results.length > 1){
					deferred.throwError("Matched multiple items for query");
				}else{
					deferred.resolve(results[0]);
				}
			}
		).catchError(deferred.throwError);
		return promise;
	}
}