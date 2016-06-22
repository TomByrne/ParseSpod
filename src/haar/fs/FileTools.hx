package haar.fs;

/**
 * ...
 * @author Thomas Byrne
 */
#if flash

	import flash.filesystem.File as FlFile;
	import flash.filesystem.FileStream;
	import flash.filesystem.FileMode;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	
	class FileTools
	{

		public static function getContent(path:String):String
		{
			var file:FlFile = new FlFile(path);
			var stream:FileStream =  new FileStream();
			stream.open(file, FileMode.READ);
			var ret:String = stream.readUTFBytes(stream.bytesAvailable);
			stream.close();
			return ret;
		}
		
		public static function saveContent(path:String, content:String):Void
		{
			var file:FlFile = new FlFile(path);
			var stream:FileStream =  new FileStream();
			stream.open(file, FileMode.WRITE);
			stream.writeUTFBytes(content);
			stream.close();
		}
	}

	
#elseif sys

	@:forward()
	abstract FileTools(sys.io.File) to sys.io.File
	{

		
	}

#end