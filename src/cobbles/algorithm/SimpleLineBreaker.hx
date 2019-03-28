package cobbles.algorithm;

import unifill.CodePoint;
import haxe.ds.Vector;
import cobbles.algorithm.LineBreakingAlgorithm;
import haxe.EnumFlags;

using unifill.Unifill;
using cobbles.algorithm.CharTools;

private enum BreakProperty {
    Breakable;
    Mandatory;
}

private typedef BreakFlags = EnumFlags<BreakProperty>;

private class BreakInfo implements LineBreakInfo {
    var flags:Vector<BreakFlags>;

    public function new(flags:Vector<BreakFlags>) {
        this.flags = flags;
    }

    public function count():Int {
        return flags.length;
    }

    public function canBreak(index:Int):Bool {
         return flags[index].has(Breakable);
    }

    public function isMandatory(index:Int):Bool {
        return flags[index].has(Mandatory);
    }
}

/**
 * Simple line breaking algorithm.
 */
class SimpleLineBreaker implements LineBreakingAlgorithm {
    // Implemented using some parts from https://unicode.org/reports/tr14/
    // This class prefers simplicity over correctness.
    // Instead, a fuller implementation should be done in another class.

    public function new() {
    }

    public function getBreaks(text:String):BreakInfo {
        #if hl @:nullSafety(Off) #end // bug
        var flagsVector = new Vector<BreakFlags>(text.uLength());

        var index = 0;
        var previousCodePoint:CodePoint = 0;
        var breakableBeforeNext = false;

        for (codePoint in text.uIterator()) {
            if (index == 0) {
                index += 1;
                continue;
            }

            var flags = new BreakFlags();

            if (isMandatory(codePoint, previousCodePoint)) {
                flags.set(Mandatory);
                flags.set(Breakable);

            } else if (isSpace(codePoint)) {
                breakableBeforeNext = true;
            } else if (breakableBeforeNext || isCJK(codePoint)) {
                flags.set(Breakable);
                breakableBeforeNext = false;
            }

            flagsVector[index] = flags;
            index += 1;
        }

        return new BreakInfo(flagsVector);
    }

    function isMandatory(codePoint:CodePoint, previous:CodePoint):Bool {
        return codePoint == "\n".code && previous != "\r".code ||
            codePoint == "\r".code ||
            codePoint == 0x85; // newline
    }

    function isSpace(codePoint:CodePoint):Bool {
        return codePoint == ' '.code ||
            codePoint == 0x3000 || // ideographic space
            codePoint.isInRange(0x2000, 0x200b) || // wide spaces to zero width space
            codePoint == 0x09 || // tab
            codePoint == 0xad; // soft hyphen
    }

    function isCJK(codePoint:CodePoint):Bool {
        return codePoint.isInRange(0x2E80, 0x2FFF) || // CJK, Kangxi Radicals, Ideographic Description Symbols)
            codePoint.isInRange(0x3040, 0x309F) || // Hiragana (except small characters)
            codePoint.isInRange(0x30A2, 0x30FA) || // Katakana (except small characters)
            codePoint.isInRange(0x3400, 0x4DBF) || // CJK Unified Ideographs Extension A
            codePoint.isInRange(0x4E00, 0x9FFF) || // CJK Unified Ideographs
            codePoint.isInRange(0xF900, 0xFAFF); // CJK Compatibility Ideographs
    }
}
