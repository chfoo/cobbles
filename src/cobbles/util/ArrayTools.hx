package cobbles.util;

class ArrayTools {
    public static inline function isEmpty<T>(array:Array<T>):Bool {
        return array.length == 0;
    }

    public static inline function last<T>(array:Array<T>):T {
        return array[array.length - 1];
    }
}
