package cobbles.layout;

enum ShapedItem {
    PenRunItem(penRun:PenRun);
    InlineObjectItem(inlineObject:InlineObject);
    LineBreakItem(spacing:Int);
}
