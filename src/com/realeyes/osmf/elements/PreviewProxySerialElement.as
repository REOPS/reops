package com.realeyes.osmf.elements
{
	import com.realeyes.osmf.events.DebugEvent;
	
	import flash.display.Loader;
	import flash.events.DataEvent;
	import flash.external.ExternalInterface;
	
	import org.osmf.elements.ImageElement;
	import org.osmf.elements.ParallelElement;
	import org.osmf.elements.ProxyElement;
	import org.osmf.elements.SWFElement;
	import org.osmf.elements.SerialElement;
	import org.osmf.elements.VideoElement;
	import org.osmf.events.MediaElementEvent;
	import org.osmf.events.TimeEvent;
	import org.osmf.layout.LayoutMetadata;
	import org.osmf.layout.ScaleMode;
	import org.osmf.media.MediaElement;
	import org.osmf.media.URLResource;
	import org.osmf.net.StreamType;
	import org.osmf.net.StreamingURLResource;
	import org.osmf.traits.DisplayObjectTrait;
	import org.osmf.traits.MediaTraitType;
	import org.osmf.traits.TimeTrait;
	
	public class PreviewProxySerialElement extends ProxyElement
	{
		
		
		private var _path:String;
		private var _previewDuration:uint;
		private var _assetPath:String;
		private var _serialElement:SerialElement;
		
		private var _preRoll:VideoElement;
		private var _preview:VideoElement;
		private var _quiz:SWFElement;
		
		/** 
		 * Constructor - store the assetPath and the previewDuration
		 * @param assetPath
		 * @param previewDuration
		 * @param proxiedElement
		 * 
		 */		
		public function PreviewProxySerialElement( assetPath:String, previewDuration:Number, proxiedElement:MediaElement=null )
		{
			_assetPath = assetPath;
			_previewDuration = previewDuration;
			super( proxiedElement );
		}
		
		/**
		 * Called when the soure element is generated and passed through. May sometimes be null first time as class instantiates so better to check first
		 * @param value
		 * 
		 */		
		override public function set proxiedElement( value:MediaElement ):void
		{
			if( value )
			{
				//create the elements that will be used to construct the serial composition
				
				//basic preroll - hardcoded media, path could be passed on meta data as well
				_preRoll = new VideoElement( new URLResource( "http://mediapm.edgesuite.net/osmf/content/test/logo_animated.flv" ) );
				
				//store the path (URI) to the original content for use later if authorized for full playback
				_path = (value.resource as URLResource).url;
				
				//generate a subclip style preview of the main media content, clipped from the start time (0) to the _previewDuration
				_preview = new VideoElement( new StreamingURLResource( _path, StreamType.RECORDED, 0, _previewDuration ) );
				
				//create a SWF element for the _assetPath
				_quiz = new SWFElement( new URLResource( _assetPath ) );
				
				//listen for traits added to the SWFElement so we can get to the Loader and setup a listener on the SWF content
				_quiz.addEventListener(MediaElementEvent.TRAIT_ADD, _onQuizTraitAdded, false, 0, true );
				
				//construct serial composition of generated elements
				_serialElement = new SerialElement();
				_serialElement.addChild( _preRoll );
				_serialElement.addChild( _preview );
				_serialElement.addChild( _quiz );
				
				
				
				//Set the proxied element to the serial composition
				super.proxiedElement = _serialElement;
				
				
			}
		}
		
		/**
		 *Handler for when traits added to the quiz element - need to know when DisplayOnject is available 
		 * @param event
		 * 
		 */		
		private function _onQuizTraitAdded( event:MediaElementEvent ):void
		{
			//if this is true, it means we can refference the Loader DisplayObject used to contain the SWF
			if( event.traitType ==  MediaTraitType.DISPLAY_OBJECT)
			{
				var dispObj:Loader = ((event.target as SWFElement).getTrait( MediaTraitType.DISPLAY_OBJECT ) as DisplayObjectTrait).displayObject as Loader;
				
				//Listen for a 'quizAnswer' event from the SWF loaded from the _assetPath
				dispObj.addEventListener( "quizAnswer", _onUserAnswer, false, 0, true );
			}
		}
		
		private function _onUserAnswer( event:DataEvent ):void
		{
			this.dispatchEvent( new DebugEvent( DebugEvent.DEBUG, "USER ANSWER: " + event.data ) );
			
			//if the data property of the EventData caught from the quiz display object is "money" then play the full content!
			if( event.data == "money")
			{
				this.dispatchEvent( new DebugEvent( DebugEvent.DEBUG, "PASSPHRASE CORRECT - Media Unlocked!" ) );
				/*_serialElement.removeChild( _preRoll );
				_serialElement.removeChild( _preview );
				_serialElement.removeChild( _quiz );
				_serialElement.addChild( new VideoElement( new URLResource( _path ) ) );*/
				
				//NOTE!!! If you ever set the super.proxiedElement it resets whats playing - thats COOL!!!
				super.proxiedElement = new VideoElement( new StreamingURLResource( _path, StreamType.RECORDED, _previewDuration - 5  ) );
			}
			
		}
		
		// ==================================================
		// Helper methods
		// ==================================================
		
		
		
	}
}