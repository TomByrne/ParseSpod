package haar.parse;
import haar.parse.ParseObjectHelper;
import haar.parse.ParseIO;
import haar.parse.ParseIO.ParseQueryOps;
import haar.parse.ParseIO.ParseQueryOptions;
import haar.parse.ParseObjectHelper.EntityDesc;
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

	public function new(serverId:String, remoteType:String, desc:EntityDesc) 
	{
		_serverId = serverId;
		_remoteType = remoteType;
		_desc = desc;
		_options = {};
	}
	
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
	
	
	public function order(value:Null<String>) : ParseQuery<T>
	{
		if (value == null){
			Reflect.deleteField(_options, "order");
		}else{
			_options.order = value;
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
		return ParseObjectHelper.query(_serverId, _remoteType, _desc, _options);
	}
}