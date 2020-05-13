Changelog
=========

Unreleased
----------

* Fixed exception conflict with Haxe 4.1.
  * If using Haxe older than 4.1, compile with `-lib exception`.
  * If using Haxe 4.1 or newer, upgrade [`safety`](https://github.com/RealyUniqueName/Safety) or use the latest with `haxelib git`.
* Fixed CPP target compilation syntax error.

0.101.0 (2020-05-09)
--------------------

* Synchronized with Cobbletext 0.2.0
  * Removed `Library.clearGlyphs()`, added `Engine.clearTiles()`.
* Added `hasOverflow` property to `TileGroupRenderer`.

0.100.1 (2020-05-06)
--------------------

* HashLink:
  * Fixed serious runtime string corruption.
  * Fixed `Library.loadFont()` & `Library.loadFontBytes()` not throwing exceptions.
  * Added hdll version check.

0.100.0 (2020-05-05)
--------------------

The native code has been moved into a separate project called
[Cobbletext](https://github.com/chfoo/cobbletext). This offloads most of the
complications of building C/C++ projects into a proper library. The project
contains better handling of multilingual text.

* Removed support for Haxe 3.
* Removed internal classes related to text processing such as `Layout`,
  `Shaper`,`LineBreakingAlgorithm`, `BidiAlgorithm`, etc.
* Removed `cobbles_binding.js` in favor of `cobbletext.js`.
* Removed `markup.ScriptAutoHandler`.
* Removed glyph caching classes.
* Changed `TextInput` to be the analog of Cobbletext `Engine`.
  * Note that `color` is now a "custom property".
* Changed `TextConfig` to be the analog of Cobbletext `Library`.
* Changed renderers to accept `Library` and `Engine`.
* Changed `InlineObject` now returns sizes in pixels, not 1/64 pixel units.

Please review the readme to see how the new API works.

0.3.0 (2019-04-14)
------------------

* Fixed Access Violation in native code on Windows.
* Changed: `LayoutFacade` renamed to `TextInput`.
* Changed: The `FontTable` singleton was moved to the new `TextConfig`
  which now holds all the singletons. Use `TextConfig.instance()` for the
  singleton. `TextInput` accepts optional `TextConfig`.
* Removed bidi algorithm interface and its use until the rendering stack
  is more defined in later versions.
* Added text run custom property map.
* Added `detectScript()` to guess script and direction.
* Added markup language support.

0.2.0 (2019-04-07)
------------------

* Fixed missing dependencies in haxelib.json.
* Fixed missing embedding default font resource.
* Fixed automatic line breaking in general.
* Added optional `fonts` parameter to `FontTable.findByCodePoint()`.

0.1.0 (2019-04-04)
------------------

* First release
