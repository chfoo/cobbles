package cobbles.native;

extern class CPPUtil {
    @:native("sizeof")
    static public function sizeof(t:Any):Int;
}
