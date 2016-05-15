package haar.ops;

import com.imagination.cli.OpArg;
import com.imagination.cli.ops.IOp;
import com.imagination.cli.utils.PrintTools;
import haar.http.Http;
import haar.model.ParseSchema;
import haar.model.ParseSchema.ParseTypeSchema;
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
			{ name:ARG_HOST, desc:"URL for Parse server (inc. api version).", assumed:false, def:"https://api.parse.com/1/" },
			{ name:ARG_EMAIL, desc:"Email address for Parse account.", assumed:true },
			{ name:ARG_PASSWORD, desc:"Password for Parse account.", assumed:true },
			{ name:ARG_APP_NAMES, desc:"Comma separated names of apps to download schemas for (or * for all).", assumed:true, def:"*" },
			{ name:ARG_DEST, desc:"Path to save schemas to.", assumed:false, def:"" }
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
			var appsResult:Result<AppInfo> = Json.parse(res);
			for (app in appsResult.results){
				if (appNames == "*" || appNamesArr.indexOf(app.appName)!=-1){
					downloadSchema(host, dest, app);
				}
			}
			
		}).catchError(function(err){
			PrintTools.print("Failed to load App info: "+err);
		});
		http.send();
	}
	
	function downloadSchema(host:String, dest:String, app:AppInfo) 
	{
		var appName = app.appName;
		appName = appName.split(" ").join("");
		
		var http = Http.string(host + "/schemas");
		http.setHeader("X-Parse-Application-Id", app.applicationId);
		http.setHeader("X-Parse-Master-Key", app.masterKey);
		http.then(function(res:String){
			var schemaRes:Result<ParseTypeSchema> = Json.parse(res);
			var schema:ParseSchema = {host:host, serverId:appName, appId:app.applicationId, masterKey:app.masterKey, types:schemaRes.results};
			var schemaStr = Json.stringify(schema, null, "\t");
			
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

typedef AppInfo =
 {
	appName:String,
	applicationId:String,
	clientClassCreationEnabled:Bool,
	clientPushEnabled: Bool,
	dashboardURL:String,
	javascriptKey:String,
	masterKey:String,
	requireRevocableSessions: Bool,
	restKey:String,
	revokeSessionOnPasswordChange: Bool,
	webhookKey:String,
	windowsKey:String
}