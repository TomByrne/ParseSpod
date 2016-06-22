package haar.parse;
import haar.parse.ParseObjectHelper;
import haar.parse.ParseIO;
import haar.parse.ParseIO.ParseEntity;
import haar.parse.ParseIO.ParseEntityList;
import haar.parse.ParseIO.ParseQueryOptions;
import haar.parse.ParseObjectHelper.EntityDesc;
import haar.http.Http.HttpMethod;
import haar.parse.ParseObjectId;
import haxe.Json;
import parse.ParseRelation;
import parse.idm.App;
import promhx.Deferred;
import promhx.Promise;

/**
 * ...
 * @author Thomas Byrne
 */
@:access(haar.parse.ParseObjectHelper)
class ParseRelationHelper
{
	
	static public function get<T>(id:String, local:Map<String, Array<T>>) : Array<T>
	{
		return _get(id, local, false);
	}
	static public function _get<T>(id:String, local:Map<String, Array<T>>, create:Bool=true) : Array<T>
	{
		if (local.exists(id)){
			return local.get(id);
		}else if(create){
			var list = [];
			local.set(id, list);
			return list;
		}else{
			return [];
		}
	}
	
	static public function loaded<T>(objectId:String, loaded:Map<String, Bool>) : Bool
	{
		return loaded.get(objectId);
	}
	
	static public function add<T>(objectId:String, local:Map<String, Array<T>>, addedLocal:Map<String, Array<T>>, removedLocal:Map<String, Array<T>>, entity:T) : Void
	{
		var localList = _get(objectId, local);
		if (localList.indexOf(entity) !=-1 ) return;
		
		_get(objectId, removedLocal).remove(entity);
		_get(objectId, addedLocal).push(entity);
		localList.push(entity);
		return;
	}
	
	static public function remove<T>(objectId:String, local:Map<String, Array<T>>, addedLocal:Map<String, Array<T>>, removedLocal:Map<String, Array<T>>, loaded:Map<String, Bool>, entity:T) : Void
	{
		var localList = _get(objectId, local);
		if (localList.indexOf(entity) == -1 && loaded.get(objectId) ) return;
		
		_get(objectId, removedLocal).push(entity);
		_get(objectId, addedLocal).remove(entity);
		localList.remove(entity);
	}
	
	static public function save<T>(server:String, ownerClass:String, objectId:String, propClass:String, prop:String, local:Map<String, Array<T>>, addedLocal:Map<String, Array<T>>, removedLocal:Map<String, Array<T>>, remote:Map<String, Array<T>>) : Promise<Array<T>>
	{
		if (ParseObjectId.isLocal(objectId)){
			throw "Can't save relation of unsaved object";
		}
		var promises:Array<Promise<Void>> = [];
		var deferred:Deferred<Array<T>> = new Deferred();
		var promise:Promise<Array<T>> = new Promise(deferred);
		
		var added = _get(objectId, addedLocal);
		if (added == null) added = [];
		var removed = _get(objectId, removedLocal);
		if (removed == null) removed = [];
		
		var localArray = _get(objectId, local);
		var remoteArray = _get(objectId, remote);
		
		if (added.length>0){
			var addObjs = [];
			for (entity in added){
				addObjs.push({__type:"Pointer", className:propClass, objectId:entity});
			}
			
			var propObj:Dynamic = {};
			Reflect.setField(propObj, prop, {__op:"AddRelation", objects:addObjs});
			
			var prom:Promise<Void> = ParseIO.get(server).add(HttpMethod.PUT, ParseUrls.getObjectUrl(server, ownerClass, objectId), propObj)
			.then(function(resp:ParseEntity){
				for (entity in added){
					remoteArray.push(entity);
					added.remove(entity);
				}
			});
			
			promises.push(prom);
		}
		
		if (removed.length>0){
			var addObjs = [];
			for (entity in removed){
				addObjs.push({__type:"Pointer", className:propClass, objectId:entity});
			}
		
			var propObj:Dynamic = {};
			Reflect.setField(propObj, prop, {__op:"RemoveRelation", objects:addObjs});
			
			var prom:Promise<Void> = ParseIO.get(server).add(HttpMethod.PUT, ParseUrls.getObjectUrl(server, ownerClass, objectId), propObj)
			.then(function(resp:ParseEntity){
				for (entity in removed){
					remoteArray.remove(entity);
					removed.remove(entity);
				}
			});
			
			promises.push(prom);
		}
		
		Promise.whenAll(promises).then(function(res:Array<Void>){
			deferred.resolve(localArray);
		});
		
		return promise;
	}
	
	static public function load<T>(server:String, ownerClass:String, objectId:String, propClass:String, prop:String, local:Map<String, Array<T>>, addedLocal:Map<String, Array<T>>, removedLocal:Map<String, Array<T>>, remote:Map<String, Array<T>>, loaded:Map<String, Bool>, overwriteChanges:Bool, relationDesc:EntityDesc) : Promise<Array<T>>
	{
		if (ParseObjectId.isLocal(objectId)){
			throw "Can't load relation of unsaved object";
		}
		var deferred:Deferred<Array<T>> = new Deferred();
		var promise:Promise<Array<T>> = new Promise(deferred);
		
		//var propObj:Dynamic = {};
		//Reflect.setField(propObj, "$relatedTo", {object:{__type:"Pointer", className:ownerClass, objectId:objectId}, key:prop});
		
		var query:ParseQueryOptions = {where:[prop => RelatedTo(ownerClass, objectId)]};
		
		
		var added = _get(objectId, addedLocal);
		if (added == null) added = [];
		var removed = _get(objectId, removedLocal);
		if (removed == null) removed = [];
		
		var localArray = _get(objectId, local);
		
		ParseIO.get(server).add(HttpMethod.GET, ParseUrls.getClassUrl(server, propClass), null, query)
		.then(function(resp:ParseEntityList){
			var remoteList:Array<T> = [];
			for (entity in resp.results){
				var obj:T = ParseObjectHelper.loadedObj(entity, relationDesc, false);
				if (added.indexOf(obj) != -1){
					added.remove(obj);
				}else if (localArray.indexOf(obj) == -1){
					localArray.push(obj);
				}
				if (overwriteChanges){
					removed.remove(obj);
				}
				remoteList.push(obj);
			}
			remote.set(objectId, remoteList);
			loaded.set(objectId, true);
			deferred.resolve(remoteList);
		})
		.catchError(function(err:String){
			deferred.throwError(err);
			
		});
		return promise;
	}
	
	
	/*static public function toString<T:String>(id:String, local:Map<String, Array<T>>) : String
	{
		var list:Array<String> = get(relation, local);
		if (list == null){
			return "[]";
		}else{
			return "["+list.join(",")+"]";
		}
	}*/
}