package parseSpod.ops;

import com.imagination.cli.OpArg;
import com.imagination.cli.ops.IOp;
import com.imagination.cli.utils.PrintTools;
import parseSpod.model.ParseSchema;
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
class GenerateClassesOp implements IOp
{
	static var DEFAULT_EXT:String = ".schema.json";
	
	public static var NAME:String = "make";
	
	private static var ARG_SCHEMA_FILES:String = "files";
	private static var ARG_DEST:String = "dest";
	private static var ARG_VERBOSE:String = "verbose";
	private static var ARG_PACKAGE:String = "package";
	private static var ARG_TEMPLATES:String = "templates";
	
	var entityTemplate:Template;
	var systemTemplate:Template;

	public function new() 
	{
		
	}
	
	
	
	public function getHelp():String 
	{
		return "Generates Parse classes from Schema file.";
	}
	
	public function getArgInfo():Array<OpArg> 
	{
		return [
			{ name:ARG_SCHEMA_FILES, desc:"Comma separated paths to schema files.", assumed:true, def:"" },
			{ name:ARG_DEST, desc:"Destination path for generated classes.", assumed:true, def:"" },
			{ name:ARG_VERBOSE, desc:"Whether to print out information on all classes generated.", assumed:false, def:"" },
			{ name:ARG_PACKAGE, desc:"Which package to put the generated classes in.", assumed:false, def:"" },
			{ name:ARG_TEMPLATES, desc:"Directory to search for templates (built-in = 'abstract').", assumed:false, def:"abstract" }
		];
	}
	
