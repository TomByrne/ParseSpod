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
 * ...
 * @author Thomas Byrne
 */
class DownloadParseSchemaOp implements IOp
{
	public static var NAME:String = "load-parse";
	
	private static var ARG_HOST:String = "host";
	private static var ARG_EMAIL:String = "email";
	private static var ARG_PASSWORD:String = "password";
	private static var ARG_APP_NAMES:String = "apps";
	private static var ARG_DEST:String = "dest";

	public function new() 
	{
		
	}
	
	public function getHelp():String 
	{
		return "Downloads schemas from parse and saves them to disk.";
	}
	
	public function getArgInfo():Array<OpArg> 
	{
		return [
			{ name:ARG_APP_NAMES, desc:"Comma separated names of apps to download schemas for (or * for all).", assumed:true, prompt:"Parse App IDs (comma separated, * for all)?" },
			{ name:ARG_EMAIL, desc:"Email address for Parse account.", assumed:false, prompt:"Parse email?" },
			{ name:ARG_PASSWORD, desc:"Password for Parse account.", assumed:false, prompt:"Parse password?" },
			{ name:ARG_HOST, desc:"URL for Parse server (inc. api version).", assumed:false, def:"https://api.parse.com/1/" },
			{ name:ARG_DEST, desc:"Path to save schemas to.", assumed:false, def:"", prompt:"Path to save schemas to?" }
		];
	}
	
	public function doOp(args:Map<String, String>):Void 
	{
		var host = args.get(ARG_HOST);
		var email = args.get(ARG_EMAIL);
		var password = args.get(ARG_PASSWORD);
		var appNames = args.get(ARG_APP_NAMES);
		var dest = args.get(ARG_DEST);
		
		var appNamesArr:Array<String> = null;
		if (appNames != "*"){
			appNamesArr = appNames.split(",");
		}
		
		if (dest == ""){
			dest = Sys.getCwd();
		}
		
		var http = Http.string(host + "/apps");
		http.setHeader("X-Parse-Email", email);
		http.setHeader("X-Parse-Password", password);
		http.then(function(res:String){
			var appsResult:Result<ParseAppInfo> = Json.parse(res);
			var found = 0;
			for (app in appsResult.results){
				if (appNames == "*" || appNamesArr.indexOf(app.appName)!=-1){
					downloadSchema(host, dest, app);
					found++;
				}
			}
			if (found < appNamesArr.length){
				PrintTools.print("Couldn't find "+(appNamesArr.length - found)+" apps");
			}
			
		}).catchError(function(err){
			PrintTools.print("Failed to load App info: "+err);
		});
		http.send();
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