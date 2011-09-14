package com.realeyes.osmf.elements
{
	
	import com.realeyes.osmf.captioning.model.Caption;
	import com.realeyes.osmf.captioning.model.CaptionFormat;
	import com.realeyes.osmf.captioning.model.CaptionStyle;
	import com.realeyes.osmf.controls.IClosedCaptionField;
	import com.realeyes.osmf.controls.IControlBar;
	import com.realeyes.osmf.controls.ILoadingIndicator;
	import com.realeyes.osmf.controls.ISkinElementBase;
	import com.realeyes.osmf.controls.SkinElementBase;
	import com.realeyes.osmf.data.ChapterVO;
	import com.realeyes.osmf.data.IChapter;
	import com.realeyes.osmf.events.ControlBarEvent;
	import com.realeyes.osmf.events.PlaylistEvent;
	import com.realeyes.osmf.model.config.skin.SkinConfig;
	import com.realeyes.osmf.model.config.skin.SkinElement;
	import com.realeyes.osmf.model.playlist.PlaylistItem;
	import com.realeyes.osmf.utils.net.URL;
	
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.display.StageDisplayState;
	import flash.events.Event;
	import flash.events.FullScreenEvent;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.system.SecurityDomain;
	import flash.text.TextFormat;
	import flash.utils.Timer;
	
	import org.osmf.containers.IMediaContainer;
	import org.osmf.containers.MediaContainer;
	import org.osmf.display.ScaleMode;
	import org.osmf.elements.ParallelElement;
	import org.osmf.events.AlternativeAudioEvent;
	import org.osmf.events.ContainerChangeEvent;
	import org.osmf.events.DynamicStreamEvent;
	import org.osmf.events.LoadEvent;
	import org.osmf.events.MediaPlayerCapabilityChangeEvent;
	import org.osmf.events.MediaPlayerStateChangeEvent;
	import org.osmf.events.PlayEvent;
	import org.osmf.events.TimeEvent;
	import org.osmf.events.TimelineMetadataEvent;
	import org.osmf.layout.LayoutMetadata;
	import org.osmf.media.MediaElement;
	import org.osmf.media.MediaPlayer;
	import org.osmf.media.MediaPlayerState;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.media.URLResource;
	import org.osmf.metadata.Metadata;
	import org.osmf.metadata.TimelineMetadata;
	import org.osmf.net.StreamingItem;
	import org.osmf.traits.PlayState;
	
	[Event(name="showClosedcaption", type="com.realeyes.osmf.events.ControlBarEvent")]
	[Event(name="hideClosedcaption", type="com.realeyes.osmf.events.ControlBarEvent")]
	/**
	 * Container for the control bar that manages layout of buttons, display of the
	 * skin, and handling control logic for user/player interaction
	 * 
	 * @author	RealEyes Media
	 * @version	1.0
	 */ 
	public class SkinContainerElement extends ParallelElement
	{
		/////////////////////////////////////////////
		//  DECLARATIONS
		/////////////////////////////////////////////
		
		
		/*
		<skin path="assets/skins/RE_Skin.swf">
			
			<skinElement id="controlBar"
			elementClass="com.realeyes.osmfplayer.controls.ControlBar" 
			initMethod="initControlBarInstance"  
			draggable="true" 
			autoHide="true" />
		
			<skinElement id="loadingIndicator"
			elementClass="com.realeyes.osmfplayer.controls.LoadingIndicator"  />
		
			<skinElement id="closedCaptionField"
			elementClass="com.realeyes.osmfplayer.controls.ClosedCaptionField" 
			initMethod="initClosedCaptionFieldInstance"  />
		
		</skin> 
		*/
		
		
		protected var _container:MediaContainer;
		protected var _mainElement:MediaElement;
		
		protected var _controlBar:IControlBar;
		protected var _loadingIndicator:ILoadingIndicator;
		protected var _closedCaptionField:IClosedCaptionField;
		
		protected var _mediaPlayerCore:MediaPlayer;
		
		private var _currentState:String;
		
		private var _path:String;
		
		private var _hasCaptions:Boolean;
		//private var _autoHide:Boolean;
		
		private var _loader:Loader;
		
		private var _bytesTotal:Number;
		
		private var _playlistItem:PlaylistItem;
		
		
		
		
		private var _bufferTimer:Timer;
		private var _bufferInterval:uint = 100;
		
		private var _restoreWidth:Number;
		private var _restoreHeight:Number;
		
		protected var _lastCurrentTime:Number;
		
		/**
		 * The skinElements to apply to the view	(Array)
		 */		
		protected var _skinElements:Array;
		protected var _skinElementInstances:Array;
		
		private var _loadingIndicatorElement:DisplayElement;
		private var _closedCaptionElement:DisplayElement;
		
		private var captionMetadata:TimelineMetadata; 
		private var _hasCaptionMarkers:Boolean;
		
		public static const CAPTIONING_TEMPORAL_METADATA_NAMESPACE:String = "http://www.osmf.org/temporal/captioning";
		
		/////////////////////////////////////////////
		//  CONSTRUCTOR
		/////////////////////////////////////////////
		/**
		 * Constructor
		 * @param	p_player		(MediaPlayerSprite) the instance of the player for this control bar
		 * @return	ControlsBarContainer
		 */
		public function SkinContainerElement( p_mainElement:MediaElement, p_player:MediaPlayer )
		{
			super();
			
			_init( p_mainElement, p_player );
		}
		
		
		/////////////////////////////////////////////
		//  INIT METHODS
		/////////////////////////////////////////////
		/**
		 * Initializes the control bar with starting settings
		 * 
		 * @param	p_player		(MediaPlayerSprite) the instance of the player for this control bar
		 * @return	void
		 */ 
		protected function _init( p_mainElement:MediaElement, p_player:MediaPlayer ):void
		{
			
			_skinElementInstances = new Array();
			
			/*_mainElement = p_mainElement;
			_mediaPlayerCore = p_player;
			mediaContainer = _mainElement.container as MediaContainer;
			*/
			
			updateExternals( p_mainElement, p_player, true );
			
			
			
			/*this.addEventListener( Event.ADDED_TO_STAGE, _onAdded );
			this.addEventListener( Event.REMOVED_FROM_STAGE, _onRemoved );*/
			
		}
		
		public function updateExternals( p_mainElement:MediaElement, p_player:MediaPlayer, p_dontClear:Boolean = false ):void
		{
			_mainElement = p_mainElement;
			_mediaPlayerCore = p_player;
			mediaContainer = _mainElement.container as MediaContainer;
			
			if( !p_dontClear )
			{
				_removeControlBarListeners();
				_removeMediaPlayerListeners();
				_initControlBarListeners();
				_initMediaPlayerListeners();
				controlBar.clearChapters();
			}
		}
		
		
		/**
		 * Initializes listening for player events
		 * 
		 * @return	void
		 */
		protected function _initMediaPlayerListeners():void
		{
			trace(">duration: " + _mediaPlayerCore.duration);
						
			_mediaPlayerCore.addEventListener(PlayEvent.PLAY_STATE_CHANGE, _onMediaStateChange, false, 0, true);
			_mediaPlayerCore.addEventListener( MediaPlayerStateChangeEvent.MEDIA_PLAYER_STATE_CHANGE, _onPlayerStateChange, false, 0, true );
			_mediaPlayerCore.addEventListener( TimeEvent.CURRENT_TIME_CHANGE, _onCurrentTimeChange, false, 0, true );
			_mediaPlayerCore.addEventListener( TimeEvent.DURATION_CHANGE, _onDurationTimeChange, false, 0, true );
			
			//_mediaPlayerCore.addEventListener( BufferEvent.BUFFER_TIME_CHANGE, _onBufferTimeChange );
			//_mediaPlayerCore.addEventListener( BufferEvent.BUFFERING_CHANGE, _onBufferingChange, false, 0, true );
			
			_mediaPlayerCore.addEventListener( LoadEvent.BYTES_LOADED_CHANGE, _onBytesLoadedChange, false, 0, true );
			_mediaPlayerCore.addEventListener( LoadEvent.BYTES_TOTAL_CHANGE, _onBytesTotalChange, false, 0, true );
			
			_mediaPlayerCore.addEventListener( DynamicStreamEvent.SWITCHING_CHANGE, _onSwitchChange, false, 0, true );
			_mediaPlayerCore.addEventListener( MediaPlayerCapabilityChangeEvent.IS_DYNAMIC_STREAM_CHANGE, _onIsDynamicStreamChange, false, 0, true );
			_mediaPlayerCore.addEventListener( AlternativeAudioEvent.AUDIO_SWITCHING_CHANGE, _onPlayerAudioStreamChange, false, 0, true );
			
		}
		
		/**
		 * Removes listening for player events
		 * 
		 * @return	void
		 */
		protected function _removeMediaPlayerListeners():void
		{
			trace("duration: " + _mediaPlayerCore.duration);
						
			_mediaPlayerCore.removeEventListener(PlayEvent.PLAY_STATE_CHANGE, _onMediaStateChange);
			_mediaPlayerCore.removeEventListener( MediaPlayerStateChangeEvent.MEDIA_PLAYER_STATE_CHANGE, _onPlayerStateChange );
			_mediaPlayerCore.removeEventListener( TimeEvent.CURRENT_TIME_CHANGE, _onCurrentTimeChange );
			_mediaPlayerCore.removeEventListener( TimeEvent.DURATION_CHANGE, _onDurationTimeChange );
			
			//_mediaPlayerCore.addEventListener( BufferEvent.BUFFER_TIME_CHANGE, _onBufferTimeChange );
			//_mediaPlayerCore.addEventListener( BufferEvent.BUFFERING_CHANGE, _onBufferingChange, false, 0, true );
			
			_mediaPlayerCore.removeEventListener( LoadEvent.BYTES_LOADED_CHANGE, _onBytesLoadedChange );
			_mediaPlayerCore.removeEventListener( LoadEvent.BYTES_TOTAL_CHANGE, _onBytesTotalChange );
			
			_mediaPlayerCore.removeEventListener( DynamicStreamEvent.SWITCHING_CHANGE, _onSwitchChange );
			_mediaPlayerCore.removeEventListener( MediaPlayerCapabilityChangeEvent.IS_DYNAMIC_STREAM_CHANGE, _onIsDynamicStreamChange );
			
			_mediaPlayerCore.addEventListener( AlternativeAudioEvent.AUDIO_SWITCHING_CHANGE, _onPlayerAudioStreamChange, false, 0, true );
			
		}
		
		/**
		 * Listen for user interaction with the control bar
		 * 
		 * @return	void
		 */
		protected function _initControlBarListeners():void
		{
			_controlBar.addEventListener( ControlBarEvent.STOP, _onStop, false, 0, true );
			_controlBar.addEventListener( ControlBarEvent.PLAY, _onPlay, false, 0, true );
			_controlBar.addEventListener( ControlBarEvent.SEEK_PERCENT, _onSeekPercent, false, 0, true );
			_controlBar.addEventListener( ControlBarEvent.SEEK_TIME, _onSeekTime, false, 0, true );
			_controlBar.addEventListener( ControlBarEvent.SEEK_TO_LIVE, _onSeekToLive, false, 0, true );
			_controlBar.addEventListener( ControlBarEvent.PAUSE, _onPause, false, 0, true );
			_controlBar.addEventListener( ControlBarEvent.MUTE, _onMute, false, 0, true );
			_controlBar.addEventListener( ControlBarEvent.UNMUTE, _onUnMute, false, 0, true );
			_controlBar.addEventListener( ControlBarEvent.VOLUME, _onVolumeChange, false, 0, true );
			_controlBar.addEventListener( ControlBarEvent.VOLUME_UP, _onVolumeUp, false, 0, true );
			_controlBar.addEventListener( ControlBarEvent.VOLUME_DOWN, _onVolumeDown, false, 0, true );
			_controlBar.addEventListener( ControlBarEvent.FULLSCREEN, _onFullScreen, false, 0, true );
			_controlBar.addEventListener( ControlBarEvent.FULLSCREEN_RETURN, _onFullscreenReturn, false, 0, true );
			_controlBar.addEventListener( ControlBarEvent.SHOW_CLOSEDCAPTION, _onShowClosedcaption, false, 0, true );
			_controlBar.addEventListener( ControlBarEvent.HIDE_CLOSEDCAPTION, _onHideClosedCaption, false, 0, true );
			_controlBar.addEventListener( ControlBarEvent.BITRATE_UP, _onBitrateUp, false, 0, true );
			_controlBar.addEventListener( ControlBarEvent.BITRATE_DOWN, _onBitrateDown, false, 0, true );
			_controlBar.addEventListener( ControlBarEvent.SWITCH_AUDIO, _onSwitchAudio, false, 0, true );
			
			
		}
		
	//TODO - need to figure out when to run this. Not sure how/where with the new skinElement system	
		private function _removeControlBarListeners():void
		{
			_controlBar.removeEventListener( ControlBarEvent.STOP, _onStop );
			_controlBar.removeEventListener( ControlBarEvent.PLAY, _onPlay );
			_controlBar.removeEventListener( ControlBarEvent.SEEK_PERCENT, _onSeekPercent );
			_controlBar.removeEventListener( ControlBarEvent.SEEK_TIME, _onSeekTime );
			_controlBar.removeEventListener( ControlBarEvent.PAUSE, _onPause );
			_controlBar.removeEventListener( ControlBarEvent.MUTE, _onMute );
			_controlBar.removeEventListener( ControlBarEvent.UNMUTE, _onUnMute );
			_controlBar.removeEventListener( ControlBarEvent.VOLUME, _onVolumeChange );
			_controlBar.removeEventListener( ControlBarEvent.VOLUME_UP, _onVolumeUp );
			_controlBar.removeEventListener( ControlBarEvent.VOLUME_DOWN, _onVolumeDown );
			_controlBar.removeEventListener( ControlBarEvent.FULLSCREEN, _onFullScreen );
			_controlBar.removeEventListener( ControlBarEvent.FULLSCREEN_RETURN, _onFullscreenReturn );
			_controlBar.removeEventListener( ControlBarEvent.SHOW_CLOSEDCAPTION, _onShowClosedcaption );
			_controlBar.removeEventListener( ControlBarEvent.HIDE_CLOSEDCAPTION, _onHideClosedCaption );
			_controlBar.removeEventListener( ControlBarEvent.BITRATE_UP, _onBitrateUp );
			_controlBar.removeEventListener( ControlBarEvent.BITRATE_DOWN, _onBitrateDown );
			_controlBar.addEventListener( ControlBarEvent.SWITCH_AUDIO, _onSwitchAudio, false, 0, true );
			
			
		}
		
		/**
		 * Creates an instance of the skin element
		 * 
		 * @param	p_skinElement	(SkinElement)
		 * @return	ISkinElementBase
		 */
		public function _generateElements( p_skinElement:SkinElement ):ISkinElementBase
		{
			//var elementClass:Class = ApplicationDomain.currentDomain.getDefinition( p_class ) as Class;
			
			//var element:DisplayElement;
			var item:ISkinElementBase;
			
			if( p_skinElement.altElementClass && p_skinElement.altWidthThreshold && _mediaPlayerShell.width < Number( p_skinElement.altWidthThreshold ) )
			{
				item = p_skinElement.buildSkinElement( p_skinElement.altElementClass )  as ISkinElementBase; 
				
			}
			else
			{
				item =  (p_skinElement.buildSkinElement()  ) as ISkinElementBase;
				
			}
			
			
			
			return item; 
			
		}
		
		protected function applyLayoutData( p_mediaElement:MediaElement, p_skinElement:SkinElement ):void
		{
			var layoutData:LayoutMetadata = new LayoutMetadata();
			
			var attrValue:String;
			var attributes:XMLList = p_skinElement.elementXML.layoutMetaData.attributes();
			
			//trace(">>> LAYOUT META DATA: ");
			for each( var attribute:XML in attributes )
			{
				attrValue = attribute.toString();
				
				if( attrValue.toLocaleLowerCase() == "true" || attrValue.toLocaleLowerCase() == "false" )
				{
					//trace(attribute.name().toString() + " : " + attrValue.toLocaleLowerCase());
					layoutData[ attribute.name().toString() ] = attrValue.toLocaleLowerCase() == "true" ? true:false;
				}
				else
				{
					layoutData[ attribute.name().toString() ] = attrValue;
					//trace(attribute.name().toString() + " : " + attrValue);
				}
			}
			
			//layoutData.percentWidth = 100;
			p_mediaElement.addMetadata( LayoutMetadata.LAYOUT_NAMESPACE, layoutData );
		}
		
		
		/**
		 * Initialize the control bar. Sets properties and enables functionality
		 * based on what controls are prseent
		 * 
		 * @p_skinElement	(ISkinElementBase)
		 * @return	void
		 */
		public function initControlBarInstance( p_skinElement:ISkinElementBase, element:DisplayElement ):void
		{
			trace("initControlBarInstance");
			
			_controlBar = p_skinElement as IControlBar;
			if( mediaContainer )
			{
				_controlBar.container = _container;
			}
			_controlBar.hasCaptions = hasCaptions;
			
			if( _mediaPlayerCore.duration )
			{
				_controlBar.duration = _mediaPlayerCore.duration;
			}
			
			var chaptersMetaData:Metadata = _mainElement.getMetadata( ChapterVO.CHAPTER_METADATA_NS );
			if( chaptersMetaData )
			{
				_controlBar.setChapters( chaptersMetaData.getValue( ChapterVO.CHAPTERS) as Vector.<IChapter> );
			}
			
			var pluginPlayerMetaData:Metadata = _mainElement.getMetadata( "com.realeyes.osmf.components.PluginPlayer" );
			if( pluginPlayerMetaData )
			{
				trace("pluginPlayerMetaData.getValue('isLive') " + pluginPlayerMetaData.getValue("isLive"));
				_controlBar.isLive = pluginPlayerMetaData.getValue("isLive");
			}
			
		//	autoHide = _controlBar.autoHide;
			
			
			_removeMediaPlayerListeners();
			
			_initMediaPlayerListeners();
			_initControlBarListeners();
			
			
			
			
			if( _mediaPlayerCore.bytesTotal )
			{
				_bytesTotal = _mediaPlayerCore.bytesTotal;
			}
			
			
			
			if( _mediaPlayerCore.playing )
			{
				_controlBar.currentState = PlayState.PLAYING;
			}
			else
			{
				_controlBar.currentState = PlayState.STOPPED;
			}
			
			
			
			
			if( _mediaPlayerCore.canBuffer )
			{
				_startBufferTimer();
			}
			else
			{
				_stopBufferTimer();
			}
			
			if( _mediaPlayerCore.isDynamicStream )
			{
				_controlBar.bitrateUpEnabled();
				_controlBar.bitrateDownEnabled();
			}
			else
			{
				_controlBar.bitrateUpDisabled();
				_controlBar.bitrateDownDisabled();
			}
			
			
		}
		
		/**
		 * Initialize the loading indicator
		 * 
		 * @param	p_skinElement	(ISkinElementBase)
		 * @return	void
		 */
		public function initLoadingIndicatorInstance( p_skinElement:ISkinElementBase, p_element:DisplayElement ):void
		{
			//var loaderIndicatorClass:Class = ApplicationDomain.currentDomain.getDefinition( p_class ) as Class;
			_loadingIndicator = p_skinElement as ILoadingIndicator;
			_loadingIndicatorElement = p_element;
			_loadingIndicator.visible = false;
		}
		
		/**
		 * Initialize the closed caption field
		 * 
		 * @param	p_skinElement	(ISkinElementBase)
		 * @return	void
		 */
		public function initClosedCaptionFieldInstance( p_skinElement:ISkinElementBase, p_element:DisplayElement ):void
		{
			
			//var closedCaptionFieldClass:Class = ApplicationDomain.currentDomain.getDefinition( p_class ) as Class;
			_closedCaptionField = p_skinElement as IClosedCaptionField;
			_closedCaptionElement = p_element;
			
			// Listen for captions being added.
			captionMetadata = _mainElement.getMetadata(CAPTIONING_TEMPORAL_METADATA_NAMESPACE) as TimelineMetadata;
			if (captionMetadata == null)
			{
				captionMetadata = new TimelineMetadata(_mainElement);
				_mainElement.addMetadata(CAPTIONING_TEMPORAL_METADATA_NAMESPACE, captionMetadata);
			}
			captionMetadata.addEventListener(TimelineMetadataEvent.MARKER_TIME_REACHED, _onShowCaption);
//			captionMetadata.addEventListener(TimelineMetadataEvent.MARKER_ADD, _onMarkerAdded);
			
			hasCaptions = true;
			
		}
		
		
		/////////////////////////////////////////////
		//  CONTROL METHODS
		/////////////////////////////////////////////
		
		/**
		 * Returns true if the given resource represents a streaming resource, false otherwise.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public static function isStreamingResource(resource:MediaResourceBase):Boolean
		{
			var result:Boolean = false;
			
			if (resource != null)
			{
				var urlResource:URLResource = resource as URLResource;
				if (urlResource != null)
				{
					result = isRTMPStream(urlResource.url);
								
					CONFIG::FLASH_10_1
					{
						if (result == false)
						{
							result = urlResource.getMetadataValue("http://www.osmf.org/httpstreaming/1.0") != null;
						}
					}
				}
			}
			
			return result;
		}
		
		/**
		 * Returns true if the given URL represents an RTMP stream, false otherwise.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public static function isRTMPStream(url:String):Boolean
		{
			var result:Boolean = false;
			
			if (url != null)
			{
				var theURL:URL = new URL(url);
				var protocol:String = theURL.protocol;
				if (protocol != null && protocol.length > 0)
				{
					result = (protocol.search(/^rtmp$|rtmp[tse]$|rtmpte$/i) != -1);
				}
			}
			
			return result;
		}
		
		
		public function loadFromXMLConfig( p_xml:XML ):void
		{
			//trace("player skin xml: " + p_xml);
			var skinConfig:SkinConfig = new SkinConfig( p_xml );
			
			trace("p_xml.@type: " + p_xml.@type);
			if(p_xml.@type == "internal")
			{
				_skinElements = skinConfig.getSkinElements();
				_generateSkin();
			}
			else
			{
				loadExternal( skinConfig.path, skinConfig.getSkinElements());	
			}
		}
		
		
		
		/**
		 * Loads in an external control bar SWF
		 * 
		 * @param	p_path			(String) URL for the SWF. Defaults to null.
		 * @param	p_skinElements	(Array) array of skin elements
		 * @param	p_useSecurity	(Boolean) should the SecurityDomain for loading be specified? (Defaults to false)			
		 * @return	void
		 */
		public function loadExternal( p_path:String, p_skinElements:Array, p_useSecurity:Boolean = false  ):void
		{
			_skinElements = p_skinElements;
			
			if( p_path || _path )
			{
				if( p_path )
				{
					//TODO: Remove Anti-cache before deploy
					_path = p_path; // + "?anticache=" + Math.random();
				}
				
				if( _loader == null)
				{
					_loader = new Loader();
					_loader.contentLoaderInfo.addEventListener( Event.COMPLETE, _skinLoadComplete );
					_loader.contentLoaderInfo.addEventListener( HTTPStatusEvent.HTTP_STATUS, _httpStatusHandler );
					_loader.contentLoaderInfo.addEventListener( Event.INIT, _initHandler );
					_loader.contentLoaderInfo.addEventListener( IOErrorEvent.IO_ERROR, _ioErrorHandler );

				}

				trace("loading control bar swf: " + _path );
				//TODO: figure how to handle cross domain files by adding SecurityDomain when not local.
				if( !p_useSecurity )
				{
					_loader.load( new URLRequest( _path ), new LoaderContext( false, ApplicationDomain.currentDomain ) );
				}
				else
				{
					_loader.load( new URLRequest( _path ), new LoaderContext( false, ApplicationDomain.currentDomain, SecurityDomain.currentDomain ) );
				}
			}
			else
			{
				throw( new Error( "No control bar path defined" ) );
			}
		}
		
		/**
		 * Calculates a percentage of two number
		 * 
		 * @param	p_current	(Number) the number whose percentage of a total you want
		 * @param	p_total		(Number) the total to compare the first value against
		 * @return	Number
		 */
		protected function _calcPercent( p_current:Number, p_total:Number ):Number
		{
			var p:Number = p_current / p_total;

			if( p > 1 )
			{
				return 1;
			}
			
			return p;
		}
		
		protected function _calcLoadPercentByBytes( bytesLoaded:uint ):void
		{
			_controlBar.setLoadBarPercent( _calcPercent( bytesLoaded, _mediaPlayerCore.bytesTotal ) );
		}
		
		/**
		 * Start monitoring the buffer time.
		 * 
		 * @return	void
		 */
		private function _startBufferTimer():void
		{
			if(_bufferTimer == null )
			{
				_bufferTimer = new Timer( _bufferInterval );
				_bufferTimer.addEventListener( TimerEvent.TIMER, _onBufferTimer );
			}
			
			if( !_bufferTimer.running )
			{
				trace("start buffer timer");
				_bufferTimer.start();
			}
			
		}
		
		/**
		 * Stop monitoring and displaying buffer time
		 * 
		 * @return	void
		 */
		private function _stopBufferTimer():void
		{
			if( _bufferTimer )
			{
				trace("stop buffer timer");
				_bufferTimer.stop();
				_controlBar.setLoadBarPercent( 0 );
			}
		}
		

		/**
		 * Hide the control bar
		 * 
		 * @return	void
		 */
		public function hideControlBar():void
		{
			_controlBar.visible = false;
		}
		

		/**
		 * Show the control bar
		 * 
		 * @return	void
		 */
		public function showControlBar():void
		{
			_controlBar.visible = true;
		}
		
		/**
		 * Populate the caption field in the control bar
		 * 
		 * @param	p_value	(String) the text to display in the caption field
		 * @return	void
		 */
		public function setClosedCaptionText( p_value:String, format:TextFormat = null ):void
		{
			if( _closedCaptionField )
			{
				_closedCaptionField.text = p_value;
			}
		}
		
		
		/**
		 * Enable or disable controls for bitrate switching
		 * 
		 * @return	void
		 */
		private function _checkDynamicStreamingIndex():void
		{
			if( _mediaPlayerCore.isDynamicStream && _controlBar )
			{
				
				if( _mediaPlayerCore.currentDynamicStreamIndex == 0 )
				{
					_controlBar.bitrateDownDisabled();
				}
				else if( _mediaPlayerCore.currentDynamicStreamIndex == _mediaPlayerCore.maxAllowedDynamicStreamIndex )
				{
					_controlBar.bitrateUpDisabled();
				}
				
				
			}
			
		}
		
		
		protected function checkAlternateAudio():void
		{
			trace("_mediaPlayerCore.hasAlternativeAudio: " + _mediaPlayerCore.hasAlternativeAudio);
			
			if(controlBar.hasAlternateAudio != _mediaPlayerCore.hasAlternativeAudio)
			{
				
				if( controlBar.hasAlternateAudio = _mediaPlayerCore.hasAlternativeAudio ) //set and check if true
				{
					
					for (var index:uint = 0; index < _mediaPlayerCore.numAlternativeAudioStreams; index++)
					{
						var item:StreamingItem = _mediaPlayerCore.getAlternativeAudioItemAt(index);
						trace("[LBA] ", item.info.language, "]");
						
						controlBar.addAlternateAudioStream( 0,  item.info.language, item ); 
						
					}
				}
			}
			
		}
		
		/**
		 * Creates an instance of a skin element and then calls its init method 
		 * 
		 * @param	p_skinElement	(SkinElement)
		 * @return	void
		 */
		public function generateSkinInstance( p_skinElement:SkinElement ):void
		{
			var instance:ISkinElementBase;
			var element:DisplayElement;
			
			if( p_skinElement.elementClassString )
			{
				instance = _generateElements( p_skinElement );
				
				element = new DisplayElement( instance as Sprite );
				applyLayoutData( element, p_skinElement );
				
				if(instance.addToContainer)
				{
					this.addChild( element );
				}
				
				_skinElementInstances.push( instance );
				
				//if there is an init function call it and pass the instance
				if( p_skinElement.initMethodName )
				{
					this[ p_skinElement.initMethodName ]( instance, element );
				}
				
				
			}
		}
		
		/**
		 * Loops through the array of skin elements and 
		 * generates teh instances from the objects
		 * 
		 * @return	void
		 */
		protected function _generateSkin():void
		{
			if( _controlBar )
			{
				_removeControlBarListeners();
			}
			
			var len:uint = _skinElements.length;
			
			for( var i:uint = 0; i < len; i++ )
			{
				generateSkinInstance( _skinElements[ i ] );
			}
			
			
		}
		
		/////////////////////////////////////////////
		//  GETTER/SETTERS
		/////////////////////////////////////////////
		
		protected function get mediaContainer():MediaContainer
		{
			return _container;
		}
		
		protected function set mediaContainer( value:MediaContainer ):void
		{
			
			_container = value as MediaContainer;
			
			if( _controlBar )
			{
				_controlBar.container = _container;
			}
			
			
		}
		
		protected function get _mediaPlayerShell():LayoutMetadata
		{
			return _mainElement.getMetadata( LayoutMetadata.LAYOUT_NAMESPACE ) as LayoutMetadata;
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
			
			if( _controlBar  )//&& _hasCaptionMarkers
			{
				_controlBar.hasCaptions = _hasCaptions;
			}
		}
		
		/**
		 * autoHide	
		 * Should the control bar hide automatically and show on mouseover?
		 * @return	Boolean
		 */
/*		public function get autoHide():Boolean
		{
			return _autoHide;
		}
		
		public function set autoHide( p_value:Boolean ):void
		{
			_autoHide = p_value;
			
			if( _autoHide )
			{
				if( _mainElement.container && _controlBar )
				{
					mediaContainer = _mainElement.container as MediaContainer;
					if( mediaContainer.stage ) 
					{
						_hideControlsTimer.reset();
						_hideControlsTimer.start();
					}
				}
				else
				{
//ISSUE - DOES NOT WORK - NEVER FIRES FOR SUB ELEMENT					
//					_mainElement.addEventListener( ContainerChangeEvent.CONTAINER_CHANGE, _onContainerChange, false, 0, true );
				}
				
			}
			else
			{
				if( _controlBar && _container && _container.hasEventListener( MouseEvent.MOUSE_MOVE ) )
				{
					_container.removeEventListener( MouseEvent.MOUSE_MOVE, _onControlBarMouseMove );
				}
				_hideControlsTimer.stop();
			}
			
		}*/
		
		public function get lastCurrentTime():Number
		{
			return _lastCurrentTime;
		}
		
		
		
		

		public function get playlistItem():PlaylistItem
		{
			return _playlistItem;
		}
		public function set playlistItem( value:PlaylistItem ):void
		{
			_playlistItem = value;
		}
		
		
		public function get controlBar():IControlBar
		{
			return _controlBar;
		}
		
		/////////////////////////////////////////////
		//  HANDLERS
		/////////////////////////////////////////////
		
		
		
		
		/**
		 * When the control bar has completed loading, initialize the setup.
		 * 
		 * @param	p_evt	(Event)
		 * @return	void
		 */
		private function _skinLoadComplete( p_evt:Event ):void 
		{
			_generateSkin();
		}
		
		/**
		 * When there is a server problem loading the control bar SWF...
		 * 
		 * @param	p_evt	(HTTPStatusEvent)
		 * @return	void
		 */
		private function _httpStatusHandler( p_evt:HTTPStatusEvent ):void 
		{
			trace("ControlBarContainer - httpStatusHandler: " + p_evt);
		}
		
		/**
		 * When there is a problem loading the control bar SWF...
		 * 
		 * @param	p_evt	(IOErrorEvent)
		 * @return	void
		 */
		private function _ioErrorHandler( p_evt:IOErrorEvent ):void 
		{
			trace("ControlBarContainer - ioErrorHandler: " + p_evt);
		}
		
		
		/**
		 * When the control bar has initialized ...
		 * 
		 * @param	p_evt	(Event)
		 * @return	void
		 */
		private function _initHandler( p_evt:Event):void 
		{
			trace("ControlBarContainer - initHandler: " + p_evt);
		}
		
		
		/**
		 * On stop click, tell the player to stop.
		 * 
		 * @param	p_evt	(ControlBarEvent) ControlBarEvent.STOP event
		 * @return	void
		 */
		protected function _onStop( p_evt:ControlBarEvent ):void
		{
			trace("core - stop");
			_mediaPlayerCore.stop();
		}
		
		/**
		 * On play click, tell the player to play.
		 * 
		 * @param	p_evt	(ControlBarEvent) ControlBarEvent.PLAY event
		 * @return	void
		 */
		protected function _onPlay( p_evt:ControlBarEvent ):void
		{
			trace("core - play");
			_mediaPlayerCore.play();
		}
		
		/**
		 * When the user seeks, tell the player to go to that percent
		 * 
		 * @param	p_evt	(ControlBarEvent) ControlBarEvent.SEEK event
		 * @return	void
		 */
		protected function _onSeekPercent( p_evt:ControlBarEvent ):void
		{
			trace("core - seek, percent: " + p_evt.value + ", duration: " + _mediaPlayerCore.duration );
			var time:Number = p_evt.value * _mediaPlayerCore.duration;
			if( _mediaPlayerCore.canSeek && _mediaPlayerCore.canSeekTo( time ) )
			{
				_mediaPlayerCore.seek( time );
			}
			p_evt.stopPropagation();
		}
		/**
		 * When the user seeks, tell the player to go to that point
		 * 
		 * @param	p_evt	(ControlBarEvent) ControlBarEvent.SEEK event
		 * @return	void
		 */
		protected function _onSeekTime( p_evt:ControlBarEvent ):void
		{
			trace("core - seek, time: " + p_evt.value + ", duration: " + _mediaPlayerCore.duration );
			if( _mediaPlayerCore.canSeek && _mediaPlayerCore.canSeekTo( p_evt.value ) )
			{
				_mediaPlayerCore.seek( p_evt.value );
			}
			p_evt.stopPropagation();
		}
		
		protected function _onSeekToLive( p_evt:ControlBarEvent ):void
		{
			trace("core - seek to live, duration: " + _mediaPlayerCore.duration );
			if( _mediaPlayerCore.canSeek && _mediaPlayerCore.canSeekTo( _mediaPlayerCore.duration ) )
			{
				_mediaPlayerCore.seek( _mediaPlayerCore.duration );
			}
			p_evt.stopPropagation();
		}
		
		/**
		 * On paise click, tell the player to pause.
		 * 
		 * @param	p_evt	(ControlBarEvent) ControlBarEvent.PAUSE event
		 * @return	void
		 */
		protected function _onPause( p_evt:ControlBarEvent ):void
		{
			trace("core - pause");
			_mediaPlayerCore.pause();
		}
		
		/**
		 * On mute click, tell the player to mute.
		 * 
		 * @param	p_evt	(ControlBarEvent) ControlBarEvent.MUTE event
		 * @return	void
		 */
		protected function _onMute( p_evt:ControlBarEvent ):void
		{
			_mediaPlayerCore.muted = true;
		}
		
		/**
		 * On unmute click, tell the player to unmute.
		 * 
		 * @param	p_evt	(ControlBarEvent) ControlBarEvent.UNMUTE event
		 * @return	void
		 */
		protected function _onUnMute( p_evt:ControlBarEvent ):void
		{
			_mediaPlayerCore.muted = false;
		}
		
		/**
		 * When the user uses the volume scrubber, change the volume
		 * 
		 * @param	p_evt	(ControlBarEvent) ControlBarEvent.VOLUME
		 * @return	void
		 */
		protected function _onVolumeChange( p_evt:ControlBarEvent ):void
		{
			trace("--volume value: " + p_evt.value);
			_mediaPlayerCore.volume = p_evt.value;
		}
		
		/**
		 * On volume up click, tell the player to raise the volume by a percent.
		 * 
		 * @param	p_evt	(ControlBarEvent) ControlBarEvent.VOLUME_UP event
		 * @return	void
		 */
		protected function _onVolumeUp( p_evt:ControlBarEvent ):void
		{
			if( (_mediaPlayerCore.volume + .1) >= 1 )
			{
				_mediaPlayerCore.volume = 1;
			}
			else
			{
				_mediaPlayerCore.volume = _mediaPlayerCore.volume + .1;
			}
		}
		
		/**
		 * On volume down click, tell the player to lower the volume by a percent.
		 * 
		 * @param	p_evt	(ControlBarEvent) ControlBarEvent.VOLUME_UP event
		 * @return	void
		 */
		protected function _onVolumeDown( p_evt:ControlBarEvent ):void
		{
			if( (_mediaPlayerCore.volume - .1) <= 0 )
			{
				_mediaPlayerCore.volume = 0;
			}
			else
			{
				_mediaPlayerCore.volume = _mediaPlayerCore.volume - .1;
			}
		}
		
		/**
		 * On full screen click, tell the player to go fullscreen.
		 * 
		 * @param	p_evt	(ControlBarEvent) ControlBarEvent.FULL_SCREEN event
		 * @return	void
		 */
		protected function _onFullScreen( p_evt:ControlBarEvent ):void
		{
			trace("SkinContainer - ON FULL SCREEN");
			this.dispatchEvent( p_evt );
		}
		
		
		/**
		 * On full screen toggle, tell the player to leave fullscreen.
		 * 
		 * @param	p_evt	(ControlBarEvent) ControlBarEvent.FULL_SCREEN_RETURN event
		 * @return	void
		 */
		protected function _onFullscreenReturn( p_evt:ControlBarEvent ):void
		{
			trace("SkinContainer - ON FULL SCREEN RETURN");
			this.dispatchEvent( p_evt );
		}
		
		
/*protected function _onShellMouseMove( event:MouseEvent ):void
{
	showControls();
	
	_hideControlsTimer.reset();
	_hideControlsTimer.start();
}*/
		
		
		/**
		 * On captioning toggle, display the caption field
		 * 
		 * @param	p_evt	(ControlBarEvent) ControlBarEvent.SHOW_CLOSEDCAPTION event
		 * @return	void
		 */
		protected function _onShowClosedcaption( p_evt:ControlBarEvent ):void
		{
			//_closedCaptionField.visible = true;
			this.addChild( _closedCaptionElement );
			this.dispatchEvent( p_evt.clone() );
		}
		
		
		/**
		 * On captioning toggle, hide the caption field
		 * 
		 * @param	p_evt	(ControlBarEvent) ControlBarEvent.HIDE_CLOSEDCAPTION event
		 * @return	void
		 */
		protected function _onHideClosedCaption( p_evt:ControlBarEvent ):void
		{
			//_closedCaptionField.visible = false;	
			this.removeChild( _closedCaptionElement );
			setClosedCaptionText( "" );
			this.dispatchEvent( p_evt.clone() );
		}
		
		
		/*protected function _onMarkerAdded(event:TimelineMetadataEvent):void
		{
			_hasCaptionMarkers = true;
			if( _controlBar && hasCaptions && _hasCaptionMarkers )
			{
				_controlBar.hasCaptions = _hasCaptions;
			}
		}*/
		
		protected function _onShowCaption(event:TimelineMetadataEvent):void
		{
			var caption:Caption = event.marker as Caption;
			setClosedCaptionText( caption.text, formatCaption(caption) );
			
		}
		
		/**
		 * Handles formatting within the caption string.
		 */
		private function formatCaption(caption:Caption):TextFormat
		{
			for (var i:uint = 0; i < caption.numCaptionFormats; i++) 
			{
				var captionFormat:CaptionFormat = caption.getCaptionFormatAt(i);
				var txtFormat:TextFormat = new TextFormat();
				var style:CaptionStyle = captionFormat.style;
				
				if (style.textColor != null) 
				{
					txtFormat.color = style.textColor;
				}
				
				if (style.fontFamily != "") 
				{
					txtFormat.font = style.fontFamily;
				}
				
				if (style.fontSize > 0) 
				{
					txtFormat.size = style.fontSize;
				}
				
				if (style.fontStyle != "") 
				{
					txtFormat.italic = (style.fontStyle == "italic") ? true : false;
				}
				
				if (style.fontWeight != "") 
				{
					txtFormat.bold = (style.fontWeight == "bold") ? true : false;
				}
				
				if (style.textAlign != "") 
				{
					txtFormat.align = style.textAlign;
				}
				
			}	
			return txtFormat;
		}
		
		
		
		/**
		 * When the user switches streams, check to see if we are at the highest
		 * or lowest stream and enabled bitrate controls accordingly.
		 * 
		 * @param	p_evt	(SwitchEvent)
		 * @return	void
		 */
		protected function _onSwitchChange( p_evt:DynamicStreamEvent ):void
		{
			//TODO: Need to verify p_evt.switching is the equiv of old p_evt.newState == SwitchEvent.SWITCHSTATE_COMPLETE
			if( !p_evt.switching )
			{
				if( _mediaPlayerCore.currentDynamicStreamIndex != 0 )
				{
					_controlBar.bitrateDownEnabled();
				}
				
				if( _mediaPlayerCore.currentDynamicStreamIndex != _mediaPlayerCore.maxAllowedDynamicStreamIndex )
				{
					_controlBar.bitrateUpEnabled();
				}
				
			}
		}
		
		/**
		 * On bitrate up click, tell the player to play a higher bitrate stream. Disable
		 * bitrate change buttons if necessary. Disables auto switching.
		 * 
		 * @param	p_evt	(ControlBarEvent) ControlBarEvent.BITRATE_UP event
		 * @return	void
		 */
		protected function _onBitrateUp( p_evt:ControlBarEvent ):void
		{
			trace("SWITCH UP");
			
			if( _mediaPlayerCore.autoDynamicStreamSwitch )
			{
				_mediaPlayerCore.autoDynamicStreamSwitch = false;
			}
			
			_mediaPlayerCore.switchDynamicStreamIndex( _mediaPlayerCore.currentDynamicStreamIndex + 1 );
			_controlBar.bitrateUpDisabled();
			_controlBar.bitrateDownDisabled();
			
		}
		
		/**
		 * On bitrate down click, tell the player to play a lower bitrate stream. Disable
		 * bitrate change buttons if necessary. Disables auto switching.
		 * 
		 * @param	p_evt	(ControlBarEvent) ControlBarEvent.BITRATE_UP event
		 * @return	void
		 */
		protected function _onBitrateDown( p_evt:ControlBarEvent ):void
		{
			trace("SWITCH DOWN");
			
			if( _mediaPlayerCore.autoDynamicStreamSwitch )
			{
				_mediaPlayerCore.autoDynamicStreamSwitch = false;
			}
			
			_mediaPlayerCore.switchDynamicStreamIndex( _mediaPlayerCore.currentDynamicStreamIndex - 1 );
			_controlBar.bitrateUpDisabled();
			_controlBar.bitrateDownDisabled();
			
		}
		
		/**
		 * Handle playlist next events
		 * 
		 * @param	event	PlaylistEvent (playlist next event)
		 * @return	void
		 */
		protected function _onPlaylistNext( event:PlaylistEvent ):void
		{
			dispatchEvent( event );
		}
		
		/**
		 * Handle playlist previous events
		 * 
		 * @param	event	PlaylistEvent (playlist previous event)
		 * @return	void
		 */
		protected function _onPlaylistPrev( event:PlaylistEvent ):void
		{
			dispatchEvent( event );
		}
		
		
		/**
		 * When the duration changes when media changes, update the display of the total time
		 * 
		 * @param	p_evt	(TimeEvent) TimeEvent.DURATION_CHANGE
		 * @return	void
		 */
		protected function _onDurationTimeChange( p_evt:TimeEvent ):void
		{
	//trace("dur time:" + _mediaPlayerCore.duration);		
			if( p_evt.time )
			{
				_controlBar.duration = Math.round( p_evt.time );
			}
		}
		
		/**
		 * Update the current time as progress events are received
		 * 
		 * @param	p_evt	(TimeEvent) TimeEvent.CURRENT_TIME_CHANGE
		 * @return	void
		 */
		protected function _onCurrentTimeChange( p_evt:TimeEvent ):void
		{
			//trace( '### ' + p_evt.time );
			_controlBar.currentTime = Math.round( p_evt.time );
			_controlBar.setCurrentBarPercent( _calcPercent( p_evt.time, _controlBar.duration ) );
			
			if( !isNaN( _controlBar.currentTime ) )
			{
				_lastCurrentTime = _controlBar.currentTime;
			}
		}
		
		
		/**
		 * Update the buffer bar.
		 * 
		 * @param	p_evt	(TimerEvent) TimerEvent.TIMER
		 * @return	void
		 */
		protected function _onBufferTimer( p_evt:TimerEvent ):void
		{
			if( _mediaPlayerCore.canBuffer )
			{
				/*
				trace("/////////_onBufferTimer//////////");
				trace("currentTime: " + _mediaPlayerCore.currentTime);
				trace("_mediaPlayerCore.bufferLength: " + _mediaPlayerCore.bufferLength);
				trace("_controlBar.duration: " + _controlBar.duration);
				trace("///////////////////");
				*/
				
				if( isStreamingResource( _mediaPlayerCore.media.resource ) )
				{
					_controlBar.setLoadBarPercent( _calcPercent( Math.ceil(_mediaPlayerCore.currentTime + _mediaPlayerCore.bufferLength), _controlBar.duration ) );
				}
				else
				{
					_calcLoadPercentByBytes( _mediaPlayerCore.bytesLoaded );
					
					
				}
			}
		}
		
		/**
		 * When the player's buffer changes ...
		 * 
		 * @param	p_evt	(BufferEvent) BufferEvent.BUFFER_CHANGED
		 * @return	void
		
		private function _onBufferingChange( p_evt:BufferEvent ):void
		{
			//p_evt.buffering
			if( _mediaPlayerCore.canBuffer )
			{
				//TODO - display buffering indicator
				
				trace("p_evt.buffering: " + p_evt.buffering);
				
				if( p_evt.buffering )
				{
					
				}
				else
				{
					
				}
			}
		} */
		
		
		/**
		 * As the media loads, display the loading progress via the load bar
		 * 
		 * @param	p_evt	(LoadEvent)
		 * @return	void
		 */
		protected function _onBytesLoadedChange( p_evt:LoadEvent ):void
		{
			_calcLoadPercentByBytes( p_evt.bytes );
			//_controlBar.setLoadBarPercent( _calcPercent( p_evt.bytes, _mediaPlayerCore.bytesTotal ) );
		}
		
		/**
		 * When beginning loading media, update the total bytes to load
		 * 
		 * @param	p_evt	(LoadEvent)
		 * @return	void
		 */
		protected function _onBytesTotalChange( p_evt:LoadEvent ):void
		{
			_bytesTotal = p_evt.bytes;
		}
		
		/**
		 * During non-progressive playback, stop buffer feedback when the media is
		 * paused or stopped, and start displaying buffer feedback when playing.
		 * 
		 * @param	p_evt	(PlayEvent)
		 * @return	void
		 */
		private function _onMediaStateChange( p_evt:PlayEvent ):void
		{
			_currentState = _controlBar.currentState = p_evt.playState;
			
			trace(">> STATE: " + _currentState);
			
			if( _mediaPlayerCore.canBuffer )
			{
			
				switch( _currentState )
				{
					//case PlayState.PAUSED :
					case PlayState.STOPPED :
					{
						_stopBufferTimer();
						break;
					}
					case PlayState.PLAYING :
					{
						
						_startBufferTimer();
						break;
					}
				}
			}
			
		}
		
		
		
		
		/**
		 * When the player's state changes, hide the loading indicator if the player is
		 * not buffering. Otherwise, show the loading indicator
		 * 
		 * @param	p_evt	(MediaPlayerStateChangeEvent)
		 * @return	void
		 */
		private function _onPlayerStateChange( p_evt:MediaPlayerStateChangeEvent ):void
		{
			if( _currentState == p_evt.state )//dont execute if same state
			{
				return;
			}
			
			_currentState = _controlBar.currentState = p_evt.state;
			//trace(">>>>>>> MEDIA PLAYER STATE: " + _currentState);
			
			
			/*
			if( p_evt.state == MediaPlayerState.BUFFERING || p_evt.state == MediaPlayerState.LOADING )
			{
				_loadingIndicator.visible = true;
			}
			else
			{
				_loadingIndicator.visible = false;
			}
			*/
			switch( p_evt.state )
			{
				case MediaPlayerState.LOADING :
				case MediaPlayerState.BUFFERING :
				{
					//_startBufferTimer();
					//TODO: once we figure out a workaround or Adobe fixes the bug, reintroduce the loading indicator
					//for live video. Currently the last event is always buffering.
//!_controlBar.isLive && //removed from if statement. May need to readd
					if( _loadingIndicator  && _mediaPlayerCore.currentTime > 0 )
					{
						_loadingIndicator.visible = true;
					}
					break;
				}
				case MediaPlayerState.READY :
				{
					//break;
					
				}
				case MediaPlayerState.PAUSED :
				case MediaPlayerState.PLAYING :
				{
					
					
					checkAlternateAudio();
					
					
					if( _loadingIndicator )
					{
						_loadingIndicator.visible = false;
					}
					_checkDynamicStreamingIndex();
					break;
				}
			}
			
		}
		
		
		private function _onIsDynamicStreamChange( p_evt:MediaPlayerCapabilityChangeEvent ):void
		{
			
			if( p_evt.enabled && _controlBar )
			{
				_controlBar.bitrateUpEnabled();
				_controlBar.bitrateDownEnabled();
			}
			else
			{
				_controlBar.bitrateUpDisabled();
				_controlBar.bitrateDownDisabled();
			}
			
		}
		
		
		
		protected function _onPlayerAudioStreamChange( event:AlternativeAudioEvent ):void
		{
			controlBar.audioIsSwitching = event.switching;
		}
		
		protected function _onSwitchAudio( event:ControlBarEvent ):void
		{
			trace("SWITCHING TO AUDIO INDEX: " + event.value);
			_mediaPlayerCore.switchAlternativeAudioIndex( event.value );
		}
		
		
		
		
		
		
		
		
/*		protected function _onContainerChange( event:ContainerChangeEvent ):void
		{
			if( event.newContainer )
			{
				mediaContainer = event.newContainer as MediaContainer;
				if( _autoHide )
				{
					_hideControlsTimer.reset();
					_hideControlsTimer.start();
				}
			}
		}*/
	}
}