package com.realeyes.osmf.interfaces
{
	import org.osmf.media.MediaElement;
	import org.osmf.media.MediaResourceBase;

	public interface IPlugablePlayer
	{
		
		
		function play( path:String, urlIncludesFMSApplicationInstance:Boolean = false ):void;
		
		//function debug( msg:String ):void;
		function ping():Boolean;
		
		function loadPlugin( plugin:MediaResourceBase ):void;
		function addPluginToQue( plugin:MediaResourceBase ):void;
		function removePluginFromQue( plugin:MediaResourceBase ):Boolean;
		function loadAllPlugins():void;
		function generateMediaElement( resource:MediaResourceBase ):MediaElement
		function clearMediaElement( element:MediaElement ):Boolean;
		function clearPluginLoadCounts():void;
		///////////////////////////////////////////////////
		// GETTER/SETTERS
		///////////////////////////////////////////////////
		
		function get totalPluginCount():uint;
		function get loadedPluginCount():uint;
		function get failedPluginCount():uint;
		
		function get width():Number;
		function set width( value:Number ):void;
		function get height():Number;
		function set height( value:Number ):void;
		
		function get mediaElement():MediaElement;
		function set mediaElement(value:MediaElement):void;
		
	}
}