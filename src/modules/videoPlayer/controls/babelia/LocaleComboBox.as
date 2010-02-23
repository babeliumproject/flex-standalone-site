package modules.videoPlayer.controls.babelia
{
	import modules.videoPlayer.events.babelia.SubtitleComboEvent;
	import modules.videoPlayer.controls.SkinableComponent;
	
	import mx.collections.ArrayCollection;
	import mx.controls.ComboBox;
	import mx.core.UIComponent;
	import flash.display.Sprite;
	import flash.events.Event;
	
	public class LocaleComboBox extends SkinableComponent
	{
		/**
		 * Skin constants
		 */
		public static const BG_COLOR:String = "bgColor";
		
		private var _bg:Sprite;
		private var _languageBox:ComboBox;
		private var _boxWidth:Number = 100;
		private var _boxHeight:Number = 20;
		private var _boxColor:uint = 0xFFFFFF;
		private var _defaultHeight:Number = 20;
		
		public function LocaleComboBox()
		{
			super("LocaleComboBox"); // Required for setup skinable component
			
			_bg = new Sprite();
			addChild(_bg);

			_languageBox = new ComboBox();
			_languageBox.addEventListener(Event.CHANGE, onChange);
			addChild( _languageBox );

			resize(_boxWidth, _boxHeight);
		}
		
		override public function availableProperties(obj:Array = null) : void
		{
			super.availableProperties([BG_COLOR]);
		}
		
		public function resize(width:Number, height:Number) : void
		{
			
			this.width = width;
			this.height = height;
			
			CreateBG( width, height );
			
			_languageBox.x = 2;
			_languageBox.y = 2;
			_languageBox.width = width-5;
			_languageBox.height = height-5;
		}
		
		private function onChange(e:Event) : void
		{
			this.dispatchEvent(new SubtitleComboEvent(SubtitleComboEvent.SELECTED_CHANGED,
										_languageBox.selectedIndex));
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
			_bg.graphics.clear();
			_bg.graphics.beginFill( getSkinColor(BG_COLOR) );
			_bg.graphics.drawRect( 0, 0, bgWidth, bgHeight );
			_bg.graphics.endFill();		
		}
	}
}