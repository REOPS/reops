package com.realeyes.osmf.controls
{
	import flash.display.Sprite;
	
	public class SkinSprite extends Sprite implements ISkinElementBase
	{
		private var _anchor:String;
		private var _addToContainer:Boolean = true;
		
		public function SkinSprite()
		{
			super();
		}
		
		public function get anchor():String
		{
			return _anchor;
		}
		
		public function set anchor(value:String):void
		{
			_anchor = value;
		}
		
		public function get addToContainer():Boolean
		{
			return _addToContainer;
		}
		
		public function set addToContainer(value:Boolean):void
		{
			_addToContainer = value;
		}

	}
}