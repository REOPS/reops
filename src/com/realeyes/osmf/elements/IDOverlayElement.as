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
	
	public class IDOverlayElement extends DisplayElement
	{
		protected var idOverlayVO:IDOverlayVO;
		
		public function IDOverlayElement( container:MediaContainer, idOverlayVO:IDOverlayVO )
		{
			
			this.idOverlayVO = idOverlayVO;
			
			//var textField:TextField = generateTextField( container.width, container.height, _idOverlayVO.separator, _idOverlayVO.format );
			
			
		}
		
		
		
	}
}