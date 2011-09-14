package com.realeyes.osmf.model.playlist
{
	public class PlaylistItem
	{
		/**
		 * Title of the item
		 */
		public var title:String;
		
		/**
		 * Description for the playlist item
		 */
		public var description:String;
		
		/**
		 * URL for the thumbnail
		 */
		public var thumbnail:String;
		
		/**
		 * The media object. Either a string or a media element object (XML or AMF)
		 */
		public var mediaElement:Object;
		
		public function PlaylistItem()
		{
		}
	}
}