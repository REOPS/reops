package com.realeyes.osmf.data
{
	public class ChapterVO implements IChapter
	{
		private var _title:String;
		private var _description:String;
		private var _thumbnailURL:String;
		private var _time:Number;
		
		public static const CHAPTER_METADATA_NS:String = "com.realeyes.osmf.data.ChapterVO";
		public static const CHAPTERS:String = "chapters";
		
		public function ChapterVO( time:Number, thumbnailURL:String = "", title:String = "", description:String = "" )
		{
			this.time = time;
			this.thumbnailURL = thumbnailURL;
			this.title = title;
			this.description = description;
		}

		public function get title():String
		{
			return _title;
		}

		public function set title(value:String):void
		{
			_title = value;
		}

		public function get description():String
		{
			return _description;
		}

		public function set description(value:String):void
		{
			_description = value;
		}

		public function get thumbnailURL():String
		{
			return _thumbnailURL;
		}

		public function set thumbnailURL(value:String):void
		{
			_thumbnailURL = value;
		}

		public function get time():Number
		{
			return _time;
		}

		public function set time(value:Number):void
		{
			_time = value;
		}


	}
}