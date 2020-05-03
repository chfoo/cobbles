package cobbles.native;

#if (js && !doc_gen)

extern class ScriptDirection {
    public var value:Int;
}

class ScriptDirectionHelper {
    static public function fromNative(scriptDirection:ScriptDirection):
            cobbles.ScriptDirection {
        switch (scriptDirection.value) {
            case 0:
                return NotSpecified;
            case 1:
                return LeftToRight;
            case 2:
                return RightToLeft;
            default:
                throw "shouldn't reach here";
        }
    }

    static public function toNative(module:EmModule,
            scriptDirection:cobbles.ScriptDirection):ScriptDirection {
        switch scriptDirection {
            case NotSpecified:
                return js.Syntax.code("{0}.ScriptDirection.NotSpecified", module);
            case LeftToRight:
                return js.Syntax.code("{0}.ScriptDirection.LTR", module);
            case RightToLeft:
                return js.Syntax.code("{0}.ScriptDirection.RTL", module);
        }
    }
}

#else

typedef ScriptDirection = cobbles.ScriptDirection;

#end
