package com.realeyes.osmf.controls
{
	import com.realeyes.osmf.data.IChapter;
	import com.realeyes.osmf.events.ChapterEvent;
	import com.realeyes.osmf.events.ControlBarEvent;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	/**
	 * Shows progress of the media playback in a slider bar. Also allows
	 * for seeking through the media by using the scrubber. Also shows 
	 * buffer progress.
	 * 
	 * @author	RealEyes Media
	 * @version	1.0
	 */
	public class ProgressBar extends SkinElementBase
	{
		
		/////////////////////////////////////////////
		//  DECLARATIONS
		/////////////////////////////////////////////
		
		public var scrubber_mc:ToggleButton;
		
		public var current_mc:MovieClip;
		public var loaded_mc:MovieClip;
		
		public var live_mc:MovieClip;
		
		public var bg_mc:MovieClip;
		
		protected var _currentPercent:Number;
		protected var _currentLoadPercent:Number;
		
		protected var _dragging:Boolean = false;
		protected var _scrubberPadding:Number = 0;
		protected var _scrubberWidth:Number = 0;
		protected var _activeRange:Number;
		
		protected var _isLive:Boolean;
		
		
		private var _duration:Number;
		private var _chaptersDisplayList:Array;
		
		/////////////////////////////////////////////
		//  CONSTRUCTOR
		/////////////////////////////////////////////
		
		public function ProgressBar()
		{
			super();
			
			anchor = SkinElementBase.BOTH;
			
			//this.addEventListener( Event.ADDED_TO_STAGE, _onAdded );
			//trace(live_mc);
			//trace(current_mc);
			//trace(loaded_mc);
			//trace(scrubber_mc);
			live_mc.visible = false;
			current_mc.width = 0;
			loaded_mc.width = 0;
			
			if( scrubber_mc )
			{
				_scrubberWidth = scrubber_mc.width;
				scrubber_mc.toggle = false;
			}
			
			_scrubberPadding = _scrubberWidth / 2;
			
			_activeRange = bg_mc.width - _scrubberWidth;
			
			_initListeners();
			
			//this.addChild( new ChapterHash() )
		}
		
		
		
		/////////////////////////////////////////////
		//  CONTROL METHODS
		/////////////////////////////////////////////
		/**
		 * Initialize listenrs for mouse events
		 * 
		 * @return	void
		 */
		private function _initListeners():void
		{
			addEventListener( MouseEvent.CLICK, _onClick );
			
			if( scrubber_mc )
			{
				scrubber_mc.addEventListener( MouseEvent.MOUSE_DOWN, _onScrubberMouseDown );
				scrubber_mc.addEventListener( MouseEvent.MOUSE_UP, _onScrubberMouseUp );
			}
			
		}
		
		/**
		 * Sets the current progress indicator at a certain percentage of the
		 * bar's width. If showing playback progress, it also moves the scrubber.
		 * 
		 * @param	p_value	(Number) percentage of the bar to place the progress indicator at
		 * @return	void
		 */ 
		public function setCurrentBarPercent( p_value:Number ):void
		{
			//trace("current percent: " + (p_value) );
			if( !_dragging )
			{
				current_mc.width = Math.round( _scrubberWidth + _activeRange * p_value );
				//trace("setCurrentBarPercent: " + p_value);
				//current_mc.scaleX = p_value;
				
				if( scrubber_mc )
				{
					scrubber_mc.x = Math.round( current_mc.width );//- _scrubberWidth ); FIXES SCRUBBER JUMP ISSUE
				}
			}
			
			_currentPercent = p_value;
		}
		
		/**
		 * Updates the loading indicator bar to be at a certain percentage of the
		 * bar's width.
		 * 
		 * @param	p_value	(Number) percentage of the bar to place the progress indicator at
		 * @return	void
		 */
		public function setLoadBarPercent( p_value:Number ):void
		{
			if( p_value <= 1 )
			{
				loaded_mc.width = Math.round( _scrubberWidth + _activeRange * p_value );
			}
			else if( !isNaN( p_value ) )
			{
				loaded_mc.width = bg_mc.width;
			}
			
			//loaded_mc.scaleX = p_value ;
			
			_currentLoadPercent = p_value;
		}
		
		/**
		 * Stops dragging of the scrubber and seeks for recorded content.
		 * 
		 * @return	void
		 */
		private function _stopScrubberDrag():void
		{
			_dragging = false;
			
			scrubber_mc.removeEventListener( MouseEvent.MOUSE_MOVE, _onScrubberMouseMove );
			scrubber_mc.stopDrag();
			
			stage.removeEventListener( MouseEvent.MOUSE_UP, _onStageMouseUp );
			
			if( !isLive )
			{
				dispatchEvent( new ControlBarEvent( ControlBarEvent.SEEK_PERCENT, scrubber_mc.x / _activeRange, true ) );
			}
		}
		
		
		public function clearAllChapters():void
		{
			trace("-- clearAllChapters() -- ");
			if( _chaptersDisplayList && _chaptersDisplayList.length)
			{
				trace("-- clearAllChapters() -- [remove everything]");
				var hash:ChapterHash;
				var len:uint = _chaptersDisplayList.length;
				for( var i:uint = 0; i < len; i++)
				{
					hash = _chaptersDisplayList.pop();
					hash.removeEventListener(MouseEvent.MOUSE_OVER, onMouseOverHash );
					hash.removeEventListener(MouseEvent.MOUSE_OUT, onMouseOutHash );
					//hash.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDownHash );
					this.removeChild( hash );
				}
			}
			else
			{
				trace("-- clearAllChapters() -- [init list]");
				_chaptersDisplayList = new Array();
			}
		}
		
		public function addChapter( chapter:IChapter ):void
		{
			
			var hash:ChapterHash = new ChapterHash( chapter );
			hash.addEventListener(MouseEvent.MOUSE_OVER, onMouseOverHash, false, 0, true );
			hash.addEventListener(MouseEvent.MOUSE_OUT, onMouseOutHash, false, 0, true );
			//hash.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDownHash, false, 0, true );
			
			hash.useHandCursor = true;
			hash.mouseEnabled = true;
			
			hash.x = (chapter.time / duration) * width ;
			trace("hash.x: " + hash.x);
			_chaptersDisplayList.push( this.addChild( hash ) );
			
			trace("_chaptersDisplayList: "  + _chaptersDisplayList);
			//this.addChild( new ChapterOverlay() ).x = hash.x;
		}
		
		/////////////////////////////////////////////
		//  GETTER/SETTERS
		/////////////////////////////////////////////
		
		/**
		 * Is the content live?
		 * 
		 * @return	Boolean
		 */
		public function get isLive():Boolean
		{
			return _isLive;
		}
		
		public function set isLive( p_value:Boolean ):void
		{
			_isLive = p_value;
			
			if( _isLive )
			{
				if( scrubber_mc )
				{
					scrubber_mc.visible = false;
				}
				current_mc.visible = false;
				loaded_mc.visible = false;
				
				live_mc.visible = true;
			}
			else
			{
				if( scrubber_mc )
				{
					scrubber_mc.visible = true;
				}
				current_mc.visible = true;
				loaded_mc.visible = true;
				
				live_mc.visible = false;
			}
		}
		
		public override function set width( value:Number ):void
		{
			bg_mc.width = value;
			live_mc.width = value;
			_activeRange = value - _scrubberWidth;
			
			setCurrentBarPercent( _currentPercent );
			setLoadBarPercent( _currentLoadPercent );
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
			_duration = p_value;
		}
		
		
		/////////////////////////////////////////////
		//  HANDLERS
		/////////////////////////////////////////////
		/**
		 * When the bar is clicked on during playback, seek to
		 * that point.
		 * 
		 * @param	p_evt	(MouseEvent) click event
		 * @return	void
		 */
		private function _onClick( p_evt:MouseEvent ):void
		{
			if( !scrubber_mc || p_evt.target != scrubber_mc && !isLive )
			{
				dispatchEvent( new ControlBarEvent( ControlBarEvent.SEEK_PERCENT, ( mouseX - _scrubberPadding ) / _activeRange, true ) );
			}
		}
		
		/**
		 * Start draggin the scrubber when the mouse is down on the scrubber.
		 * 
		 * @param	p_evt	(MouseEvent) mouse down event
		 * @return	void
		 */
		private function _onScrubberMouseDown( p_evt:MouseEvent ):void
		{
			_dragging = true;
			
			scrubber_mc.addEventListener( MouseEvent.MOUSE_MOVE, _onScrubberMouseMove );
			
			stage.addEventListener( MouseEvent.MOUSE_UP, _onStageMouseUp );
			
			scrubber_mc.startDrag( false, new Rectangle( 0, scrubber_mc.y, _activeRange, 0 ) );
		}
		
		/**
		 * Stop dragging the scrubber
		 * 
		 * @param	p_evt	(MouseEvent) mouse up event
		 * @return	void
		 */
		private function _onScrubberMouseUp( p_evt:MouseEvent ):void
		{
			_stopScrubberDrag();
		}
		
		/**
		 * Change the width of the progress bar to match movements of the
		 * scrubber when it is being dragged.
		 * 
		 * @param	p_evt	(MouseEvent) mouse move event
		 * @return	void
		 */
		private function _onScrubberMouseMove( p_evt:MouseEvent ):void
		{
			current_mc.width = scrubber_mc.x + _scrubberPadding;
		}
		
		/**
		 * Stop dragging the scrubber
		 * 
		 * @param	p_evt	(MouseEvent) mouse up event
		 * @return	void
		 */
		private function _onStageMouseUp( p_evt:MouseEvent ):void
		{
			_stopScrubberDrag();
		}
		
		
		/*protected function onMouseDownHash(event:MouseEvent):void
		{
			this.dispatchEvent( new ControlBarEvent( ControlBarEvent.SEEK_TIME, (event.target as ChapterHash).time, true ) );
		}*/
		
		protected function onMouseOutHash(event:MouseEvent):void
		{
			this.dispatchEvent( new ChapterEvent( ChapterEvent.HIDE_CHAPTER_OVERLAY, (event.target as ChapterHash) ) );
				
			
		}
		
		protected function onMouseOverHash(event:MouseEvent):void
		{
			this.dispatchEvent( new ChapterEvent( ChapterEvent.SHOW_CHAPTER_OVERLAY, (event.target as ChapterHash) ) );
				
		}
		
		
	}
}