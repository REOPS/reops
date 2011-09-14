package com.realeyes.osmf.elements
{
	import com.realeyes.osmf.events.DebugEvent;
	
	import flash.external.ExternalInterface;
	
	import org.osmf.elements.ImageElement;
	import org.osmf.elements.ParallelElement;
	import org.osmf.elements.ProxyElement;
	import org.osmf.events.MediaElementEvent;
	import org.osmf.events.TimeEvent;
	import org.osmf.layout.LayoutMetadata;
	import org.osmf.layout.ScaleMode;
	import org.osmf.media.MediaElement;
	import org.osmf.media.URLResource;
	import org.osmf.traits.MediaTraitType;
	import org.osmf.traits.TimeTrait;
	
	
	public class WatermarkProxyElement extends ProxyElement
	{
		
		private var _assetPath:String;
		
		/**
		 *Constructor - store the assetPath to use as the source for the watermark later 
		 * @param assetPath
		 * @param proxiedElement
		 * 
		 */		
		public function WatermarkProxyElement( assetPath:String, proxiedElement:MediaElement=null )
		{
			_assetPath = assetPath;
			super( proxiedElement );
		}
		
		
		/**
		 * Called when the soure element is generated and passed through. May sometimes be null first time as class instantiates so better to check first
		 * @param value
		 * 
		 */		
		override public function set proxiedElement( value:MediaElement ):void
		{
			if( value )
			{
				//Create the image element
				var image:ImageElement = new ImageElement( new URLResource( _assetPath ) );
				var layout:LayoutMetadata = new LayoutMetadata();
				layout.bottom = 0;
				layout.left = 0;
				layout.index = 1;//this is so it is ontop of the media
				
				//add layout meta data to handle the positioning
				image.addMetadata( LayoutMetadata.LAYOUT_NAMESPACE, layout );
				
				//create a parallel element so we can add the image & original element
				var parallel:ParallelElement = new ParallelElement();
				
				//Add the proxied element and the image as children
				parallel.addChild( value );
				parallel.addChild( image );
				
				//Set the proxied element
				super.proxiedElement = parallel;
				
				
			}
		}
		
		
		// ==================================================
		// Helper methods
		// ==================================================
		
		/*public function debug( msg:String ):void
		{
			trace( msg );
			this.dispatchEvent( new DebugEvent( DebugEvent.DEBUG, msg, true ) );
			
		}*/
		
	}
}