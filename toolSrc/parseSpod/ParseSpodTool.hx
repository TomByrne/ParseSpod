package parseSpod;

import com.imagination.cli.CliTool;
import com.imagination.util.app.App;
import haxe.Resource;
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
		addHelpOp("Parse Spod Tool", App.getVersion());
		addOp(DownloadParseSchemaOp.NAME, new DownloadParseSchemaOp());
		addOp(GenerateClassesOp.NAME, new GenerateClassesOp());
	}
}