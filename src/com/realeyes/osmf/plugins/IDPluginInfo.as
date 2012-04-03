package com.realeyes.osmf.plugins
{
	import com.realeyes.osmf.data.IDOverlayVO;
	import com.realeyes.osmf.elements.IDFingerprintElement;
	import com.realeyes.osmf.elements.IDOverlayElement;
	import com.realeyes.osmf.elements.IDWatermarkElement;
	import com.realeyes.osmf.elements.SkinContainerElement;
	import com.realeyes.osmf.elements.WatermarkProxyElement;
	import com.realeyes.osmf.events.DebugEvent;
	import com.realeyes.osmf.interfaces.IVideoShell;
	import com.realeyes.osmf.utils.PluginUtils;
	
	import flash.events.Event;
	import flash.external.ExternalInterface;
	import flash.text.TextFormat;
	
	import org.osmf.containers.MediaContainer;
	import org.osmf.elements.F4MElement;
	import org.osmf.elements.ProxyElement;
	import org.osmf.events.ContainerChangeEvent;
	import org.osmf.events.MediaElementEvent;
	import org.osmf.events.TimeEvent;
	import org.osmf.layout.HorizontalAlign;
	import org.osmf.layout.LayoutMetadata;
	import org.osmf.layout.ScaleMode;
	import org.osmf.layout.VerticalAlign;
	import org.osmf.media.MediaElement;
	import org.osmf.media.MediaFactoryItem;
	import org.osmf.media.MediaFactoryItemType;
	import org.osmf.media.MediaPlayer;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.media.PluginInfo;
	import org.osmf.metadata.Metadata;
	import org.osmf.net.NetLoader;
	import org.osmf.traits.MediaTraitType;
	import org.osmf.traits.TimeTrait;
	
	public class IDPluginInfo extends IDOverlayPluginInfo
	{
		
		
		private var _jsDebug:Boolean;
		
		///////////////////////////////////////////////////
		// CONSTRUCTOR
		///////////////////////////////////////////////////
		
		public function IDPluginInfo( mediaFactoryItems:Vector.<MediaFactoryItem>=null, mediaElementCreationNotificationFunction:Function=null )
		{
			
			
			//pass along the default Vector of MediaFacttoryItems, and specify which notification function to use for refference plugin implementation
			super( mediaFactoryItems, elementCreatedNotification );
		}
		
		
		
		
		/**
		 * Called from super class when plugin has been initialized with the MediaFactory from which it was loaded.
		 *  
		 * @param resource	Provides acces to the Resource used to load the plugin and any associated meta data
		 * 
		 */	
		override public function initializePlugin( resource:MediaResourceBase ):void
		{
			
			
			debug( "IDOverlayPluginInfo - Initialized" );
			
			//var metaData:Metadata = resource.getMetadataValue( NAMESPACE ) as Metadata;
			
			var type:String = IDOverlayPluginInfo.FINGERPRINT;
			var overlayID:String = String( resource.getMetadataValue("overlayID") );
			var separator:String = " | ";
			var format:TextFormat = new TextFormat("_sans", 10, 0xFF0000);
			var alpha:Number = .5;
			
			_jsDebug = Boolean( resource.getMetadataValue( "jsDebug" ) );
			
				
			idOverlayVO = new IDOverlayVO( type, overlayID, separator, format, alpha );
			
		}
		
		
		
		// ==================================================
		// Helper methods
		// ==================================================
		
		override protected function debug( msg:String ):void 
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