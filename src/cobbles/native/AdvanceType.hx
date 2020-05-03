package cobbles.native;

#if (js && !doc_gen)

extern class AdvanceType {
    public var value:Int;
}

class AdvanceTypeHelper {
    public static function fromNative(advanceType:AdvanceType)
            :cobbles.AdvanceInfo.AdvanceType {
        switch advanceType.value {
            case 0:
                return Invalid;
            case 1:
                return Glyph;
            case 2:
                return InlineObject;
            case 3:
                return LineBreak;
            case 4:
                return Bidi;
            case 5:
                return Layout;
            default:
                throw "shouldn't reach here";
        }
    }
}

#else

typedef AdvanceType = cobbles.AdvanceInfo.AdvanceType;

#end
