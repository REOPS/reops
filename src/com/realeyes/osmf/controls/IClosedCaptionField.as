package com.realeyes.osmf.controls
{
	import flash.text.TextFormat;

	public interface IClosedCaptionField extends ISkinElementBase
	{
		function get text():String;
		function set text( p_value:String):void;
		function setTextAndStyle( p_text:String, p_format:TextFormat=null):void;
	}
}