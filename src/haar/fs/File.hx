package haar.fs;
import com.imagination.util.fs.File;
import openfl.net.SharedObject;


/**
 * ...
 * @author Thomas Byrne
 */
#if air3


	typedef File = flash.filesystem.File;
	
	
#elseif sys


	abstract File(String)
	{
		public function new(path:String) 
		{
			if (path.indexOf("file://") != 0){
				path = convertFromNativePath();
			}
			this = path;
		}
		
		public function resolvePath(path:String):File
		{
			return new File(this.path + "/" + path)
		}
		
		public function deleteFile():Void
		{
			sys.FileSystem.deleteFile(this);
		}
		
		public function deleteDirectory():Void
		{
			sys.FileSystem.deleteDirectory(this);
		}
		
		public function createDirectory():Void
		{
			sys.FileSystem.createDirectory(this);
		}
		
		public function getDirectoryListing():Array<File>
		{
			return cast sys.FileSystem.readDirectory(this);
		}
		
		public var exists(get, null):Bool;
		function get_exists():Bool 
		{
			return sys.FileSystem.exists(this);
		}
		
		public var isDirectory(get, null):Bool;
		function get_isDirectory():Bool 
		{
			return sys.FileSystem.isDirectory(this);
		}
		
		public var nativePath(get, null):String;
		function get_nativePath():String 
		{
			return convertToNativePath(url);
		}
		
		public var url(get, null):String;
		function get_url():String 
		{
			return this;
		}
		
		function convertToNativePath(url:String) : String
		{
			
		}
		
		function convertFromNativePath(path:String) : String 
		{
			
		}
	}
#elseif js
	
	class File
	{
		public static var documentsDirectory(get, null):File;
		
		@:allow(com.imagination.util.fs.FileStream)
		private var sharedObject:SharedObject;
		private var path:String;
		public var nativePath(get, null):String;
		public var exists(get, null):Bool;
		
		public function new(path:String) 
		{
			this.path = path;
			init();
		}
		
		private function init():Void
		{
			if (sharedObject == null) sharedObject = SharedObject.getLocal(path);
		}
		
		public function resolvePath(path:String):File
		{
			return new File(this.path + "/" + path);
		}
		
		
		private function get_nativePath():String 
		{
			return path;
		}
		
		private static function get_documentsDirectory():File 
		{
			return new File("documents/");
		}
		
		private function get_exists():Bool 
		{
			if (Reflect.getProperty(sharedObject.data, "data") == null) {
				return false;
			}
			else {
				return true;
			}
		}
	}
	
	
#end