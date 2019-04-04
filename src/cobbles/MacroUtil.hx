package cobbles;

#if macro
import haxe.macro.Context;
import haxe.io.Path;
#end

class MacroUtil {
    public static macro function embedFontResources() {
        // Expected to be called from FontTable
        var thisFile = Context.getPosInfos(Context.currentPos()).file;
        var rootDir = Path.join([Path.directory(thisFile), '../../../']);

        var resourcePaths = ['resource/fonts/adobe-notdef/AND-Regular.otf'];

        for (resourcePath in resourcePaths) {
            var path = Path.join([rootDir, resourcePath]);

            if (!sys.FileSystem.exists(path)) {
                Context.warning(
                    'Cobbles could not find and embed $path',
                    Context.currentPos());

                continue;
            }

            Context.addResource(resourcePath, sys.io.File.getBytes(path));
        }

        return macro null;
    }
}
