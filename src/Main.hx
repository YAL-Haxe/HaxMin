package ;

import haxe.io.Path;
import neko.Lib;
import sys.FileSystem;
import sys.io.File;

/**
 * ...
 * @author YellowAfterlife
 */
class Main {
	//
	static function main() {
		var path0:String = null, path1:String = null,
			listFiles:Array<String> = ["default.txt"];
		//
		var args = Sys.args();
		if (args.length >= 1) {
			path0 = args[0];
			if (args.length >= 2) {
				path1 = args[1];
			} else path1 = path0;
		} else {
			Lib.println("Usage: haxmin [source file] [destination file] [exclusion files...]");
			Lib.println("...or: haxmin [path] [exclusion list file]");
			Sys.exit(1);
		}
		if (FileSystem.isDirectory(path0)) {
			listNames(path0, path1);
			return;
		}
		// add exclusion word sources from arguments:
		for (i in 2 ... args.length) listFiles.push(args[i]);
		// load additional exclusion words from files:
		for (p in listFiles) if (p.charAt(0) == "[") {
			var j = p.indexOf("]");
			if (j < 0) {
				Lib.print("Identifier list has no end: " + p);
				continue;
			}
			var words = p.substring(1, j).split(",");
			for (word in words) Haxmin.SL_EXCLUDE.push(word);
			Lib.println("Added identifiers: " + Std.string(words));
		} else try {
			var lines = File.getContent(p).split("\n");
			Lib.println("Loading list from " + p + "...");
			for (line in lines) Haxmin.SL_EXCLUDE.push(line);
		} catch (e:Dynamic) { Lib.println("Failed to load from " + p); }
		//
		var size0:Int, size1:Int;
		var src:String = sys.io.File.getContent(path0);
		Lib.println("Source is " + getSizeString(size0 = src.length));
		Lib.println("Seeking...");
		var tks = Haxmin.parse(src);
		//
		/*print("Printing...");
		src = Haxmin.print(tks);
		print("Minified is " + src.length + "b");
		print("Saving...");
		FileSystem.deleteFile(path + "test-min.js");
		File.saveContent("../src/test-min.js", src);*/
		//
		Lib.println("Renaming...");
		Haxmin.rename(tks, []);
		Lib.println("Printing...");
		src = Haxmin.print(tks);
		Lib.println("Minified+renamed is " + getSizeString(size1 = src.length)
		+ "(" + Std.int(size1 / size0 * 100) + "%)");
		Lib.println("Saving...");
		if (FileSystem.exists(path1)) FileSystem.deleteFile(path1);
		File.saveContent(path1, src);
		Lib.println("Done.");
	}
	static function getSizeString(bytes:Float):String {
		var v:Float;
		if ((v = bytes) < 10000) return Std.int(v) + "B";
		if ((v /= 1024) < 10000) return Std.int(v) + "KB";
		if ((v /= 1024) < 10000) return Std.int(v) + "MB";
		if ((v /= 1024) < 10000) return Std.int(v) + "GB";
		return Std.int(v /= 1024) + "TB";
	}
	/**
	 * Recursive function, used for finding declarations inside HX files.
	 * It is not very smart, since it's intended for use solely with generated classes.
	 */
	static function listNode(path:String, map:Map<String, Bool>, fcount:Array<Int>):Void {
		var files:Array<String> = FileSystem.readDirectory(path);
		for (file in files) {
			var fpath = path + "/" + file;
			if (FileSystem.isDirectory(fpath)) {
				listNode(fpath, map, fcount);
			} else if (Path.extension(fpath) == "hx") {
				var q:Int, p:Int, d = File.getContent(fpath), s:String;
				fcount[0]++;
				Lib.print(fpath);
				// add @:native()'s:
				p = 0; while ((p = d.indexOf("@:native(\"", p)) >= 0) {
					p += 10;
					q = p;
					while (d.charAt(p) != "\"") p++;
					map.set(d.substring(q, p), true);
				}
				// add variables:
				s = Haxmin.CL_IDENTX;
				p = 0; while ((p = d.indexOf("var ", p)) >= 0) {
					p += 4;
					while (s.indexOf(d.charAt(p)) < 0) p++;
					q = p;
					while (s.indexOf(d.charAt(p)) >= 0) p++;
					map.set(d.substring(q, p), true);
				}
				// add methods:
				s = Haxmin.CL_IDENTX;
				p = 0; while ((p = d.indexOf("function ", p)) >= 0) {
					p += 9;
					while (s.indexOf(d.charAt(p)) < 0) p++;
					q = p;
					while (s.indexOf(d.charAt(p)) >= 0) p++;
					map.set(d.substring(q, p), true);
				}
				s = String.fromCharCode(8);
				Lib.print(StringTools.lpad("", s, fpath.length));
				Lib.print(StringTools.lpad("", " ", fpath.length));
				Lib.print(StringTools.lpad("", s, fpath.length));
			}
		}
	}
	static function listNames(path:String, fname:String):Void {
		var map = new Map<String, Bool>(), fileCount:Array<Int>;
		Lib.println("Indexing...");
		listNode(path, map, fileCount = [0]);
		Lib.println(fileCount[0] + " files total.");
		Lib.println("Printing...");
		var b = new StringBuf(), count:Int = 0;
		for (k in map.keys()) {
			b.addSub(k, 0);
			b.addChar("\n".code);
			count++;
		}
		if (FileSystem.exists(fname)) FileSystem.deleteFile(fname);
		File.saveContent(fname, b.toString());
		Lib.println(count + " lines total.");
		Lib.println("Done.");
	}
}