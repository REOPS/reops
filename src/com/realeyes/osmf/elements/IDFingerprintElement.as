package com.realeyes.osmf.elements
{
	
	import com.realeyes.osmf.controls.CanvasSprite;
	import com.realeyes.osmf.data.IDOverlayVO;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.utils.setTimeout;
	
	import org.osmf.containers.MediaContainer;
	
	public class IDFingerprintElement extends IDOverlayElement
	{
		
		protected var textField:TextField;
		protected var holder:CanvasSprite;
		
		protected const MIN_INTERVAL:uint = 1000;
		protected const MAX_INTERVAL:uint = 5000;
		protected const DISPLAY_INTERVAL:uint = 300;
		
		public function IDFingerprintElement( container:MediaContainer, idOverlayVO:IDOverlayVO )
		{
			super( container, idOverlayVO );
			//_idOverlayVO = idOverlayVO;
			
			textField = generateTextField( container.width, container.height, idOverlayVO.separator, idOverlayVO.format );
			holder = new CanvasSprite();
			holder.width = container.width;
			holder.height = container.height;
			holder.alpha = idOverlayVO.alpha;
			
			setTimeout( updateLayout, randomMinMax( MIN_INTERVAL, MAX_INTERVAL) );
			
			updateLayout();
			
			initDisplayElement( holder );
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
		
	}
}