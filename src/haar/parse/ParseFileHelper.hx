package haar.parse;
import haar.parse.ParseIO.ParseEntity;
import haar.fs.FileSystem;
import haar.http.Http.HttpMethod;
import haar.parse.ParseFile;
import promhx.Deferred;
import promhx.Promise;

/**
 * ...
 * @author Thomas Byrne
 */
class ParseFileHelper
{
	
	static public function uploadForEntity(server:String, objectId:String, local:Map<String, ParseFile>, parseFile:ParseFile, contentTypes:Map<String, String>)  : Promise<ParseFile>
	{
		var deferred:Deferred<ParseFile> = new Deferred();
		var promise:Promise<ParseFile> = new Promise(deferred);
		
		upload(server, parseFile, contentTypes)
		.then(function(fileEntity:ParseFileEntity){
			var file = new ParseFile(fileEntity.name, fileEntity.url);
			local.set(objectId, file);
			deferred.resolve(file);
		});
		
		return promise;
	}
	
	static public function upload(server:String, parseFile:ParseFile, contentTypes:Map<String, String>) : Promise<ParseFileEntity>
	{
		
		var deferred:Deferred<ParseFileEntity> = new Deferred();
		var promise:Promise<ParseFileEntity> = new Promise(deferred);
		
		if (parseFile.uploaded){
			deferred.throwError("Parse file already uploaded: " + parseFile.id);
			return promise;
		}
		
		var path = parseFile.id;
		var filename = FileSystem.getName(path);
		
		ParseIO.get(server).add(HttpMethod.POST, ParseUrls.getFilesUrl(server, filename), null, null, null, null, path, parseFile.contentType)
		.then(function(resp:ParseFileEntity){
			contentTypes.remove(path);
			deferred.resolve(resp);
		})
		.catchError(function(err:String){
			deferred.throwError(err);
			
		});
		return promise;
	}
	
	static public function getUploaded(id:String, contentType:Map<String, String>) : Bool
	{
		return !contentType.exists(id);
	}
	
	static public function getContentType(id:String, contentType:Map<String, String>) : String
	{
		if (getUploaded(id, contentType)){
			throw "Can't get contentType of uploaded file";
		}
		return contentType.get(id);
	}
	
	/*static public function delete(server:String, parseFile:ParseFile) : Promise<Void>
	{
		var deferred:Deferred<T> = new Deferred();
		var promise:Promise<T> = new Promise(deferred);
		
		if (!parseFile.uploaded){
			deferred.throwError("Parse file not uploaded: " + parseFile.id);
			return promise;
		}
		
		ParseIO.get(server).add(HttpMethod.DELETE, ParseUrls.getObjectUrl(server, className, id))
		.then(function(resp:ParseEntity){
			unload(id, desc);
			deferred.resolve(null);
		})
		.catchError(function(err:String){
			deferred.throwError(err);
			
		});
		return promise;
	}*/
	
}

typedef ParseFileEntity =
{
	name:String,
	url:String
}