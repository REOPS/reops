package com.realeyes.osmf.model.playlist
{
	public class Playlist
	{
		//=================================================================
		//	PROPERTY DECLARATIONS
		//=================================================================
		/**
		 * Should playback move to the next item in the playlist when the current item has finished?
		 */
		public var autoProgress:Boolean;
		
		/** 
		 * Should playback of the list start from the beginning after reaching the end
		 */
		public var loopPlayback:Boolean;
		
		/**
		 * Can the user change which element is playing in the playlist
		 */
		public var userNavigable:Boolean;
		
		/**
		 * Array of PlaylistItems
		 */
		public var media:Array;
		
		//=================================================================
		//	INIT METHODS
		//=================================================================
		public function Playlist()
		{
			media = new Array();
		}
		
		//=================================================================
		//	CONTROL METHODS
		//=================================================================
		public function getItemAt( index:uint ):PlaylistItem
		{
			if( index > length )
			{
				throw( new Error( 'Index ' + index + ' out of bounds.' ) );
			}
			
			return media[ index ] as PlaylistItem;
		}
		
		//=================================================================
		//	GETTER/SETTERS
		//=================================================================
		public function get length():uint
		{
			return media.length;
		}
		
	}
}