package com.realeyes.osmf.net
{
	import com.realeyes.osmf.model.buffer.BufferManagerModel;
	import com.realeyes.osmf.model.buffer.BufferTimeItem;
	
	import flash.events.Event;
	import flash.events.NetStatusEvent;
	import flash.events.TimerEvent;
	import flash.net.NetStream;
	import flash.net.NetStreamInfo;
	import flash.utils.Timer;
	
	import org.osmf.net.NetStreamCodes;
	import org.osmf.net.NetStreamMetricsBase;
	import org.osmf.net.httpstreaming.HTTPNetStream;
	import org.osmf.net.httpstreaming.HTTPNetStreamMetrics;
	import org.osmf.net.rtmpstreaming.RTMPNetStreamMetrics;
	import org.osmf.traits.BufferTrait;
	
	public class RENetStreamBufferTrait extends BufferTrait
	{
		//==========================================================
		//	DECLARATIONS
		//==========================================================
		
		public const BUFFER_START:String = "bufferStart";
		public const BUFFER_BASE:String = "bufferBase";
		public const BUFFER_EXTENDED:String = "bufferExtended";
		public const BUFFER_LIMITED:String = "bufferLimited";
		
		//refference to the video NetStream instance
		private var _ns:NetStream;
		
		//available bandwidth
		public var availableKbps:uint = 0;
		
		//video bit rate
		public var videoKbps:uint = 0;
		
		//video duration
		public var videoDuration:Number = 0;
		
		//overshoot calculated buffer by this amount (sec)
		public var calcOvershoot:Number = 0;
		
		//multiply the calculated buffer by this amount for over/under-shoot
		public var calcMultiplier:Number = 0;
		
		public var calcStartBuffer:Boolean;
		public var calcErrorBuffer:Boolean;
		
		private var _startBuffer:Number = 1;
		private var _baseBuffer:Number = 10;
		private var _extendedBuffer:Number = 20;
		private var _limitedBuffer:Number = 3;
		
		private var _pollTimer:Timer;
		private var _liveBandwidthTimer:Timer;
		private var _pollInterval:uint = 250;
		
		public var time:Number;		
		
		private var _emptyCount:uint = 0;
		private var _currentEmptyCount:int = 0;
		
		private var _fullTime:Number = 0;
		private var _fullTimeStart:Number = 0;
		
		private var _currentBufferMode:String;
		
		//buffer mode on deck or preffered at the moment
		private var _targetBufferMode:String;
		private var _targetBufferTime:Number;
		
		private var _calcNextBuffer:Boolean;
		
		private var _prevTotalLength:Number;
		private var _bwData:Array;
		private var _bwHistoryLen:uint = 30;
		private var _liveBandwidthEnabled:Boolean = true;
		
		private var _firstPlay:Boolean = true;
		private var _playingFromSeek:Boolean = false;
		
		private var _dataProvider:BufferManagerModel;
		
		private var _useNetStreamInfo:Boolean = true;
		
		
		private var _metrics:NetStreamMetricsBase;
		private var _useBufferManagement:Boolean = true;
		
		public function RENetStreamBufferTrait( netStream:NetStream, bufferModel:BufferManagerModel )
		{	
			super();
			
			this._ns = netStream;	
			bufferTime = _ns.bufferTime;
			
			_dataProvider = bufferModel;
			
			_bwData = new Array();
			
			if( _dataProvider )
			{
				calcStartBuffer = _dataProvider.calcStartBuffer;
				calcErrorBuffer = _dataProvider.calcErrorBuffer;
				calcOvershoot = _dataProvider.calcOvershoot;
				calcMultiplier = _dataProvider.calcMultiplier;
				startBuffer = _dataProvider.startBuffer;
				baseBuffer = _dataProvider.baseBuffer;
				extendedBuffer = _dataProvider.extendedBuffer;
				limitedBuffer = _dataProvider.limitedBuffer;
				emptyCount= _dataProvider.emptyCount;
				fullTime = _dataProvider.fullTime;
				//Default to true
				//_useNetStreamInfo = _dataProvider.useNetStreamInfo;
	
				//Start the stream off in the base buffer
				_targetBufferMode = BUFFER_BASE;
				
				//Begin with calculating buffer from bandwidth
				if( calcStartBuffer )
				{
					_calcNextBuffer = true;
				}
				
				//Use different metrics objects depending on stream type
				/*
				if( _ns is HTTPNetStream )
				{
					_metrics = new HTTPNetStreamMetrics( _ns as HTTPNetStream );
				}
				else
				{
					_metrics = new RTMPNetStreamMetrics( _ns );
				}
				*/
			}
			else
			{
				_useBufferManagement = false;
			}
			
			
			_ns.addEventListener(NetStatusEvent.NET_STATUS, _onNetStatus, false, 0, true);	
		}
		
		public function setBufferMode( mode:String, changeBuffer:Boolean = true ):void
		{
			trace("CHANGE BUFFER MODE: " + mode);
			
			_targetBufferTime = _bufferModeToSeconds( mode );
			
			_currentBufferMode = mode;
			
			if( changeBuffer )
			{
				setBufferTime( _targetBufferTime );
			}
		}
		
		private function _bufferModeToSeconds( mode:String ):Number
		{
			switch( mode )
			{
				case BUFFER_START:
				{
					return _startBuffer;
				}
				case BUFFER_BASE:
				{
					return _baseBuffer;
				}
				case BUFFER_EXTENDED:
				{
					return _extendedBuffer;
				}
				case BUFFER_LIMITED:
				{
					return _limitedBuffer;
				}
				default:
				{
					throw( new Error( "Unsupported Buffer Mode" ) );
				}
			}
		}
		
		
		public function calcBuffer( hideDebug:Boolean=false ):Number
		{
			hideDebug ? null : trace("-- calcBuffer() --");
			
			//TODO - add live buffer check	-- _bwData		
			
			if( isNaN( time ) )
			{
				time = 0;
			}
			
			var len:uint = _bwData.length;
			var bwSum:Number = 0;
			
			if( _useNetStreamInfo )
			{
				if( _bwData.length > 0 )
				{
					
					for( var i:uint = 0; i < len; i++ )
					{
						bwSum += _bwData[i];
					}
					
					availableKbps = bwSum / len;
				}
			}
			else
			{
				//only overwrite initial bandwidth value if we have enought data
				//TODO: figure out optimal amount of history to start live calculation, right
				//now half of the default data set length (30) seems to be a pretty good spot
				//between too long of a delay and not enough data
				if( _bwData.length >= ( _bwHistoryLen / 3 ) && _liveBandwidthEnabled )
				{
					var item:BufferTimeItem;
					var prevItem:BufferTimeItem; 
					var diffTime:Number;
					var diffVidTime:Number;
					var diffBuffer:Number;
					
					for( i = 0; i < len; i++)
					{
						item = _bwData[i];
						prevItem = _bwData[ i - 1];
						
						
						if( i != 0 )
						{
							
							diffTime = ( item.timeStamp - prevItem.timeStamp ) / 1000;
							diffBuffer = item.bufferTime - prevItem.bufferTime;
							diffVidTime = item.videoTime - prevItem.videoTime;
							var sum:Number = ( ( diffBuffer * videoKbps ) + ( diffVidTime * videoKbps ) ) / diffTime;
							
							if( !isNaN( sum ) )
							{
								bwSum += sum;
							}
							
						}
						
						availableKbps = bwSum / _bwData.length;
					}
				}
			}
			
			var duration:Number = videoDuration - time;
			var totalNeededBits:Number = Number( duration * videoKbps );
			var totalAvailableBits:Number = Number( duration * availableKbps );
			
			var balanceBits:Number = Number( totalNeededBits - totalAvailableBits );
			
			var bufferTime:Number = balanceBits / availableKbps;
			
			hideDebug ? null : trace("buffertime = balanceBits ( " + balanceBits + " ) / availableKbps ( " + availableKbps + " ) ");
			hideDebug ? null : trace("bufferTime: " + bufferTime);
			
			if( calcMultiplier > 0 )
			{
				bufferTime = bufferTime * calcMultiplier;
			}
			
			bufferTime += calcOvershoot;
			
			hideDebug ? null : trace("bufferTime w/overshoot: " + bufferTime);
			
			//setBufferTime( bufferTime < 0 ? 0 : bufferTime );
			
			return bufferTime < 0 ? 0 : bufferTime ;
		}
		
		public function setBufferTime( time:Number ):void
		{
			trace("SET BUFFER TIME: " + time);
			bufferTimeChangeStart( time );
			
			bufferTimeChangeEnd();
		}
		
		public function getBufferLength():Number
		{
			return _ns.bufferLength;
		}
		
		public function resetMarkers():void
		{
			resetEmptyMarkers();
			resetFullMarkers();
		}
		
		public function resetEmptyMarkers():void
		{
			_currentEmptyCount = 0;
		}
		
		public function resetFullMarkers():void
		{
			_fullTimeStart = -1;
		}
		
		public function updateBufferMode():void
		{
			if( _currentBufferMode != _targetBufferMode )
			{
				setBufferMode( _targetBufferMode );
			}
		}
		
		public function clearBandwidthHistory():void
		{
			_bwData = new Array();
		}
		
		
		public function startTimers():void
		{
			if( _pollTimer == null )
			{
				_pollTimer = new Timer( _pollInterval );
				_pollTimer.addEventListener( TimerEvent.TIMER, _onBufferPoll );
			}
			
			_pollTimer.start();
			
			if( !_useNetStreamInfo )
			{
				if( _liveBandwidthTimer == null )
				{
					_liveBandwidthTimer = new Timer( 1000 );
					_liveBandwidthTimer.addEventListener( TimerEvent.TIMER, _onLiveBandwidthTimer );
				}
				
				_liveBandwidthTimer.start();
			}
		}
		
		public function stopTimers():void
		{
			if( _pollTimer )
			{
				_pollTimer.stop()
			}
			
			if( _liveBandwidthTimer )
			{
				_liveBandwidthTimer.stop();
			}
		}
		
		public function clearTimer():void
		{
			_pollTimer.removeEventListener( TimerEvent.TIMER, _onBufferPoll );
			_pollTimer = null;
		}
		
		//TODO: find an internal solution, netstream doesn't always dispatch
		//NetStream.Seek.Notify #SEEK_FIX#
		public function seekReset():void
		{
			resetMarkers();
			
			_prevTotalLength = 0;
			
			//if we don't clear history on next play, data from different seek points throws
			//live bandwidth calculation waaay out of wack
			_playingFromSeek = true;
			
			if( calcStartBuffer )
			{
				trace( "SEEKING: calcStartBuffer enabled, will calc next buffer" );
				_calcNextBuffer = true;
			}
			else
			{
				setBufferMode( BUFFER_START );
			}
		}
		
		/**
		 * Checks if buffer is already bigger than what is calculated
		 * for cases if the user leaves the player paused. 
		 * 
		 */		
		private function _calculateBufferIfNecessary():void
		{
			var calculatedBuffer:Number = calcBuffer();
			
			if( ns.bufferLength < calculatedBuffer || calculatedBuffer == 0 )
			{
				if( calculatedBuffer > 0 )
				{
					if( _firstPlay && !calcStartBuffer )
					{
						trace( "INSUFFICIENT BANDWIDTH: not enough bw for quick play, calculated initial buffer" );
					}
					
					setBufferTime( calculatedBuffer );
				}
				else
				{
					setBufferMode( BUFFER_START );
				}
			}
		}
		
		
		
		//==========================================================
		//	HANDLERS
		//==========================================================
		private function _onNetStatus( evt:NetStatusEvent ):void
		{
			switch( evt.info.code ) 
			{
				case NetStreamCodes.NETSTREAM_BUFFER_EMPTY:
				{	
					bufferTime = _ns.bufferTime;				
					setBuffering(true);
					
					if( _useBufferManagement )
					{
						//If calcErrorBuffer is true and video is not at the end of playback
						//calculate buffer if we don't have enough
						if( calcErrorBuffer && ns.time < videoDuration )
						{
							trace( "BUFFER EMPTY: calcError enabled, will calculate" );
							_calculateBufferIfNecessary();
						}
						
						_currentEmptyCount++;
						
						if( _currentEmptyCount >= emptyCount )
						{
							if( _currentBufferMode != BUFFER_LIMITED )
							{
								resetEmptyMarkers();
								
								//_targetBufferMode = BUFFER_LIMITED;
								setBufferMode( BUFFER_LIMITED );
							}
						}
					}
					break;
				}			
				case NetStreamCodes.NETSTREAM_SEEK_NOTIFY:
				{
					trace( 'seek notify' );
					//FIXED? seemes to run consistently here.
					//TODO: currently using work around since this does not run always #SEEK_FIX#
					resetMarkers();
					
					if( calcStartBuffer )
					{
						trace( "SEEKING: calcStartBuffer enabled, will calc next buffer" );
						_calcNextBuffer = true;
					}
					else
					{
						setBufferMode( BUFFER_START );
					}
					
				}
				case NetStreamCodes.NETSTREAM_PLAY_COMPLETE:
				{
					//for now considering re-playing after complete a first play as well
					//so we'll calc on restart if less bw than stream
					stopTimers();
					_firstPlay = true;
					resetMarkers();
				}
				case NetStreamCodes.NETSTREAM_BUFFER_FULL:
				{
					setBuffering(false);
					
					if( _useBufferManagement )
					{
						updateBufferMode();
						
						startTimers();
					}
					break;
				}	
				case NetStreamCodes.NETSTREAM_PLAY_START:
				{
					bufferTime = _ns.bufferTime;				
					setBuffering(true);
					
					
					
					if( _useBufferManagement )
					{
						//If the initial settings haven't been set
						if( availableKbps == 0 )
						{
							try
							{
								availableKbps = _ns.info.maxBytesPerSecond;
								//videoKbps = _ns.info.
								//videoDuration = _ns.
							}
							catch( e:Error )
							{
								_useNetStreamInfo = false;
								trace( e.message );
							}
							
						}
							
						//if we're playing after a seek, clear bw history so live bw
						//stays accurate
						if( _playingFromSeek )
						{
							clearBandwidthHistory();
							
							_playingFromSeek = false;
						}
						
						startTimers();
						
						if( _calcNextBuffer || ( _firstPlay && availableKbps < videoKbps ) )
						{
							_calculateBufferIfNecessary();
							
							_firstPlay = false;
							_calcNextBuffer = false;
						}
					}
					
					break;
				}	
				case NetStreamCodes.NETSTREAM_PLAY_STOP:
				{
					stopTimers();
					break;
				}
				case NetStreamCodes.NETSTREAM_BUFFER_FLUSH:
				{
					setBuffering(false);
					
					//TODO - should we handle anything here?  Was going to use this to determine when to disable
					//		 live bandwidth monitoring but this event does not fire consistently with when is
					//		 supposed as per documentation so the liveBandwidthTimer handles that.
					
					break;
				}
			}
		}
		
		private function _onLiveBandwidthTimer( evt:TimerEvent ):void
		{
			var totalLength:Number = getBufferLength() + ns.time;
			
			if( _prevTotalLength )
			{
				if( ( totalLength - _prevTotalLength ) < .5 && _liveBandwidthEnabled )
				{
					trace( "XXX -- not actively buffering, disabling live bandwidth detection" );
					_liveBandwidthEnabled = false;
					_prevTotalLength = 0;
				}
				else if( ( totalLength - _prevTotalLength ) > .75 && !_liveBandwidthEnabled )
				{
					trace( "^^^ -- actively buffering, enabling live bandwidth detection" );
					clearBandwidthHistory();
					_liveBandwidthEnabled = true;
					_prevTotalLength = 0;
				}
			}
			
			_prevTotalLength = totalLength;
		}
		
		
		
		private function _onBufferPoll( evt:TimerEvent ):void
		{
			if( _liveBandwidthEnabled )
			{
				if( _useNetStreamInfo )
				{
					var bandwidth:Number = 0
					try
					{
						var _nsInfo:NetStreamInfo = _ns.info;
						bandwidth = _nsInfo.maxBytesPerSecond;
					}
					catch( e:Error )
					{
						clearTimer();
						trace( e.message );
					}
					
					if( bandwidth > 0 )
					{
						_bwData.push( bandwidth / 128 );
					}
				}
				else
				{
					_bwData.push( new BufferTimeItem( ns.time, getBufferLength() ) );
				}
			}
			
			if( _bwData.length > _bwHistoryLen )
			{
				_bwData.shift();
			}
			
			//if on the good side
			if( getBufferLength() >= _targetBufferTime && _currentBufferMode != BUFFER_EXTENDED )
			{
				if( _fullTimeStart == -1)
				{
					_fullTimeStart = ns.time;
				}
				else if( ( ns.time - _fullTimeStart ) >= _fullTime )
				{
					trace( "POLL TRIGGERED EXTENDED, time: " + ns.time + ", _fullTimeStart: " + _fullTimeStart + ", fullTime: " + _fullTime );
					
					if( _currentBufferMode == BUFFER_LIMITED )
					{
						resetFullMarkers();
						
						setBufferMode( BUFFER_BASE );
					}
					else
					{
						setBufferMode( BUFFER_EXTENDED );
					}
				}
			}
			else
			{
				resetFullMarkers();
			}
			
			/*
			dispatchEvent( new BufferEvent(	BufferEvent.BUFFER_STATUS, 
				ns.bufferLength, 
				ns.bufferTime, 
				_bufferModeToSeconds( _targetBufferMode ) ) );
			*/
		}

		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
	//==========================================================================================================================	
		
		/**
		 * @private
		 * Communicates a <code>bufferTime</code> change to the media through the NetStream. 
		 *
		 * @param newTime New <code>bufferTime</code> value.
		 */											
		override protected function bufferTimeChangeStart( newTime:Number ):void
		{
			_ns.bufferTime = newTime;
		}
		
		/*
		protected function onNetStatus( event:NetStatusEvent ):void
		{			
			trace( 'on buffer trait ' + event.info.code );
			switch( event.info.code )
			{
				case NetStreamCodes.NETSTREAM_PLAY_START:   // Once playing starts, we will be buffering (streaming and progressive, until we receive a Buffer.Full or Buffer.flush
				case NetStreamCodes.NETSTREAM_BUFFER_EMPTY:	 //Grab buffertime once again, since VOD will force it up to .1 from 0				
					if( _useBufferManagement )
					{
						
					}
					break;
				case NetStreamCodes.NETSTREAM_BUFFER_FLUSH:
				case NetStreamCodes.NETSTREAM_BUFFER_FULL:
					setBuffering(false);
					
					if( _useBufferManagement )
					{
						
					}
					break;
			}
		}
		*/
		//==========================================================
		//	GETTER/SETTERS
		//==========================================================
		public function get ns():NetStream
		{
			return _ns;
		}
		
		public function set ns( value:NetStream ):void
		{
			_ns = value;
			_ns.addEventListener( NetStatusEvent.NET_STATUS, _onNetStatus );
		}
		
		public function get startBuffer():Number
		{
			return _startBuffer;
		}
		public function set startBuffer( value:Number ):void
		{
			if( value != _startBuffer )
			{
				_startBuffer = value;
				dispatchEvent( new Event( "startBufferChange" ) );
			}
		}
		
		public function get baseBuffer():Number
		{
			return _baseBuffer;
		}
		public function set baseBuffer( value:Number ):void
		{
			if( value != _baseBuffer )
			{
				_baseBuffer = value;
				dispatchEvent( new Event( "baseBufferChange" ) );
			}
		}
		
		public function get extendedBuffer():Number
		{
			return _extendedBuffer;
		}
		public function set extendedBuffer( value:Number ):void
		{
			if( value != _extendedBuffer )
			{
				_extendedBuffer = value;
				dispatchEvent( new Event( "extendedBufferChange" ) );
			}
		}
		
		public function get limitedBuffer():Number
		{
			return _limitedBuffer;
		}
		public function set limitedBuffer( value:Number ):void
		{
			if( value != _limitedBuffer )
			{
				_limitedBuffer = value;
				dispatchEvent( new Event( "limitedBufferChange" ) );
			}
		}
		
		public function get emptyCount():uint
		{
			return _emptyCount;
		}
		public function set emptyCount( value:uint ):void
		{
			if( value != _emptyCount )
			{
				_emptyCount = value;
				dispatchEvent( new Event( "emptyCountChange" ) );
			}
		}
		
		public function get fullTime():Number
		{
			return _fullTime;
		}
		public function set fullTime( value:Number ):void
		{
			if( value != _fullTime )
			{
				_fullTime = value;
				dispatchEvent( new Event( "fullTimeChange" ) );
			}
		}
		
		/**
		 *  @private
		 */ 
		override public function get bufferLength():Number
		{
			return _ns.bufferLength;
		}
		
		public function get metrics():NetStreamMetricsBase
		{
			return _metrics;
		}
		
	}
}