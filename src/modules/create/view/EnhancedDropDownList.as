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
	
	public class EnhancedDropDownList extends DropDownList
	{
		private var _sorter:SortingCollator  = new SortingCollator();
		private var _sortItems:Boolean;
		private var sortItemsChanged:Boolean;
		
		private var _resourceDataProvider:IList;
		private var resourceDataProviderChanged:Boolean;
		
		public function EnhancedDropDownList()
		{
			super();
			
		}
		
		protected function localeChangeHandler(event:Event):void{
			var items:IList = getLocalizedItems();
			if(dataProvider === items) return;
			trace("Selected item: "+ObjectUtil.toString(selectedItem));
			dataProvider = items;
		}
		
		override public function set dataProvider(value:IList):void{
			super.dataProvider=value;
			sortItemsChanged=true;
			invalidateProperties();
		}
		
		override protected function commitProperties():void{
			super.commitProperties();
			if(sortItemsChanged){
				sortItemsChanged=false;
				if(_sortItems){
					var oldSelectedItem:Object = selectedItem;
					//FIXME casting should be to parent of ArrayCollection and should also allow ArrayList
					(dataProvider as ArrayCollection).source.sort(localizedSorting);
				}
			}
			
			var item:Object = getWidestItem();
			if(item){
				this.typicalItem = item;
				invalidateDisplayList();
			}
		}
		
		protected function getLocalizedItems():IList{
			var copyResDP:IList = null;
			var dataList:IList = new ArrayCollection();
			var o:Object;
			var label:String;
			copyResDP= ObjectUtil.copy(resourceDataProvider) as IList;
			for (var i:int=0; i<copyResDP.length; i++){
				o = copyResDP.getItemAt(i);
				if(o is String){
					o = ResourceManager.getInstance().getString('myResources', o as String);
				} else {
					trace("Item is object: "+ObjectUtil.toString(o));
					if(o.hasOwnProperty(this.labelField)){
						o[this.labelField] = ResourceManager.getInstance().getString('myResources', o[this.labelField]);
						trace("Set the labelField property of the object to the translated value: "+ObjectUtil.toString(o));
					}
				}
				dataList.addItem(o);
			}
			return dataList;
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
			var text:String;
			for (var i:uint=0; i<this.dataProvider.length; i++){
				o = this.dataProvider.getItemAt(i);
				text = getItemLabel(o);
				textField.text = text ? text : "";
				if (textField.textWidth > twidth){
					twidth = textField.textWidth;
					widestItem = o;
				}
			}
			return widestItem;
		}
		
		protected function getItemLabel(item:Object):String{
			if(!item) return "";
			
			var label:String;
			if (this.labelFunction != null){
				label = this.labelFunction(item);
			} else{
				label = item.hasOwnProperty(this.labelField) ? item[this.labelField] : item as String;
			}
			return label;
		}
		
		[Bindable("resourceDataProviderChanged")]
		public function get resourceDataProvider():IList{
			return _resourceDataProvider;
		}
		
		public function set resourceDataProvider(value:IList):void
		{   
			if (resourceDataProvider === value)
				return;
			
			_resourceDataProvider=value;
			dataProvider = getLocalizedItems();
			ResourceManager.getInstance().addEventListener(Event.CHANGE, localeChangeHandler);
			
			dispatchEvent(new Event("resourceDataProviderChanged"));
		}
		
		public function set sortItems(value:Boolean):void{
			if (value == _sortItems)
				return;
			
			_sortItems=value;
			sortItemsChanged = true;
			invalidateProperties();
		}
		
		public function get sortItems():Boolean{
			return _sortItems;
		}
	}
}