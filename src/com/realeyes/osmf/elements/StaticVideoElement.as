package com.realeyes.osmf.elements
{
	import org.osmf.elements.VideoElement;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.net.NetLoader;
	
	public class StaticVideoElement extends VideoElement
	{
		public function StaticVideoElement(resource:MediaResourceBase=null, loader:NetLoader=null)
		{
			super(resource, loader);
			//super.loader = loader;
			
			super.resource = resource;
		}
		
		
		/**
		 * @private
		 **/
		override public function set resource(value:MediaResourceBase):void
		{
			/*
			// Make sure the appropriate loader is set up front.
			loader = getLoaderForResource(value, alternateLoaders);
			
			super.resource = value;
			*/
			trace("loader:" + loader);
			trace("Ignoring: " + value);
		}
	}
}