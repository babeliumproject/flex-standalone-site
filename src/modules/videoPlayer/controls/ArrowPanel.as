package modules.videoPlayer.controls
{
	import mx.controls.Alert;
	import mx.controls.Image;
	import mx.core.UIComponent;
	import flash.display.Sprite;
	
	
	public class ArrowPanel extends UIComponent
	{
		private var _bg:Sprite;
		private var _arrows:Array;
		private var _dataProvider:Array;
		private var _boxWidth:Number = 500;
		private var _boxHeight:Number = 50;
		private var _defaultHeight:Number = 20;
		
		public function ArrowPanel(state:Boolean = false)
		{
			super();

			_arrows = new Array();

			resize(_boxWidth, _boxHeight);
		}
		
		public function resize(width:Number, height:Number) : void
		{
			while ( numChildren > 0 ) removeChildAt(0);
			
			this.width = width;
			this.height = height;
			
			CreateBG( width, height );
			
			for each ( var img:Image in _arrows )
				addChild(img);
		}
		
		public function setArrows(data:Array, duration:Number, role:String) : void
		{
			_dataProvider = data;
			
			for each ( var obj:Object in _dataProvider )
				doShowArrow(obj[0], duration, obj[1] == role);
		}
		
		public function removeArrows() : void
		{
			while ( _arrows.length > 0 )
			{
				removeChildAt(1);
				_dataProvider.pop();
				_arrows.pop();
			}
		}
		
		private function CreateBG( bgWidth:Number, bgHeight:Number ):void
		{
			_bg = new Sprite();
			_bg.graphics.beginFill( 0x000000 );
			_bg.graphics.drawRoundRect(0, 0, width, height, 12, 12);
			_bg.graphics.endFill();
			_bg.graphics.beginFill( 0x343434 );
			_bg.graphics.drawRoundRect(2, 2, width-4, height-4, 10, 10);
			_bg.graphics.endFill();
			addChildAt(_bg, 0);
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

			_arrows.push(arrow);
			addChild(arrow);			
		}
	}
}