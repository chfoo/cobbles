#!/bin/sh

if [ -f "minify_HeapsExample.sh" ]; then
    echo "Run me at the root of the project. (I.E., do 'cd ../')"
    exit 1
fi

echo "Minifying..."

closure-compiler --js out/js/cobbletext.js \
    --js_output_file out/js/cobbletext.min.js \
    --language_in ECMASCRIPT5
closure-compiler --js out/js/example_heaps.js \
    --js_output_file out/js/example_heaps.min.js \
    --language_in ECMASCRIPT5

sed 's:out/js/cobbletext.js:cobbletext.min.js:' example_heaps.html |
    sed 's:out/js/example_heaps.js:example_heaps.min.js:' > out/js/example_heaps.html

echo "Output placed in out/js"
