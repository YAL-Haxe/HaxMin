package ;

/**
 * ...
 * @author YellowAfterlife
 */
class Embed {
	macro public static function file(path:String) {
		var t = haxe.macro.Context.defined("display") ? ""
			: sys.io.File.getContent(path);
		return haxe.macro.Context.makeExpr(t, haxe.macro.Context.currentPos());
	}
}