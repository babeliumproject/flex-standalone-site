package modules.videoPlayer.controls.babelia
{
	import flash.display.Sprite;
	
	import modules.videoPlayer.controls.SkinableComponent;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Image;
	import mx.core.UIComponent;


	public class ArrowPanel extends SkinableComponent
	{
		/**
		 * Skin constants
		 */
		public static const BORDER_COLOR:String="borderColor";
		public static const BG_COLOR:String="bgColor";
		public static const HL_COLOR:String="hlColor";

		private var _bg:Sprite;
		private var _arrows:ArrayCollection;
		private var _dataProvider:ArrayCollection;
		private var _boxWidth:Number=500;
		private var _boxHeight:Number=50;
		private var _highlight:Boolean=false;

		public function ArrowPanel(state:Boolean=false)
		{
			super("ArrowPanel"); // Required for setup skinable component

			_bg=new Sprite();
			addChild(_bg);

			_arrows=new ArrayCollection();

			resize(_boxWidth, _boxHeight);
		}

		override public function availableProperties(obj:Array=null):void
		{
			super.availableProperties([BG_COLOR, BORDER_COLOR]);
		}

		public function resize(width:Number, height:Number):void
		{
			this.width=width;
			this.height=height;

			refresh();
		}
		
		override protected function updateDisplayList(w:Number, h:Number):void
		{
			if ( w != 0 ) width = w;
			if ( h != 0 ) height = h;
			
			CreateBG(width, height);
		}

		public function setArrows(data:ArrayCollection, duration:Number, role:String):void
		{
			_dataProvider=data;

			for each (var obj:Object in _dataProvider)
				doShowArrow(obj.time, duration, obj.role == role);
		}

		public function removeArrows():void
		{
			if (_arrows.length > 0)
			{
				while (_arrows.length > 0)
				{
					removeChildAt(1);
					_arrows.removeItemAt(0);
				}

				_dataProvider.removeAll();
			}
		}

		private function CreateBG(bgWidth:Number, bgHeight:Number):void
		{
			_bg.graphics.clear();

			_bg.graphics.beginFill(getSkinColor(BORDER_COLOR));
			_bg.graphics.drawRoundRect(0, 0, width, height, 12, 12);
			_bg.graphics.endFill();
			if ( !_highlight )
				_bg.graphics.beginFill(getSkinColor(BG_COLOR));
			else
				_bg.graphics.beginFill(getSkinColor(HL_COLOR));
			_bg.graphics.drawRoundRect(2, 2, width - 4, height - 4, 10, 10);
			_bg.graphics.endFill();
		}
		
		public function set highlight(flag:Boolean) : void
		{
			_highlight = flag;
			refresh();
		}

		private function doShowArrow(time:Number, duration:Number, flag:Boolean):void
		{
			var arrow:Image=new Image();
			if (flag)
				arrow.source="resources/images/fletxa_gorri.png";
			else return;
			//	arrow.source="resources/images/fletxa_beltza.png";

			/*************************************
			 *    \/  (0)
			 *  _________________________________
			 * |__|______________________________|
			 * 0                               duration
			 * 
			 * arrow's width: 17px
			 * scrubber's width: 10px
			 * margins: ~5px (left) ~5px (right)
			 * ***********************************/
			var margin:int = 5;
			var scrubberW:int = 10;
			
			arrow.width=17;
			arrow.height=35;
			arrow.x=time * (width-scrubberW - margin*2) / duration + 
							(margin + scrubberW - arrow.width/2 -1); // -1 
			arrow.y=4;

			_arrows.addItem(arrow);
			addChild(arrow);
		}
	}
}