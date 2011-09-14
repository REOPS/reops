package com.realeyes.osmf.model.config.skin
{
	
	import flash.system.ApplicationDomain;
	import flash.system.SecurityDomain;
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;

	/**
	 * Visual element defined in the skin and defined in the config.
	 * 
	 * @author	RealEyes Media
	 * @version	1.0
	 */
	public class SkinElement
	{
		static public const CONTROL_BAR:String = "controlBar";
		static public const LOADING_INDICATOR:String = "loadingIndicator";
		static public const CLOSED_CAPTION_FIELD:String = "closedCaptionField";
		
		/**
		 * Unique identifier for the element. Required in the XML config and must be unique.	(String)
		 */
		public var id:String;
		
		/**
		 * Name of a method on the control bar container to call once the component has instantiated.	(String)
		 */
		public var initMethodName:String;
		
		/**
		 * Class path for the functionality of the skin element.	(String)
		 */
		public var elementClassString:String;
		public var altElementClass:String;
		public var altWidthThreshold:Number;
		
		
		
		
		/**
		 * Different properties for the element.	(Dictionary)
		 */
		public var properties:Dictionary;
		
		private var _elementXML:XML;
		
		/**
		 * Constructor
		 * 
		 * @param	elementXML	(XML) XML node defining the skin element. Defaults to null.
		 */
		public function SkinElement( elementXML:XML=null )
		{
			properties = new Dictionary();
			this.elementXML = elementXML;
		}
		
		/**
		 * Instantiates the class defined by elementClassString if no parameter supplied, and set properties
		 * on it defined in the XML
		 * 
		 * @return	*	(whatever class type was defined by elementClassString)
		 */
		public function buildSkinElement( p_classString:String = null ):*
		{
			var classStr:String = p_classString || elementClassString;
			trace(">> Creating Instance of Class: " + classStr);
			var elementClassDef:Class = ApplicationDomain.currentDomain.getDefinition( classStr ) as Class;
			var elementClass:* = new elementClassDef(); // Create the object
			for( var key:String in properties ) // Set the specified properties from the config on the new control bar object
			{
				elementClass[ key ] = properties[ key ];
			}
			return elementClass;
		}

		/**
		 * XML node defining the skin element	(XML)
		 * Parses the XML when set.
		 */
		public function get elementXML():XML
		{
			return _elementXML;
		}

		public function set elementXML(value:XML):void
		{
			if( value != _elementXML )
			{
				if( value )
				{
					_elementXML = value;
					
					id = _elementXML.@id.toString();
					elementClassString = _elementXML.@elementClass.toString();
					initMethodName = _elementXML.@initMethod.toString();
					altElementClass = _elementXML.@altElementClass.toString();
					altWidthThreshold = _elementXML.@altWidthThreshold.toString();
					
					var attributes:XMLList = _elementXML.attributes();
					for each( var attribute:XML in attributes )
					{
						if( attribute.name() != "id" && attribute.name() != "elementClass" && attribute.name() != "initMethod" && attribute.name() != "altElementClass" && attribute.name() != "altWidthThreshold" )
						{
							var attrValue:String = attribute.toString();
							var attrValueLowerCase:String = attribute.toString().toLowerCase();
							if( attrValueLowerCase == "true" || attrValueLowerCase == "false" )
							{
								properties[ attribute.name().toString() ] = attrValueLowerCase == "true" ? true:false;
							}
							else
							{
								properties[ attribute.name().toString() ] = attrValue;
							}
						}
					}
				}
				else
				{
					elementXML = value;
				}
			}
		}

	}
}