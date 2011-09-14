package com.realeyes.osmf.controls
{
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	/**
	 * Displays captions for media in the control bar. Accepts HTML
	 * text (limited by Flash HTML display). This component starts
	 * out invisible, and must be manually made visible.
	 * 
	 * @author	RealEyes Media
	 * @version	1.0
	 */
	public class ClosedCaptionField extends SkinElementBase implements IClosedCaptionField
	{
		/////////////////////////////////////////////
		//  DECLARATIONS
		/////////////////////////////////////////////
		
		public var cc_txt:TextField;
		
		
		
		
		/////////////////////////////////////////////
		//  CONSTRUCTOR
		/////////////////////////////////////////////
		
		public function ClosedCaptionField()
		{
			super();
			
			//start up hidden
			//this.visible = false;
			text = "";
		}
		
		
		
		/////////////////////////////////////////////
		//  CONTROL METHODS
		/////////////////////////////////////////////
		
		public function setTextAndStyle( p_text:String, p_format:TextFormat = null):void
		{
			if( cc_txt )
			{
				if( p_format )
				{
					cc_txt.setTextFormat( p_format );
				}
				
				cc_txt.htmlText = p_text;
			}
		}
		
		/////////////////////////////////////////////
		//  GETTER/SETTERS
		/////////////////////////////////////////////
		
		/**
		 * text
		 * The HTML text to display
		 * 
		 * @return	String
		 */
		public function get text():String
		{
			return cc_txt.htmlText;
		}
		
		public function set text( p_value:String):void
		{
			if( cc_txt )
			{
				cc_txt.htmlText = p_value;
			}
			trace("set cc text: " + p_value);
			
		}
		
		
		/////////////////////////////////////////////
		//  HANDLERS
		/////////////////////////////////////////////
		
		
		
		
	}
}