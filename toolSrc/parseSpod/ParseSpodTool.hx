package parseSpod;

import com.imagination.cli.CliTool;
import com.imagination.util.app.App;
import haxe.Resource;
import parseSpod.http.BaseHaxeHttp;
import parseSpod.ops.DownloadParseSchemaOp;
import parseSpod.ops.GenerateClassesOp;

/**
 * ...
 * @author Thomas Byrne
 */
class ParseSpodTool extends CliTool
{
	static function main() 
	{
		new ParseSpodTool();
	}
	
	public function new() 
	{
		super({checkLastArgForCWD:true});
	}
	override function addOps() 
	{
		//BaseHaxeHttp.PROXY = { host : "127.0.0.1", port : 8888, auth : { user : "--", pass : "--" } };
		
		addHelpOp("Parse Spod Tool", App.getVersion());
		addOp(DownloadParseSchemaOp.NAME, new DownloadParseSchemaOp());
		//addOp(DownloadParseSchemaLegacyOp.NAME, new DownloadParseSchemaLegacyOp());
		addOp(GenerateClassesOp.NAME, new GenerateClassesOp());
	}
}