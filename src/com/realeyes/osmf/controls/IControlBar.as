package com.realeyes.osmf.controls
{
	import com.realeyes.osmf.data.IChapter;
	
	import flash.display.Sprite;
	

	public interface IControlBar extends ISkinElementBase
	{
		/**
		 * Sets the percentage of the current progress indicator to the given
		 * percentage of the progress bar
		 * 
		 * @param	p_value	(Number) percentage of the bar to set the progress indicator at
		 * @return	void
		 */
		function setCurrentBarPercent( p_value:Number ):void;
		/**
		 * Sets the percentage of the loading indicator to the given
		 * percentage of the progress bar
		 * 
		 * @param	p_value	(Number) percentage of the bar to set the progress indicator at
		 * @return	void
		 */
		function setLoadBarPercent( p_value:Number ):void;
		/**
		 * Enables manual selection of a higher bitrate stream, if it exists
		 * 
		 * @return	void
		 */
		function bitrateUpEnabled():void;
		/**
		 * Enables manual selection of a lower bitrate stream, if it exists
		 * 
		 * @return	void
		 */
		function bitrateDownEnabled():void;
		/**
		 * Disables manual selection of a higher bitrate stream
		 * 
		 * @return	void
		 */
		function bitrateUpDisabled():void;
		
		/**
		 * Disables manual selection of a lower bitrate stream
		 * 
		 * @return	void
		 */
		function bitrateDownDisabled():void;
		
		function setChapters( chapters:Vector.<IChapter> ):void;
		function clearChapters():void;
		
		function addAlternateAudioStream( index:int, language:String, info:Object = null ):void;
		
		
		/////////////////////////////////////////////
		//  GETTER/SETTERS
		/////////////////////////////////////////////
		
		/**
		 * A refference to the MediaContainer. Typed as Sprite to avoid OSMF Inclusion in assets
		 * @return 
		 * 
		 */		
		function get container():Sprite;
		function set container(value:Sprite):void;
		
		
		function get autoHide():Boolean;
		function set autoHide(value:Boolean):void;
		
		
		
		/**
		 * isLive
		 * Is the media playing live?
		 * @return	Boolean
		 */
		function get isLive():Boolean;
		function set isLive( p_value:Boolean ):void;
		/**
		 * currentTime
		 * The current time in seconds.
		 * @return	Number
		 */
		function get currentTime():Number;
		function set currentTime( p_value:Number ):void;
		
		/**
		 * duration
		 * The length of the media in seconds.
		 * @return	Number
		 */
		function get duration():Number;
		function set duration( p_value:Number ):void;
		/**
		 * currentState
		 * The current state. Options include: 'stopped', 'paused', and 'playing'
		 * @return	String
		 */
		function get currentState():String;
		function set currentState( p_value:String ):void;
		
		/**
		 * hasCaptions	
		 * Should the control enable the closed caption controls if they exist
		 * @return	Boolean
		 */
		function get hasCaptions():Boolean;
		function set hasCaptions( p_value:Boolean ):void;
		
		function get autoHideVolume():Boolean;
		function set autoHideVolume( value:Boolean ):void;
		
		
		function set hasAlternateAudio( value:Boolean ):void;
		function get hasAlternateAudio():Boolean;
		
		function set audioIsSwitching( value:Boolean ):void;
	}
}