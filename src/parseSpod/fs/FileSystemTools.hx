package parseSpod.fs;
import parseSpod.sys.System;

/**
 * ...
 * @author Thomas Byrne
 */
class FileSystemTools
{
	static private var _inited:Bool;
	static private var _isWin:Bool;
	static private var _slash:String;
	
	static private function init() 
	{
		if (_inited) return;
		_inited = true;
		
		_isWin = System.systemName == SystemName.Windows;
		
		_slash = ( _isWin ? "\\" : "/");
	}
	
	public static function slash() : String 
	{
		init();
		return _slash;
	}
	
	public static function isWin() : Bool 
	{
		init();
		return _isWin;
	}
	
	public static function cleanupNativePath(nativePath:String) 
	{
		init();
		if (_isWin){
			nativePath = StringTools.replace(nativePath, "/", "\\");
		}
		return nativePath;
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