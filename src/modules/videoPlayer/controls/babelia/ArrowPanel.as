package modules.videoPlayer.controls.babelia
{
	import mx.collections.ArrayCollection;
	import mx.controls.Image;
	import mx.controls.Alert;
	import mx.core.UIComponent;
	import flash.display.Sprite;
	import modules.videoPlayer.controls.SkinableComponent;
	
	
	public class ArrowPanel extends SkinableComponent
	{
		/**
		 * Skin constants
		 */
		public static const BORDER_COLOR:String = "borderColor";
		public static const BG_COLOR:String = "bgColor";
		
		private var _bg:Sprite;
		private var _arrows:ArrayCollection;
		private var _dataProvider:ArrayCollection;
		private var _boxWidth:Number = 500;
		private var _boxHeight:Number = 50;
		
		public function ArrowPanel(state:Boolean = false)
		{
			super("ArrowPanel"); // Required for setup skinable component
			
			_bg = new Sprite();
			addChild(_bg);

			_arrows = new ArrayCollection();

			resize(_boxWidth, _boxHeight);
		}
		
		override public function availableProperties(obj:Array = null) : void
		{
			super.availableProperties([BG_COLOR,BORDER_COLOR]);
		}
		
		public function resize(width:Number, height:Number) : void
		{
			this.width = width;
			this.height = height;
			
			CreateBG( width, height );
		}
		
		public function setArrows(data:ArrayCollection, duration:Number, role:String) : void
		{
			_dataProvider = data;
			
			for each ( var obj:Object in _dataProvider )
				doShowArrow(obj.time, duration, obj.role == role);
		}
		
		public function removeArrows() : void
		{
			while ( _arrows.length > 0 )
			{
				removeChildAt(1);
				_arrows.removeItemAt(0);
			}
			
			_dataProvider.removeAll();
		}
		
		private function CreateBG( bgWidth:Number, bgHeight:Number ):void
		{
			_bg.graphics.clear();
			
			//Alert.show(getSkinColor(BORDER_COLOR).toString());
			
			_bg.graphics.beginFill( getSkinColor(BORDER_COLOR) );
			_bg.graphics.drawRoundRect(0, 0, width, height, 12, 12);
			_bg.graphics.endFill();
			_bg.graphics.beginFill( getSkinColor(BG_COLOR) );
			_bg.graphics.drawRoundRect(2, 2, width-4, height-4, 10, 10);
			_bg.graphics.endFill();
		}
		
		private function doShowArrow(time:Number, duration:Number, flag:Boolean) : void
		{
			var arrow:Image = new Image();
			if ( flag )
				arrow.source="resources/images/fletxa_gorri.png";
			else
				arrow.source="resources/images/fletxa_beltza.png";

			arrow.x = time * this.width / duration - 3; // TODO 3
			arrow.y = 4;
			arrow.width = 17;
			arrow.height = 35;

			_arrows.addItem(arrow);
			addChild(arrow);			
		}
	}
}