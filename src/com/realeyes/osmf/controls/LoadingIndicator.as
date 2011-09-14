package com.realeyes.osmf.controls
{
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	
	/**
	 * Text component for showing the loading progress
	 * 
	 * @author	RealEyes Media
	 * @version	1.0
	 */
	public class LoadingIndicator extends SkinElementBase implements ILoadingIndicator
	{
		/////////////////////////////////////////////
		//  DECLARATIONS
		/////////////////////////////////////////////
		
		public var label_txt:TextField;
		
		
		
		/////////////////////////////////////////////
		//  CONSTRUCTOR
		/////////////////////////////////////////////
		
		public function LoadingIndicator()
		{
			super();
			
			if( label_txt )
			{
				label_txt.autoSize = TextFieldAutoSize.CENTER;
			}
		}
		
		
		
		/////////////////////////////////////////////
		//  CONTROL METHODS
		/////////////////////////////////////////////
		
		
		
		
		/////////////////////////////////////////////
		//  GETTER/SETTERS
		/////////////////////////////////////////////
		
		/**
		 * label
		 * The text to display in the loading indicator
		 * @return	String
		 */
		public function get label():String
		{
			return label_txt.text
		}
		
		public function set label( p_value:String):void
		{
			label_txt.text = p_value;
		}
		
		
		/////////////////////////////////////////////
		//  HANDLERS
		/////////////////////////////////////////////
		
		
		
		
	}
}