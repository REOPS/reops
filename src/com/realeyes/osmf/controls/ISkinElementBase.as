package com.realeyes.osmf.controls
{
	import flash.events.IEventDispatcher;

	public interface ISkinElementBase extends IEventDispatcher
	{
		
		
		function get width():Number;
		function set width(value:Number):void;
		
		function get height():Number;
		function set height(value:Number):void;
		
		function get x():Number;
		function set x(value:Number):void;
		
		function get y():Number;
		function set y(value:Number):void;
		
		function get visible():Boolean;
		function set visible(value:Boolean):void;
		
		////////////////////////////////////////
		
		function get anchor():String;
		function set anchor(value:String):void;
		
		function get addToContainer():Boolean;
		function set addToContainer(value:Boolean):void;
	}
}