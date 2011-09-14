package com.realeyes.osmf.events
{
	import com.realeyes.osmf.controls.ChapterHash;
	import com.realeyes.osmf.data.IChapter;
	
	import flash.events.Event;
	
	/**
	 * Event for control bar interactions.
	 * 
	 * @author	RealEyes Media
	 * @version	1.0
	 */
	public class ChapterEvent extends Event
	{
		
		public static const SHOW_CHAPTER_OVERLAY:String = "showChapterOverlay";
		public static const HIDE_CHAPTER_OVERLAY:String = "hideChapterOverlay";
		
		/**
		 * The value for the data.	(Number)
		 * @default	0
		 */
		public var chapterHash:ChapterHash;
		
		
		
		/**
		 * Constructor
		 * @param	p_type			(String) the event type
		 * @param	p_volume		(Number) volume to use for a volume event. Defaults to 0.
		 * @param	p_seekPercent	(Number) percentage of the file to seek to for seek events. Defaults to 0.
		 * @param	p_bubbles		(Boolean) does the event bubble? Defaults to false
		 * @param	p_cancelable	(Boolean) can the event be canceled? Defaults to false
		 * @return	ControlBarEvent
		 */
		public function ChapterEvent(	p_type:String,
											p_chapterHash:ChapterHash,
											p_bubbles:Boolean=false, 
											p_cancelable:Boolean=false )
		{
			super( p_type, p_bubbles, p_cancelable );
			
			this.chapterHash = p_chapterHash;
			
		}
		
		/**
		 * Clones the event
		 * 
		 * @return	Event
		 */
		override public function clone():Event
		{
			return new ChapterEvent( type, chapterHash, bubbles, cancelable );
		}
	}
}