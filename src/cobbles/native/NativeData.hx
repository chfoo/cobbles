package cobbles.native;

import cobbles.native.CobblesExtern;

class NativeData {
    static var cobblesPointer:Null<CobblesExtern.CobblesPointer>;

    public static function getCobblesPointer():CobblesExtern.CobblesPointer {
        if (cobblesPointer == null) {
            cobblesPointer = CobblesExtern.init();

            if (cobblesPointer == null) {
                throw "Failed to create cobbles struct";
            }
        }

        var errorCode = CobblesExtern.get_error(cobblesPointer);

        if (errorCode != 0) {
            throw 'Cobbles init error $errorCode';
        }

        return cobblesPointer;
    }
}
