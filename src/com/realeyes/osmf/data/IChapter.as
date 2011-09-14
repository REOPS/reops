package com.realeyes.osmf.data
{
	public interface IChapter
	{
		function get title():String;
		function set title(value:String):void;
		function get description():String;
		function set description(value:String):void;
		function get thumbnailURL():String;
		function set thumbnailURL(value:String):void;
		function get time():Number;
		function set time(value:Number):void;
	}
}