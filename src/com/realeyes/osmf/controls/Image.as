package com.realeyes.osmf.controls
{
	
	
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	
	public class Image extends Sprite
	{
		private var _loader:Loader;
		private var _width:Number;
		private var _height:Number;
		private var _letterbox:Boolean;
		
		
		/**
		 * Calls the super class's constructor, and sets the image
		 * url, width, and height, to the values specified by the supplied parameters. 
		 *  
		 * @param url - the image's url location
		 * @param width - the width of the image
		 * @param height - the height of the image
		 * 
		 */
		public function Image(  url:String = null, width:Number = undefined, height:Number = undefined, letterbox:Boolean = true )
		{
			
			super();
			
			_loader = new Loader();
			addChild( _loader );
			//_loader.mouseEnabled = false;
			
			if(width)
			{
				_width = width;
			}
			if(height)
			{
				_height = height;
			}
			
			_letterbox = letterbox;
			
			if( url )
			{
				load( url );
			}
			
			//this.addEventListener( LayoutItemBase.RESIZE, _onUpdateSize, false, 0, true );
		}
		
		
		
		
		
		/**
		 * Loads the image of the specified url
		 *  
		 * @param url - the url location of the image
		 * 
		 */
		public function load( url:String ):void
		{
			_cleanupLoader();
			
			_loader.contentLoaderInfo.addEventListener( Event.COMPLETE, _onComplete );
			_loader.contentLoaderInfo.addEventListener( IOErrorEvent.IO_ERROR, _onIOError );
			
			
			
			_loader.load( new URLRequest( url ) );
		}
		
		/**
		 * This method is used by the onComplete and onIOError methods to remove
		 * the event listeners after a load request has been completed.
		 * 
		 */
		private function _cleanupLoader():void
		{
			_loader.contentLoaderInfo.removeEventListener( Event.COMPLETE, _onComplete );
			_loader.contentLoaderInfo.removeEventListener( IOErrorEvent.IO_ERROR, _onIOError );
		}
		
		/**
		 * This event listener fires when an Event.COMPLETE event is dispatched. It 
		 * is responsible for setting the loader width and height, adding the _loader
		 * object, resizing the item, and cleaning up the Loader object.
		 *  
		 * @param event
		 * 
		 */
		private function _onComplete( event:Event ):void
		{
			trace("IMAGE LOAD COMPLETE!");
			
			
			if( _width || _height )
			{
				if( _letterbox )
				{
					var ratio:Number;
					if( _loader.width > _loader.height )
					{
						ratio = _loader.height / _loader.width;
						_loader.width = _width;
						_loader.height = _width * ratio;
					}
					else
					{
						ratio = _loader.width / _loader.height;
						_loader.height = _height;
						_loader.height = _height * ratio;
					}
				}
				else
				{
			
					if(_width)
					{
						_loader.width = _width;
					}
					if(_height)
					{
						_loader.height = _height;
					}
				}
			}
			
			this.dispatchEvent( new Event( Event.COMPLETE ) );
			_cleanupLoader();
		}
		
		/**
		 * This event listener fires when an IOErrorEvent.IO_ERROR event is dispatched. It 
		 * is responsible for cleaning up the Loader.
		 * 
		 * @param event
		 * 
		 */
		private function _onIOError( event:IOErrorEvent ):void
		{
			_cleanupLoader();	
		}
		
		
		
		override public function set width(value:Number):void
		{
			//super.width = value;
			_width = value;
		}
		
		override public function set height(value:Number):void
		{
			//super.height = value;
			_height = value;
		}
	}
}


	
