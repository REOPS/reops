package com.realeyes.osmf.model.config.skin
{
	

	/**
	 * Parses and stores config data for the skin and
	 * control bar.
	 * 
	 * @author	RealEyes Media
	 * @version	1.0
	 */
	public class SkinConfig
	{
		
		
		/**
		 * Path for the skin file	(String)
		 */
		public var path:String;
		
		/**
		 * Skin config XML	(XML)
		 */
		public var skinXML:XML;
		
		private var _elements:Array;
		
		/**
		 * Constructor
		 * @param	skinConfigXML	(XML) defaults to null
		 * @return	void
		 */
		public function SkinConfig( skinConfigXML:XML=null )
		{
			if( skinConfigXML )
			{
				skinXML = skinConfigXML;
				path = skinXML.@path;
				_elements = new Array();
				
				var configElements:XMLList = skinXML.skinElement;
				var len:int = configElements.length();
				for( var i:int = 0; i < len; i++ )
				{
					var elementXML:XML = configElements[i];
					var skinElement:SkinElement = new SkinElement( elementXML );
					
					_elements.push( skinElement );
				}
			}
		}
		
		/**
		 * Returns the skin element specified by the ID
		 * 
		 * @param	elementID	(String)
		 * @return	SkinElement
		 */
		public function getSkinElementByID( elementID:String ):SkinElement
		{
			for each( var element:SkinElement in _elements )
			{
				if( element.id == elementID )
				{
					return element;
				}
			}
			return null;
		}
		
		/**
		 * Returns an array of all skin elements that have been created in the skin
		 * 
		 * @return	Array
		 */
		public function getSkinElements():Array
		{
			return _elements;
		}
		
		public function get elements():Array
		{
			return _elements;
		}
		public function set elements( value:Array ):void
		{
			_elements = value;
		}
	}
}