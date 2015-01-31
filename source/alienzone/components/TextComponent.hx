/**
 *--------------------------------------------------------------------+
 * TextComponent.hx
 *--------------------------------------------------------------------+
 * Copyright DarkOverlordOfData (c) 2014
 *--------------------------------------------------------------------+
 *
 * This file is a part of Alien Zone
 *
 * Alien Zone is free software; you can copy, modify, and distribute
 * it under the terms of the GPLv3 License
 *
 *--------------------------------------------------------------------+
 *
 */
package alienzone.components;
import hxE.Component;

class TextComponent extends Component {

    public var value:String;
    public var font:String;
    public var fill:Int;
    public var align:String;

    public function new(value:String, font:String, fill:Int, align:String="center") {
        super();
        this.value = value;
        this.font = font;
        this.fill = fill;
        this.align = align;
    }
}
