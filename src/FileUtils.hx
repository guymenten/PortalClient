package;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.geom.Rectangle;
import flash.utils.ByteArray;

/**
 * ...
 * @author GM
 */
class FileUtils
{
	//var dataArray:Array;
	var file:File;
	var fileName:String;
	var fileData:String;
	static var streamPng:FileStream;
	static var filePng:File;

	public function FileUtils():Void
	{
	}

	/**
	 * 
	 * @param	ba
	 * @param	rect
	 * @param	fileName
	 */
	public static function savePNGData(ba:ByteArray, rect:Rectangle, fileName:String)
	{
		// Saving the BitmapData
		//
		if (!cast streamPng) {
			streamPng = new FileStream();
			filePng = new File(getApplicationDirURL(fileName));
		}

		streamPng.open(filePng, FileMode.WRITE);
		streamPng.writeBytes(ba);
		streamPng.close();
	}

	/**
	 * 
	 * @param	string
	 */
	static public function getApplicationDirURL(fileName:String) :String
	{
		return File.applicationDirectory.nativePath + "\\" + fileName;
	}

	/**
	 *
	 */
	function readFile():Bool
	{
		var stream:FileStream = new FileStream();
		stream.open(file, FileMode.READ);
		fileData = stream.readUTFBytes(stream.bytesAvailable);
		stream.close();
		
		return fileData.length != 0;
	}

	/**
	 *
	 * @param	strFile
	 */
	public function readApplicationDirectoryFile(strFile:String):Void
	{
		fileName = strFile;
		file = File.applicationDirectory.resolvePath(strFile);
		readFile();
	}
	/**
	 * 
	 * @param	string
	 */
	public function readApplicationStorageDirectoryFile(strFile:String):Void
	{
		fileName = strFile;
		file = File.applicationStorageDirectory.resolvePath(fileName);
		readFile();
	}

}