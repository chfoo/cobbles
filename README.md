# Cobbles

Cobbles is a text layout/rendering engine library for Haxe. It uses Freetype and Harfbuzz for font loading, text shaping, and glyph rasterization. Its intended purpose is for use in 3D graphics (OpenGL/WebGL/DirectX) applications that uses textures directly to display text. This is useful when no other facility to display text is available.

[WebGL demo](https://chfoo.github.io/cobbles/demo/example_heaps.html)—Built using Heaps.io and Emscripten.

## Feature Summary

What is supported:

* Left-to-right text
* Right-to-left text with direction and script specified
* Automatic and manual line breaking
* Simple script, direction, and font detection
* Markup language (including manual bidirectional support)
* Rendering text using Heaps.io

What is not supported:

* Vertical text
* Text decoration (underline, emphasis dots)
* Unicode line breaking algorithm (Only a simple implementation is used currently)
* Format text by arbitrary ranges (like an editor)
* Font family querying by name
* Text segmentation:
  * Font fallback
  * Unicode bidirectional algorithm
* Text cursor navigation (characters vs clusters)

## Getting started

Requires Haxe 3 or 4.

Install the library from Haxelib:

    haxelib install cobbles

Or the latest from the repo:

    haxelib git https://github.com/chfoo/cobbles

Next, you will need the native library and as well the dependencies installed. To do this, see the library section below. Once those are built or installed, continue here.

The easiest entry to using the library is with the `TextInput` class:

```haxe
import cobbles.TextConfig;
import cobbles.TextInput;

var config = TextConfig.instance();
var cobbles = new TextInput();
```

In order to display anything meaningful, load a font from the filesystem:

```haxe
var latinSans = config.fontTable.openFile("path/to/font.ttf");
```

Or by the bytes directly:

```haxe
var fontBytes:Bytes; // your font here
var latinSans = config.fontTable.openBytes(fontBytes);
```

Next, we set the default font properties:

```haxe
cobbles.font = latinSans;
cobbles.fontSize = 14;
```

Now we add some text:

```haxe
cobbles.addText("Hello world in the default properties!");
cobbles.addLineBreak();
cobbles.addText("This is tiny.").fontSize(8);
```

Then perform the layout:

```haxe
cobbles.layoutText()
```

The text has been shaped and positioned. In order to see anything, the glyphs need to be rasterized. For this example, we'll save it to a PGM file. First we create a bitmap where the data will be stored:

```haxe
import cobbles.render.GrayscaleBitmap;

var layout = cobbles.layout;
var width = layout.point64ToPixel(layout.boundingWidth);
var height = layout.point64ToPixel(layout.boundingHeight);
var bitmap = new GrayscaleBitmap(width, height);
```

Next, we use a renderer that will draw each glyph onto the bitmap:

```haxe
import cobbles.render.BitmapRenderer;

var renderer = new BitmapRenderer(config.fontTable);
renderer.setBitmap(bitmap);
renderer.render(layout);
```

Finally, we save to disk:

```haxe
bitmap.savePGM("my_text_on_a_bitmap.pgm");
```

To learn more, please see the [API documentation](https://chfoo.github.io/cobbles/api/).

## Heaps.io integration

There is a [Heaps](https://heaps.io/) renderer included in the library. It is used like so:

```haxe
import cobbles.render.heaps.TextureAtlas;
import cobbles.render.heaps.TileGroupRenderer;

var cobbles:TextInput; // your instance here
var textureAtlas = new TextureAtlas(512, 512);
var renderer = new TileGroupRenderer(config.fontTable, textureAtlas);
var tileGroup = renderer.newTileGroup();

s2d.addChild(tileGroup);

// Whenever you update your text, call
renderer.renderTileGroup(cobbles.layout, tileGroup);
```

A texture atlas contains all the glyphs required to display the text. The renderer will automatically build the texture atlas as needed. Remember that a single texture atlas is intended to be shared for all your text blocks. If you create more than one renderer, provide it with the texture atlas in the arguments. Otherwise, it will create new texture atlas by default.

For details, see the example in the `example/heaps` directory and the API docs.

## Markup language

Cobbles also supports markup language. The following shows how to use the default tags that correspond to the methods on `TextInput`:

```haxe
cobbles.addMarkup(
    "You can have things like " +
    "<span color='#ff0000'>color</span> and<br/>line breaks." +
    " And maybe an inline <object name='abc' width='10pt'/> too. " +
    " Simplistic bidirectional text like this (Unicode/<sa>يونيكود</sa>) " +
    " is also possible.");
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
var parser = TextConfig.instance().markupParser;
parser.elementHandlers.set("shout", new MyShoutHandler());
```

And use it like so:

```haxe
cobbles.addMarkup("I said it before and I'll say it again...<br/><shout>Nope! Nope! Nope!</shout>");
```

## Other text layout and typographic features

Cobbles only provides a minimal subset of [features](https://w3c.github.io/typography/) to get your OpenGL/WebGL/DirectX application looking fairly decent. (Text engines are hard to write.) If you need to render significant amounts of text, consider alternative solutions such as embedding a web view or adding a hyperlink to open a web browser in your application.

If you would like to help getting a feature implemented (or make a feature run faster), see the Contributing section.

## Native library and dependencies

The native library (cobbles.hdll/cobbles.wasm) is required in order for Haxe generated code to communicate with other libraries like Freetype and Harfbuzz.

Prebuilt libraries may be bundled in the zip file under the "bin" folder which can be distributed along with your application. Or you can build them yourself.

### Dependencies

The following dependencies are required:

* [Freetype](https://www.freetype.org/download.html) 2+
* [Harfbuzz](https://www.freedesktop.org/wiki/Software/HarfBuzz/) 1.8+
* iconv (part of GNU C Library)

#### Linux

The libraries are most likely installed, however if this is not the case, they can be installed by a package manager.

On Ubuntu:

    apt install libfreetype6 libharfbuzz0b libc6

The headers can be installed with

    apt install libfreetype6-dev libharfbuzz-dev libc6-dev

The `LD_LIBRARY_PATH` environment variable with directory path containing the cobbles library is required for applications that don't search in the current directory.

#### Windows

You will need the dll files match the architecture of the HashLink exe. If you downloaded HashLink from the Haxe website, you will need 32-bit versions. The dlls can be installed to your system and bundled within the same directory as your application.

If prebuilt dlls are not available or you want to build them yourself, you can use [vcpkg](https://github.com/Microsoft/vcpkg):

1. Install Visual Studio 2017
2. Install Desktop C++ workload under "Get Tools and Features..."
3. Install vcpkg
4. run `vcpkg install freetype:x86-windows harfbuzz:x86-windows libiconv:x86-windows`
5. run `vcpkg export --zip freetype:x86-windows harfbuzz:x86-windows libiconv:x86-windows`

This will create a zip file containing the libraries and the dependent libraries. Dig into the "x64-windows" folder and the libraries will be in the "bin" folder and header files in the "include" folder.

#### Mac OS

If prebuilt libraries are not available or you want to build them yourself, you can use Homebrew:

    brew install freetype harfbuzz

The libraries and headers will be symlinked into /usr/local. Use `brew info` to find the location of the libraries.

### Targets

The instructions and makefiles assume a Linux-like environemnt. On Windows, use something like Git Bash that gives you Bash shell to your Windows documents.

#### CPP

Compilation should work seamlessly as the XML config is injected into the build. Cobbles will be linked statically while dependencies are dynamically linked.

If the Freetype, Harfbuzz, or Libiconv cannot be found, you can specify in your `~/.hxcpp_config.xml` or `%HOMEPATH%/.hxcpp_config.xml` file. For header include path `-I` flag, add `<flag>` to the `<compiler>` section. To specify dynamic library link path `-L` flag, add `<flag>` to the `<linker>` section.

On Windows, you may optionally use MinGW-w64 if you have trouble compiling. Under the "VARS" section, set `mingw` to `1`.

#### HashLink

cobbles.hdll can be generated by running the makefile:

    cd native/
    make hdll

On Windows, instead of "make", use:

    mingw32-make.exe hdll GCC=i686-w64-mingw32-gcc.exe WIN_PREFIX=/c/path/to/libraries/

On Mac OS, use:
    make hdll LINK_ICONV=-liconv

Inspect the makefile to see the exact paths needed. If you used the vcpkg step, "bin" and "include" folders should be in the `WIN_PREFIX` path.

#### JavaScript

Follow the [Emscripten download and install instructions](https://emscripten.org/docs/getting_started/downloads.html) to install the Emscripten SDK. Note that you don't have to install any dependencies yourself, they are automatically downloaded and included as part of the build.

Generate the Javascript by running the makefile:

    cd native/
    make js

The output will be placed in the `out/js/` directory.

Next in your Haxe application, load the Emscripten library with

    cobbles.Runtime.loadEmscripten().then(success -> {
        // ... your code continues here ...
    });

Then load or package `cobbles.js`, followed by `cobbles_binding.js`, and then your application JS.

## Contributing

Use the GitHub issues or pull requests section for bug reports and features.

Optimizing and improving the general architecture (especially to match the best practices of "real" text engines) would be appreciated.

If you want to implement a feature, please consider the guidelines:

* The feature is likely to be used by at least 80% of users.
* It does not cause library to run significantly slower. (The demo WebGL app takes about 2 milliseconds per frame on a 2015 mobile device.)
* It does not significantly increase the library's size. (It should not rely on the full Unicode database.)

To run the unit tests, use the hxml files in the `hxml/` directory. For example:

    haxe hxml/test.hl.hxml

Output is placed in the `out/` directory.

## License

Licensed under MIT. See the licence file.

Remember that you must comply with the licenses of Freetype, Harfbuzz, libiconv and their dependencies when bundling them.
