package com.realeyes.osmf.net
{
	import com.realeyes.osmf.utils.net.NetStreamUtils;
	import com.realeyes.osmf.utils.net.URL;
	
	import org.osmf.media.MediaResourceBase;
	import org.osmf.media.URLResource;
	import org.osmf.net.NetConnectionFactoryBase;
	import org.osmf.net.NetLoader;
	
	public class RTMFPUnicastNetLoader extends NetLoader
	{
		public function RTMFPUnicastNetLoader(arg0:NetConnectionFactoryBase=null)
		{
			super(arg0);
		}
		
		
		
		/**
		 * @private
		 * 
		 * The NetLoader returns true for URLResources which support the media and mime-types
		 * (or file extensions) for streaming audio and streaming or progressive video, or
		 * implement one of the following schemes: http, https, file, rtmp, rtmpt, rtmps,
		 * rtmpe or rtmpte.
		 * 
		 * @param resource The URL of the source media.
		 * @return Returns <code>true</code> for URLResources which it can load
		 **/
		override public function canHandleResource(resource:MediaResourceBase):Boolean
		{
			/*var rt:int = MediaTypeUtil.checkMetadataMatchWithResource(resource, MEDIA_TYPES_SUPPORTED, MIME_TYPES_SUPPORTED);
			if (rt != MediaTypeUtil.METADATA_MATCH_UNKNOWN)
			{
				return rt == MediaTypeUtil.METADATA_MATCH_FOUND;
			}	*/		
			
			/*
			* The rules for URL checking are outlined below:
			* 
			* If the URL is null or empty, we assume being unable to handle the resource
			* If the URL has no protocol, we check for file extensions
			* If the URL has protocol, we have to make a distinction between progressive and stream
			* 		If the protocol is progressive (file, http, https), we check for file extension
			*		If the protocol is stream (the rtmp family), we assume that we can handle the resource
			*
			* We assume being unable to handle the resource for conditions not mentioned above
			*/
			var res:URLResource = resource as URLResource;
			var extensionPattern:RegExp = new RegExp("\.flv$|\.f4v$|\.mov$|\.mp4$|\.mp4v$|\.m4v$|\.3gp$|\.3gpp2$|\.3g2$", "i");
			var url:URL = res != null ? new URL(res.url) : null;
			if (url == null || url.rawUrl == null || url.rawUrl.length <= 0)
			{
				return false;
			}
			if (url.protocol == "")
			{
				return extensionPattern.test(url.path);
			}
//NOTE: USING RE VERSION W/RTMFP SUPPORT!!!!
			if (NetStreamUtils.isRTMPStream(url.rawUrl)) 
			{
				return true;
			}
			if (url.protocol.search(/file$|http$|https$/i) != -1)
			{
				return (url.path == null ||
					url.path.length <= 0 ||
					url.extension.length == 0 ||
					extensionPattern.test(url.path));
			}
			
			return false;
		}
	}
}