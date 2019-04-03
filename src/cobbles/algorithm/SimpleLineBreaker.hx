package cobbles.algorithm;

import unifill.CodePoint;
import cobbles.algorithm.LineBreakingAlgorithm;
import haxe.EnumFlags;

using cobbles.algorithm.CharTools;

/**
 * Simple line breaking algorithm.
 */
class SimpleLineBreaker implements LineBreakingAlgorithm {
    // Implemented using some parts from https://unicode.org/reports/tr14/
    // This class prefers simplicity over correctness.
    // Instead, a fuller implementation should be done in another class.

    public function new() {
    }

    public function getBreaks(codePoints:Iterable<CodePoint>, sot:Bool):Array<LineBreakRule> {
        var flagsList = [];

        var index = 0;
        var previousCodePoint:CodePoint = 0;
        var breakableBeforeNext = false;

        for (codePoint in codePoints) {
            if (index == 0 && sot) {
                flagsList.push(Prohibited);
                index += 1;
                continue;
            }

            if (isMandatory(codePoint, previousCodePoint)) {
                flagsList.push(Mandatory);
            } else if (isSpace(codePoint)) {
                flagsList.push(Unspecified);
                breakableBeforeNext = true;
            } else if (breakableBeforeNext || isCJK(codePoint)) {
                flagsList.push(Opportunity);
                breakableBeforeNext = false;
            } else {
                flagsList.push(Unspecified);
            }

            index += 1;
        }

        return flagsList;
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
