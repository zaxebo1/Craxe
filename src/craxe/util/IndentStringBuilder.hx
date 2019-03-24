package craxe.util;

/**
 * For string builder with indent
 */
class IndentStringBuilder {
	/**
	 * Count of spaces to indent
	 */
	private static inline final INDENT_SPACE_COUNT = 4;

	/**
	 * String builder
	 */
	private var buffer:StringBuf;

	/**
	 * Indent string
	 */
	private var indentStr:String;

	/**
	 * Current indent
	 */
	public var indent(default, set):Int;

	public function set_indent(value:Int):Int {
		indent = value;
		calcIndent();
		return indent;
	}

	/**
	 * Calculate indent string
	 */
	private function calcIndent() {
		indentStr = "";
		for (i in 0...indent * INDENT_SPACE_COUNT)
			indentStr += " ";
	}

	/**
	 * Constructor
	 */
	public function new() {
		buffer = new StringBuf();
		indent = 0;
		indentStr = "";
	}

	/**
	 * Increment indent
	 */
	public inline function inc() {
		indent += 1;
		calcIndent();
	}

	/**
	 * Decrement indent
	 */
	public inline function dec() {
		if (indent == 0)
			return;

		indent -= 1;
		calcIndent();
	}

	/**
	 * Add value to buffer without indent
	 * @param value
	 */
	public inline function add(value:String) {
		buffer.add(value);
	}

	/**
	 * Add value to buffer with indent
	 * @param value
	 */
	public inline function addWithIndent(value:String) {
		buffer.add(indentStr);
		buffer.add(value);
	}

	/**
	 * Add value to buffer line with indent
	 * @param value
	 */
	public inline function addLine(value:String) {
		addWithIndent(value);
		buffer.add("\n");
	}

	/**
	 * Add break line
	 * @param value
	 */
	public inline function addBreakLine(addIndent = false) {
		buffer.add("\n");
		if (addIndent) {
			addWithIndent("");
		}
	}

	/**
	 * Return string
	 */
	public inline function toString() {
		return buffer.toString();
	}
}
