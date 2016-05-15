package haar.ops;

import com.imagination.cli.OpArg;
import com.imagination.cli.ops.IOp;
import com.imagination.cli.utils.PrintTools;
import haar.model.ParseSchema;
import haxe.Json;
import haxe.Resource;
import haxe.Template;
import sys.FileSystem;
import sys.io.File;
import sys.io.FileOutput;

/**
 * ...
 * @author Thomas Byrne
 */
class GenerateAbstractsOp implements IOp
{
	static var DEFAULT_EXT:String = ".schema.json";
	
	public static var NAME:String = "make";
	
	private static var ARG_SCHEMA_FILES:String = "files";
	private static var ARG_DEST:String = "dest";
	private static var ARG_VERBOSE:String = "verbose";
	
	var template:Template;

	public function new() 
	{
		
	}
	
	
	
	public function getHelp():String 
	{
		return "Generates HAAR classes from Schema file.";
	}
	
	public function getArgInfo():Array<OpArg> 
	{
		return [
			{ name:ARG_SCHEMA_FILES, desc:"Comma separated paths to schema files.", assumed:true, def:"" },
			{ name:ARG_DEST, desc:"Destination path for generated classes.", assumed:true, def:"" },
			{ name:ARG_VERBOSE, desc:"Whether to print out information on all classes generated.", assumed:false, def:"" }
		];
	}
	
	public function doOp(args:Map<String, String>):Void 
	{
		var templateStr = Resource.getString("AbstractTemplate");
		template = new Template(templateStr);
		
		var files = args.get(ARG_SCHEMA_FILES);
		var dest = args.get(ARG_DEST);
		var verbose:Bool = args.get(ARG_VERBOSE)=="true";
		
		if (dest == ""){
			dest = Sys.getCwd();
		}
		
		var filesArr:Array<String>;
		if (files == ""){
			
			var allFiles = FileSystem.readDirectory(Sys.getCwd());
			filesArr = [];
			for (file in allFiles){
				var ind = file.indexOf(DEFAULT_EXT);
				if (!FileSystem.isDirectory(Sys.getCwd() + file) && ind!=-1 && ind == file.length - DEFAULT_EXT.length){
					filesArr.push(Sys.getCwd() + file);
				}
			}
			if (filesArr.length == 0){
				PrintTools.error("Couldn't find any schemas to process in folder: " + Sys.getCwd());
				return;
			}
		}else{
			filesArr = files.split(",");
		}
		
		for (file in filesArr){
			readSchema(file, dest, verbose);
		}
	}
	
	private function readSchema(schemaFile:String, dest:String, verbose:Bool) 
	{
		if (!FileSystem.exists(schemaFile)){
			PrintTools.error("Schema file doesn't exist: " + schemaFile);
			return;
		}
		
		PrintTools.progressInfo("Reading schema: "+schemaFile);
		
		var schemaStr = File.getContent(schemaFile);
		var schema:ParseSchema = Json.parse(schemaStr);
		
		var serverId:String = schema.serverId;
		var classPack:String = "parse." + schema.serverId;
		var dir:String = "/parse/" + schema.serverId + "/";
		
		var destDir = dest + dir;
		
		if (FileSystem.exists(destDir)){
			if (!FileSystem.isDirectory(destDir)){
				throw "Could not create directory, file was found";
			}else{
				var files = FileSystem.readDirectory(destDir);
				if (files.length > 0){
					if (!PrintTools.confirm("Files already exist in folder, overwrite? [Y/N]  ", 30)){
						return;
					}else{
						for (file in files){
							if (!FileSystem.isDirectory(destDir + file)){
								FileSystem.deleteFile(destDir + file);
							}
						}
					}
				}
			}
		}else{
			FileSystem.createDirectory(destDir);
		}
		
		for (typeSchema in schema.types){
			var fieldsArr:Array<ParseFieldSchema> = [];
			
			if (typeSchema.className.charAt(0) == "_"){
				typeSchema.className = typeSchema.className.substr(1) + "_";
			}
			
			var fields = Reflect.fields(typeSchema.fields);
			for (i in 0 ... fields.length){
				var field = fields[i];
				var fieldSchema = Reflect.field(typeSchema.fields, field);
				fieldSchema.i = i;
				fieldSchema.first = (i==0);
				fieldSchema.last = (i==fields.length-1);
				fieldSchema.name = field;
				fieldsArr.push(fieldSchema);
			}
			
			var classStr = template.execute({className:typeSchema.className, fields:fieldsArr, haarVersion:"0.1beta", serverId:serverId, classPack:classPack});
			
			var path = dir + typeSchema.className + ".hx";
			var outputStream:FileOutput = File.write(dest + path);
			outputStream.writeString(classStr);
			outputStream.close();
			
			if (verbose){
				PrintTools.progressInfo("Successfully generated class " + path);
			}
		}
	}
	
}