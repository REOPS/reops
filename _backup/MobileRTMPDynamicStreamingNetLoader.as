package com.realeyes.osmf.media
{
	import flash.net.NetConnection;
	import flash.net.NetStream;
	
	import org.osmf.net.DynamicStreamingResource;
	import org.osmf.net.NetConnectionFactoryBase;
	import org.osmf.net.NetStreamSwitchManager;
	import org.osmf.net.NetStreamSwitchManagerBase;
	import org.osmf.net.SwitchingRuleBase;
	import org.osmf.net.rtmpstreaming.DroppedFramesRule;
	import org.osmf.net.rtmpstreaming.InsufficientBandwidthRule;
	import org.osmf.net.rtmpstreaming.InsufficientBufferRule;
	import org.osmf.net.rtmpstreaming.RTMPDynamicStreamingNetLoader;
	import org.osmf.net.rtmpstreaming.RTMPNetStreamMetrics;
	import org.osmf.net.rtmpstreaming.SufficientBandwidthRule;
	
	/**
	 * The MobileRTMPDynamicStreamingNetLoader Class is used to create and
	 * manage Mobile RTMP Dynamic Stream Net Loader objects.
	 * @author Realeyes Media
	 * 
	 */
	public class MobileRTMPDynamicStreamingNetLoader extends RTMPDynamicStreamingNetLoader
	{
		
		
		/**
		 * Constructor 
		 * @param factory
		 * 
		 */
		public function MobileRTMPDynamicStreamingNetLoader(factory:NetConnectionFactoryBase=null)
		{
			super(factory);
		}
		
		
		
		
		/**
		 * @private
		 * 
		 * Overridden to allow the creation of a NetStreamSwitchManager object.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		override protected function createNetStreamSwitchManager(connection:NetConnection, netStream:NetStream, dsResource:DynamicStreamingResource):NetStreamSwitchManagerBase
		{
			// Only generate the switching manager if the resource is truly
			// switchable.
			if (dsResource != null)
			{
				var metrics:RTMPNetStreamMetrics = new RTMPNetStreamMetrics(netStream);
				return new NetStreamSwitchManager(connection, netStream, dsResource, metrics, getMobileSwitchingRules(metrics));
			}
			return null;
		}
		
		/**
		 * Called by the createNetStreamSwitchManager function. Responsible for returning a Vector
		 * of switching rules for the passed in metrics parameter. 
		 * 
		 * @param metrics the stream metrics
		 * @return the switching rules for the metrics parameter.
		 * 
		 */
		private function getMobileSwitchingRules(metrics:RTMPNetStreamMetrics):Vector.<SwitchingRuleBase>
		{
			var rules:Vector.<SwitchingRuleBase> = new Vector.<SwitchingRuleBase>();
			rules.push(new SufficientBandwidthRule(metrics));
			rules.push(new InsufficientBandwidthRule(metrics));
			rules.push(new DroppedFramesRule(metrics));
			rules.push(new InsufficientBufferRule(metrics));
			return rules;
		}
		
	}
}