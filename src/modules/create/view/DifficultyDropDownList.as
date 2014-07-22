package modules.create.view
{
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import mx.collections.ArrayCollection;
	import mx.collections.IList;
	import mx.events.CollectionEvent;
	import mx.events.FlexEvent;
	import mx.resources.ResourceManager;
	import mx.utils.ObjectUtil;
	
	import spark.components.DropDownList;
	import spark.globalization.SortingCollator;
	
	public class DifficultyDropDownList extends DropDownList
	{
		private var _sorter:SortingCollator;
		private var _sortItems:Boolean;
		
		public function DifficultyDropDownList()
		{
			super();
			ResourceManager.getInstance().addEventListener(Event.CHANGE, localeChangeHandler);
		}
		
		protected function localeChangeHandler(event:Event):void{
			getLocalizedItems();
			if(_sortItems){
				dataProvider.toArray().sort(localizedSorting);
			}
		}
		
		override public function set dataProvider(value:IList):void{
			super.dataProvider = value;
			getLocalizedItems();
			if(_sortItems){
				dataProvider.toArray().sort(localizedSorting);
			}
		}
		
		protected function getLocalizedItems():Array{
			var _dataList:Array = new Array();
			var o:Object;
			var label:String;
			for (var i:int=0; i<dataProvider.length; i++){
				o = this.dataProvider.getItemAt(i);
				label = getItemLabel(o);
				if(label)
					_dataList.push(ResourceManager.getInstance().getString('myResources', label));
			}
			return _dataList;
		}
		
		override protected function dataProvider_collectionChangeHandler(event:Event):void{
			super.dataProvider_collectionChangeHandler(event);
			var item:Object = getWidestItem();
			if(item) this.typicalItem = item;
		}
		
		protected function localizedSorting(item1:Object, item2:Object):int{
			var label1:String = getItemLabel(item1);
			var label2:String = getItemLabel(item2);
			_sorter.setStyle('locale',ResourceManager.getInstance().localeChain[0]);
			_sorter.ignoreCase=true;
			return _sorter.compare(label1,label2);
		}
		
		protected function getWidestItem():Object{
			var widestItem:Object = null;
			var twidth:uint = this.minWidth;
			var format:TextFormat = new TextFormat();
			format.font = this.getStyle("font-family");
			format.size = this.getStyle("font-size");
			var textField:TextField = new TextField;
			textField.setTextFormat(format);
			
			var o:Object;
			for (var i:uint=0; i<this.dataProvider.length; i++){
				o = this.dataProvider.getItemAt(i);
				textField.text = getItemLabel(o);
				if (textField.textWidth > twidth){
					twidth = textField.textWidth;
					widestItem = o;
				}
			}
			return widestItem;
		}
		
		protected function getItemLabel(item:Object):String{
			if(!item) return null;
			
			var label:String;
			if (this.labelFunction != null){
				label = this.labelFunction(item);
			} else{
				label = item.hasOwnProperty(this.labelField) ? item[this.labelField] : item as String;
			}
			return label;
		}
		
		public function set sortItems(value:Boolean):void{
			if(value){
				_sorter = new SortingCollator();
			} else {
				_sorter = null;
			}
			_sortItems;
		}
		
		public function get sortItems():Boolean{
			return _sortItems;
		}
	}
}