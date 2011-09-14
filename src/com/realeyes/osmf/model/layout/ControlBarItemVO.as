package com.realeyes.osmf.model.layout
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;

	public class ControlBarItemVO
	{
		public var target:DisplayObject;
		public var anchor:String;
		public var left:Number;
		public var right:Number;
		
		
		public function ControlBarItemVO( p_target:DisplayObject, p_anchor:String, p_left:Number, p_right:Number)
		{
			target = p_target;
			anchor = p_anchor;
			left = p_left;
			right = p_right;
		}
	}
}