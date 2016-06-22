package haar.fs;
import haar.sys.System;

/**
 * ...
 * @author Thomas Byrne
 */
class FileSystem
{
	static private var _inited:Bool;
	static private var _slash:String;
	
	static private function init() 
	{
		if (_inited) return;
		_inited = true;
		
		_slash = (System.systemName==SystemName.Windows ? "\\" : "/");
	}
	
	public static function slash() : String 
	{
		init();
		return _slash;
	}

	public static function getName(nativePath:String) : String
	{
		init();
		var lastIndex:Int = nativePath.lastIndexOf(_slash);
		if (lastIndex == nativePath.length - 1){
			nativePath = nativePath.substr(0, nativePath.length - 1);
			lastIndex = nativePath.lastIndexOf(_slash);
		}
		return lastIndex!=-1 ? nativePath.substr(lastIndex+1) : nativePath;
	}
	
}