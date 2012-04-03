package com.realeyes.osmf.elements
{
	import com.realeyes.osmf.controls.CanvasSprite;
	import com.realeyes.osmf.data.IDOverlayVO;
	import com.realeyes.osmf.events.DebugEvent;
	
	import flash.external.ExternalInterface;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.utils.setTimeout;
	
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
	
	public class IDProxyElement extends ProxyElement
	{
		protected var holder:CanvasSprite;
		protected var textField:TextField;
		protected var idOverlayVO:IDOverlayVO;
		protected var canvasWidth:Number;
		protected var canvasHeight:Number;
		
		protected const MIN_INTERVAL:uint = 1000;
		protected const MAX_INTERVAL:uint = 5000;
		protected const DISPLAY_INTERVAL:uint = 300;
		
		/**
		 *Constructor - store the assetPath to use as the source for the watermark later 
		 * @param assetPath
		 * @param proxiedElement
		 * 
		 */		
		public function IDProxyElement( idOverlayVO:IDOverlayVO, canvasWidth:Number, canvasHeight:Number, proxiedElement:MediaElement=null )
		{
			
			super( proxiedElement );
			
			this.idOverlayVO = idOverlayVO;
			this.canvasWidth = canvasWidth;
			this.canvasHeight = canvasHeight;
			
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
				
				
				textField = generateTextField( canvasWidth, canvasHeight, idOverlayVO.separator, idOverlayVO.format );
				holder = new CanvasSprite();
				holder.width = canvasWidth;
				holder.height = canvasHeight;
				holder.alpha = idOverlayVO.alpha;
				
				var idOverlayElement:DisplayElement = new DisplayElement( holder );
				
				setTimeout( updateLayout, randomMinMax( MIN_INTERVAL, MAX_INTERVAL) );
				
				updateLayout();
				
				//initDisplayElement( holder );
				
				
				
				
				//create a parallel element so we can add the image & original element
				var parallel:ParallelElement = new ParallelElement();
				
				//Add the proxied element and the image as children
				parallel.addChild( value );
				parallel.addChild( idOverlayElement );
				
				//Set the proxied element
				super.proxiedElement = parallel;
				
				
			}
		}
		
		protected function randomMinMax( min:Number, max:Number ):Number
		{
			return Math.round( min + (max - min) * Math.random() );
		}
		
		
		protected function generateTextField( containerWidth:Number, containerHeight:Number, separator:String, format:TextFormat = null ):TextField
		{
			
			var tf:TextField = new TextField();
			tf.autoSize = TextFieldAutoSize.LEFT;
			tf.defaultTextFormat = format;
			
			tf.text = idOverlayVO.overlayID;
			
			return tf;
			
		}
		
		protected function updateLayout():void
		{
			textField.x = randomMinMax(0, holder.width - textField.width);
			textField.y = randomMinMax(0, holder.height - textField.height);
			
			holder.addChild( textField );
			setTimeout( clearLayout, DISPLAY_INTERVAL );
			
		}
		
		protected function clearLayout():void
		{
			if( holder.contains( textField ) )
			{
				holder.removeChild( textField )
			}
			setTimeout( updateLayout, randomMinMax( MIN_INTERVAL, MAX_INTERVAL) );
			
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