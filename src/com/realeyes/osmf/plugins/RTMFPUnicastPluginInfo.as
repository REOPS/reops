package com.realeyes.osmf.plugins
{
	import com.realeyes.osmf.elements.PreviewProxySerialElement;
	import com.realeyes.osmf.elements.WatermarkProxyElement;
	import com.realeyes.osmf.events.DebugEvent;
	import com.realeyes.osmf.interfaces.IVideoShell;
	import com.realeyes.osmf.net.RTMFPUnicastNetFactory;
	import com.realeyes.osmf.net.RTMFPUnicastNetLoader;
	import com.realeyes.osmf.utils.PluginUtils;
	
	import flash.external.ExternalInterface;
	
	import org.osmf.elements.VideoElement;
	import org.osmf.events.MediaElementEvent;
	import org.osmf.events.TimeEvent;
	import org.osmf.media.MediaElement;
	import org.osmf.media.MediaFactoryItem;
	import org.osmf.media.MediaFactoryItemType;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.media.PluginInfo;
	import org.osmf.net.NetLoader;
	import org.osmf.traits.MediaTraitType;
	import org.osmf.traits.TimeTrait;
	
	public class RTMFPUnicastPluginInfo extends PluginInfo
	{
		// Plugin Namespace
		static public const NAMESPACE:String = "com.realeyes.osmf.plugins.RTMFPUnicastPluginInfo";
		
		private var _currentElement:MediaElement;
		private var _vidShell:IVideoShell;
		
		///////////////////////////////////////////////////
		// CONSTRUCTOR
		///////////////////////////////////////////////////
		
		public function RTMFPUnicastPluginInfo( mediaFactoryItems:Vector.<MediaFactoryItem>=null, mediaElementCreationNotificationFunction:Function=null )
		{
			
			
			//Specify the media items that this plugin will handle 
			var items:Vector.<MediaFactoryItem> = new Vector.<MediaFactoryItem>();
			
			//Let the MediaFactory know what kinda of media the plugin can handle - for now we'll go with the built in NetLoader.canHandleResource
			var netLoader:NetLoader = new RTMFPUnicastNetLoader( new RTMFPUnicastNetFactory() );
			var item:MediaFactoryItem = new MediaFactoryItem( 
				NAMESPACE, 
				netLoader.canHandleResource,
				function():MediaElement
				{
					return new VideoElement(null, netLoader);
				}
			);
			items.push( item );
			
			//pass the Vector of MediaFacttoryItems, and pass along the default for the notification function
			super( items, _mediaElementCreationNotificationFunction );
		}
		
		
		private function _mediaElementCreationNotificationFunction( element:MediaElement ):void
		{
			trace("element created: " + element);
		}
		
		
		
		
		// ==================================================
		// Helper methods
		// ==================================================
		
		
	}
}