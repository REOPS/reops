package com.realeyes.osmf.net
{
	import com.realeyes.osmf.utils.net.FMSURL;
	import com.realeyes.osmf.utils.net.PortProtocol;
	import com.realeyes.osmf.utils.net.URL;
	
	import org.osmf.net.NetConnectionFactory;
	
	public class RTMFPUnicastNetFactory extends NetConnectionFactory
	{
		
		private static const DEFAULT_PORTS:String = "1935,443,80";
		private static const DEFAULT_PROTOCOLS_FOR_RTMFP:String = "rtmfp,rtmp,rtmpt,rtmps"
		private static const DEFAULT_PROTOCOLS_FOR_RTMP:String = "rtmfp,rtmp,rtmp,rtmpt,rtmps"
		private static const DEFAULT_PROTOCOLS_FOR_RTMPE:String = "rtmpe,rtmpte";
		//private static const DEFAULT_CONNECTION_ATTEMPT_INTERVAL:Number = 200;
		
		private static const PROTOCOL_RTMFP:String = "rtmfp";
		private static const PROTOCOL_RTMP:String = "rtmp";
		private static const PROTOCOL_RTMPS:String = "rtmps";
		private static const PROTOCOL_RTMPT:String = "rtmpt";
		private static const PROTOCOL_RTMPE:String = "rtmpe";
		private static const PROTOCOL_RTMPTE:String = "rtmpte";
		
		
		
		public function RTMFPUnicastNetFactory(shareNetConnections:Boolean=true)
		{
			super(shareNetConnections);
		}
		
		
		override protected function createNetConnectionURLs(url:String, urlIncludesFMSApplicationInstance:Boolean=false):Vector.<String>
		{
			var urls:Vector.<String> = new Vector.<String>();
			
			var portProtocols:Vector.<PortProtocol> = buildPortProtocolSequence(url);
			for each (var portProtocol:PortProtocol in portProtocols)
			{
				urls.push(buildConnectionAddress(url, urlIncludesFMSApplicationInstance, portProtocol));
			}
			
			return urls;
		}
		
		/** 
		 * Assembles a vector of PortProtocol Objects to be used during the connection attempt.
		 * 
		 * @param url the URL to be loaded
		 * @returns a Vector of PortProtocol objects. 
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		private function buildPortProtocolSequence(url:String):Vector.<PortProtocol>
		{
			var portProtocols:Vector.<PortProtocol> = new Vector.<PortProtocol>;
			
			var theURL:URL = new URL(url);
			
			var allowedPorts:String = (theURL.port == "") ? DEFAULT_PORTS: theURL.port;
			var allowedProtocols:String = "";
			switch (theURL.protocol)
			{
				case PROTOCOL_RTMFP:
					allowedProtocols = DEFAULT_PROTOCOLS_FOR_RTMFP;
					break;
				case PROTOCOL_RTMP:
					allowedProtocols = DEFAULT_PROTOCOLS_FOR_RTMP;
					break;
				case PROTOCOL_RTMPE:
					allowedProtocols = DEFAULT_PROTOCOLS_FOR_RTMPE;
					break;
				case PROTOCOL_RTMPS:
				case PROTOCOL_RTMPT:
				case PROTOCOL_RTMPTE:
					allowedProtocols = theURL.protocol;
					break;
			}
			var portArray:Array = allowedPorts.split(",");
			var protocolArray:Array = allowedProtocols.split(",");
			for (var i:int = 0; i < protocolArray.length; i++)
			{
				for (var j:int = 0; j < portArray.length; j++)
				{
					var attempt:PortProtocol = new PortProtocol();
					attempt.protocol = protocolArray[i];
					attempt.port = portArray[j];
					portProtocols.push(attempt);
				}
			} 
			return portProtocols;
		}
		
		/**
		 * Assembles a connection address. 
		 * 
		 * @param url The URL to be loaded.
		 * @param urlIncludesFMSApplicationInstance Indicates whether the URL includes
		 * the FMS application instance name.  See StreamingURLResource for more info.
		 * @param portProtocol The port and protocol being used for the connection.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		private function buildConnectionAddress(url:String, urlIncludesFMSApplicationInstance:Boolean, portProtocol:PortProtocol):String
		{
			var fmsURL:FMSURL = new FMSURL(url, urlIncludesFMSApplicationInstance);
			var addr:String = portProtocol.protocol + "://" + fmsURL.host + ":" + portProtocol.port + "/" + fmsURL.appName + (fmsURL.useInstance ? "/" + fmsURL.instanceName:"");
			
			// Pass along any query string params
			if (fmsURL.query != null && fmsURL.query != "")
			{
				addr += "?" + fmsURL.query;
			}
			
			return addr;
		}
		
		
	}
}