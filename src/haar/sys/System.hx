package haar.sys;

/**
 * ...
 * @author Thomas Byrne
 */
class System
{
	static var _inited:Bool;
	static var _systemName:SystemName;
	static var _is64Bit:Bool;


	static public function init() 
	{
		if (_inited) return;
		
		_inited = true;
		
		#if sys
			_systemName = untyped Sys.systemName();
			_is64Bit = (_systemName == SystemName.Mac);
		
		#elseif openfl
			_is64Bit = openfl.system.Capabilities.supports64BitProcesses;
			
			var os = openfl.system.Capabilities.os;
			if (os.indexOf("Win") !=-1){
				_systemName = SystemName.Windows;
				
			}else if (os.indexOf("Mac") != -1){
				_systemName = SystemName.Mac;
				
			}else{
				_systemName = SystemName.Linux;
			}
		#else
			throw "Not supported";
		#end
	}
	
	
	public static var systemName(get, never):SystemName;
	static function get_systemName():SystemName 
	{
		init();
		return _systemName;
	}
	
	public static var is64Bit(get, never):Bool;
	static function get_is64Bit():Bool 
	{
		init();
		return _is64Bit;
	}
	
}

@:enum
abstract SystemName(String){
	public var Windows = "Windows";
	public var Linux = "Linux";
	public var BSD = "BSD";
	public var Mac = "Mac";
}