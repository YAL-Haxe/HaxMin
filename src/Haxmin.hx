package ;

/**
 * ...
 * @author YellowAfterlife
 */
//
enum Token {
	TFlow(o:Int); // ;
	TDot; // .
	TSy(o:String); // {[(...
	TSi(o:Int); // A single symbol
	TId(o:String); // identifier
	TKw(o:Int); // for/while/etc.
	TSt(o:String); // "string"
	TNu(o:String); // 0.0
	TRx(o:String); // /magic/
}
class Haxmin {
	public static var CL_NEWLINE:String = "\r\n";
	public static var CL_WHITESPACE:String = " \t\r\n";
	public static var CL_LOWER:String;
	public static var CL_UPPER:String;
	public static var CL_ALPHA:String;
	public static var CL_DIGITS:String;
	public static var CL_DIGHEX:String;
	public static var CL_NUMBER:String;
	public static var CL_IDENT:String;
	public static var CL_IDENTX:String;
	//
	private static var SM_KEYWORD:Array<String>;
	private static var SL_KEYWORD:Map<String, Int>;
	private static var keywordElse:Int;
	private static var keywordWhile:Int;
	private static var keywordCatch:Int;
	public static var SL_EXCLUDE:Array<String>;
	//
	private static inline function isNewline(k:Int) {
		return k == "\r".code || k == "\n".code;
	}
	private static inline function isWhitespace(k:Int) {
		return k == " ".code || k == "\t".code || k == "\r".code || k == "\n".code;
	}
	private static inline function isDigit(k:Int) {
		return k >= "0".code && k <= "9".code;
	}
	private static inline function isNumber(k:Int) {
		return isDigit(k) || k == ".".code;
	}
	private static inline function isHex(k:Int) {
		return isDigit(k) || (k >= "a".code && k <= "f".code) || (k >= "A".code && k <= "F".code);
	}
	private static inline function isLower(k:Int) {
		return k >= "a".code && k <= "z".code;
	}
	private static inline function isUpper(k:Int) {
		return k >= "A".code && k <= "Z".code;
	}
	private static inline function isLetter(k:Int) {
		return isLower(k) || isUpper(k);
	}
	private static inline function isIdent(k:Int) {
		return isLetter(k) || k == "$".code || k == "_".code;
	}
	private static inline function isIdentX(k:Int) {
		return isIdent(k) || isDigit(k);
	}
	//
	private static function __init__():Void {
		var i:Int, k:Int, s:String, m:Array<String>;
		s = ''; i = '0'.code; k = '9'.code; while (i <= k) s += String.fromCharCode(i++);
		CL_DIGITS = s;
		s = ''; i = 'a'.code; k = 'z'.code; while (i <= k) s += String.fromCharCode(i++);
		CL_LOWER = s;
		s = ''; i = 'A'.code; k = 'Z'.code; while (i <= k) s += String.fromCharCode(i++);
		CL_UPPER = s;
		//
		CL_DIGHEX = CL_DIGITS + "abcdef";
		CL_NUMBER = CL_DIGITS + ".";
		CL_ALPHA = CL_LOWER + CL_UPPER;
		CL_IDENT = "$_" + CL_ALPHA;
		CL_IDENTX = CL_IDENT + CL_DIGITS;
		//
		SL_KEYWORD = new Map();
		m = ["abstract", "break", "case", "catch", "continue", "default", "delete", "do", "each",
			"else", "false", "finally", "for", "function", "goto", "if", "in", "instanceof", "new",
			"null", "return", "switch", "this", "throw", "true", "try", "typeof", "undefined", "var",
			"with", "while"];
		i = -1; k = m.length; while (++i < k) SL_KEYWORD.set(m[i], i);
		SM_KEYWORD = m;
		keywordElse = SL_KEYWORD.get("else");
		keywordCatch = SL_KEYWORD.get("catch");
		keywordWhile = SL_KEYWORD.get("while");
		// basic exclusion list:
		SL_EXCLUDE = [
		// console and tracing:
		"console", "assert", "clear", "count", "debug", "error", "info", "log", "time", "trace", "warn",
		// typeof
		"object", "boolean", "number", "string", "xml",
		// top-level in window:
		"window", "navigator", "document", "body", "location", "href",
		// elements:
		"div", "img", "span", "textarea", "audio", "canvas",
		// units:
		"px", "pt", "em", "cm", "deg", "s", "ms",
		// base JS API:
		"Navigator", "appCodeName", "appName", "appVersion", "cookieEnabled", "doNotTrack",
			"geolocation", "getStorageUpdates", "javaEnabled", "language", "mimeTypes", "onLine",
			"platform", "plugins", "product", "productSub", "registerProtocolHandler",
			"userAgent", "vendor", "vendorSub", 
		"Object", "prototype", "toString", "hasOwnProperty", "valueOf", "equals", "isPrototypeOf",
		"Boolean",
		"Function", "apply", "call", "arguments", "bind",
		"Array", "concat", "every", "filter", "forEach", "indexOf", "join", "length", "lastIndexOf",
			"pop", "push", "shift", "slice", "some", "sort", "splice", "unshift",
		"String", "charAt", "charCodeAt", "fixed", "match", "replace", "search", "split", "substr",
			"substring", "toLowerCase", "toUpperCase", "trim", "trimLeft", "trimRight", "fromCharCode",
		"Number", "toFixed", "toPrecision", "toExponential", "isNaN", "isFinite", "parseInt", "parseFloat",
		"RegExp", "compile", "exec", "lastIndex", "multiline", "source", "test",
		"Math", "E", "PI", "LN10", "LN2", "LOG10E", "LOG2E", "NEGATIVE_INFINITY",
			"POSITIVE_INFINITY", "SQRT1_2", "SQRT2", "NaN",
			"abs", "acos", "asin", "atan", "atan2", "ceil", "cos", "exp", "floor", "imul", "log",
			"max", "min", "pow", "random", "round", "sin", "sqrt", "tan",
		"Date", "getDate", "getDay", "getFullYear", "getHours", "getMilliseconds", "getMinutes",
			"getMonth", "getSeconds", "getTime", "getTimezoneOffset", "getUTCDate", "getUTCDay",
			"getUTCFullYear", "getUTCHours", "getUTCMilliseconds", "getUTCMinutes", "getUTCMonth",
			"getUTCSeconds", "getYear", "setDate", "setFullYear", "setHours", "setMinutes",
			"setMonth", "setSeconds", "setTime", "setUTCDate", "setUTCFullYear", "setUTCHours",
			"setUTCMilliseconds", "setUTCMonth", "setUTCSeconds", "setYear", "toDateString",
			"toGMTString", "toISOString", "toJSON", "toLocaleDateString", "toLocaleString",
			"toLocaleTimeString", "toUTCString",
		"escape", "unescape", "copy", "delete", "eval", "keys", 
		// Haxe-specific:
		"node", "get_", "set_",
		];
	}
	/// parses a string into array of tokens
	public static function parse(d:String):Array<Token> {
		var p:Int = -1, q:Int, l:Int = d.length,
			c:String, s:String,
			k:Int, i:Int,
			z:Bool,
			r:Array<Token> = [], n:Int = -1;
		while (++p < l) switch (k = d.charCodeAt(p)) {
		case "/".code: switch (k = d.charCodeAt(++p)) {
			case "/".code: // "//"
				while (++p < l && (CL_NEWLINE.indexOf(c = d.charAt(p)) < 0)) { }
			case "*".code: // "/* */"
				while (++p < l && (d.substr(p, 2) != "*/")) { }
				p++;
			default:
				if (n >= 0) switch (r[n]) {
					case TFlow(o): z = (o != ")".code) && (o != "]".code);
					case TSy(_): z = true;
					case TSi(_): z = true;
					default: z = false;
				} else z = true;
				if (z) {
					q = p - 1;
					while (++p < l && (k = d.charCodeAt(p)) != "/".code && !isNewline(k)) {
						if (k == "\\".code) p++;
					}
					if (isNewline(k)) { // unclosed, is not a regexp
						r[++n] = TSy("/"); p = q;
					} else {
						while (++p < l && CL_ALPHA.indexOf(c = d.charAt(p)) >= 0) { }
						r[++n] = TRx(d.substring(q, p)); p--;
					}
				} else { // not a good place for regular expression
					r[++n] = TSy("/");
					p--;
				}
			}
		case ".".code:
			if (CL_DIGITS.indexOf(d.charAt(p + 1)) >= 0) {
				q = p; while (++p < l && CL_NUMBER.indexOf(c = d.charAt(p)) >= 0) { }
				if (c == "e") {
					while (++p < l && CL_DIGITS.indexOf(d.charAt(p).toLowerCase()) >= 0) { }
				}
				r[++n] = TNu(d.substring(q, p)); p--;
			} else r[++n] = TFlow(k);
		case "{".code, "}".code, ";".code, "(".code, ")".code,
			"[".code, "]".code, "?".code, ":".code, ",".code:
			r[++n] = TFlow(k);
		case "^".code, "~".code, "*".code, "%".code:
			r[++n] = TSi(k);
		case "&".code, "|".code, "^".code, "+".code, "-".code:
			c = String.fromCharCode(k);
			s = c;
			if (d.charAt(++p) == c) {
				s += c;
			} else p--;
			r[++n] = TSy(s);
		case "!".code, "=".code:
			c = String.fromCharCode(k);
			s = c;
			if (d.charAt(++p) == "=") {
				s += "=";
				if (d.charAt(++p) == "=") {
					s += "=";
				} else p--;
			} else p--;
			r[++n] = TSy(s);
		case "<".code, ">".code:
			c = String.fromCharCode(k);
			s = c;
			switch (c = d.charAt(++p)) {
			case "=", "<", ">":
				s += c;
				if (s == ">>" && c == ">") {
					if ((c = d.charAt(++p)) == ">") s += c; else p--;
				}
			default: p--;
			}
			r[++n] = TSy(s);
		case "'".code, "\"".code:
			q = p + 1;
			while (++p < l && (i = d.charCodeAt(p)) != k) if (i == "\\".code) p++;
			r[++n] = TSt(d.substring(q, p));
		default:
			if (isIdent(k)) { // id/keyword
				q = p; while (++p < l && isIdentX(d.charCodeAt(p))) { }
				r[++n] = SL_KEYWORD.exists(s = d.substring(q, p))
					? TKw(SL_KEYWORD.get(s))
					: TId(s);
				p--;
			} else if (isNumber(k)) { // number
				q = p; while (++p < l && isNumber(k = d.charCodeAt(p))) { }
				if (k == "e".code) {
					while (++p < l && isDigit(d.charCodeAt(p))) { }
				} else if (k == "x".code && p == q + 1) {
					while (++p < l && isHex(d.charCodeAt(p))) { }
				}
				r[++n] = TNu(d.substring(q, p)); p--;
			}
		}
		return r;
	}
	///
	public static function rename(list:Array<Token>, exlist:Array<String>, debug:Bool, ns:Bool = true):Void {
		var refCount:Map<String, Int> = new Map(),
			exclude:Map<String, Bool> = new Map(),
			changes:Map<String, String> = new Map(),
			refKeys:Array<String> = [], // keys of refCount
			refVals:Array<Int> = [], // values of refCount
			refOrder:Array<String> = [], // top-to-bottom sorted order of names
			refGen:Array<String> = [], // generated names
			next:Array<Int> = [ -1], // name-picking magic
			nx1:Int = 0, // next.length - 1
			rget:String = "get_", rset:String = "set_", // renamed get_\set_
			il1:Int = CL_IDENT.length, ilx:Int = CL_IDENTX.length,
			i:Int, l:Int, j:Int, c:Int,
			mi:Int, mc:Int, ms:String, s:String, tk:Token, z:Bool, w:Bool;
		// Form hashmap of keywords:
		i = -1; l = exlist.length; while (++i < l) exclude.set(exlist[i], true);
		for (k in SL_KEYWORD.keys()) exclude.set(k, true);
		i = -1; l = SL_EXCLUDE.length; while (++i < l) exclude.set(SL_EXCLUDE[i], true);
		// Count up occurences of identifiers:
		i = -1; l = list.length; while (++i < l) switch (list[i]) {
		case TId(o):
			// Starts with "get_"/"set_":
			if (o.length >= 4 && o.charCodeAt(3) == "_".code
			&& ((j = o.charCodeAt(0)) == "g".code || j == "s".code)
			&& o.charCodeAt(1) == "e".code && o.charCodeAt(2) == "t".code) {
				if (j == "g".code) {
					refCount.set("get_", refCount.exists("get_") ? refCount.get("get_") + 1 : 1);
				} else {
					refCount.set("set_", refCount.exists("set_") ? refCount.get("set_") + 1 : 1);
				}
				o = o.substr(4);
			}
			//
			if (!exclude.exists(o)) {
				refCount.set(o, refCount.exists(o) ? refCount.get(o) + 1 : 1);
			}
		default:
		}
		// Count up occurences in strings (if flag is set):
		i = -1; if (ns) while (++i < l) switch (list[i]) {
		case TSt(o):
			// Starts with "get_"/"set_":
			if (o.length >= 4 && o.charCodeAt(3) == "_".code
			&& ((j = o.charCodeAt(0)) == "g".code || j == "s".code)
			&& o.charCodeAt(1) == "e".code && o.charCodeAt(2) == "t".code) {
				if (j == "g".code) {
					refCount.set("get_", refCount.exists("get_") ? refCount.get("get_") + 1 : 1);
				} else {
					refCount.set("set_", refCount.exists("set_") ? refCount.get("set_") + 1 : 1);
				}
				o = o.substr(4);
			}
			if (refCount.exists(o)) refCount.set(o, refCount.get(o) + 1);
		default:
		}
		// Sort identifiers in order of frequency of appearance (most used go first):
		l = 0; for (k in refCount.keys()) {
			refKeys.push(k);
			refVals.push(refCount.get(k));
			l++;
		}
		while (l > 0) { // (mysteriously, this performs better than bubble sort)
			i = -1;
			mi = -1; mc = 0;
			while (++i < l) if ((c = refVals[i]) > mc) {
				mc = c;
				mi = i;
			}
			refOrder.push(refKeys[mi]);
			refKeys.splice(mi, 1);
			refVals.splice(mi, 1);
			l--;
		}
		// generate get_/set_ remaps:
		if (!debug) {
			if (Math.random() < 0.5) {
				rget = CL_IDENT.charAt(Std.int(Math.random() * CL_IDENT.length))
					+ (Math.random() < 0.5 ? "$" : "_");
				do { rset = CL_IDENT.charAt(Std.int(Math.random() * CL_IDENT.length))
					+ (Math.random() < 0.5 ? "$" : "_");
				} while (rset == rget);
			} else {
				rget = (Math.random() < 0.5 ? "$" : "_")
					+ CL_IDENT.charAt(Std.int(Math.random() * CL_IDENT.length));
				do { rset = (Math.random() < 0.5 ? "$" : "_")
					+ CL_IDENT.charAt(Std.int(Math.random() * CL_IDENT.length));
				} while (rset == rget);
			}
		}
		// find new names:
		i = -1; l = refOrder.length;
		if (!debug) while (++i < l) {
			s = refOrder[i];
			if (s == "get_" || s == "set_") {
				refOrder.splice(i--, 1);
				l--;
				continue;
			} else do {
				j = nx1; do {
					if ((c = next[j] + 1) >= (j > 0 ? ilx : il1)) {
						next[j] = 0;
						if (j == 0) {
							next.unshift(0);
							nx1++;
							break;
						} else j--;
					} else {
						next[j] = c;
						break;
					}
				} while (true);
				s = "";
				j = 0; while (j <= nx1) s += CL_IDENTX.charAt(next[j++]);
			} while (exclude.exists(s)
			|| s.indexOf(rget) == 0
			|| s.indexOf(rset) == 0);
			refGen.push(s);
		} else while (++i < l) { // debug renaming (prefix everything with "$")
			s = refOrder[i];
			if (s == "get_" || s == "set_") {
				refOrder.splice(i--, 1);
				l--;
				continue;
			} else refGen.push("$" + s);
		}
		// just renaming identifiers is not enough. let's shuffle them.
		mi = 0; mc = il1; c = 1;
		if (mc > l) mc = l;
		i = -1; if (!debug) while (++i < l) {
			if (i >= mi + mc) {
				mi += mc; c++; mc = il1;
				j = 1; while (++j <= c) mc *= ilx;
				if (mi + mc > l) mc = l - mi;
			}
			j = Std.int(mi + Math.random() * mc);
			s = refGen[j]; refGen[j] = refGen[i]; refGen[i] = s;
		}
		// fill up the renaming map:
		i = -1; while (++i < l) changes.set(refOrder[i], refGen[i]);
		// apply changes!
		i = -1; l = list.length; while (++i < l) switch (tk = list[i]) {
		case TId(o), TSt(o):
			// Starts with "get_"/"set_":
			if (o.length >= 4 && o.charCodeAt(3) == "_".code
			&& ((j = o.charCodeAt(0)) == "g".code || j == "s".code)
			&& o.charCodeAt(1) == "e".code && o.charCodeAt(2) == "t".code) {
				s = (j == "g".code ? rget : rset)
					+ (changes.exists(s = o.substr(4)) ? changes.get(s) : s);
				switch (tk) {
				case TId(_): list[i] = TId(s);
				default: if (ns) list[i] = TSt(s);
				}
			} else if (changes.exists(o)) {
				s = changes.get(o);
				switch (tk) {
				case TId(_): list[i] = TId(s);
				default: if (ns) list[i] = TSt(s);
				}
			} else if (o.length > 1) switch (tk) {
			case TSt(o):
				j = -1; c = o.length; s = ""; mi = 0; mc = 0;
				if (ns) while (++j <= c) switch (ms = (j < c ? o.charAt(j) : ".")) {
				case ".":
					ms = o.substring(mi, j);
					if (mi == j) break;
					if (changes.exists(ms)) {
						ms = changes.get(ms);
					} else if (!exclude.exists(ms)) {
						j = 0;
						break;
					}
					if (s != "") s += ".";
					s += ms;
					mi = j + 1;
					mc++;
				default:
					if ((j == mi ? CL_IDENT : CL_IDENTX).indexOf(ms) < 0) break;
				}
				if (mc > 1) list[i] = TSt(s);
			default:
			}
		default:
		}
		//
	}
	/// Replaces string characters with escaped symbols with a chance.
	public static function rEscape(list:Array<Token>, chance:Float):Void {
		var i:Int = -1, l:Int = list.length, j:Int, m:Int, r:String, n:Int;
		while (++i < l) switch (list[i]) {
		case TSt(s):
			j = -1; m = s.length; r = "";
			while (++j < m) if (Math.random() < chance) {
				n = s.charCodeAt(j);
				r += (n < 0x100) ? ("\\x" + StringTools.hex(n, 2)) : ("\\u" + StringTools.hex(n, 4));
			} else r += s.charAt(j);
			if (r != s) list[i] = TSt(r);
		default:
		}
	}
	public static function print(list:Array<Token>):String {
		var b:StringBuf = new StringBuf(), 
			i:Int = -1, l:Int = list.length, // iterators
			s:String, sn:String = "", // string/next string
			c0:String = "", c1:String,
			k0:Int, k1:Int,
			xc:Int, // extra character
			c:Int = 0, // counter
			tk:Token = TFlow(" ".code), ltk:Token, // token/last token
			kwElse = keywordElse,
			kwWhile = keywordWhile,
			kwCatch = keywordCatch;
		while (++i <= l) {
			xc = 0;
			ltk = tk;
			s = sn; sn = tkString(tk = list[i]);
			// micro-optimizations and fixes:
			if (tk != null) switch (tk) {
			case TId(_), TNu(_): switch (ltk) {
				case TId(_): xc = " ".code;
				case TKw(_): xc = " ".code;
				case TNu(_): xc = " ".code;
				default:
				}
			case TKw(kw): switch (ltk) {
				case TFlow(fc): if (fc == "}".code && kw != kwElse
				&& kw != kwWhile && kw != kwCatch) xc = ";".code;
				case TKw(_): xc = " ".code;
				case TId(_), TNu(_): xc = " ".code;
				default:
				}
			case TFlow(fc):
				if (fc == "}".code) switch (ltk) {
				case TFlow(fp): if (fp == ";".code) s = null;
				default:
				} else if (fc == "]".code) switch (ltk) {
				case TFlow(fp): if (fp == ",".code) s = null;
				default:
				}
			case TSy(s): switch (ltk) {
				case TSy(sp):
					k0 = sp.charCodeAt(sp.length - 1);
					k1 = s.charCodeAt(0);
					if ((k0 == "+".code || k0 == "-".code) && (k1 == "+".code || k1 == "-".code)) {
						xc = " ".code;
					}
				default:
				}
			default:
			}
			if (s == null) continue;
			b.addSub(s, 0);
			if (xc != 0) { b.addChar(xc); c++; }
			c += s.length;
			// linebreaks:
			if (c >= 8000) switch (ltk) {
			case TFlow(o):
				if (o == "}".code || o == ";".code) {
					c = 0;
					b.addChar(10);
				}
			default:
			}
		}
		return b.toString();
	}
	public static function tkString(t:Token):String {
		var r = "";
		if (t == null) return r;
		switch (t) {
			case TFlow(o): r = String.fromCharCode(o);
			case TDot: r = ".";
			case TSy(o): r = o;
			case TSi(o): r = String.fromCharCode(o);
			case TId(o): r = o;
			case TKw(o): r = SM_KEYWORD[o];
			case TSt(o): r = "\"" + o + "\"";
			case TNu(o): r = o;
			case TRx(o): r = o;
		}
		return r;
	}
	///
}