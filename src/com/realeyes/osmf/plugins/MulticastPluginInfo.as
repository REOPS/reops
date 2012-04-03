package com.realeyes.osmf.plugins
{
	import com.realeyes.osmf.elements.PreviewProxySerialElement;
	import com.realeyes.osmf.elements.StaticVideoElement;
	import com.realeyes.osmf.elements.WatermarkProxyElement;
	import com.realeyes.osmf.events.DebugEvent;
	import com.realeyes.osmf.interfaces.IVideoShell;
	import com.realeyes.osmf.utils.PluginUtils;
	import com.realeyes.osmf.utils.net.FMSURL;
	
	import flash.external.ExternalInterface;
	
	import org.osmf.elements.VideoElement;
	import org.osmf.events.MediaElementEvent;
	import org.osmf.events.TimeEvent;
	import org.osmf.media.MediaElement;
	import org.osmf.media.MediaFactoryItem;
	import org.osmf.media.MediaFactoryItemType;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.media.PluginInfo;
	import org.osmf.media.URLResource;
	import org.osmf.net.MulticastNetLoader;
	import org.osmf.net.MulticastResource;
	import org.osmf.net.NetLoader;
	import org.osmf.traits.MediaTraitType;
	import org.osmf.traits.TimeTrait;
	import org.osmf.utils.Version;
	
	
	public class MulticastPluginInfo extends PluginInfo
	{
		// Plugin Namespace
		static public const NAMESPACE:String = "com.realeyes.osmf.plugins.MulticastPluginInfo";
		static public const MULTICAST_KEY:String = "_multicast";
		
		
		
		private var _jsDebug:Boolean = true;
		private var _groupspec:String;
		private var _resource:URLResource;
		
		
		///////////////////////////////////////////////////
		// CONSTRUCTOR
		///////////////////////////////////////////////////
		
		public function MulticastPluginInfo( mediaFactoryItems:Vector.<MediaFactoryItem>=null, mediaElementCreationNotificationFunction:Function=null )
		{
			
			debug("MulticastPluginInfo - [constructor] " + Version.version);
			
			
			//Let the MediaFactory know what kinda of media the plugin can handle - for now we'll go with the built in canHandleResource
			var item:MediaFactoryItem = new MediaFactoryItem( 
				NAMESPACE, 
				canHandleResourceFunction, 
				createMediaElement
				
			);
			
			if( !mediaFactoryItems ) 
			{
				mediaFactoryItems = new Vector.<MediaFactoryItem>();
			}
				
			mediaFactoryItems.push( item );
			
			//pass the Vector of MediaFacttoryItems, and pass along the default for the notification function
			super( mediaFactoryItems, mediaElementCreated );
		}
		
		
		
		/** OSMF will invoke this function for any resource that is passed
		* to MediaFactory.createMediaElement.  The method must take a single
		* parameter of type MediaResourceBase and return a Boolean.  The
		* plug-in should return true if it can create a MediaElement for that
		* resource.
		*/
		private function canHandleResourceFunction(resource:MediaResourceBase):Boolean
		{
			
			var result:Boolean = false;
			// Only return true if the resource is an URLResource...
			var urlResource:URLResource = resource as URLResource;
			
			if (urlResource != null && urlResource.url.indexOf( MULTICAST_KEY ) == urlResource.url.length - MULTICAST_KEY.length)
			{
				// ... and if the URL starts with "multicase|".
				_resource = urlResource;
				result = true;
			}
			else
			{
				_resource = null;
			}
			
			debug("Can Handle? " + result);
			debug(urlResource.url);
			//debug(urlResource.url.indexOf( MULTICAST_KEY) + " | " + urlResource.url.length);
			return result;
		}
		
		
		
		/**
		 *Function that will generate the MediaElement for the MediaFactory if the can handle resource is true for the resouce loading 
		 * Since this is a proxy plugin it generates a subclass of the ProxYElement and returns it.
		 *  @return 
		 * 
		*/		
		public function createMediaElement():VideoElement
		{
			debug(" - Create Media Element - " );
			//var uriData:Array = _resource.url.split( MULTICAST_KEY )[0].split("/");
			//var url:FMSURL = new FMSURL( _resource.url.split( MULTICAST_KEY )[0] );
			var url:FMSURL = new FMSURL( _resource.url );
			url.protocol = "rtmfp";
			//var streamName:String = uriData.pop()
			//var uri:String = uriData.join("/");
			debug("> stream name: " + url.streamName );
			var uri:String = url.protocol + "://" + url.host + "/" + url.appName;
			debug("> uri: " + uri);
			debug("> groupspec: " + "G:"+_groupspec);
			var multicastResource:MulticastResource = new MulticastResource( uri, "G:"+_groupspec, url.streamName );
			var element:StaticVideoElement = new StaticVideoElement( multicastResource, new MulticastNetLoader() );
			
			return element;
		}
		 
		
		public function mediaElementCreated( element:MediaElement ):void
		{
			debug("Element Created Notification -- " + element.resource["url"]);
			
			/*
			if( element is VideoElement && _resource )
			{
				
				debug( "Create multicast resource" );
				
				//var uriData:Array = _resource.url.split( MULTICAST_KEY )[0].split("/");
				var url:FMSURL = new FMSURL( _resource.url.split( MULTICAST_KEY )[0] );
				url.protocol = "rtmfp";
				//var streamName:String = uriData.pop()
				//var uri:String = uriData.join("/");
				
				var uri:String = url.protocol + "://" + url.host + "/" + url.appName;
				
				debug("  streamName: " + url.streamName);
				debug("  uri: " + uri);
				
				var multicastResource:MulticastResource = new MulticastResource( uri, "G:"+_groupspec, url.streamName );
				//var multicastResource:MulticastResource = new MulticastResource( uri, "G:01012105f8cd3b377cf93646b30b07f29cf917d68d63c26ac60af46f0563829280d48fc5010c160e666d732e6d756c7469636173742e6578616d706c650009157265616c65796573", url.streamName );
			
			//	element.resource = multicastResource;
				
			}
			*/
		}
		
		
		
		/**
		 * Called from super class when plugin has been initialized with the MediaFactory from which it was loaded.
		 *  
		 * @param resource	Provides acces to the Resource used to load the plugin and any associated meta data
		 * 
		 */	
		override public function initializePlugin( resource:MediaResourceBase ):void
		{
			
			_groupspec = String( resource.getMetadataValue( "groupspec" ) );
//			_groupspec = "ABC_INTERNAL";
			
			_jsDebug = Boolean( resource.getMetadataValue( "jsDebug" ) );
			
			debug( "MulticastPluginInfo - Initialized" );
			//debug((resource as URLResource).url);
			debug( "Groupspec: " + _groupspec );
			
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
			trace( msg );
			
			if( _jsDebug )
			{
				ExternalInterface.call( "debug", msg );
				//ExternalInterface.call( "alert", msg );
			}
		}
	}
}