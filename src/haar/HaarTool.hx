package haar;

import com.imagination.cli.CliTool;
import haar.ops.DownloadParseSchemaOp;
import haar.ops.GenerateAbstractsOp;

/**
 * ...
 * @author Thomas Byrne
 */
class HaarTool extends CliTool
{
	static function main() 
	{
		new HaarTool();
	}
	
	public function new() 
	{
		super();
	}
	override function addOps() 
	{
		super.addOps();
		addOp(DownloadParseSchemaOp.NAME, new DownloadParseSchemaOp());
		addOp(GenerateAbstractsOp.NAME, new GenerateAbstractsOp());
	}
}