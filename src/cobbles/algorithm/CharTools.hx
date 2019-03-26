package cobbles.algorithm;

import unifill.CodePoint;

class CharTools {
    public inline static function isInRange(num:CodePoint, lower:Int, upper:Int):Bool {
        return num >= lower && num <= upper;
    }
}
