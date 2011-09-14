package com.realeyes.osmf.controls
{
	public interface ILoadingIndicator extends ISkinElementBase
	{
		/**
		 * label
		 * The text to display in the loading indicator
		 * @return	String
		 */
		function get label():String;
		function set label( p_value:String):void;
		
	}
}