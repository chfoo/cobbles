package cobbles.native;

extern class EmbindVector<T> {
    public function size():Int;
    public function get(index:Int):T;
    public function delete():Void;
}
