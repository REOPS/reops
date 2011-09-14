package com.realeyes.osmf.elements
{
	import com.realeyes.osmf.model.buffer.BufferManagerModel;
	import com.realeyes.osmf.net.RENetStreamBufferTrait;
	import com.realeyes.osmf.utils.net.NetStreamUtils;
	
	import flash.net.NetStream;
	
	import org.osmf.elements.VideoElement;
	import org.osmf.events.MediaElementEvent;
	import org.osmf.events.TimeEvent;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.net.NetLoader;
	import org.osmf.traits.BufferTrait;
	import org.osmf.traits.LoaderBase;
	import org.osmf.traits.MediaTraitType;
	import org.osmf.traits.TimeTrait;
	
	public class BufferedVideoElement extends VideoElement
	{
		protected var bufferModel:BufferManagerModel;
		public var duration:Number = -1;
		public var timeTrait:TimeTrait;
		
		public function BufferedVideoElement(resource:MediaResourceBase=null, loader:NetLoader=null, bufferModel:BufferManagerModel = null )
		{
			super(resource, loader);
			
			//Without a buffer model, this functions just like a video element
			if( bufferModel )
			{
				this.bufferModel = bufferModel;
				addEventListener( MediaElementEvent.TRAIT_ADD, _onTraitAdded );
			}
		}
		
		protected function applyDurationToBufferModel():void
		{
			if( hasTrait( MediaTraitType.BUFFER ) )
			{
				var bufferingTrait:RENetStreamBufferTrait = getTrait( MediaTraitType.BUFFER ) as RENetStreamBufferTrait;
				if( bufferingTrait )
				{
					bufferingTrait.videoDuration = duration;
				}
			}
		}
		
		protected function _onTraitAdded( event:MediaElementEvent ):void
		{
			if( event.traitType == MediaTraitType.BUFFER )
			{
				var elementLoader:LoaderBase = loader;
				
				//If the buffer trait is not our custom buffer trait, remove it and replace it with our own
				var currentBufferTrait:BufferTrait = getTrait( MediaTraitType.BUFFER ) as BufferTrait;
				if( !(currentBufferTrait is RENetStreamBufferTrait ) )
				{
					removeTrait( MediaTraitType.BUFFER );
					if( elementLoader.hasOwnProperty( 'netStream' ) )
					{
						//Because we have to deal with multiple classes and can't affect the base class
						//to add there, we need to do this dynamically. TODO: fix if we can do better
						var netStream:NetStream = elementLoader[ 'netStream' ];
						var newBufferTrait:RENetStreamBufferTrait = new RENetStreamBufferTrait( netStream, bufferModel );
						if( !isNaN( duration ) && duration >= 0 )
						{
							newBufferTrait.videoDuration = duration;
						}
						addTrait( MediaTraitType.BUFFER, newBufferTrait );
					}
				}
			}
			else if( event.traitType == MediaTraitType.TIME )
			{
				timeTrait = getTrait( MediaTraitType.TIME ) as TimeTrait;
				
				if( isNaN( timeTrait.duration ) )
				{
					timeTrait.addEventListener( TimeEvent.DURATION_CHANGE, _onDurationChange );
				}
				else
				{
					duration = timeTrait.duration;
					applyDurationToBufferModel();
				}
				
			}
		}
		
		protected function _onDurationChange( event:TimeEvent ):void
		{
			duration = event.time;
			applyDurationToBufferModel();
		}
	}
}