	public function doOp(args:Map<String, String>):Void 
	{
		var templateDir = args.get(ARG_TEMPLATES);
		var entityTemplatePath = templateDir + "/EntityTemplate";
		var systemTemplatePath = templateDir + "/SystemTemplate";
		
		
		var entityTemplateStr = Resource.getString(entityTemplatePath);
		if (entityTemplateStr == null){
			entityTemplateStr = File.getContent(entityTemplatePath+".hx");
		}
		if(entityTemplateStr != null){
			entityTemplate = new Template(entityTemplateStr);
		}
		
		var systemTemplateStr = Resource.getString(systemTemplatePath);
		if (systemTemplateStr == null){
			systemTemplateStr = File.getContent(systemTemplatePath+".hx");
		}
		if(systemTemplateStr != null){
			systemTemplate = new Template(systemTemplateStr);
		}
		
		if (entityTemplate == null && systemTemplate == null){
			PrintTools.error("Couldn't find any templates in folder: " + templateDir);
			return;
		}
		
		var files = args.get(ARG_SCHEMA_FILES);
		var dest = args.get(ARG_DEST);
		var verbose:Bool = args.get(ARG_VERBOSE)=="true";
		var pack = args.get(ARG_PACKAGE);
		
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
			readSchema(file, dest, verbose, pack, filesArr.length);
		}
	}
	
	private function readSchema(schemaFile:String, dest:String, verbose:Bool, classPack:String, totalCount:Int) 
	{
		if (!FileSystem.exists(schemaFile)){
			PrintTools.error("Schema file doesn't exist: " + schemaFile);
			return;
		}
		
		PrintTools.progressInfo("Reading schema: "+schemaFile);
		
		var schemaStr = File.getContent(schemaFile);
		var schema:ParseSystemInfo = Json.parse(schemaStr);
		
		var appName:String = schema.appName.toLowerCase().split(" ").join("_");
		schema.appName = appName;
		
		if (classPack == ""){
			classPack = "parse." + appName;
		}else if(totalCount > 1){
			classPack += "." + appName;
		}
		
		var dir:String = "/" + classPack.split(".").join("/") + "/";
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
		
		var toolVersion = "0.1beta";
		
		var entities = [];
		
		for (typeSchema in schema.types){
			var allFieldsArr:Array<ParseFieldInfo> = [];
			var fieldsArr:Array<ParseFieldInfo> = [];
			var pointersArr:Array<ParseFieldInfo> = [];
			var relationsArr:Array<ParseFieldInfo> = [];
			var filesArr:Array<ParseFieldInfo> = [];
			
			
			var fields = Reflect.fields(typeSchema.fields);
			for (i in 0 ... fields.length){
				var field = fields[i];
				if (field == "objectId") continue;
				
				var fieldSchema = Reflect.field(typeSchema.fields, field);
				var type:String;
				var descType:String = "EntityDescFieldType.NORMAL";
				var addTo:Array<ParseFieldInfo> = fieldsArr;
				switch(fieldSchema.type){
					case "String":
						type = "String";
						
					case "Boolean":
						type = "Bool";
						
					case "Number":
						type = "Float";
						
					case "Object":
						type = "Dynamic";
						
					case "Array":
						type = "Array<Dynamic>";
						
					case "Date":
						type = "ParseDate";
						
					case "ACL":
						type = "ParseACL";
						
					case "Pointer":
						descType = "EntityDescFieldType.POINTER";
						type = cleanupClassName(fieldSchema.targetClass);
						addTo = pointersArr;
						
					case "Relation":
						descType = "EntityDescFieldType.RELATION";
						type = cleanupClassName(fieldSchema.targetClass);
						addTo = relationsArr;
						
					case "File":
						descType = "EntityDescFieldType.FILE";
						type = "ParseFile";
						addTo = filesArr;
						
					default:
						type = fieldSchema.type;
						PrintTools.warn("Unknown type: " + fieldSchema.type);
				}
				var remoteType = (fieldSchema.targetClass == null ? "null" : '"' + fieldSchema.targetClass + '"');
				var fieldInfo = { i:i, first:(i == 0), last:(i == fields.length - 1), name:field, type:type, descType:descType, remoteType:remoteType };
				addTo.push(fieldInfo);
				allFieldsArr.push(fieldInfo);
			}
			
			var classInfo:ParseClassInfo = {className:cleanupClassName(typeSchema.className), remoteClassName:typeSchema.className, allFields:allFieldsArr, fields:fieldsArr, pointers:pointersArr, relations:relationsArr, files:filesArr, toolVersion:toolVersion, appName:appName, classPack:classPack};
			entities.push(classInfo);
		
			if(entityTemplate != null){
				var classStr = entityTemplate.execute(classInfo);
				
				var path = dir + classInfo.className + ".hx";
				var outputStream:FileOutput = File.write(dest + path);
				outputStream.writeString(classStr);
				outputStream.close();
				
				if (verbose){
					PrintTools.progressInfo("Successfully generated class " + path);
				}
			}
		}
		
		if (systemTemplate != null){
			
			schema.className = "Server";
			schema.toolVersion = toolVersion;
			schema.classPack = classPack;
			schema.entities = entities;
			
			var systemStr = systemTemplate.execute(schema);
			
			var path = dir + schema.className + ".hx";
			var outputStream:FileOutput = File.write(dest + path);
			outputStream.writeString(systemStr);
			outputStream.close();
			
			if (verbose){
				PrintTools.progressInfo("Successfully generated system class " + path);
			}
		}
	}
	
	inline function cleanupClassName(className:String) 
	{
		
		if (className.charAt(0) == "_"){
			className = className.substr(1) + "_";
		}
		className = className.substr(0, 1).toUpperCase() + className.substr(1);
		return className;
	}
	
}
typedef ParseSystemInfo =
{
	> ParseAppInfo,
	toolVersion:String,
	className:String,
	classPack:String,
	entities:Array<ParseClassInfo>,
}
typedef ParseClassInfo =
{
	appName:String,
	toolVersion:String,
	className:String,
	classPack:String,
	remoteClassName:String,
	
	allFields:Array<ParseFieldInfo>,
	fields:Array<ParseFieldInfo>,
	pointers:Array<ParseFieldInfo>,
	relations:Array<ParseFieldInfo>,
	files:Array<ParseFieldInfo>,
}
typedef ParseFieldInfo =
{
	i:Int,
	first:Bool,
	last:Bool,
	name:String,
	type:String,
	descType:String,
	remoteType:String
}