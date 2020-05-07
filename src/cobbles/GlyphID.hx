package cobbles;

/**
 * Unique glyph ID.
 *
 * A plain integer that can be used to identify a glyph for a font face,
 * at a specific font size.
 *
 * It will always be unique per library context.
 *
 * IDs are recycled to different glyphs if no engine holds references to the
 * ID.
 */
typedef GlyphID = Int;
