package modules.videoPlayer.controls
{
	import modules.videoPlayer.events.StopEvent;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	import mx.core.UIComponent;

	public class StopButton extends UIComponent
	{
		/**
		 * Variables
		 * 
		 */
		 
		 
		private var bg:Sprite;
		private var bgOver:Sprite;
		
		
		public function StopButton()
		{
			super();
			
			this.height = 20;
			this.width = 20;
			
			this.buttonMode = true;
			this.useHandCursor = true;
			
			this.addEventListener( MouseEvent.ROLL_OVER, onMouseOver );
			this.addEventListener( MouseEvent.ROLL_OUT, onMouseOut );
			this.addEventListener( MouseEvent.CLICK, onClick );
		}
		
		
		/**
		 * Methods
		 * 
		 */
		
		
		/** OVERRIDEN */
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList( unscaledWidth, unscaledHeight );
			
			this.graphics.clear();
			
			bgOver = new Sprite();
			bgOver.graphics.beginFill( 0x454545 );
			bgOver.graphics.drawRect( 0, 0, 20, 20 );
			bgOver.graphics.endFill();
			
			addChild( bgOver );
			
			bg = new Sprite();
			bg.graphics.beginFill( 0x343434 );
			bg.graphics.drawRect( 0, 0, 20, 20 );
			bg.graphics.endFill();
			
			addChild( bg );
			
			
			var btn:Sprite = new Sprite();
			btn = createStopBtn();
			btn.x = this.width/2 - btn.width/2;
			btn.y = this.height/2 - btn.height/2;
			
			addChild( btn );
		}
		
		
		private function createStopBtn():Sprite
		{
			var g:Sprite = new Sprite();
			g.graphics.beginFill( 0xffffff );
			g.graphics.drawRect( 0, 0, 8, 8 );
			g.graphics.endFill();
			
			return g;
		}
		
		
		private function onMouseOver( e:MouseEvent ):void
		{
			bg.alpha = 0;
		}
		
		
		private function onMouseOut( e:MouseEvent ):void
		{
			bg.alpha = 1;
		}
		
		
		private function onClick( e:MouseEvent ):void
		{
			dispatchEvent( new StopEvent( StopEvent.STOP_CLICK ) );
		}
		
	}
}