package com.realeyes.osmf.elements
{
	
	import com.realeyes.osmf.data.IDOverlayVO;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import org.osmf.containers.MediaContainer;
	
	public class IDWatermarkElement extends IDOverlayElement
	{
		
		public function IDWatermarkElement( container:MediaContainer, idOverlayVO:IDOverlayVO )
		{
			super( container, idOverlayVO );
			//_idOverlayVO = idOverlayVO;
			
			var textField:TextField = generateTextField( container.width, container.height, idOverlayVO.separator, idOverlayVO.format );
			var bmp:Bitmap = generateBitmap( textField );
			var holder:Sprite = generateHolder( bmp );
			
			applyLayout( bmp, holder, container);
			//applyMask( holder, container.width, container.height );
			holder.alpha = idOverlayVO.alpha;
			initDisplayElement( holder );
		}
		
		protected function generateTextField( containerWidth:Number, containerHeight:Number, separator:String, format:TextFormat = null ):TextField
		{
			
			var tfSize:Number =  Math.sqrt( (containerWidth * containerHeight ) + (containerHeight * containerHeight) );
			
			var tf:TextField = new TextField();
			tf.x = 0;
			tf.y = 0;
			tf.width = tfSize;
			tf.height = tfSize;
			tf.multiline = true;
			tf.wordWrap = true;
			tf.defaultTextFormat = format;
			
			var labelValue:String = "";
	//TODO - need to figure how to make this dynamic # of loops		
			var loopCount:uint = 1000;//Math.floor( tf.maxChars / _idOverlayVO.overlayID.length );
			for( var i:uint = 0; i < loopCount; i++ )
			{
				labelValue += idOverlayVO.overlayID + separator;
			}
			tf.text = labelValue;
			
			return tf;
			//tf.rotation = 45;
			
			
		}
		
		protected function generateBitmap( textField:TextField ):Bitmap
		{
			var myBitmapData:BitmapData = new BitmapData(textField.width, textField.height, true, 0);
			myBitmapData.draw(textField);
			return new Bitmap(myBitmapData);
			
		}
		
		
		protected function generateHolder( bmp:Bitmap ):Sprite
		{
			var holder:Sprite = new Sprite();
			holder.addChild( bmp );
			
			return holder;
		}
		
		
		private function applyLayout( bitmap:Bitmap, holder:Sprite, container:MediaContainer ):void
		{
			bitmap.x = (bitmap.width / 2) * -1;
			bitmap.y = (bitmap.height / 2) * -1;
			
			var angle:Number = Math.atan( container.height / container.width ) * 180/Math.PI;
			
			holder.rotation = angle;
			
			//container.x + 
			//container.y + 
		//	holder.x = (container.width/2);
		//	holder.y = (container.height/2);
			
		}
		
		
		/*private function applyMask( holder:Sprite, containerWidth:Number, containerHeight:Number ):void
		{
			
			
			var wMask:Sprite =  new Sprite();
			wMask.graphics.beginFill(0xFF0000);
			wMask.graphics.drawRect( 0, 0, containerWidth, containerHeight );
			wMask.graphics.endFill();
			//wMask.x = screen.x;
			//wMask.y = screen.y;
			//holder.addChild( wMask );
			holder.mask = wMask;
			
		}	*/	
		
		
		
	}
}