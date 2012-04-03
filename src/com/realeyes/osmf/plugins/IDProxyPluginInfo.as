
package com.realeyes.osmf.plugins
{
	import com.realeyes.osmf.data.IDOverlayVO;
	import com.realeyes.osmf.elements.IDProxyElement;
	import com.realeyes.osmf.elements.WatermarkProxyElement;
	import com.realeyes.osmf.events.DebugEvent;
	import com.realeyes.osmf.interfaces.IVideoShell;
	import com.realeyes.osmf.utils.PluginUtils;
	
	import flash.external.ExternalInterface;
	import flash.text.TextFormat;
	
	import org.osmf.elements.ProxyElement;
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
	
	public class IDProxyPluginInfo extends PluginInfo
	{
		// Plugin Namespace
		static public const NAMESPACE:String = "com.realeyes.osmf.plugins.IDProxyPluginInfo";
		
		private var _assetPath:String;
		private var _vidShell:IVideoShell;
		private var _currentElement:MediaElement;
		private var _jsDebug:Boolean;
		
		
		protected var idOverlayVO:IDOverlayVO;
		
		///////////////////////////////////////////////////
		// CONSTRUCTOR
		///////////////////////////////////////////////////
		
		public function IDProxyPluginInfo( mediaFactoryItems:Vector.<MediaFactoryItem>=null, mediaElementCreationNotificationFunction:Function=null )
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
			
			super( items, mediaElementCreationNotificationFunction );
		}
		
		
		/**
		 *Function that will generate the MediaElement for the MediaFactory if the can handle resource is true for the resouce loading 
		 * Since this is a proxy plugin it generates a subclass of the ProxYElement and returns it.
		 *  @return 
		 * 
		 */	
		public function createMediaElement():ProxyElement
		{
			debug( "Create ID proxy element element" );
			
			//Create and return a new WatermarkProxyElement and pass it the asset use as the watermark
			return new IDProxyElement( idOverlayVO, 400, 300);
		}
		
		
		
		/**
		 * Called from super class when plugin has been initialized with the MediaFactory from which it was loaded.
		 *  
		 * @param resource	Provides acces to the Resource used to load the plugin and any associated meta data
		 * 
		 */	
		override public function initializePlugin( resource:MediaResourceBase ):void
		{
			_assetPath = resource.getMetadataValue( NAMESPACE ) as String;
			
			_jsDebug = Boolean( resource.getMetadataValue( "jsDebug" ) );
			
			//_vidShell = resource.getMetadataValue( PluginUtils.SHELL ) as IVideoShell;
			debug( "IDProxyPluginInfo - Initialized" );
			
			
			var type:String = IDOverlayPluginInfo.FINGERPRINT;
			var overlayID:String = String( resource.getMetadataValue("overlayID") );
			var separator:String = " | ";
			var format:TextFormat = new TextFormat("_sans", 10, 0xFFFFFF);
			var alpha:Number = .5;
			
			
			
			idOverlayVO = new IDOverlayVO( type, overlayID, separator, format, alpha );
		}
		
		
		// ==================================================
		// Helper methods
		// ==================================================
		
		protected function debug( msg:String ):void 
		{
			//trace( msg );
			if( _vidShell )
			{
				_vidShell.debug( msg );
			}
			
			if( _jsDebug )
			{
				ExternalInterface.call( "debug", msg );
				//ExternalInterface.call( "alert", msg );
			}
		}
	}
}