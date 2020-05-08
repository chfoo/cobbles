# Cobbles

Cobbles is a Haxe binding to [Cobbletext](https://github.com/chfoo/cobbletext) layout/rendering engine library. It is intended for use in 3D graphics (OpenGL/WebGL/DirectX) applications that uses textures directly to display text. This is useful when no other facility to display text is available.

This binding tries to align the same supported features in the main Cobbletext project.

[WebGL demo](https://chfoo.github.io/cobbles/demo/example_heaps.html)—Built using Heaps.io and Emscripten.

## Getting started

Requires Haxe 4.

Install the library from Haxelib:

    haxelib install cobbles

Or the latest from the repo:

    haxelib git https://github.com/chfoo/cobbles

Next, you will need the Cobbletext version **0.2.0** libraries. See the Cobbletext project for downloads in the Releases or see the readme on how to build it. Either install the Cobbletext libraries to the system or place them in a directory to be specified in the configuration next.

### CPP target

When compiling with hxcpp, an XML config is injected into the build process which uses the following defines (`haxe -D YOUR_DEFINE_HERE=123 ...`):

* `COBBLETEXT_INCLUDE_PATH`: Directory containing the `cobbletext` directory C/C++ header files.
* `COBBLETEXT_LIBRARIES_PATH`: Directory containing all the cobbletext libraries (lib,so,dylib).

These optional defines can be used if Cobbletext is not installed in a well-known path. Alternatively, you can manually edit your `~/.hxcpp_config.xml` or `%HOMEPATH%/.hxcpp_config.xml` to include Cobbletext.

Cobbles will link directly to Cobbletext.

### HashLink

Cobbles requires a `cobbles.hdll` file wich is native HashLink library binding to Cobbletext. You can either get `cobbles.hdll` from within a release zip.

You can also build it yourself with cmake:

    mkdir out
    cd out
    cmake .. -D CMAKE_BUILD_TYPE=Release
    cmake --build . --config Release
    cmake --install . --config Release --prefix installed/

Use `-D` or set variables in CMakeCache.txt as needed:

* `COBBLETEXT_INCLUDE_PATH`: Directory containing the `cobbletext` directory C/C++ header files.
* `COBBLETEXT_LIBRARY_PATH`: Filename of the Cobbletext library (lib/so/dylib).
* `HASHLINK_INCLUDE_PATH`: Directory containing `hl.h`.
* `HASHLINK_LIBRARY_PATH`: Filename of the HashLink library (lib/so/dylib).

`cobbles.hdll` will be built to `out/native/` or `out/native/Release` for development. `out/installed/` contains one suitable for redistribution (rpath stuff). On macOS, see "Running your application" for important tips.

### JavaScript

You will need `cobbletext.js` and `cobbletext.wasm` from the Cobbletext project.

The JavaScript object `CobbletextModule` from `cobblescript.js` needs to be available before creating any Cobbles objects. The easiest way is to include the script into the HTML before yours:

```html
<script src="cobblescript.js"></script>
<script src="my_app.js"></script>
```

### Starting with Cobbles

The Cobbles API tries align with Cobbletext, so let's start with opening a library context and layout engine:

```haxe
import cobbles.Library;

var library = new Library();
var engine = new Engine(library);

// on JavaScript use:
Library.loadModule().then(library -> {
    var engine = new Engine(library);
    // ...
});
```

In order to display anything meaningful, load a font from the filesystem:

```haxe
var latinSans = library.loadFont("path/to/font.ttf");
```

Or by the bytes directly:

```haxe
var fontBytes:Bytes; // your font here
var latinSans = library.loadFontBytes(fontBytes);
```

Next, we set the default font properties:

```haxe
engine.font = latinSans;
engine.fontSize = 14;
```

Now we add some text:

```haxe
cobbles.addText("Hello world in the default properties!");
cobbles.addLineBreak();
cobbles.fontSize = 8;
cobbles.addText("This is tiny.")
```

Then perform the layout:

```haxe
cobbles.layOut()
```

The text has been shaped and positioned. In order to see anything, the glyphs need to be rasterized and drawn.

### Builtin renderer

For this example, we'll save it to a PGM file using a builtin renderer. The builtin renderers take care of storing the glyph images and drawing them to a destination. If you don't like this, skip to the manual drawing section.

First we create a bitmap where the data will be stored:

```haxe
import cobbles.render.GrayscaleBitmap;

var width = engine.outputInfo.textWidth;
var height = engine.outputInfo.textHeight;
var bitmap = new GrayscaleBitmap(width, height);
```

Next, we use a renderer that will draw each glyph onto the bitmap:

```haxe
import cobbles.render.BitmapRenderer;

var renderer = new BitmapRenderer(library, engine);
renderer.setBitmap(bitmap);
renderer.render();
```

Finally, we save to disk:

```haxe
bitmap.savePGM("my_text_on_a_bitmap.pgm");
```

### Manual drawing

For complete control, you can use the low level API matching Cobbletext. When `engine.layOut()` is called, Cobbletext stores the text into tiles and advances. Tiles represent images of the glyphs associated with the given text and advances represent pen instructions to draw tiles.

#### Texture atlas creation

First, convert the glyphs to images:

```haxe
engine.rasterize();
```

Then, arrange the tiles to a texture atlas:

```haxe
var hasOverflow:Bool = engine.packTiles(256, 256);
```

The tile packing function will return a value indicating that the tiles did not fit within the texture. To handle the case where it does not fit, double the texture size. If you aren't using a texture atlas, you can skip the texture atlas step.

Now get the tiles, glyph images, and store the atlas metadata:

```haxe
var tiles = engine.tiles();

for (tile in tiles) {
    var glyph = library.getGlyphInfo(tile.glyphID);

    myDrawToAtlas(
        glyph.image, glyph.imageWidth, glyph.imageHeight, // Source
        tile.atlasX, tile.atlasY // Destination
    );
    myAtlas.set(
        tile.glyphID, // Key
        tile.atlasX, tile.atlasY, // Location on atlas
        glyph.imageOffsetX, glyph.imageOffsetY // Drawing metadata
    );
}
```

In order to not recreate the atlas every time text is changed, use:

```haxe
var isValid:Bool = engine.tilesValid();
```

#### Draw advances

First prepare the destination image:

```haxe
var myImage = new MyImage(engine.outputInfo.textWidth, engine.outputInfo.textHeight);
```

Then loop through the advances:

```haxe
var advances = engine.advances();
var penX = 0;
var penY = 0;

for (advance in advances) {
    switch advance.type {
        case Glyph:
            var myAtlasEntry = myAtlas.get(advance.glyphID);

            var x = penX + advance->glyphOffsetX + entry.imageOffsetX;
            var y = penY + advance->glyphOffsetY + entry.imageOffsetY;

            myImage.myDrawTile(
                entry.atlasX, entry.atlasY, // Source position
                x, y // Destination position
            );
    }

    penX += advance.advanceX;
    penY += advance.advanceY;
}
```

### Reuse engine

To reuse the engine, call `clear()`. This will remove the text from its internal buffer but keep all properties and tiles intact.

```haxe
engine.clear();
engine.addText("your text here");
```

### Clearing tiles

If your texture atlas for an engine is filling up, instead of deleting and recreating an engine entirely, you can clear the tiles and the associated glyphs.

```haxe
engine.clearTiles();
```

### Running your application

When running your application, (lib)cobbletext.{dll,so,dylib} and related files (and cobbles.hdll if HashLink) needs to be in your OS library search path.

On Windows, the search path includes the exe folder, so you can place the dll files in the same folder.

On MacOS, the search path may include the same directory as your application. But you can temporarily include library paths using the `DYLD_FALLBACK_LIBRARY_PATH` environment variable. For example: `DYLD_FALLBACK_LIBRARY_PATH=my/path/to/dylib/directory/:/usr/local/lib:/lib:/usr/lib ./my_application`. As well, use `otool` on your application or cobbles.hdll to check the paths of the library dependencies. Use `install_name_tool` to change these paths.

On Linux, you can temporarily include library paths using the `LD_LIBRARY_PATH` environment variable. For example: `LD_LIBRARY_PATH=my/path/to/so/directory/ ./my_application`.

Check the Cobbletext project for information about troubleshooting libraries.

## Heaps.io integration

There is a [Heaps](https://heaps.io/) renderer included in the library. It is used like so:

```haxe
import cobbles.render.heaps.TextureAtlas;
import cobbles.render.heaps.TileGroupRenderer;

var library = new Library();
var engine = new Engine(library);
var textureAtlas = new TextureAtlas(512, 512);
var renderer = new TileGroupRenderer(library, engine, textureAtlas);
var tileGroup = renderer.newTileGroup();

s2d.addChild(tileGroup);

engine.addText("Hello world!");
engine.layOut();

renderer.renderTileGroup(tileGroup);
```

A texture atlas contains all the glyphs required to display the text. The renderer will automatically build the texture atlas as needed. Remember that a single texture atlas is tied to the renderer and the engine. If you want more than one texture atlas, create another engine and renderer.

For example, one set of engine, texture atlas, and renderer can be dedicated to drawing GUI elements with each element containing a tile group. And another set of engine, texture atlas, and renderer can be dedicated to drawing chat messages with each message represented by a tile group.

For details, see the example in the `example/heaps` directory and the API docs.

## Markup language

Cobbles also supports markup language. The following shows how to use the default tags that correspond to the methods on `Engine`:

```haxe
engine.addMarkup(
    "You can have things like " +
    "<span color='#ff0000'>color</span> and<br/>line breaks." +
    " And maybe an inline <object name='abc' width='10pt'/> too. " +
    " Bidirectional text is handled automatically: Unicode/يونيكود ");
```

For the full details on the syntax, see the API doc on `MarkupParser`.

### Customizing markup

Markup languages such as HTML5 separate semantics and style. For example, you may want to display dialog expressing shouting. Instead of manually specifying the properties using a `<span>` element, you can define a `<shout>` element handler that sets the properties for you. The benefit is that you can customize the properties depending on the script. The text can be displayed in bold & italic in one script, while it can be displayed in red and large font size in another script.

To add a custom handler, implement `ElementHandler`:

```haxe
class MyShoutHandler implements ElementHandler {
    public function handleElementStart(context:TextContext, element:Xml) {
        if (context.textInput.script == "Latn") {
            context.pushFont(myBoldItalicFontKey);
        } else {
            context.pushFontSize(context.fontSize * 1.2);
            context.pushColor(0xffff0000);
        }
    }

    public function handleElementEnd(context:TextContext, element:Xml) {
        if (context.textInput.script == "Latn") {
            context.popFont();
        } else {
            context.popFontSize();
            context.popColor();
        }
    }
}
```

And add it to the markup parser:

```haxe
var parser = engine.markupParser;
parser.elementHandlers.set("shout", new MyShoutHandler());
```

And use it like so:

```haxe
cobbles.addMarkup("I said it before and I'll say it again...<br/><shout>Nope! Nope! Nope!</shout>");
```

Note that markup support is implemented in Cobbles, not in Cobbletext, at this time.

## Further reading

To learn more, please see the [Cobbletext readme and API docs](https://github.com/chfoo/cobbletext) and the Cobbles [API documentation](https://chfoo.github.io/cobbles/api/).

## Contributing

Use the GitHub issues or pull requests section for bug reports and features.

## License

Copyright 2019-2020 Christopher Foo.

Licensed under MIT. See the licence file.

Remember that you must comply with the licenses of Freetype, Harfbuzz, ICU and their dependencies when bundling them.
