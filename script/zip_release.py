'''Create a zip file of the latest commit in the git repository.

Used to create consistently named zip files that don't include undesired or
uncommited files.
'''
import json
import os
import os.path
import subprocess
import sys
import time
import zipfile

NAME = 'cobbles'

def main():
    project_dir = os.path.join(os.path.dirname(__file__), '..')
    json_path = os.path.join(project_dir, 'haxelib.json')

    with open(json_path) as file:
        doc = json.load(file)
        version = doc['version']

    timestamp = time.strftime('%Y%m%d-%H%M%S', time.gmtime())
    name = '{name}-{version}-{timestamp}.zip'.format(
        name=NAME, version=version, timestamp=timestamp)
    output_dir = os.path.join(project_dir, 'out', 'release')
    output_path = os.path.join(output_dir, name)

    print('Outputting to', output_path)

    os.makedirs(output_dir, exist_ok=True)
    subprocess.run(['git', 'archive', 'HEAD', '-o', output_path], cwd=project_dir)

    if '--bin' in sys.argv:
        add_bin(output_path, project_dir)

    if '--sign' in sys.argv:
        sign(output_path)

    print('Done')

def add_bin(zip_filename: str, project_dir: str):
    print('Adding binaries')

    filenames = (
        'bin/js/cobbles_binding.min.js',
        'bin/js/cobbles.min.js',
        'bin/js/cobbles.wasm',
        'bin/win32/bz2.dll',
        'bin/win32/cobbles.hdll',
        'bin/win32/freetype.dll',
        'bin/win32/harfbuzz.dll',
        'bin/win32/libcharset.dll',
        'bin/win32/libiconv.dll',
        'bin/win32/libpng16.dll',
        'bin/win32/zlib1.dll',
    )

    zip_file = zipfile.ZipFile(zip_filename, mode='a')

    for filename in filenames:
        print('Adding', filename)
        zip_file.write(os.path.join(project_dir, filename), filename)

def sign(filename: str):
    print('Sign release:')
    subprocess.run(['gpg', '--armor', '--detach-sign', filename])

if __name__ == '__main__':
    main()
