# Cobbles

Cobbles is a text layout/rendering engine library for Haxe. It uses Freetype and Harfbuzz for font loading, text shaping, and glyph rasterization. Its intended purpose is for use in 3D graphics (OpenGL/WebGL/DirectX) applications that uses textures directly to display text. This is useful when no other facility to display text is available.

[WebGL demo](https://chfoo.github.io/cobbles/demo/example_heaps.html)—Built using Heaps.io and Emscripten.

It is currently a work in progress. Links and prebuilt libraries may not yet be available.

What currently works:

* Left-to-right text
* Right-to-left text with manual direction and script specified
* Manually specified line breaks
* Rendering text using Heaps.io

What is work-in-progress:

* Automatic line breaking

What is not yet supported:

* Vertical text
* Formatting text by ranges and deriving the text runs
* Markup language
* Bidirectional support

## Getting started

Requires Haxe 3 or 4.

Install the library from Haxelib:

    haxelib install cobbles

Or the latest from the repo:

    haxelib git https://github.com/chfoo/cobbles

Next, you will need the native library and as well the dependencies installed. To do this, see the library section below. Once those are built or installed, continue here.

The easiest entry to using the library is with the `LayoutFacade` class:

```haxe
import cobbles.LayoutFacade;

var cobbles = new LayoutFacade();
```

In order to display anything meaningful, load a font from the filesystem:

```haxe
var latinSans = LayoutFacade.fontTable.openFile("path/to/font.ttf");
```

Or by the bytes directly:

```haxe
var fontBytes:Bytes; // your font here
var latinSans = LayoutFacade.fontTable.openBytes(fontBytes);
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

var renderer = new BitmapRenderer(LayoutFacade.fontTable);
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
import cobbles.render.heaps.TileGroupRenderer;

var cobbles:LayoutFacade; // your instance here
var renderer = new TileGroupRenderer(LayoutFacade.fontTable);
var tileGroup = renderer.newTileGroup();

s2d.addChild(tileGroup);

// Whenever you update your text, call
renderer.renderTileGroup(cobbles.layout, tileGroup);
```

The renderer will automatically build a texture atlas as needed.

## Native library and dependencies

The native library (cobbles.xdll) is required in order for Haxe generated code to communicate with other libraries like Freetype and Harfbuzz.

Prebuilt libraries are bundled in the zip file under the "bin" folder which can be distributed along with your application.

### Dependencies

The following dependencies are required:

* [Freetype](https://www.freetype.org/download.html) 2+
* [Harfbuzz](https://www.freedesktop.org/wiki/Software/HarfBuzz/) 1.8+

#### Linux

The libraries are most likely installed, however if this is not the case, they can be installed by a package manager.

On Ubuntu:

    apt install libfreetype6 libharfbuzz0b

#### Windows

The dll files can be downloaded from the websites and installed to your system. As well, they can be bundled within the same directory as your application.

#### Mac OS

Freetype is likely installed, but Harfbuzz may not. If prebuilt libraries are not available from the websites or in the zip file, you will have to build it yourself. I suggest using a package manager like Homebrew.

### Building the libraries yourself

If you want to build the native library yourself, you will also need the header files.

You can build the dependent libraries too by following their build instructions.

#### Linux

The headers are likely available in the package manager.

On Ubuntu:

    apt install libfreetype6-dev libharfbuzz-dev

#### Windows

Put the headers in a location and save them for the section that follows.

#### Mac OS

Same as the libraries, use something like Homebrew to install.

### Targets

The instructions and makefiles assume a Linux-like environemnt. On Windows, use something like Git Bash that gives you Bash shell to your Windows documents.

#### CPP

Compilation should work seamlessly as the XML config is injected into the build. Cobbles will be linked statically while dependencies are dynamically linked.

If the Freetype or Harfbuzz cannot be found, you can specify in your `~/.hxcpp_config.xml` or `%HOMEPATH%/.hxcpp_config.xml` file. For header include path `-I` flag, add `<flag>` to the `<compiler>` section. To specify dynamic library link paths, add `<flag>` to the `<linker>` section.

On Windows, you may optionally used MinGW-w64 if you have trouble compiling. Under the "VARS" section, set `mingw` to `1`.

#### HashLink

cobbles.hdll can be generated by running the makefile:

    cd native/
    make hdll

If you have trouble compiling, see the CPP section and check if compilation works there.

#### JavaScript

Follow the [Emscripten download and install instructions](https://emscripten.org/docs/getting_started/downloads.html) to install the Emscripten SDK.

Generate the Javascript by running the makefile:

    cd native/
    make js

The output will be placed in out/js/.

Next in your Haxe application, load the Emscripten library with

    cobbles.Runtime.loadEmscripten().then(success -> {
        // ... your code continues here ...
    });

Then load or package `cobbles.js`, followed by `cobbles_binding.js`, and then your application JS.

## Contributing

Use the GitHub issues or pull requests section for bug reports and features.

## License

Licensed under MIT. See the licence file.

Remember that you must comply with the Freetype and Harfbuzz licenses as well when bundling them.
