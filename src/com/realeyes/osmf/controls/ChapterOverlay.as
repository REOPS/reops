package com.realeyes.osmf.controls
{
	import com.realeyes.osmf.data.IChapter;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.text.TextField;
	
	public class ChapterOverlay extends Sprite
	{
		public var chapterOverlayBG_mc:MovieClip;
		public var title_txt:TextField;
		protected var thumbnail:Image;
		private var _padding:int;
		
		
		public function ChapterOverlay( padding:uint = 2 )
		{
			super();
			_padding = padding;
			
		}
		
		public function setChapter( chapter:IChapter ):void
		{
			if( !thumbnail )
			{
				thumbnail = new Image( chapter.thumbnailURL, chapterOverlayBG_mc.width - (_padding*2), chapterOverlayBG_mc.height - title_txt.height - (_padding*3));
				thumbnail.y = _padding;
				thumbnail.x = _padding;
				this.addChild( thumbnail );
			}
			else
			{
				thumbnail.load( chapter.thumbnailURL );
			}
			
			title_txt.text = chapter.title;
		}
	}
}