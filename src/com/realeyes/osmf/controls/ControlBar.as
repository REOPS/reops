package com.realeyes.osmf.controls
{
	import com.realeyes.osmf.data.IChapter;
	import com.realeyes.osmf.events.ChapterEvent;
	import com.realeyes.osmf.events.ControlBarEvent;
	import com.realeyes.osmf.events.RollOutToleranceEvent;
	import com.realeyes.osmf.events.ToggleButtonEvent;
	import com.realeyes.osmf.model.layout.ControlBarItemVO;
	import com.realeyes.osmf.utils.RollOutTolerance;
	
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.StageDisplayState;
	import flash.events.Event;
	import flash.events.FullScreenEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.text.TextField;
	import flash.utils.Timer;
	
	
	
	/**
	 * Displays controls for the associated player. 
	 * 
	 * @author	RealEyes Media
	 * @version	1.0
	 */
	public class ControlBar extends SkinElementBase implements IControlBar
	{
		
		/////////////////////////////////////////////
		//  DECLARATIONS
		/////////////////////////////////////////////
		
		public static const VERSION:String = "1.3";
		
		
		
		public static const REWIND_INTERVAL:Number = 1.5;
		
		//typing this to sprite to avoid OSMF inclusion
		private var _container:Sprite;
		
		public var rewind_mc:ToggleButton;
		public var restart_mc:ToggleButton;
		public var expand_mc:ToggleButton;
		
		protected var _hideControlsTimer:Timer;
		protected var _hideControlsDelay:uint = 2000;

		protected var rewindTimer:Timer;
		protected var targetPercent:Number;
		
		public var bg_mc:Sprite;
		
		public var audioSelection_mc:ToggleButton;
		public var seekToLive_mc:ToggleButton;
		public var play_mc:ToggleButton;
		public var pause_mc:ToggleButton;
		public var playPause_mc:ToggleButton;
		public var volume_mc:ToggleButton;
		public var fullScreen_mc:ToggleButton;
		public var closedCaption_mc:ToggleButton;
		
		public var stop_mc:ToggleButton;
		public var volumeUp_mc:ToggleButton;
		public var volumeDown_mc:ToggleButton;
		
		public var bitrateUp_mc:ToggleButton;
		public var bitrateDown_mc:ToggleButton;
				
		public var progress_mc:ProgressBar;
		
		public var divider_mc:Sprite;
		
		public var volumeSlider_mc:VolumeSlider;
		
		public var currentTime_txt:TextField;
		public var totalTime_txt:TextField;
		
		public var displayVolumeSliderBelow:Boolean = false;
		
		private var _currentState:String;
		
		public var draggable:Boolean = true;

		private var _volumeSliderRolloutTolerance:RollOutTolerance;
		private var _isLive:Boolean;
		private var _hasCaptions:Boolean;
		private var _hasAlternateAudio:Boolean;
		//private var _audioIsSwitching:Boolean;
		private var _autoHideVolume:Boolean = false;
		
		public var dispatchVisibility:Boolean = false;

//TODO - should make interface		
		private var _chapterOverlay:ChapterOverlay;
		
		private var _currentTime:Number;
		private var _duration:Number;
		
		// Added to account for settings in the config using the <element> sub-nodes in <skin>
		private var _autoHide:Boolean;
		protected var _controlsItemList:Vector.<ControlBarItemVO>;
		
		
		
		/////////////////////////////////////////////
		//  CONSTRUCTOR
		/////////////////////////////////////////////
		
		public function ControlBar()
		{
			super();
			
			trace(">> CONTROL BAR");
			
			
			this.addEventListener( Event.ADDED_TO_STAGE, _onAdded );
			this.addEventListener( Event.REMOVED_FROM_STAGE, _onRemoved );
			
			_checkControls();
			
			autoHideVolume = _autoHideVolume;
			
			if( displayVolumeSliderBelow )
			{
				volumeSlider_mc.y += volumeSlider_mc.height + volume_mc.height;
				//volumeSlider_mc.displayBelow = true;
			}
			
			if( currentTime_txt )
			{
				currentTime_txt.mouseEnabled = false;
			}
			
			if( totalTime_txt )
			{
				totalTime_txt.mouseEnabled = false;
			}
		}
		
		
		/////////////////////////////////////////////
		//  INIT METHODS
		/////////////////////////////////////////////
		/**
		 * Creates listeners for each of the controls that are present.
		 * 
		 * @return	void
		 */
		protected function _checkControls():void
		{
			
			if( audioSelection_mc )
			{
				_initAudioSelectionButton();
				
			}
			
			
			if( seekToLive_mc )
			{
				_initSeekToLiveButton();
				
			}
			
			if( rewind_mc )
			{
				_initRewindButton();
			}
			
			if( restart_mc )
			{
				_initRestartButton();
				
			}
			
			if( expand_mc )
			{
				_initExpandButton();
				
			}
			
			
			if( play_mc )
			{
				_initPlayButton();
			}
			
			if( pause_mc )
			{
				_initPauseButton();
				
			}
			
			if( stop_mc )
			{
				_initStopButton();
			}
			
			if( volumeUp_mc )
			{
				_initVolumeUpButton();
			}
			
			if( volumeDown_mc )
			{
				_initVolumeDownButton();
			}
			
			
			if(playPause_mc)
			{
				_initPlayPauseButton();
			}
			
			if(volume_mc)
			{
				_initVolumeButton();
			}
			
			if( volumeSlider_mc )
			{
				_initVolumeSlider();
			}
			
			if(fullScreen_mc)
			{
				_initFullScreenButton();
			}
			
			if(closedCaption_mc)
			{
				_initClosedCaptionButton();
			}
			
			if(bitrateUp_mc)
			{
				_initBitrateUpButton();
			}
			
			if(bitrateDown_mc)
			{
				_initBitrateDownButton();
			}
			
			if(bg_mc)
			{
				_initBG();
			}
			
			
			if( progress_mc )
			{
				_initProgressBar();
			}
			
			if( currentTime_txt )
			{ 
				_initCurrentTimeText();
			}
			
			if( totalTime_txt )
			{
				_initTotalTimeText();
			}
			
			if( divider_mc )
			{
				_initDivider();
			}
		}
		
		protected function _initAudioSelectionButton():void
		{
			audioSelection_mc.enabled = _hasAlternateAudio;
			audioSelection_mc.toggle = false;
			audioSelection_mc.addEventListener( ToggleButtonEvent.TOGGLE_BUTTON_CLICK, onAudioSelectionClick );
			_addControlItem( audioSelection_mc );
		}
		
		protected function _initSeekToLiveButton():void
		{
			seekToLive_mc.toggle = false;
			seekToLive_mc.addEventListener( ToggleButtonEvent.TOGGLE_BUTTON_CLICK, _onSeekToLiveClick );
			_addControlItem( seekToLive_mc );
		}
		
		
		protected function _initRewindButton():void
		{
			rewind_mc.toggle = false;
			rewind_mc.addEventListener( MouseEvent.MOUSE_DOWN, _onRewindDown );
			rewind_mc.addEventListener( MouseEvent.MOUSE_UP, _onRewindUp );
			_addControlItem( rewind_mc );
		}
		
		protected function _initRestartButton():void
		{
			restart_mc.toggle = false;
			restart_mc.addEventListener( ToggleButtonEvent.TOGGLE_BUTTON_CLICK, _onRestartClick );
			_addControlItem( restart_mc );
		}
		
		protected function _initExpandButton():void
		{
			expand_mc.addEventListener( ToggleButtonEvent.TOGGLE_BUTTON_CLICK, _onExpandClick );
			_addControlItem( expand_mc );
		}
		
		protected function _initPlayButton():void
		{
			play_mc.toggle = false;
			play_mc.addEventListener( ToggleButtonEvent.TOGGLE_BUTTON_CLICK, _onPlayClick );
			_addControlItem( play_mc );
		}
		
		protected function _initPauseButton():void
		{
			pause_mc.toggle = false;
			pause_mc.addEventListener( ToggleButtonEvent.TOGGLE_BUTTON_CLICK, _onPauseClick );
			_addControlItem( pause_mc );
		}
		
		protected function _initStopButton():void
		{
			
			stop_mc.toggle = false;
			stop_mc.addEventListener( ToggleButtonEvent.TOGGLE_BUTTON_CLICK, _onStopClick );
			_addControlItem( stop_mc );
		}
		
		protected function _initVolumeUpButton():void
		{
			volumeUp_mc.toggle = false;
			volumeUp_mc.addEventListener( ToggleButtonEvent.TOGGLE_BUTTON_CLICK, _onVolumeUpClick );
			_addControlItem( volumeUp_mc );
		}
		
		protected function _initVolumeDownButton():void
		{
			volumeDown_mc.toggle = false;
			volumeDown_mc.addEventListener( ToggleButtonEvent.TOGGLE_BUTTON_CLICK, _onVolumeDownClick );
			_addControlItem( volumeDown_mc );
		}
		
		protected function _initPlayPauseButton():void
		{
			trace("---_initPlayPauseButton");
			playPause_mc.addEventListener( ToggleButtonEvent.TOGGLE_BUTTON_CLICK, _onPlayPauseClick );
			_addControlItem( playPause_mc );
		}
		
		protected function _initVolumeButton():void
		{
			volume_mc.addEventListener( ToggleButtonEvent.TOGGLE_BUTTON_CLICK, _onVolumeClick );
			volume_mc.addEventListener( MouseEvent.MOUSE_OVER, _onVolumeOver );
			volume_mc.addEventListener( MouseEvent.MOUSE_OUT, _onVolumeOut );
			_addControlItem( volume_mc );
		}
		
		protected function _initVolumeSlider():void
		{
			_addControlItem( volumeSlider_mc );
			
		}
		
		protected function _initFullScreenButton():void
		{
			//trace(">> INIT FULL SCREEN BUTTON");
			fullScreen_mc.addEventListener( ToggleButtonEvent.TOGGLE_BUTTON_CLICK, _onfullScreenClick );
			_addControlItem( fullScreen_mc );
		}
		
		protected function _initClosedCaptionButton():void
		{
			closedCaption_mc.addEventListener( ToggleButtonEvent.TOGGLE_BUTTON_CLICK, _onClosedCaptionClick );
			_addControlItem( closedCaption_mc );
		}
		
		protected function _initBitrateUpButton():void
		{
			bitrateUp_mc.toggle = false;
			bitrateUp_mc.addEventListener( ToggleButtonEvent.TOGGLE_BUTTON_CLICK, _onBitrateUpClick );
			_addControlItem( bitrateUp_mc );
		}
		
		
		protected function _initBitrateDownButton():void
		{
			bitrateDown_mc.toggle = false;
			bitrateDown_mc.addEventListener( ToggleButtonEvent.TOGGLE_BUTTON_CLICK, _onBitrateDownClick );
			_addControlItem( bitrateDown_mc );
		}
		
		protected function _initBG():void
		{
			bg_mc.addEventListener( MouseEvent.MOUSE_DOWN, _onBGDown );
			bg_mc.addEventListener( MouseEvent.MOUSE_UP, _onBGUp );
		}
		
		protected function _initProgressBar():void
		{
			_addControlItem( progress_mc );
		}
		
		protected function _initCurrentTimeText():void
		{
			_addControlItem( currentTime_txt );
		}
		
		protected function _initTotalTimeText():void
		{
			_addControlItem( totalTime_txt );
		}
		
		protected function _initDivider():void
		{
			_addControlItem( divider_mc );
		}
		
		/////////////////////////////////////////////
		//  CONTROL/METHODS
		/////////////////////////////////////////////
		
		protected function _addControlItem( p_item:DisplayObject ):void
		{
			var anchor:String;
			var left:Number;
			var right:Number;
			
			if( p_item is ISkinElementBase && (p_item as ISkinElementBase).anchor )
			{
				anchor = (p_item as ISkinElementBase).anchor;
			}
			//trace(">> LAYOUT: " + p_item);
			//trace(">> LAYOUT: " + anchor);
			if( !anchor )
			{
				if( p_item.x <= this.width / 2 )
				{
					anchor = SkinElementBase.LEFT;
				}
				else
				{
					anchor = SkinElementBase.RIGHT;
				}
			}
			
			
			left = p_item.x;
			right = this.width - ( p_item.x + p_item.width );
			
			
			
			if( !_controlsItemList )
			{
				_controlsItemList = new Vector.<ControlBarItemVO>;
			}
			
			//trace(">> LAYOUT: " + left);
			//trace(">> LAYOUT: " + right);
			//trace(">>>>>>>>>>>>>>>");
			_controlsItemList.push( new ControlBarItemVO( p_item, anchor, left, right ) );
		}
		
		public function hideAudioList():void
		{
			//overriden
		}
		
		public function _updateLayout():void
		{
			
			
			if( _controlsItemList && _controlsItemList.length )
			{
				for each( var vo:ControlBarItemVO in _controlsItemList )
				{
					_updateItemPosition( vo );
				}
				
				//_controlsItemList.forEach( _updateItemPosition );
			}
		}
		
		public function _updateItemPosition( p_item:ControlBarItemVO ):void
		{
			switch( p_item.anchor )
			{
				case SkinElementBase.LEFT:
				{
					p_item.target.x = p_item.left;
					break;
				}
				
				case SkinElementBase.RIGHT:
				{
					p_item.target.x = width - p_item.target.width - p_item.right;
					break;
				}
					
				case SkinElementBase.BOTH:
				{
					p_item.target.x = p_item.left;
					p_item.target.width = width - p_item.right - p_item.left;
					break;
				}
			}
			
			
		}
		
		
		public function addAlternateAudioStream( index:int, language:String, info:Object = null ):void 
		{
			
		}
		
		/**
		 * Recieves percent complete and converts to time for rewind functionality 
		 * @param percent
		 * @return 
		 * 
		 */
		protected function getTimeFromPercent( percent:Number ):Number
		{
			return duration * percent;
		}
		
		
		
		/**
		 * Takes a number of seconds and returns it in the format
		 * of M:SS.
		 * 
		 * @param	p_time	(Number) the time in seconds
		 * @return	String
		 */
		protected function formatSecondsToString( p_time:Number ):String
		{
			var min:Number = Math.floor( p_time / 60 );
			var sec:Number = Math.floor( p_time % 60);
			
			return min + ":" + ( sec.toString().length < 2 ? "0" + sec : sec );
		}
		
		/**
		 * Sets the percentage of the current progress indicator to the given
		 * percentage of the progress bar
		 * 
		 * @param	p_value	(Number) percentage of the bar to set the progress indicator at
		 * @return	void
		 */
		public function setCurrentBarPercent( p_value:Number ):void
		{
			if( progress_mc )
			{
				progress_mc.setCurrentBarPercent( p_value );
			}
			
		}
		
		/**
		 * Sets the percentage of the loading indicator to the given
		 * percentage of the progress bar
		 * 
		 * @param	p_value	(Number) percentage of the bar to set the progress indicator at
		 * @return	void
		 */
		public function setLoadBarPercent( p_value:Number ):void
		{
			if( progress_mc )
			{
				progress_mc.setLoadBarPercent( p_value );
			}
		}
		
		/**
		 * Enables manual selection of a higher bitrate stream, if it exists
		 * 
		 * @return	void
		 */
		public function bitrateUpEnabled():void
		{
			if( bitrateUp_mc )
			{
				bitrateUp_mc.enabled = true;
			}
		}
		
		/**
		 * Enables manual selection of a lower bitrate stream, if it exists
		 * 
		 * @return	void
		 */
		public function bitrateDownEnabled():void
		{
			if( bitrateDown_mc )
			{
				bitrateDown_mc.enabled = true;
			}
		}
		
		/**
		 * Disables manual selection of a higher bitrate stream
		 * 
		 * @return	void
		 */
		public function bitrateUpDisabled():void
		{
			if( bitrateDown_mc )
			{
				bitrateUp_mc.enabled = false;
			}
		}
		
		
		/**
		 * Disables manual selection of a lower bitrate stream
		 * 
		 * @return	void
		 */
		public function bitrateDownDisabled():void
		{
			if( bitrateDown_mc )
			{
				bitrateDown_mc.enabled = false;
			}
		}
		
		
		/**
		 * Sets chapters onto progress bar 
		 * @param chapters
		 * 
		 */
		public function setChapters( chapters:Vector.<IChapter> ):void
		{
			clearChapters();
			for( var i:uint = 0; i < chapters.length; i++)
			{
				trace("ADD CHAPTER: " + chapters[i].title + chapters[i].time);
				progress_mc.addChapter( chapters[i] );
			}
			progress_mc.addEventListener( ChapterEvent.SHOW_CHAPTER_OVERLAY, onShowChapterOverlay );
			progress_mc.addEventListener( ChapterEvent.HIDE_CHAPTER_OVERLAY, onHideChapterOverlay );
		}
		
		
		/**
		 * Clears chapters on progress bar 
		 * 
		 */
		public function clearChapters():void
		{
			progress_mc.clearAllChapters();
			progress_mc.removeEventListener( ChapterEvent.SHOW_CHAPTER_OVERLAY, onShowChapterOverlay );
			progress_mc.removeEventListener( ChapterEvent.HIDE_CHAPTER_OVERLAY, onHideChapterOverlay );
		}
		
		
		/////////////////////////////////////////////
		//  GETTER/SETTERS
		/////////////////////////////////////////////
		
		
		public function get autoHide():Boolean
		{
			return _autoHide;
		}
		
		public function set autoHide(value:Boolean):void
		{
			_autoHide = value;
			if( _autoHide )
			{
				if( !_hideControlsTimer )
				{
					
					_hideControlsTimer = new Timer( _hideControlsDelay, 1 );
					
					_hideControlsTimer.addEventListener( TimerEvent.TIMER_COMPLETE, _onHideControlsTimerComplete );
					
				}
				
				if( stage )
				{
					//trace("LISTEN FOR MOUSE MOVE (1)");
					stage.addEventListener( MouseEvent.MOUSE_MOVE, _onMouseMove );
				}
				
				_hideControlsTimer.reset();
				_hideControlsTimer.start();
			}
			else 
			{
				if(  stage )
				{
					stage.removeEventListener( MouseEvent.MOUSE_MOVE, _onMouseMove );
				}
				
				if( _hideControlsTimer )
				{
					_hideControlsTimer.stop();
				}
				
				visible = true;
			}
		}
		
		
		public function get hideControlsDelay():uint
		{
			return _hideControlsDelay;
		}
		
		public function set hideControlsDelay(value:uint):void
		{
			trace("hideControlsDelay: " + value);
			_hideControlsDelay = value;
			
			if( _hideControlsTimer )
			{
				
				_hideControlsTimer.delay = _hideControlsDelay;
			}
		}
		
		
		/**
		 * A refference to the MediaContainer - but used as sprite for optimization 
		 * @return 
		 * 
		 */
		public function get container():Sprite
		{
			return _container;
		}
		
		public function set container(value:Sprite):void
		{
			trace(">> CONTAINER: " + value);
			if( _container )
			{
				//_container.removeEventListener( MouseEvent.MOUSE_MOVE, _onMouseMove );
				_container.removeEventListener( ControlBarEvent.IS_LIVE, _onIsLiveChange );
			}
			_container = value;
			if( _autoHide )
			{
				//trace("LISTEN FOR MOUSE MOVE (2)");
				//_container.addEventListener( MouseEvent.MOUSE_MOVE, _onMouseMove );
				_container.addEventListener( ControlBarEvent.IS_LIVE, _onIsLiveChange, false, 0, true );
			}
		}
		
		/**
		 * height
		 * Height of the background or the containing clip
		 * @return	Number
		 */
		override public function get height():Number
		{
			if( bg_mc )
			{
				return bg_mc.height;
			}
				
			return super.height;
			
		}
		
		override public function set height(value:Number):void
		{
			hideAudioList();
			super.height = value;
		}
		
			
		override public function get width():Number
		{
			if( bg_mc )
			{
				return bg_mc.width;
			}
				
			return super.width;
			
		}
		
		override public function set width( p_value:Number):void
		{
			if( bg_mc )
			{
				
				
				bg_mc.width = p_value;
	//trace("!!!!! bg_mc.width : " + bg_mc.width);			
				_updateLayout();
				
				return;
			}
				
			super.width = p_value;
			//trace(">>> CONTROL WIDTH: " + p_value);
		}
		
		
		/**
		 * isLive
		 * Is the media playing live?
		 * @return	Boolean
		 */
		public function get isLive():Boolean
		{
			return _isLive;
		}
		
		public function set isLive( p_value:Boolean ):void
		{
			_isLive = p_value;
			trace("_isLive: " + _isLive);
			if( progress_mc )
			{
				progress_mc.isLive = _isLive;
			}
			
			if( _isLive )
			{
				if( rewind_mc )
				{
					rewind_mc.enabled = false;
				}
				if( restart_mc )
				{
					restart_mc.enabled = false;
				}
			}
			
			if( !_isLive )
			{
				if( rewind_mc )
				{
					rewind_mc.enabled = true;
				}
				if( restart_mc )
				{
					restart_mc.enabled = true;
				}
			}
		}
		
		/**
		 * currentTime
		 * The current time in seconds.
		 * @return	Number
		 */
		public function get currentTime():Number
		{
			return _currentTime;
		}
		
		public function set currentTime( p_value:Number ):void
		{
			_currentTime = p_value;
			if( currentTime_txt )
			{
				currentTime_txt.text = formatSecondsToString( p_value );
			}
			
		}
		
		/**
		 * duration
		 * The length of the media in seconds.
		 * @return	Number
		 */
		public function get duration():Number
		{
			return _duration;
		}
		
		public function set duration( p_value:Number ):void
		{
			if( p_value != _duration )
			{
				_duration = p_value;
				if( totalTime_txt )
				{
					totalTime_txt.text = formatSecondsToString( p_value );
				}
				
				if( progress_mc )
				{
					
					progress_mc.duration = _duration;
				}
			}
		}
		
		/**
		 * currentState
		 * The current state. Options include: 'stopped', 'paused', and 'playing'
		 * @return	String
		 */
		public function get currentState():String
		{
			return _currentState;
		}
		
		public function set currentState( p_value:String ):void
		{
			_currentState = p_value;
			
			trace("CONTROL BAR STATE: " + p_value);
			
			switch( _currentState )
			{
				case "stopped" :
				{
					//setLoadBarPercent(0);
				}
				case "paused" :
				{
					
					if( playPause_mc && !playPause_mc.selected)
					{
						playPause_mc.selected = true;
					}
					
					if( _autoHide )
					{
						_hideControlsTimer.stop();
						visible = true;
					}
					
					break;
				}
				case "playing" :
				{
					
					if( playPause_mc && playPause_mc.selected)
					{
						trace("Set selected playing -- false" );
						playPause_mc.selected = false;
					}
					
					
					if( _autoHide )
					{
						_hideControlsTimer.start();
						
					}
					
					break;
				}
				default:
				{
					visible = true;
				}
			}
			
		}
		
		
		/**
		 * hasCaptions	
		 * Should the control enable the closed caption controls if they exist
		 * @return	Boolean
		 */
		public function get hasCaptions():Boolean
		{
			return _hasCaptions;
		}
		
		public function set hasCaptions( p_value:Boolean ):void
		{
			_hasCaptions = p_value;
			
			if( closedCaption_mc )
			{
				closedCaption_mc.enabled = _hasCaptions;
			}
		}
		
		public function get autoHideVolume():Boolean
		{
			return _autoHideVolume;
		}
		public function set autoHideVolume( value:Boolean ):void
		{
			_autoHideVolume = value;
			
			if( _autoHideVolume )
			{
				this.removeChild( volumeSlider_mc );
				
				if( !_volumeSliderRolloutTolerance )
				{
					_volumeSliderRolloutTolerance = new RollOutTolerance( volumeSlider_mc, volume_mc );
				}
				_volumeSliderRolloutTolerance.addEventListener( RollOutToleranceEvent.TOLERANCE_OUT, _onVolumeSliderTolleranceOut );
			
			}
			else if( _volumeSliderRolloutTolerance )
			{
				_volumeSliderRolloutTolerance.removeEventListener( RollOutToleranceEvent.TOLERANCE_OUT, _onVolumeSliderTolleranceOut );
				_volumeSliderRolloutTolerance.stop();
			}
			
		}
		
		public function get volumeSliderDirection():String
		{
			return volumeSlider_mc.direction;
		}
		
		public function set volumeSliderDirection(value:String):void
		{
			volumeSlider_mc.direction = value;
		}
		
		override public function get visible():Boolean
		{
			return super.visible;
		}
		
		override public function set visible(value:Boolean):void
		{
			super.visible = value;
			
			if( dispatchVisibility )
			{
				this.dispatchEvent( new ControlBarEvent( ControlBarEvent.CONTROL_BAR_VISIBILITY, value ? 1 : 0, true) );
			}
		}
		
		public function get hasAlternateAudio():Boolean
		{
			return _hasAlternateAudio;
		}
		
		public function set hasAlternateAudio( value:Boolean ):void
		{
			_hasAlternateAudio = value;
			
			if( audioSelection_mc )
			{
				audioSelection_mc.enabled = value;
				
			}
		}
		
		/*public function get audioIsSwitching():Boolean
		{
			return _audioIsSwitching;
		}*/
		
		public function set audioIsSwitching( value:Boolean ):void
		{
			/*if( value != _audioIsSwitching)
			{
				_audioIsSwitching = value;	
			}*/
		}
		
		
		
		/////////////////////////////////////////////
		//  HANDLERS
		/////////////////////////////////////////////
		/**
		 * Dispatches ControlBarEvent.PLAY when Play button is clicked
		 * 
		 * @param	p_evt	(ToggleButtonEvent) click event
		 * @return	void
		 */
		private function _onPlayClick( p_evt:ToggleButtonEvent ):void
		{
			this.dispatchEvent( new ControlBarEvent( ControlBarEvent.PLAY ) );
		}
		
		/**
		 * Dispatches ControlBarEvent.PAUSE when Pause button is clicked
		 * 
		 * @param	p_evt	(ToggleButtonEvent) click event
		 * @return	void
		 */
		private function _onPauseClick( p_evt:ToggleButtonEvent ):void
		{
			this.dispatchEvent( new ControlBarEvent( ControlBarEvent.PAUSE ) );
		}
		
		/**
		 * Dispatches ControlBarEvent.PLAY or ControlBarEvent.PAUSE when 
		 * Pause/Play button is toggled
		 * 
		 * @param	p_evt	(ToggleButtonEvent) click event
		 * @return	void
		 */
		private function _onPlayPauseClick( p_evt:ToggleButtonEvent ):void
		{
			if( p_evt.selected)
			{
				//trace("disp - PAUSE");
				_onPauseClick( p_evt );
			}
			else
			{
				//trace("disp - PLAY");
				_onPlayClick( p_evt );
			}
		}
		
		/**
		 * Dispatches ControlBarEvent.MUTE or ControlBarEvent.UNMUTE when 
		 * the Volume button is clicked
		 * 
		 * @param	p_evt	(ToggleButtonEvent) click event
		 * @return	void
		 */
		private function _onVolumeClick( p_evt:ToggleButtonEvent ):void
		{
			if( p_evt.selected)
			{
				this.dispatchEvent( new ControlBarEvent( ControlBarEvent.MUTE ) );
			}
			else
			{
				this.dispatchEvent( new ControlBarEvent( ControlBarEvent.UNMUTE ) );
			}
		}
		
		
		/**
		 * Display the volume slider when rolled over
		 * 
		 * @param	p_evt	(MouseEvent) Mouse Over event
		 * @return	void
		 */
		private function _onVolumeOver( p_evt:MouseEvent ):void
		{
			if( _autoHideVolume && !this.contains( volumeSlider_mc ) )
			{
				this.addChildAt( volumeSlider_mc, this.getChildIndex(volume_mc) );
			}
		}
		
		
		/**
		 * Hide the volume slider when rolled over
		 * 
		 * @param	p_evt	(MouseEvent) Mouse Out event
		 * @return	void
		 */
		private function _onVolumeOut( p_evt:MouseEvent ):void
		{
			if( _autoHideVolume && _volumeSliderRolloutTolerance )
			{
				_volumeSliderRolloutTolerance.start();
			}
		}
		
		
		
		/**
		 * Dispatches ControlBarEvent.FULLSCREEN or ControlBarEvent.FULLSCREEN_RETURN 
		 * when the fullscreen button is toggled
		 * 
		 * @param	p_evt	(ToggleButtonEvent) click event
		 * @return	void
		 */
		private function _onfullScreenClick( p_evt:ToggleButtonEvent ):void
		{
			//trace( ">>>> ON FULL SCREEN CLICK: p_evt.selected: " + p_evt.selected );
			if( p_evt.selected)
			{
				//trace( ">>>> ON FULL SCREEN CLICK: ENTER FULL SCREEN" );
				this.dispatchEvent( new ControlBarEvent( ControlBarEvent.FULLSCREEN, 0, true ) );
				
				/*
				trace( ">>>> ON FULL SCREEN CLICK: ENTER FULL SCREEN: Parent Stage: " +  parent.stage );
				if( stage )
				{ 
					
					stage.removeEventListener( FullScreenEvent.FULL_SCREEN, _onFullScreen );
					stage.addEventListener( FullScreenEvent.FULL_SCREEN, _onFullScreen );
				}
				*/
			}
			else
			{
				//trace( ">>>> ON FULL SCREEN CLICK: EXIT FULL SCREEN" );
				this.dispatchEvent( new ControlBarEvent( ControlBarEvent.FULLSCREEN_RETURN, 0, true ) );
			}
		}
		
		/**
		 * When the player returns to normal from fullscreen mode, make sure the fullscreen
		 * button gets updated
		 * 
		 * @param	p_evt	(FullScreenEvent)
		 * @return	void
		 */
		private function _onFullScreen( p_evt:FullScreenEvent ):void
		{
			//trace( ">>>> ON FULL SCREEN" );
			//trace( ">>>> ON FULL SCREEN: Stage: " + stage );
			/*
			if( stage )
			{
				trace( ">>>> ON FULL SCREEN: Stage: " + stage + " Stage Display State: " + stage.displayState );
			}
			trace( ">>>> ON FULL SCREEN: fullScreen_mc selected? " + fullScreen_mc.selected );
			*/
			
			if( (stage && stage.displayState == StageDisplayState.NORMAL && fullScreen_mc.selected) || (!stage && fullScreen_mc.selected) )
			{
				fullScreen_mc.selected = false;
			}
		}
		
		/**
		 * Dispatches ControlBarEvent.SHOW_CLOSEDCAPTION or ControlBarEvent.HIDE_CLOSEDCAPTION 
		 * when the closed caption button is toggled
		 * 
		 * @param	p_evt	(ToggleButtonEvent) click event
		 * @return	void
		 */
		private function _onClosedCaptionClick( p_evt:ToggleButtonEvent ):void
		{
			if( p_evt.selected)
			{
				this.dispatchEvent( new ControlBarEvent( ControlBarEvent.SHOW_CLOSEDCAPTION ) );
			}
			else
			{
				this.dispatchEvent( new ControlBarEvent( ControlBarEvent.HIDE_CLOSEDCAPTION ) );
			}
		}
		
		/**
		 * For draggable control bars, starts the dragging when the
		 * BG is clicked on.
		 * 
		 * @param	p_evt	(MouseEvent) mouse down event
		 * @return	void
		 */
		private function _onBGDown( p_evt:MouseEvent ):void
		{
			if( draggable )
			{
				this.startDrag();
			}
		}
		
		/**
		 * For draggable control bars, ends the dragging when the
		 * BG is released.
		 * 
		 * @param	p_evt	(MouseEvent) mouse up event
		 * @return	void
		 */
		private function _onBGUp( p_evt:MouseEvent ):void
		{
			if( draggable )
			{
				this.stopDrag();				
			}
		}
		
		
		/**
		 * Dispatches ControlBarEvent.STOP when Stop button is clicked
		 * 
		 * @param	p_evt	(ToggleButtonEvent) click event
		 * @return	void
		 */
		private function _onStopClick( p_evt:ToggleButtonEvent ):void
		{
			this.dispatchEvent( new ControlBarEvent( ControlBarEvent.STOP ) );
		}

		/**
		 * Hide the volume slider when rolled out from.
		 * 
		 * @param	p_evt	(RollOutToleranceEvent)
		 * @return	void
		 */
		protected function _onVolumeSliderTolleranceOut( p_evt:RollOutToleranceEvent ):void
		{
			if( _autoHideVolume )
			{
				//volumeSlider_mc.visible = false;
				if( this.contains( volumeSlider_mc ) )
				{
					this.removeChild( volumeSlider_mc );
				}
			}
			else
			{
				_volumeSliderRolloutTolerance.removeEventListener( RollOutToleranceEvent.TOLERANCE_OUT, _onVolumeSliderTolleranceOut );
			}
		}
		
		/**
		 * Dispatches ControlBarEvent.VOLUME_UP when Volume Up button is clicked
		 * 
		 * @param	p_evt	(ToggleButtonEvent) click event
		 * @return	void
		 */
		private function _onVolumeUpClick( p_evt:ToggleButtonEvent ):void
		{
			this.dispatchEvent( new ControlBarEvent( ControlBarEvent.VOLUME_UP ) );
		}
		
		/**
		 * Dispatches ControlBarEvent.VOLUME_DOWN when Volume Down button is clicked
		 * 
		 * @param	p_evt	(ToggleButtonEvent) click event
		 * @return	void
		 */
		private function _onVolumeDownClick( p_evt:ToggleButtonEvent ):void
		{
			this.dispatchEvent( new ControlBarEvent( ControlBarEvent.VOLUME_DOWN ) );
		}
		
		/**
		 * Dispatches ControlBarEvent.BITRATE_UP when Bitrate Up button is clicked
		 * 
		 * @param	p_evt	(ToggleButtonEvent) click event
		 * @return	void
		 */
		private function _onBitrateUpClick( p_evt:ToggleButtonEvent ):void
		{
			this.dispatchEvent( new ControlBarEvent( ControlBarEvent.BITRATE_UP ) );
		}
		
		/**
		 * Dispatches ControlBarEvent.BITRATE_DOWN when Bitrate Down button is clicked
		 * 
		 * @param	p_evt	(ToggleButtonEvent) click event
		 * @return	void
		 */
		private function _onBitrateDownClick( p_evt:ToggleButtonEvent ):void
		{
			this.dispatchEvent( new ControlBarEvent( ControlBarEvent.BITRATE_DOWN ) );
		}
		
		
		
		protected function _onRewindDown( event:MouseEvent ):void
		{
			trace("rw-dwn: " + rewind_mc.enabled);
			if(rewind_mc.enabled)
			{
				this.dispatchEvent( new ControlBarEvent( ControlBarEvent.PAUSE ) );
				
				if( !rewindTimer )
				{
					rewindTimer = new Timer(200);
					rewindTimer.addEventListener( TimerEvent.TIMER, _onRewindTimer );
				}
				
				targetPercent = currentTime / duration;
				
				rewindTimer.start();
			
			}
		}
		
		private function _onRewindTimer( event:TimerEvent ):void
		{
			targetPercent = (getTimeFromPercent( targetPercent ) - REWIND_INTERVAL ) / duration;
			targetPercent = targetPercent < 0 ? 0 : targetPercent;
			this.progress_mc.setCurrentBarPercent( targetPercent );
		}
		
		protected function _onRewindUp( event:MouseEvent ):void
		{
			trace("rw-up: " + rewind_mc.enabled);
			if(rewind_mc.enabled && rewindTimer && rewindTimer.running)
			{
				rewindTimer.stop();
				dispatchEvent( new ControlBarEvent( ControlBarEvent.SEEK_TIME, getTimeFromPercent(targetPercent) ) );
				targetPercent = -1;
				this.dispatchEvent( new ControlBarEvent( ControlBarEvent.PLAY ) );
			}
		}
		
		protected function onAudioSelectionClick( event:ToggleButtonEvent ):void
		{
			
		}
		
		private function _onSeekToLiveClick( event:ToggleButtonEvent ):void
		{
			dispatchEvent( new ControlBarEvent( ControlBarEvent.SEEK_TO_LIVE) );
		}
		
		private function _onRestartClick( event:ToggleButtonEvent ):void
		{
			dispatchEvent( new ControlBarEvent( ControlBarEvent.SEEK_TIME, 0) );
		}
		
		
		private function _onExpandClick( event:ToggleButtonEvent ):void
		{
			if( event.selected )
			{
				this.dispatchEvent( new Event( ControlBarEvent.EXPAND, true ) );
			}
			else
			{
				this.dispatchEvent( new Event( ControlBarEvent.RESTORE, true ) );
			}
		}
		
		
		
		/**
		 * After a delay, check to see if the user is over the player. If they aren't, 
		 * hide the controls. Otherwise, keep checking to see when they mouse out.
		 * 
		 * @param	event	(TimerEvent) TimerEvent.TIMER
		 * @return	void
		 */
		protected function _onHideControlsTimerComplete( event:TimerEvent ):void
		{
			
			if( visible )
			{
				visible = false;
			}
			
		}
		
		/**
		 * When the user mouses over the control bar, show the controls if hidden,
		 * and monitor user activity to see when to hide the controls
		 * 
		 * @param	event	(MouseEvent)
		 * @return	void
		 */
		protected function _onMouseMove( event:MouseEvent ):void
		{
			//trace("container mouse move");
			
			if( !visible )
			{
				visible = true;
			}
			
			if( _hideControlsTimer )
			{					
				_hideControlsTimer.reset();
				_hideControlsTimer.start();
			}
			
		}
		
		
		/**
		 * Dispatched on the container from elsewhere in the app to trigger a change in the media 
		 * @param event
		 * 
		 */
		protected function _onIsLiveChange( event:ControlBarEvent ):void
		{
			isLive = Boolean( event.value ); 
		}
		
		
		/**
		 * Added to stage - setup FS listener
		 * 
		 * @param p_evt Event parameter for the generic event
		 * 
		 */
		protected function _onAdded( p_evt:Event = null ):void
		{
			//trace( ">>> ADDED TO STAGE: Stage? " + stage );
			stage.addEventListener( FullScreenEvent.FULL_SCREEN, _onFullScreen );
			
			//_container.addEventListener( ControlBarEvent.IS_LIVE, _onIsLiveChange, false, 0, true );
			
			if( _autoHide )
			{
				stage.addEventListener( MouseEvent.MOUSE_MOVE, _onMouseMove );
				
				_hideControlsTimer.reset();
				_hideControlsTimer.start();
			}
			
		}
		
		/**
		 * Removed from stage - cleanup FS listener
		 * 
		 * @param p_evt Event parameter for the generic event
		 * 
		 */
		protected function _onRemoved( p_evt:Event = null ):void
		{
			//trace( ">>> REMOVED FROM STAGE: Stage? " + stage ); 
			stage.removeEventListener( FullScreenEvent.FULL_SCREEN, _onFullScreen );
			if( _hideControlsTimer) 
			{
				_hideControlsTimer.stop();
			}
		}
		
		protected function getChapterOverlayX( hash:Sprite ):int
		{
			var base:uint = hash.x + progress_mc.x;
			trace("hash.x: " + hash.x);
			trace("progress_mc.x: " + progress_mc.x);
			trace("_chapterOverlay.width: " + _chapterOverlay.width);
			var targetPos:int = Math.round( base - (_chapterOverlay.width/2) );
			trace("targetPos: " + targetPos);
			if( targetPos < 0 )
			{
				trace("near edge");
				return 0;
			}
			else if( base + (_chapterOverlay.width/2) > width )
			{
				trace("far edge");
				return Math.round( width -_chapterOverlay.width );
			}
			
			return targetPos;
		}
		
		protected function onShowChapterOverlay( event:ChapterEvent ):void
		{
			trace("!! SHOW CHAPTER : " + event.chapterHash.chapter.thumbnailURL );
			if(!_chapterOverlay)
			{
				_chapterOverlay = new ChapterOverlay();
			}
			_chapterOverlay.setChapter( event.chapterHash.chapter );
			_chapterOverlay.x = getChapterOverlayX( event.chapterHash as Sprite );
			_chapterOverlay.y = (_chapterOverlay.height * -1 )- 5;
			
			if( !this.contains( _chapterOverlay ) )
			{
				this.addChild( _chapterOverlay );
			}
		}
		
		protected function onHideChapterOverlay( event:ChapterEvent ):void
		{
			trace("!! HIDE CHAPTER : " + event.chapterHash.chapter.thumbnailURL );
			if( this.contains( _chapterOverlay ) )
			{
				this.removeChild( _chapterOverlay );
			}
		}
		
	}
}