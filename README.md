# Cobbles

Cobbles is a text layout/rendering engine library for Haxe. It uses Freetype and Harfbuzz for font loading, text shaping, and glyph rasterization. Its intended purpose is for use in 3D graphics (OpenGL/WebGL/DirectX) applications that uses textures directly to display text. This is useful when no other facility to display text is available.

[WebGL demo](https://chfoo.github.io/cobbles/demo/example_heaps.html)—Built using Heaps.io and Emscripten.

*It is currently a work in progress.*

What is supported:

* Left-to-right text
* Right-to-left text with manual direction and script specified
* Automatic and manual line breaking
* Rendering text using Heaps.io

What is not yet supported:

* Direction and script detection
* Unicode bidirectional algorithm
* Unicode line breaking algorithm
* Text decoration
* Format text by arbitrary ranges
* Markup language
* Text cursor navigation (characters vs clusters)
* Vertical text

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

There is a Heaps renderer included in the library. It is used like so:

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

To run the unit tests, use the hxml files in the `hxml/` directory. For example:

    haxe hxml/test.hl.hxml

Output is placed in the `out/` directory.

## License

Licensed under MIT. See the licence file.

Remember that you must comply with the licenses of Freetype, Harfbuzz, libiconv and their dependencies when bundling them.
