package com.realeyes.osmf.plugins
{
	import com.realeyes.osmf.elements.PreviewProxySerialElement;
	import com.realeyes.osmf.elements.WatermarkProxyElement;
	import com.realeyes.osmf.events.DebugEvent;
	import com.realeyes.osmf.interfaces.IVideoShell;
	import com.realeyes.osmf.utils.PluginUtils;
	
	import flash.external.ExternalInterface;
	
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
	
	public class PreviewProxyPluginInfo extends PluginInfo
	{
		// Plugin Namespace
		static public const NAMESPACE:String = "com.realeyes.osmf.plugins.PreviewProxyPluginInfo";
		
		private var _assetPath:String;
		private var _previewDuration:uint;
		private var _vidShell:IVideoShell;
		private var _currentElement:MediaElement;
		
		
		///////////////////////////////////////////////////
		// CONSTRUCTOR
		///////////////////////////////////////////////////
		
		public function PreviewProxyPluginInfo( mediaFactoryItems:Vector.<MediaFactoryItem>=null, mediaElementCreationNotificationFunction:Function=null )
		{
			
			
			//Specify the media items that this plugin will handle 
			var items:Vector.<MediaFactoryItem> = new Vector.<MediaFactoryItem>();
			
			//Let the MediaFactory know what kinda of media the plugin can handle - for now we'll go with the built in NetLoader.canHandleResource
			var loader:NetLoader = new NetLoader();
			var item:MediaFactoryItem = new MediaFactoryItem( 
				NAMESPACE, 
				loader.canHandleResource, 
				createMediaElement,
				MediaFactoryItemType.PROXY
			);
			items.push( item );
			
			//pass the Vector of MediaFacttoryItems, and pass along the default for the notification function
			super( items, mediaElementCreationNotificationFunction );
		}
		
		/**
		 *Function that will generate the MediaElement for the MediaFactory if the can handle resource is true for the resouce loading 
		 * Since this is a proxy plugin it generates a subclass of the ProxYElement and returns it.
		 *  @return 
		 * 
		 */		
		public function createMediaElement():Object
		{
			debug( "Create preview proxy element element" );
			//Create a new PreviewProxySerialElement and pass it the assetPath and the previewDuration
			var proxy:PreviewProxySerialElement = new PreviewProxySerialElement( _assetPath, _previewDuration );
			proxy.addEventListener( DebugEvent.DEBUG, _onDebugEvent, false, 0, true );
			return proxy;
		}
		
		
		
		
		/**
		 * Called from super class when plugin has been initialized with the MediaFactory from which it was loaded.
		 *  
		 * @param resource	Provides acces to the Resource used to load the plugin and any associated meta data
		 * 
		 */	
		override public function initializePlugin( resource:MediaResourceBase ):void
		{
			var metaData:XML = new XML( resource.getMetadataValue( NAMESPACE ) );
			//parse and store the assetPath and previewDuration for use with the proxy element
			_assetPath = metaData.assetPath;
			_previewDuration = metaData.previewDuration;
			
			_vidShell = resource.getMetadataValue( PluginUtils.SHELL ) as IVideoShell;
			
			debug( "PreviewProxyPluginInfo - Initialized" );
			
			debug("_assetPath: " + _assetPath );
			debug("_previewDuration: " + _previewDuration );
		}
		
		
		private function _onDebugEvent( event:DebugEvent ):void
		{
			debug( event.message );
		}
		
		// ==================================================
		// Helper methods
		// ==================================================
		
		protected function debug( msg:String ):void 
		{
			//trace( msg );
			_vidShell.debug( msg );
		}
	}
}