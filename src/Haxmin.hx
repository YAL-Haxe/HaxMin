package ;
import haxe.Timer;

/**
 * ...
 * @author YellowAfterlife
 */
/**
 * Token types.
 * `kind` here indicates 0 for normal, and 1/-1 for get_/set_ prefix accordingly.
 */
enum Token {
	TFlow(o:Int); // ;
	TDot; // .
	TSy(o:SubString); // {[(...
	TSi(o:Int); // A single symbol
	TId(o:SubString, kind:Int); // identifier
	TKw(o:Int); // for/while/etc.
	TSt(o:SubString, kind:Int, double:Bool); // double ? "string" : 'string'
	TNu(o:SubString); // 0.0
	TRx(o:SubString); // /magic/
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
	private static var SL_KEYWORD:StringLessMap<Int>;
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
		SL_KEYWORD = new StringLessMap();
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
			z:Bool, o:SubString,
			r:Array<Token> = [], n:Int = -1;
		inline function char():Int return StringTools.fastCodeAt(d, p);
		inline function next():Int return StringTools.fastCodeAt(d, ++p);
		while (++p < l) switch (k = char()) {
		case "/".code: switch (k = next()) {
			case "/".code: // "//"
				while (++p < l && (CL_NEWLINE.indexOf(c = d.charAt(p)) < 0)) { }
			case "*".code: // "/* */"
				while (++p < l && (d.substr(p, 2) != "*/")) { }
				p++;
			default:
				// check whether the slash is likely to be starting a regular expression:
				if (n >= 0) switch (r[n]) {
					case TFlow(o): z = (o != ")".code) && (o != "]".code);
					case TSy(_): z = true;
					case TSi(_): z = true;
					default: z = false;
				} else z = true;
				if (z) { // regular expression
					q = p - 1;
					while (++p < l) switch (k = d.charCodeAt(p)) {
					case "/".code: break;
					case "\r".code, "\n".code: break;
					case "\\".code: p++; // escape character
					case "[".code: // character class
						while (++p < l) switch (k = d.charCodeAt(p)) {
							case "]".code: break;
							case "\r".code, "\n".code:
								p--;
								break;
							case "\\".code: p++;
						}
					}
					if (p >= l || isNewline(k)) { // unclosed, is not a regexp
						r[++n] = TSy(new SubString(d, q, 1)); p = q;
					} else {
						while (++p < l && CL_ALPHA.indexOf(c = d.charAt(p)) >= 0) { }
						r[++n] = TRx(new SubString(d, q, p - q)); p--;
					}
				} else { // not a good place for regular expression
					r[++n] = TSy(new SubString(d, p - 1, 1));
					p--;
				}
			}
		case ".".code:
			if (CL_DIGITS.indexOf(d.charAt(p + 1)) >= 0) {
				q = p; while (++p < l && CL_NUMBER.indexOf(c = d.charAt(p)) >= 0) { }
				if (c == "e") {
					while (++p < l && CL_DIGITS.indexOf(d.charAt(p).toLowerCase()) >= 0) { }
				}
				r[++n] = TNu(new SubString(d, q, p - q)); p--;
			} else r[++n] = TFlow(k);
		case "{".code, "}".code, ";".code, "(".code, ")".code,
			"[".code, "]".code, "?".code, ":".code, ",".code:
			r[++n] = TFlow(k);
		case "^".code, "~".code, "*".code, "%".code:
			r[++n] = TSi(k);
		case "&".code, "|".code, "^".code, "+".code, "-".code:
			q = p;
			if (next() == k) {
				r[++n] = TSy(new SubString(d, q, 2));
			} else {
				p--;
				r[++n] = TSy(new SubString(d, q, 1));
			}
		case "!".code, "=".code:
			// `!`, `!=`, `!==`
			q = p;
			if (next() == "=".code) {
				if (next() != "=".code) p--;
			} else p--;
			r[++n] = TSy(new SubString(d, q, p - q + 1));
		case "<".code, ">".code:
			// `<`, `>`, `<<`, `>>`, `>>>`
			q = p;
			k = next();
			if (k == ">".code) {
				if (next() != ">".code) p--;
			} else if (k != "=".code && k != "<".code) p--;
			r[++n] = TSy(new SubString(d, q, p - q + 1));
		case "'".code, "\"".code:
			q = p + 1;
			while (++p < l && (i = char()) != k) if (i == "\\".code) p++;
			o = new SubString(d, q, p - q);
			r[++n] = TSt(o, o.prefix(), k == "\"".code);
		default:
			if (isIdent(k)) { // id/keyword
				q = p; while (++p < l && isIdentX(char())) { }
				k = SL_KEYWORD.get(d, q, p - q);
				r[++n] = k != null ? TKw(k)
					: TId(o = new SubString(d, q, p - q), o.prefix());
				p--;
			} else if (isNumber(k)) { // number
				q = p; while (++p < l && isNumber(k = char())) { }
				if (k == "e".code || k == "E".code) { // exponential
					while (++p < l && isDigit(char())) { }
				} else if (k == "x".code && p == q + 1) { // hexadecimal
					while (++p < l && isHex(char())) { }
				}
				r[++n] = TNu(new SubString(d, q, p - q)); p--;
			}
		}
		return r;
	}
	///
	public static function rename(list:Array<Token>, exlist:Array<String>, debug:Bool, ns:Bool = true):Void {
		var refCount:StringLessIntMap = new StringLessIntMap(),
			exclude:StringLessMap<Bool> = new StringLessMap(),
			changes:StringLessMap<String> = new StringLessMap(),
			refKeys:Array<String> = [], // keys of refCount
			refVals:Array<Int> = [], // values of refCount
			refOrder:Array<String> = [], // top-to-bottom sorted order of names
			refGen:Array<String> = [], // generated names
			next:Array<Int> = [ -1], // name-picking magic
			nx1:Int = 0, // next.length - 1
			rget:String = "get_", rset:String = "set_", // renamed get_\set_
			il1:Int = CL_IDENT.length, ilx:Int = CL_IDENTX.length,
			i:Int, l:Int, j:Int, c:Int, k:Int, q:SubString,
			mi:Int, mc:Int, ms:String, s:String, tk:Token, z:Bool, w:Bool;
		// Profiling... kind of.
		#if haxmin_logtimes
		var t0:Float = Timer.stamp(), t1:Float;
		#end
		inline function section(name:String) {
			#if haxmin_logtimes
			t1 = Timer.stamp();
			trace(name + ": " + Std.int((t1 - t0) * 1000) + "ms");
			t0 = t1;
			#end
		}
		// Form hashmap of keywords:
		i = -1; l = exlist.length; while (++i < l) exclude.set(exlist[i], true);
		for (k in SM_KEYWORD) exclude.set(k, true);
		for (k in SL_EXCLUDE) exclude.set(k, true);
		l = list.length;
		section("hash");
		// Count up occurences of identifiers:
		i = -1; while (++i < l) switch (list[i]) {
		case TId(o, t):
			if (t != 0) refCount.add(t > 0 ? "get_" : "set_", 1);
			if (!exclude.subGet(o)) {
				refCount.subAdd(o, 1);
			}
		default:
		}
		section("refCount");
		// Count up occurences in strings (if flag is set):
		i = -1; if (ns) while (++i < l) switch (list[i]) {
		case TSt(o, t, _):
			if (t != 0) refCount.add(t > 0 ? "get_" : "set_", 1);
			refCount.subAddx(o, 1);
		default:
		}
		section("strCount");
		// Sort identifiers in order of frequency of appearance (most used go first):
		var refPairs:Array<{ k: String, v: Int }> = [];
		l = 0; refCount.forEach(function(k, v) {
			refPairs.push( { k: k, v: v } );
			l++;
		});
		section("preSort");
		refPairs.sort(function(a, b) {
			return a.v - b.v;
		});
		section("sort");
		for (o in refPairs) refOrder.push(o.k);
		section("postSort");
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
		section("getset");
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
			} while (exclude.get(s)
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
		section("genNames");
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
		case TId(o, t):
			var newValue = changes.subGet(o);
			if (newValue != null) o.setTo(newValue);
		case TSt(o, t, _): if (ns) {
			var newValue = changes.subGet(o);
			if (newValue != null) {
				o.setTo(newValue);
			} else { // obfuscate "com.package.className" strings
				c = o.length;
				mi = 0; // segment offset
				mc = 0; // segments replaced
				s = null; // resulting string
				j = -1; while (++j <= c) {
					if (j < c) k = o.charCodeAt(j); else k = ".".code;
					if (k == ".".code) {
						newValue = changes.get(o.string, o.offset + mi, j - mi);
						if (newValue != null) {
							if (s == null) s = o.string.substr(o.offset, mi);
							else s += ".";
							s += newValue;
						} else if (s != null) {
							k = o.offset;
							s += "." + o.string.substring(k + mi, k + j);
						}
						mi = j + 1;
					} else if (!isIdentX(k)) break;
				}
				if (s != null) {
					o.setTo(s);
				}
			}
			}
		default:
		}
		section("rename");
		//
	}
	/// Replaces string characters with escaped symbols with a chance.
	/*public static function rEscape(list:Array<Token>, chance:Float):Void {
		var i:Int = -1, l:Int = list.length, j:Int, m:Int, r:String, n:Int;
		while (++i < l) switch (list[i]) {
		case TSt(s, t):
			j = -1; m = s.length; r = "";
			while (++j < m) if (Math.random() < chance) {
				n = s.charCodeAt(j);
				r += (n < 0x100) ? ("\\x" + StringTools.hex(n, 2)) : ("\\u" + StringTools.hex(n, 4));
			} else r += s.charAt(j);
			if (r != s) list[i] = TSt(r);
		default:
		}
	}*/
	public static function print(list:Array<Token>):String {
		var b:StringBuf = new StringBuf(), 
			i:Int = -1, l:Int = list.length, // iterators
			s:String, sn:String = "", // string/next string
			vi:Bool, // if thing should be printed
			c0:String = "", c1:String,
			k0:Int, k1:Int,
			xc:Int, // extra character
			c:Int = 0, // counter
			tk:Token = TFlow(" ".code), ltk:Token, // token/last token
			kwElse = keywordElse,
			kwWhile = keywordWhile,
			kwCatch = keywordCatch,
			get_ = "get_",
			set_ = "set_";
		//
		while (++i <= l) {
			xc = 0;
			ltk = tk;
			tk = list[i];
			vi = true;
			// micro-optimizations and fixes:
			if (tk != null) switch (tk) {
			case TId(_), TNu(_): switch (ltk) {
				// insert a space between pairs of ids/numbers/keywords [1]:
				case TId(_), TKw(_), TNu(_): xc = " ".code;
				// insert a semicolon between "}" and ids/numbers:
				case TFlow(fp): if (fp == "}".code) xc = ";".code;
				default:
				}
			case TKw(kw): switch (ltk) {
				// insert a semicolon between "}" and keywords:
				case TFlow(fc): if (fc == "}".code && kw != kwElse
				&& kw != kwWhile && kw != kwCatch) xc = ";".code;
				// insert a space between pairs of ids/numbers/keywords [2]:
				case TKw(_), TId(_), TNu(_): xc = " ".code;
				default:
				}
			case TFlow(fc): switch (fc) {
				case "}".code: switch (ltk) {
					case TFlow(fp): switch (fp) {
						// last semicolon before "}" can be omitted:
						case ";".code: vi = false;
						// last comma before "}" *should* be omitted:
						case ",".code: vi = false;
						}
					default:
					}
				case "]".code: switch (ltk) {
					// last comma before "]" *should* be omitted:
					case TFlow(fp): if (fp == ",".code) vi = false;
					default:
					} 
				}
			case TSy(s): switch (ltk) {
				case TSy(sp):
					// ensure that "touching" symbols do not accidentally form an *crement operator:
					k0 = sp.charCodeAt(sp.length - 1);
					k1 = s.charCodeAt(0);
					if ((k0 == "+".code || k0 == "-".code) && (k1 == "+".code || k1 == "-".code)) {
						xc = " ".code;
					}
				default:
				}
			default:
			}
			if (!vi) continue;
			// print token into buffer:
			switch (ltk) {
			case TFlow(o): b.addChar(o); c++;
			case TDot: b.addChar(".".code); c++;
			case TSy(o): o.writeTo(b); c += o.length;
			case TSi(o): b.addChar(o); c++;
			case TId(o, t):
				if (t != 0) { // get_/set_ prefix
					b.addSub(t > 0 ? get_ : set_, 0);
					c += (t > 0 ? get_ : set_).length;
				}
				o.writeTo(b);
				c += o.length;
			case TSt(o, t, d):
				b.addChar(d ? "\"".code : "'".code);
				if (t != 0) { // get_/set_ prefix
					b.addSub(t > 0 ? get_ : set_, 0);
					c += (t > 0 ? get_ : set_).length;
				}
				o.writeTo(b);
				b.addChar(d ? "\"".code : "'".code);
				c += o.length + 2;
			case TKw(o): b.addSub(SM_KEYWORD[o], 0); c += SM_KEYWORD[o].length;
			case TNu(o): o.writeTo(b); c += o.length;
			case TRx(o): o.writeTo(b); c += o.length;
			default:
			}
			//b.addSub(s = tkString(ltk), 0);
			if (xc != 0) { b.addChar(xc); c++; }
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
	/*public static function tkString(t:Token):String {
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
	}*/
	///
}

/**
 * Represents a pointer to string fragment.
 * Needed because Neko lacks immutable strings
 * (thus string operations cause reallocations).
 */
class SubString {
	//
	public var string:String;
	public var offset:Int;
	public var length:Int;
	//
	public function new(?string:String, ?offset:Int, ?length:Int) {
		setTo(string, offset, length);
	}
	
	public function setTo(string:String, ?offset:Int, ?length:Int):Void {
		this.string = string;
		if (string != null) {
			if (offset == null) offset = 0;
			this.offset = offset;
			if (length == null) length = string.length - offset;
			this.length = length;
		}
	}
	
	public function log() {
		trace('[$offset, $length] ' + this.toString());
	}
	
	public function toString():String {
		return string.substr(offset, length);
	}
	
	public inline function writeTo(buffer:StringBuf):Void {
		buffer.addSub(string, offset, length);
	}
	
	public inline function charCodeAt(position:Int):Int {
		return StringTools.fastCodeAt(string, offset + position);
	}
	
	/**
	 * Can be executed post-init to resolve whether this Substring has a get_/set_ prefix.
	 * String offset is changed accordingly in process.
	 * @return -1 for `get_`, +1 for `set_`, 0 for no prefix.
	 */
	public function prefix():Int {
		var i:Int, z:Bool;
		if (length >= 4 && charCodeAt(3) == "_".code
		&& ((z = (i = charCodeAt(0)) == "g".code) || i == "s".code)
		&& charCodeAt(1) == "e".code && charCodeAt(2) == "t".code) {
			offset += 4;
			length -= 4;
			return z ? 1 : -1;
		}
		return 0;
	}
}

/**
 * Represents a Map-like structure that avoids the use of String type for keys
 * (again, for Neko VM performance).
 */
class StringLessMap<T> {
	/// index is character code, value is map for next character in string
	private var map:Map<Int, StringLessMap<T>>;
	private var value:T;
	
	public function new() {
		map = new Map();
		value = null;
	}
	
	function __get(string:String, offset:Int, length:Int):T {
		if (length > 0) {
			var m = map.get(StringTools.fastCodeAt(string, offset));
			if (m != null) {
				return m.__get(string, offset + 1, length - 1);
			} else return null;
		} else return value;
	}
	public function get(string:String, offset:Int = 0, length:Int = -1):T {
		if (length == -1) length = string.length - offset;
		return __get(string, offset, length);
	}
	public inline function subGet(sub:SubString):T {
		return __get(sub.string, sub.offset, sub.length);
	}
	
	function __set(string:String, offset:Int, length:Int, change:T):Void {
		if (length > 0) {
			var k = StringTools.fastCodeAt(string, offset),
				m = map.get(k);
			if (m == null) map.set(k, m = new StringLessMap());
			m.__set(string, offset + 1, length - 1, change);
		} else value = change;
	}
	public function set(string:String, change:T, offset:Int = 0, length:Int = -1):Void {
		if (length == -1) length = string.length - offset;
		__set(string, offset, length, change);
	}
	public inline function subSet(sub:SubString, change:T):Void {
		__set(sub.string, sub.offset, sub.length, change);
	}
}

class StringLessIntMap extends StringLessMap<Int> {
	public function new() {
		super();
		value = 0;
	}
	function __add(string:String, offset:Int, length:Int, change:Int):Void {
		if (length > 0) {
			var k = StringTools.fastCodeAt(string, offset),
				m:StringLessIntMap = cast map.get(k);
			if (m == null) map.set(k, m = new StringLessIntMap());
			m.__add(string, offset + 1, length - 1, change);
		} else value += change;
	}
	public function add(string:String, change:Int, offset:Int = 0, length:Int = -1):Void {
		if (length == -1) length = string.length - offset;
		__add(string, offset, length, change);
	}
	public inline function subAdd(sub:SubString, change:Int):Void {
		__add(sub.string, sub.offset, sub.length, change);
	}
	//
	function __addx(string:String, offset:Int, length:Int, change:Int):Void {
		if (length > 0) {
			var k = StringTools.fastCodeAt(string, offset),
				m:StringLessIntMap = cast map.get(k);
			if (m == null) return;
			m.__addx(string, offset + 1, length - 1, change);
		} else if (value > 0) value += change;
	}
	public function addx(string:String, change:Int, offset:Int = 0, length:Int = -1):Void {
		if (length == -1) length = string.length - offset;
		__addx(string, offset, length, change);
	}
	public inline function subAddx(sub:SubString, change:Int):Void {
		__addx(sub.string, sub.offset, sub.length, change);
	}
	public function forEach(f:String->Int->Void, s:String = ""):Void {
		if (value != 0) f(s, value);
		for (k in map.keys()) {
			var v:StringLessIntMap = cast map.get(k);
			v.forEach(f, s + String.fromCharCode(k));
		}
	}
}