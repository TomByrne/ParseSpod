package haar;
import com.imagination.util.time.Timer;
import haar.ParseIO.ParseRequest;
import haar.http.Http;
import haar.http.Http.HttpMethod;
import haxe.Json;
import promhx.Deferred;
import promhx.Promise;

/**
 * ...
 * @author Thomas Byrne
 */
class ParseIO
{
	static var instances:Map<String, ParseIO> = new Map();
	
	var server:String;
	var batchDelay:Float;
	var batchQue:Array<ParseRequest> = [];
	var batchTimer:Timer;
	var httpAttempts:Int;

	public inline static function setServer(server:String, batchDelay:Float = 1, httpAttempts:Int = 2) 
	{
		var parseIO = instances.get(server);
		if (parseIO != null){
			parseIO.batchDelay = batchDelay;
			parseIO.httpAttempts = httpAttempts;
		}else {
			instances.set(server, new ParseIO(server, batchDelay, httpAttempts));
		}
	}
	public inline static function get(server:String) : ParseIO 
	{
		return instances.get(server);
	}
	
	function new(server:String, batchDelay:Float = 1, httpAttempts:Int = 2) 
	{
		this.server = server;
		this.batchDelay = batchDelay;
		this.httpAttempts = httpAttempts;
	}
	
	public function add<T>(method:HttpMethod, url:String, ?data:Dynamic) : Promise<T>
	{
		if (batchDelay <= 0 || !canBatch(method, url, data)){
			return sendSingleRequest(method, url, data);
		}else{
			var deferred:Deferred<T> = new Deferred();
			var reqPack:ParseRequestPackage = {method:method, url:url};
			if (data != null) reqPack.data = data;
			batchQue.push({ pack:reqPack, deferred:deferred });
			startBatchTimer();
			return new Promise(deferred);
		}
	}
	
	function canBatch(method:HttpMethod, url:String, ?data:Dynamic) : Bool
	{
		return (method == HttpMethod.PUT || method == HttpMethod.POST || method == HttpMethod.DELETE);
	}
	
	private function startBatchTimer() 
	{
		if (batchTimer == null){
			batchTimer = new Timer(sendBatch, Std.int(batchDelay * 1000));
		}
		batchTimer.go();
	}
	
	private function sendBatch() 
	{
		batchTimer.stop();
		
		var batchQue = this.batchQue;
		this.batchQue = [];
		
		if (batchQue.length == 1){
			var queItem = batchQue[0];
			_sendSingleRequest(queItem.pack.method, queItem.pack.url, queItem.pack.data, queItem.deferred);
			return;
		}
		var data:BatchOpData = {requests:[]};
		for (queItem in batchQue){
			data.requests.push(queItem.pack);
		}
		var http = getHttp(HttpMethod.POST, ParseUrls.getBatchUrl(server), data);
		http.then(onBatchSuccess.bind(_, batchQue));
		http.catchError(onBatchFail.bind(_, batchQue));
		http.send();
	}
	
	private function onBatchFail(res:String, batchQue:Array<ParseRequest>) 
	{
		for (item in batchQue){
			item.deferred.throwError(res);
		}
	}
	
	private function onBatchSuccess(res:String, batchQue:Array<ParseRequest>) 
	{
		var res:BatchResponse = Json.parse(res);
		for (i in 0 ... batchQue.length){
			var item = batchQue[i];
			interpretResult(item.deferred, res.results[i]);
		}
	}
	
	inline function interpretResult(deferred:Deferred<Dynamic>, res:Dynamic) 
	{
		deferred.resolve(res);
	}
	
	private function sendSingleRequest(method:HttpMethod, url:String, data:Dynamic) 
	{
		var deferred:Deferred<Dynamic> = new Deferred();
		var promise = new Promise(deferred);
		_sendSingleRequest(method, url, data, deferred);
		return promise;
	}
	
	function _sendSingleRequest(method:HttpMethod, url:String, data:Dynamic, deferred:Deferred<Dynamic>) 
	{
		var http:Http<String> = getHttp(method, url, data);
		http.send();
		http.then(function(res:String){
			interpretResult(deferred, Json.parse(res));
			
		}).catchError(function(err:String){
			deferred.throwError(err);
		});
	}
	
	inline private function getHttp(method:HttpMethod, url:String, data:Dynamic) : Http<String>
	{
		var http = Http.string(url);
		http.method = method;
		http.attempts = httpAttempts;
		http.data(Json.stringify(data));
		http.setHeader("X-Parse-Application-Id", ParseServers.getAppId(server));
		http.setHeader("X-Parse-REST-API-Key", ParseServers.getRestKey(server));
		return http;
	}
	
}

typedef ParseRequest =
{
	pack:ParseRequestPackage,
	deferred:Deferred<Dynamic>
}

typedef BatchOpData =
{
	requests:Array<ParseRequestPackage>
}

typedef ParseRequestPackage =
{
	method:HttpMethod,
	url:String,
	?data:Dynamic
}

typedef BatchResponse = 
{
	results:Array<Dynamic>
}

typedef ParseEntity = 
{
	objectId:String,
	updatedAt:ParseDate,
	createdAt:ParseDate,
}

typedef ParseEntityList =
{
	results:Array<ParseEntity>
}

abstract ParseDate(String){
	
}