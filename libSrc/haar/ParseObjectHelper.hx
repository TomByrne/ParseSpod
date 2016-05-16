package haar;
import haar.ParseIO.ParseEntity;
import haar.ParseIO.ParseEntityList;
import haar.ParseObjectHelper.EntityDesc;
import haar.http.Http.HttpMethod;
import parse.idm.App;
import promhx.Deferred;
import promhx.Promise;

/**
 * ...
 * @author Thomas Byrne
 */
class ParseObjectHelper
{
	
	static public function getLoaded<K:String>(obj:K, loadedObjects:Map<K, Bool>) : Bool
	{
		return loadedObjects.exists(obj);
	}

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
				loadedObj(entity, desc, false);
				list.push(untyped entity.objectId);
			}
			deferred.resolve(list);
			
		})
		.catchError(function(err:String){
			deferred.throwError(err);
			
		});
		return promise;
	}
	
	static inline private function loadedObj(entity:ParseEntity, desc:EntityDesc, overwriteChanges:Bool) 
	{
		var objId = entity.objectId;
		desc.loaded.set(objId, true);
		for (field in desc.fields){
			if(overwriteChanges) field.local.remove(objId);
			switch(field.type){
				case EntityDescFieldType.NORMAL:
					field.remote.set(objId, Reflect.field(entity, field.name));
					
				case EntityDescFieldType.POINTER:
					var pointer = Reflect.field(entity, field.name);
					if(pointer != null) field.remote.set(objId, pointer.objectId);
					
				case EntityDescFieldType.FILE:
					var file = Reflect.field(entity, field.name);
					if(file != null) field.remote.set(objId, file.url);
					
				case EntityDescFieldType.RELATION:
					// must be explicitly loaded
			}
		}
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
				switch(field.type){
					case EntityDescFieldType.NORMAL:
						Reflect.setField(changedProps, field.name, field.local.get(objId));
							
					case EntityDescFieldType.POINTER:
						var objectId = field.local.get(objId);
						if (objectId != null) Reflect.setField(changedProps, field.name, { objectId:objectId, __type: "Pointer", className: field.remoteType });
						else Reflect.setField(changedProps, field.name, null);
							
					case EntityDescFieldType.FILE | EntityDescFieldType.RELATION:
						// Can't directly set these types
					
				}
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
	
	public static inline function load<T>(obj:T, overwriteChanges:Bool, server:String, className:String, desc:EntityDesc) : Promise<T>
	{
		var objId:String = untyped obj;
		var deferred:Deferred<T> = new Deferred();
		var promise:Promise<T> = new Promise(deferred);
		
		ParseIO.get(server).add(HttpMethod.GET, ParseUrls.getObjectUrl(server, className, objId))
		.then(function(resp:ParseEntity){
			loadedObj(resp, desc, overwriteChanges);
			deferred.resolve(obj);
		})
		.catchError(function(err:String){
			deferred.throwError(err);
			
		});
		return promise;
	}
	
	public static function delete<T>(obj:T, server:String, className:String, desc:EntityDesc) : Promise<T>
	{
		var objId:String = untyped obj;
		var deferred:Deferred<T> = new Deferred();
		var promise:Promise<T> = new Promise(deferred);
		
		ParseIO.get(server).add(HttpMethod.DELETE, ParseUrls.getObjectUrl(server, className, objId))
		.then(function(resp:ParseEntity){
			unload(objId, desc);
			deferred.resolve(null);
		})
		.catchError(function(err:String){
			deferred.throwError(err);
			
		});
		return promise;
	}
	
	public static inline function unload(objId:String, desc:EntityDesc) 
	{
		desc.loaded.remove(objId);
		for (field in desc.fields){
			field.remote.remove(objId);
			field.local.remove(objId);
		}
	}
	
	public static inline function toString<T:String>(obj:T, desc:EntityDesc) : String
	{
		if (obj == null) return "null";
		var str = "{";
		for (i in 0 ... desc.fields.length){
			var field = desc.fields[i];
			if (i != 0) str += ", ";
			var value = get(obj, field.local, field.remote);
			if (Std.is(value, String)) value = '"' + value + '"';
			str += field.name + ":" + value;
		}
		return str + "}";
	}
	
}

typedef EntityDesc =
{
	fields:Array<EntityDescField<Dynamic>>,
	loaded:Map<String, Bool>
}

typedef EntityDescField<T> =
{
	name:String,
	local:Map<String, T>,
	remote:Map<String, T>,
	type:EntityDescFieldType,
	?remoteType:String
}

@:enum
abstract EntityDescFieldType(String){
	public var NORMAL = "normal";
	public var POINTER = "pointer";
	public var RELATION = "relation";
	public var FILE = "file";
}