package com.realeyes.osmf.data
{
	import flash.text.TextFormat;

	public class IDOverlayVO
	{
		private var _type:String;
		private var _overlayID:String;
		private var _separator:String;
		private var _format:TextFormat;
		private var _alpha:Number;
		
		public function IDOverlayVO( type:String, overlayID:String, separator:String = " | ", format:TextFormat = null, alpha:Number = 0.2 )
		{
			this.type = type;
			this.overlayID = overlayID
			this.separator = separator;
			
			if( !format )
			{
				format = new TextFormat();
				format.font = "Verdana";
				format.bold = true;
				format.size = 20;
				format.leading = 30;
				format.color = 0xFFFFFF;
			}
			
			this.format = format;
			this.alpha = alpha;
		}

		public function get overlayID():String
		{
			return _overlayID;
		}

		public function set overlayID(value:String):void
		{
			_overlayID = value;
		}

		public function get separator():String
		{
			return _separator;
		}

		public function set separator(value:String):void
		{
			_separator = value;
		}

		public function get format():TextFormat
		{
			return _format;
		}

		public function set format(value:TextFormat):void
		{
			_format = value;
		}

		public function get alpha():Number
		{
			return _alpha;
		}

		public function set alpha(value:Number):void
		{
			_alpha = value;
		}

		public function get type():String
		{
			return _type;
		}

		public function set type(value:String):void
		{
			_type = value;
		}


	}
}