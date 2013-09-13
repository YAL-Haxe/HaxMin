# HaxMin
JavaScript obfuscator, powered by Haxe, intended for use with Haxe-generated JavaScript code. Compatible with Reflect. May also work with non-Haxe code (as long as accessors are prefixed accordingly).

## Usage
Pretty straight-forward:
```
	neko Haxmin.n [filepath]
```
Or add an extra file with "whitelisted" identifier names:
```
	neko Haxmin.n [filepath] [whitelist file path]
```
A precompiled Haxmin.n can be found in bin/. Binary file of [Neko ](https://github.com/HaxeFoundation/neko) is placed as well, just in case.
"default.txt" contains "default" whitelisted names and contains identifiers from HTML5 API accessible from Haxe (generated from js.html.*). Format for custom whitelist files is also straight-forward: one identifier name per line. Lines are to be terminated with char 10.

## Known issues
*	Program may accidentally "obfuscate" strings that share names with variables. This happens because it's not possible to easily recognize whether the value is going to be used with Reflect or not. You can fix this by modifying the strings or by creating a whitelist file with them.
*	"Composing" strings ("my" + "Field" + "1") may cause them to not work with Reflect after obfuscation. Doing so is not a good practice either. Think about it.

## Future
The following features are planned to be added to program in future:
*	Balance get_/set_ prefix obfuscation to warrant smallest filesizes.
*	Possibly add micro-optimizations to reduce file size even further.
*	Possibly include "legal" unicode characters in renamed identifiers while keeping their lengths in mind.

## Licence
Currently HaxMin itself is licenced under [Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported](http://creativecommons.org/licenses/by-nc-sa/3.0/) licence.
Obfuscated code of yours remains in your ownership, obviously :)