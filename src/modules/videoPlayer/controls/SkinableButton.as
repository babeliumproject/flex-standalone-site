package modules.videoPlayer.controls
{	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	import mx.core.UIComponent;

	public class SkinableButton extends SkinableComponent
	{
		/**
		 * Skin related constants
		 */
		public static const BG_COLOR:String = "bgColor";
		public static const OVERBG_COLOR:String = "overBgColor";
		public static const ICON_COLOR:String = "iconColor";

		/**
		 * Variables
		 * 
		 */
		private var bg:Sprite;
		private var bgOver:Sprite;
		protected var btn:Sprite;
		
		
		public function SkinableButton(name:String = "SkinableButton")
		{
			super(name); // Required for setup skinable component
			
			this.height = 20;
			this.width = 20;
			
			bgOver = new Sprite();
			bg = new Sprite();
			btn = new Sprite();
			
			addChild( bgOver );
			addChild( bg );
			addChild( btn );
			
			this.buttonMode = true;
			this.useHandCursor = true;
			
			this.addEventListener( MouseEvent.ROLL_OVER, onMouseOver );
			this.addEventListener( MouseEvent.ROLL_OUT, onMouseOut );
			this.addEventListener( MouseEvent.CLICK, onClick );
		}
		
		
		
		override public function availableProperties(obj:Array = null) : void
		{
			super.availableProperties([BG_COLOR,OVERBG_COLOR,ICON_COLOR]);
		}
		
		/**
		 * Enable/disable stop button
		 **/
		override public function set enabled(flag:Boolean) : void
		{
			super.enabled = flag;
			
			this.buttonMode = flag;
			this.useHandCursor = flag;

			if ( flag )
			{
				this.addEventListener( MouseEvent.ROLL_OVER, onMouseOver );
				this.addEventListener( MouseEvent.ROLL_OUT, onMouseOut );
				this.addEventListener( MouseEvent.CLICK, onClick );
			}
			else
			{
				this.removeEventListener( MouseEvent.ROLL_OVER, onMouseOver );
				this.removeEventListener( MouseEvent.ROLL_OUT, onMouseOut );
				this.removeEventListener( MouseEvent.CLICK, onClick );
			}
			
			if ( bg ) onMouseOut(null);
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
			
			bgOver.graphics.clear();
			bgOver.graphics.beginFill( getSkinColor(OVERBG_COLOR) );
			bgOver.graphics.drawRect( 0, 0, 20, 20 );
			bgOver.graphics.endFill();
			
			bg.graphics.clear();
			bg.graphics.beginFill( getSkinColor(BG_COLOR) );
			bg.graphics.drawRect( 0, 0, 20, 20 );
			bg.graphics.endFill();

			btn.x = this.width/2 - btn.width/2;
			btn.y = this.height/2 - btn.height/2;
		}
				
		
		private function onMouseOver( e:MouseEvent ):void
		{
			bg.alpha = 0;
		}
		
		
		private function onMouseOut( e:MouseEvent ):void
		{
			bg.alpha = 1;
		}
		
		
		// NOTE: this methos is empty, but don't remove it
		protected function onClick( e:MouseEvent ) : void
		{
			// Nothing in superclass
		}
		
	}
}