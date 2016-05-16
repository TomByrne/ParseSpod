package haar;
import haxe.Json;
import haxe.macro.ComplexTypeTools;
import haxe.macro.Context;
import haxe.macro.Expr.ComplexType;
import haxe.macro.Expr.TypeDefKind;
import haxe.macro.Expr.TypeDefinition;
import haxe.macro.Expr.TypePath;
import haxe.macro.Type.AbstractType;
import haxe.macro.TypeTools;
import sys.io.File;

/**
 * ...
 * @author Thomas Byrne
 */
#if macro
class ParseBuilder
{

	public static function build(id:String, loadSchema:Bool, appId:String, restKey:String, host:String="https://api.parse.com", apiVersion:String="1", ?pack:String) 
	{
		
	}
	
}
#end