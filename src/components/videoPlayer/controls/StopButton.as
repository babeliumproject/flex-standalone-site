package components.videoPlayer.controls
{
	import components.videoPlayer.events.StopEvent;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;

	public class StopButton extends DictionarySkinnableButton
	{		
		public function StopButton()
		{
			super("StopButton");
		}
		
		override public function dispose():void{
			super.dispose();
			
			//There are no objects that need to be manually disposed
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList( unscaledWidth, unscaledHeight );
			
			createStopBtn();
			btn.x = this.width/2 - btn.width/2;
			btn.y = this.height/2 - btn.height/2;
			addChild(btn);
		}
		
		private function createStopBtn() : void
		{
			var g:Sprite = btn;
			g.graphics.clear();
			g.graphics.beginFill( getSkinColor(ICON_COLOR) );
			g.graphics.drawRect( 0, 0, 10, 10 );
			g.graphics.endFill();
		}

		override protected function onClick( e:MouseEvent ) : void
		{
			dispatchEvent( new StopEvent( StopEvent.STOP_CLICK ) );
		}
		
	}
}
