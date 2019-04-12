package cobbles;

import haxe.PosInfos;

class Debug {
    public dynamic static function warning(message:String, ?infos:PosInfos) {
        haxe.Log.trace(message, infos);
    }
}
