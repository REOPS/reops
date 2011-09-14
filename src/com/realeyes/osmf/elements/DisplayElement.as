package com.realeyes.osmf.elements
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	
	import org.osmf.events.DisplayObjectEvent;
	import org.osmf.layout.LayoutMetadata;
	import org.osmf.media.MediaElement;
	import org.osmf.media.MediaFactory;
	import org.osmf.traits.DisplayObjectTrait;
	import org.osmf.traits.MediaTraitType;
	import org.osmf.traits.PlayState;
	import org.osmf.traits.PlayTrait;
	
	public class DisplayElement extends MediaElement
	{
		
		public var sprite:Sprite;
			
		public function DisplayElement( p_disp:Sprite = null )
		{
			super();
			
			if( p_disp )
			{
				initDisplayElement( p_disp );
			}
		}
		
		protected function initDisplayElement( p_disp:Sprite ):void 
		{
			sprite = p_disp;
			var displayTrait:DisplayObjectTrait = new DisplayObjectTrait( p_disp, p_disp.width, p_disp.height  );
			addTrait( MediaTraitType.DISPLAY_OBJECT, displayTrait );
			
			displayTrait.addEventListener( DisplayObjectEvent.DISPLAY_OBJECT_CHANGE, _onDisplayObjectChange);
		}

		protected function _onDisplayObjectChange(event:DisplayObjectEvent):void
		{
			trace( "Display Object Change in DisplayElement" )
		}

		
	}
}