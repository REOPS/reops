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

package com.akamai.osmf
{
	import com.akamai.osmf.net.AkamaiNetConnectionFactory;
	import com.akamai.osmf.net.AkamaiNetLoader;
	
	import org.osmf.elements.AudioElement;
	import org.osmf.elements.VideoElement;
	import org.osmf.media.MediaElement;
	import org.osmf.media.MediaFactoryItem;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.media.PluginInfo;
	import org.osmf.metadata.Metadata;
	import org.osmf.net.NetLoader;
	
	/**
	 * The PlugInfo class required by the OSMF plugin API.
	 */
	public class AkamaiBasicStreamingPluginInfo extends PluginInfo
	{	
		// Constants for specifying custom settings for the Akamai plugin
		
		/**
		 * The namespace for setting/getting metadata on both the plugin resource
		 * and the media resource.
		 **/
		public static const AKAMAI_METADATA_NAMESPACE:String = "http://www.akamai.com/basicstreamingplugin/1.0";
		
		/**
		 * This is a key for a plugin resource metadata value.
		 * <p/>
		 * For live streams, if the primary and secondary encoders stop (crash),
		 * the plugin will try to restart the stream every AKAMAI_METADATA_KEY_RETRY_INTERVAL seconds.
		 * This value overrides the default in AkamaiNetStream.
		 * <p/>
		 * Valid values are true or false typed as a Boolean.
		 **/
		public static const AKAMAI_METADATA_KEY_RETRY_LIVE:String = "retry-live";
		
		/**
		 * This is a key for a plugin resource metadata value.
		 * <p/>
		 * 
		 * The live stream retry interval in seconds. This value overrides the default
		 * in AkamaiNetStream.
		 **/
		public static const AKAMAI_METADATA_KEY_RETRY_INTERVAL:String = "retry-interval";
		
		/**
		 * This is a key for a plugin resource metadata value.
		 * <p/>
		 * The live stream time out in seconds. If the live stream does not start playing
		 * within this time, a stream not found error is dispatched. This value
		 * overrides the default in AkamaiNetStream.
		 **/
		public static const AKAMAI_METADATA_KEY_LIVE_TIMEOUT:String = "live-timeout";
		
		/**
		 * This is a key for a media resource metadata value.
		 * <p/>
		 * The name-value pairs required for invoking connection authorization services on the 
		 * Akamai network. Typically these include the "auth","aifp" and "slist"
		 * parameters. These name-value pairs must be separated by a "&" and should
		 * not begin with a "?", "&" or "/". An example of a valid string would be:
		 * <p/>
		 * 
		 * auth=dxaEaxdNbCdQceb3aLd5a34hjkl3mabbydbbx-bfPxsv-b4toa-nmtE&aifp=babufp&slist=secure/babutest
		 *
		 * <p/>
		 * This value must be set as content resource metadata, not plugin resource metadata.
		 **/
		public static const AKAMAI_METADATA_KEY_CONNECT_AUTH_PARAMS:String = "connect-auth-params";
		
		/**
		 * This is a key for a plugin resource metadata value.
		 * <p/>
		 * The name-value pairs required for invoking stream-level authorization services against
		 * streams on the Akamai network. Typically these include the "auth" and "aifp" 
		 * parameters. These name-value pairs must be separated by a "&" and should
		 * not begin with a "?", "&" or "/". An example of a valid string would be:
		 * <p/>
		 * 
		 * auth=dxaEaxdNbCdQceb3aLd5a34hjkl3mabbydbbx-bfPxsv-b4toa-nmtE&aifp=babufp
		 * 
		 * <p/>
		 * This value must be set as content resource metadata, not plugin resource metadata.
		 **/
		public static const AKAMAI_METADATA_KEY_STREAM_AUTH_PARAMS:String = "stream-auth-params";
		
		
		/**
		 * Constructor. Creates custom objects required for the plugin's functionality and any <code>MediaInfo</code> objects
		 * supported by the plugin.
		 */	
		public function AkamaiBasicStreamingPluginInfo()
		{		
			var items:Vector.<MediaFactoryItem> = new Vector.<MediaFactoryItem>();
			netLoader = new AkamaiNetLoader(new AkamaiNetConnectionFactory());
			
			var item:MediaFactoryItem = new MediaFactoryItem("com.akamai.osmf.BasicStreamingVideoElement", netLoader.canHandleResource, createVideoElement);
			items.push(item);

			item = new MediaFactoryItem("com.akamai.osmf.BasicStreamingAudioElement", netLoader.canHandleResource, createAudioElement);
			items.push(item);
			
			super(items);
		}
		
		/**
		 * @inheritDoc
		 **/
		override public function initializePlugin(resource:MediaResourceBase):void
		{
			pluginMetadata = resource.getMetadataValue(AKAMAI_METADATA_NAMESPACE) as Metadata;
		}
		
		private function createVideoElement():MediaElement
		{
			(netLoader as AkamaiNetLoader).pluginMetadata = pluginMetadata;
			return new VideoElement(null, netLoader);
		}
		
		private function createAudioElement():MediaElement
		{
			(netLoader as AkamaiNetLoader).pluginMetadata = pluginMetadata;
			return new AudioElement(null, netLoader);
		}
				
		private var netLoader:NetLoader;
		private var pluginMetadata:Metadata;
	}
}
