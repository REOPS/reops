package com.realeyes.osmf.controls
{
	import flash.display.MovieClip;
	
//TODO - should this be dynamic or not?	
	/**
	 * Base class for skin elements used in instantiation and layout of
	 * the components through the config file.
	 * 
	 * @author	RealEyes Media
	 * @version	1.0
	 */
	public dynamic class SkinElementBase extends MovieClip implements ISkinElementBase
	{
		
		/////////////////////////////////////////////
		//  DECLARATIONS
		/////////////////////////////////////////////
		
		public static const LEFT:String = "left";
		public static const RIGHT:String = "right";
		public static const BOTH:String = "both";
		
		private var _addToContainer:Boolean = true;
		private var _anchor:String;
		
		/////////////////////////////////////////////
		//  CONSTRUCTOR
		/////////////////////////////////////////////
		
		public function SkinElementBase()
		{
			super();
		}
		
		
		
		/////////////////////////////////////////////
		//  GETTER/SETTERS
		/////////////////////////////////////////////
		
		
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