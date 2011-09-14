package com.realeyes.osmf.controls
{
	import com.realeyes.osmf.data.IChapter;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	public class ChapterHash extends Sprite
	{
		///////////////////////////////////////////////////
		// DECLARATIONS
		///////////////////////////////////////////////////
		
		
		private var _chapter:IChapter;
		
		///////////////////////////////////////////////////
		// CONSTRUCTOR
		///////////////////////////////////////////////////
		
		public function ChapterHash( chapter:IChapter )
		{
			super();
			this.chapter = chapter;
			/*
			this.addEventListener(MouseEvent.MOUSE_OVER, onMouseOverHash, false, 0, true );
			this.addEventListener(MouseEvent.MOUSE_OUT, onMouseOutHash, false, 0, true );
			this.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDownHash, false, 0, true );
			*/
		}
		
		
		///////////////////////////////////////////////////
		// EVENT HANDLERS
		///////////////////////////////////////////////////
		
		/*protected function onMouseDownHash(event:MouseEvent):void
		{
			// TODO Auto-generated method stub
			
		}
		
		protected function onMouseOutHash(event:MouseEvent):void
		{
			// TODO Auto-generated method stub
			
		}
		
		protected function onMouseOverHash(event:MouseEvent):void
		{
			this.dispatchEvent( new 
			
		}
		*/
		
		///////////////////////////////////////////////////
		// GETTER/SETTERS
		///////////////////////////////////////////////////
		

		public function get chapter():IChapter
		{
			return _chapter;
		}

		public function set chapter(value:IChapter):void
		{
			_chapter = value;
		}

	}
}