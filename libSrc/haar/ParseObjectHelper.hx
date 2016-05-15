package haar;
import haar.ParseIO.ParseEntity;
import haar.ParseIO.ParseEntityList;
import haar.http.Http.HttpMethod;
import promhx.Deferred;
import promhx.Promise;

/**
 * ...
 * @author Thomas Byrne
 */
class ParseObjectHelper
{

	public static inline function get<K:String, T>(object:K, local:Map<String, T>, remote:Map<String, T>) : T
	{
		return local.exists(object) ? local.get(object) : remote.get(object);
	}

	public static inline function set<K:String, T>(object:K, value:T, local:Map<String, T>, remote:Map<String, T>) : T
	{
		var remoteVal:T = remote.get(object);
		if (value == remoteVal){
			local.remove(object);
		}else{
			local.set(object, value);
		}
		return value;
	}
	
	public static inline function all<T>(server:String, className:String, desc:EntityDesc) : Promise<Array<T>>
	{
		var deferred:Deferred<Array<T>> = new Deferred();
		var promise:Promise<Array<T>> = new Promise(deferred);
		ParseIO.get(server).add(HttpMethod.GET, ParseUrls.getClassUrl(server, className))
		.then(function(resp:ParseEntityList){
			var list:Array<T> = [];
			for (entity in resp.results){
				for(field in desc.fields){
					field.remote.set(entity.objectId, Reflect.field(entity, field.name));
				}
				list.push(untyped entity.objectId);
			}
			deferred.resolve(list);
			
		})
		.catchError(function(err:String){
			deferred.throwError(err);
			
		});
		return promise;
	}
	
	public static inline function save<T>(obj:T, server:String, className:String, desc:EntityDesc) : Promise<T>
	{
		var objId:String = untyped obj;
		var deferred:Deferred<T> = new Deferred();
		var promise:Promise<T> = new Promise(deferred);
		var changedProps = {};
		var changedFields = [];
		for (field in desc.fields){
			if (field.local.exists(objId)){
				Reflect.setField(changedProps, field.name, field.local.get(objId));
				changedFields.push(field);
			}
		}
		
		ParseIO.get(server).add(HttpMethod.PUT, ParseUrls.getObjectUrl(server, className, objId), changedProps)
		.then(function(resp:ParseEntity){
			for (field in changedFields){
				field.remote.set(objId, field.local.get(objId));
				field.local.remove(objId);
			}
			if (resp.updatedAt != null){
				// save new updatedAt?
			}
			deferred.resolve(obj);
		})
		.catchError(function(err:String){
			deferred.throwError(err);
			
		});
		return promise;
	}
	
	public static function load<T>(obj:T, overwriteChanges:Bool, server:String, className:String, desc:EntityDesc) : Promise<T>
	{
		var objId:String = untyped obj;
		var deferred:Deferred<T> = new Deferred();
		var promise:Promise<T> = new Promise(deferred);
		
		ParseIO.get(server).add(HttpMethod.GET, ParseUrls.getObjectUrl(server, className, objId))
		.then(function(resp:ParseEntity){
			for (field in desc.fields){
				if (Reflect.hasField(resp, field.name)){
					field.remote.set(objId, Reflect.field(resp, field.name));
					if(overwriteChanges) field.local.remove(objId);
				}
			}
			deferred.resolve(obj);
		})
		.catchError(function(err:String){
			deferred.throwError(err);
			
		});
		return promise;
	}
	
}

typedef EntityDesc =
{
	fields:Array<EntityDescField<Dynamic>>
}

typedef EntityDescField<T> =
{
	name:String,
	local:Map<String, T>,
	remote:Map<String, T>,
}