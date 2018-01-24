package parseSpod.ops;

import com.imagination.cli.OpArg;
import com.imagination.cli.ops.IOp;
import com.imagination.cli.utils.PrintTools;
import parseSpod.http.Http;
import parseSpod.model.ParseSchema;
import parseSpod.model.ParseSchema.ParseTypeSchema;
import haxe.Json;
import sys.io.File;
import sys.io.FileOutput;

/**
 * @author Thomas Byrne
 */
class DownloadParseSchemaOp implements IOp
{
	public static var NAME:String = "load-parse";
	
	private static var ARG_HOST:String = "host";
	private static var ARG_NAME:String = "name";
	private static var ARG_APP_ID:String = "appId";
	private static var ARG_REST_KEY:String = "restKey";
	private static var ARG_MASTER_KEY:String = "masterKey";
	private static var ARG_DEST:String = "dest";

	public function new() 
	{
		
	}
	
	public function getHelp():String 
	{
		return "Downloads schemas from parse and saves them to disk.\n\nDEPRECATED: This operation is built for the old 'multi-app' Parse server.\nFor the new open-source source server (which only allwos one app per server) use 'load-parse'.";
	}
	
	public function getArgInfo():Array<OpArg> 
	{
		return [
			{ name:ARG_HOST, desc:"URL for Parse server (inc. api version).", assumed:false, prompt:"URL for Parser Server?" },
			{ name:ARG_NAME, desc:"Parse App name.", assumed:false, prompt:"App name on Parser Server?" },
			{ name:ARG_APP_ID, desc:"Parse App ID.", assumed:false, prompt:"App ID on Parser Server?" },
			{ name:ARG_REST_KEY, desc:"Rest Key (required for runtime calls).", assumed:false, prompt:"Rest Key (required for runtime calls)?" },
			{ name:ARG_MASTER_KEY, desc:"Master Key (required for schema lookup).", assumed:false, prompt:"Master Key (required for schema lookup)?" },
			{ name:ARG_DEST, desc:"Path to save schemas to.", assumed:false, def:"", prompt:"Path to save schemas to?" }
		];
	}
	
	public function doOp(args:Map<String, String>):Void 
	{
		var host = args.get(ARG_HOST);
		var appId = args.get(ARG_APP_ID);
		var restKey = args.get(ARG_REST_KEY);
		var masterKey = args.get(ARG_MASTER_KEY);
		var dest = args.get(ARG_DEST);
		var appName = args.get(ARG_NAME);
		
		if (dest == ""){
			dest = Sys.getCwd();
		}
		
		var app:ParseAppInfo = {
			appName : appName,
			applicationId : appId,
			restKey : restKey,
			masterKey : masterKey,
			serverHost : host,
			types:null
		}
		
		
		downloadSchema(host, dest, app);
	}
	
	function downloadSchema(host:String, dest:String, app:ParseAppInfo) 
	{
		var appName = app.appName;
		appName = appName.split(" ").join("");
		
		var http = Http.string(host + "/schemas");
		http.setHeader("X-Parse-Application-Id", app.applicationId);
		http.setHeader("X-Parse-Master-Key", app.masterKey);
		http.then(function(res:String){
			var schemaRes:Result<ParseTypeSchema> = Json.parse(res);
			app.types = schemaRes.results;
			app.serverHost = host;
			var schemaStr = Json.stringify(app, null, "\t");
			
			var path = dest + "/" + appName +".schema.json";
			var output:FileOutput = File.write(path);
			output.writeString(schemaStr);
			output.close();
			
			PrintTools.progressInfo("SuccessFully downloaded schema for App " + app.appName + ", to file " + path);
			
		}).catchError(function(err){
			PrintTools.print("Failed to load App schema: "+err);
		});
		http.send();
	}
	
}