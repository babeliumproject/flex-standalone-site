package modules.videoPlayer.controls
{
	import mx.collections.ArrayCollection;
	import mx.controls.ComboBox;
	import mx.core.UIComponent;
	import flash.display.Sprite;
	
	public class LocaleComboBox extends UIComponent
	{
		private var _bg:Sprite;
		private var _languageBox:ComboBox;
		private var _boxWidth:Number = 100;
		private var _boxHeight:Number = 20;
		private var _boxColor:uint = 0xFFFFFF;
		private var _defaultHeight:Number = 20;
		
		public function LocaleComboBox()
		{
			super();

			resize(_boxWidth, _boxHeight);
		}
		
		public function resize(width:Number, height:Number) : void
		{
			while ( numChildren > 0 ) removeChildAt(0);
			
			this.width = width;
			this.height = height;
			
			CreateBG( width, height );
			
			if ( _languageBox == null )
				_languageBox = new ComboBox();
			
			_languageBox.x = 2;
			_languageBox.y = 2;
			_languageBox.width = width-5;
			_languageBox.height = height-5;
			addChild( _languageBox );
		}
		
		public function setDataProvider(dataProvider:ArrayCollection) : void
		{
			_languageBox.dataProvider = dataProvider;
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			//super.updateDisplayList( unscaledWidth, unscaledHeight );
		}
		
		private function CreateBG( bgWidth:Number, bgHeight:Number ):void
		{
			_bg = new Sprite();
			_bg.graphics.beginFill( 0x343434 );
			_bg.graphics.drawRect( 0, 0, bgWidth, bgHeight );
			_bg.graphics.endFill();
			addChild(_bg);
			
		}
	}
}