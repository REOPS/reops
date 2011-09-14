/*****************************************************
*  
*  Copyright 2009 Akamai Technologies, Inc.  All Rights Reserved.
*  
*****************************************************
*  The contents of this file are subject to the Mozilla Public License
*  Version 1.1 (the "License"); you may not use this file except in
*  compliance with the License. You may obtain a copy of the License at
*  http://www.mozilla.org/MPL/
*   
*  Software distributed under the License is distributed on an "AS IS"
*  basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
*  License for the specific language governing rights and limitations
*  under the License.
*   
*  
*  The Initial Developer of the Original Code is Akamai Technologies, Inc.
*  Portions created by Akamai Technologies, Inc. are Copyright (C) 2009 Akamai 
*  Technologies, Inc. All Rights Reserved. 
*  
*****************************************************/
package com.realeyes.osmf.plugins
{
	import com.realeyes.osmf.captioning.model.Caption;
	import com.realeyes.osmf.captioning.model.CaptioningDocument;
	import com.realeyes.osmf.captioning.parsers.DFXPParser;
	import com.realeyes.osmf.captioning.parsers.ICaptioningParser;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import org.osmf.elements.F4MElement;
	import org.osmf.elements.ProxyElement;
	import org.osmf.media.MediaElement;
	import org.osmf.media.MediaFactoryItem;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.media.PluginInfo;
	import org.osmf.metadata.Metadata;
	import org.osmf.metadata.TimelineMetadata;

	/**
	 * Encapsulation of a Captioning plugin.
	 * 
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.0
	 *  @productversion OSMF 1.0
	 */
	public class RECaptioningPluginInfo extends PluginInfo
	{
		// Constants for specifying the Timed Text document URL on the resource metadata
		public static const CAPTIONING_METADATA_NAMESPACE:String = "com.realeyes.osmf.plugins.RECaptioningPluginInfo";
		public static const CAPTIONING_METADATA_KEY_URI:String = "uri";
		
		// Constants for the temporal metadata (captions)
		public static const TEMPORAL_METADATA_NAMESPACE:String = "http://www.osmf.org/temporal/captioning";
		
		private var _f4mElement:F4MElement;
		private var _mediaElement:MediaElement;
		private var _captionLoader:URLLoader;
		private var captionMetaData:Metadata;
		
		
		/**
		 * Constructor.
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.0
		 *  @productversion OSMF 1.0
		 */
		public function RECaptioningPluginInfo( mediaFactoryItems:Vector.<MediaFactoryItem>=null, mediaElementCreationNotificationFunction:Function=null )
		{
			super( mediaFactoryItems, elementCreatedNotification );
		}
		
		
		///////////////////////////////////////////////////
		// CONTROL METHODS
		///////////////////////////////////////////////////
		
		
		public function initCaptions():void
		{
			if (captionMetaData == null)
			{
				//???
				debug("!! ERROR - No Caption Meta Data" );
			}
			else
			{		
				var timedTextURL:String = captionMetaData.getValue(CAPTIONING_METADATA_KEY_URI);
				if (timedTextURL != null)
				{
					if( !_captionLoader )
					{
						_captionLoader = new URLLoader();
						
					}
					addLoaderListeners();
					_captionLoader.load( new URLRequest( timedTextURL ) )
				}
				else
				{
					debug("!! ERROR - No Caption Meta Data URI" );
				}
				
			}
			
		}
		
		protected function addLoaderListeners():void
		{
			_captionLoader.addEventListener(Event.COMPLETE, completeHandler);
			_captionLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
			_captionLoader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
		}
		
		
		protected function removeLoaderListeners():void
		{
			_captionLoader.removeEventListener(Event.COMPLETE, completeHandler);
			_captionLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
			_captionLoader.removeEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
		}
		
		
		protected function parseCaptionDocument( data:String ):void
		{
			var parser:ICaptioningParser = new DFXPParser();
			var captioningDocument:CaptioningDocument;
			
			try
			{
				captioningDocument = parser.parse( data );
			}
			catch(e:Error)
			{
				CONFIG::LOGGING
				{
					if (logger != null)
					{
						logger.debug("Error parsing captioning document: " + e.errorID + "-" + e.message);
					}
				}
			}
			
			applyCaptionDocument( captioningDocument );
		}
		
		protected function applyCaptionDocument( document:CaptioningDocument ):void
		{
			// Create a TimelineMetadata object to associate the captions with
			// the media element.
	
			var timelineMetadata:TimelineMetadata = _mediaElement.getMetadata(TEMPORAL_METADATA_NAMESPACE) as TimelineMetadata;
			if (timelineMetadata == null)
			{
				timelineMetadata = new TimelineMetadata(_mediaElement);
			
				_mediaElement.addMetadata(TEMPORAL_METADATA_NAMESPACE, timelineMetadata);
			}
			
			for (var i:int = 0; i < document.numCaptions; i++)
			{
				var caption:Caption = document.getCaptionAt(i);
				debug(">>>>> CC add marker - " + caption.time + " : " + caption.text);
				timelineMetadata.addMarker(caption);
			}
			
			_captionLoader.data = null;
		}
		
		
		////////////////////////////////////////////////
		//REFFERENCE PLUGIN IMPLEMENTATION
		
		/**
		 *Called whenever a MediaElement is generated by the MediaFactory which the plugin was loaded from.
		 * This method will be called for any element that was created. It will be called for elements loaded before the plugin was loaded if they exist. 
		 * @param element
		 * 
		 */
		protected function elementCreatedNotification( element:MediaElement ):void 
		{
			debug( "Element Created: " + element);
			
			_mediaElement = element;
			
			var tempMetaData:Metadata;
			
			if( _mediaElement is F4MElement || (_mediaElement is ProxyElement && (_mediaElement as ProxyElement).proxiedElement is F4MElement ) )
			{
				tempMetaData = _mediaElement.resource.getMetadataValue(CAPTIONING_METADATA_NAMESPACE) as Metadata;
				if( tempMetaData )
				{
					
					captionMetaData = tempMetaData;
				}
				else
				{
					captionMetaData = null;
				}
			}
			else
			{
				tempMetaData = _mediaElement.resource.getMetadataValue(CAPTIONING_METADATA_NAMESPACE) as Metadata;
				if( tempMetaData )
				{
					captionMetaData = tempMetaData;
				}
				else
				{
					_mediaElement.resource.addMetadataValue( CAPTIONING_METADATA_NAMESPACE, tempMetaData );
				}
				initCaptions();
			}
			
		}
		
		
		
		
		// ==================================================
		// Helper methods
		// ==================================================
		
		protected function debug( msg:String ):void 
		{
			trace( msg );
			
		}
		
		
		
		///////////////////////////////////////////////////
		// EVENT HANDLERS
		///////////////////////////////////////////////////
		
		private function completeHandler(event:Event):void 
		{
			parseCaptionDocument( new XML( _captionLoader.data ) );
			removeLoaderListeners();
		}
		
		private function securityErrorHandler(event:SecurityErrorEvent):void 
		{
			trace("securityErrorHandler: " + event);
			
			removeLoaderListeners();
		}
		
		private function ioErrorHandler(event:IOErrorEvent):void 
		{
			trace("ioErrorHandler: " + event);
			
			removeLoaderListeners();
		}
		
	}
}
