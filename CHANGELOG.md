Changelog
=========

Unreleased
----------

* Changed: `LayoutFacade` renamed to `TextInput`.
* Changed: The `FontTable` singleton was moved to the new `TextConfig` which now holds all the singletons. Use `TextConfig.instance()` for the singleton. `TextInput` accepts optional `TextConfig`.
* Removed bidi algorithm interface and its use until the rendering stack
  is more defined in later versions.
* Added text run custom property map.
* Added `detectScript()` to guess script and direction.

0.2.0 (2019-04-07)
------------------

* Fixed missing dependencies in haxelib.json.
* Fixed missing embedding default font resource.
* Fixed automatic line breaking in general.
* Added optional `fonts` parameter to `FontTable.findByCodePoint()`.

0.1.0 (2019-04-04)
------------------

* First release
