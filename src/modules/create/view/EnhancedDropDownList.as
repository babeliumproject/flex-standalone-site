package modules.create.view
{
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.TextFormat;

	import mx.collections.ArrayCollection;
	import mx.collections.ICollectionView;
	import mx.collections.IList;
	import mx.collections.IViewCursor;
	import mx.collections.ListCollectionView;
	import mx.events.CollectionEvent;
	import mx.events.FlexEvent;
	import mx.resources.ResourceManager;
	import mx.utils.ObjectUtil;

	import spark.components.DropDownList;
	import spark.globalization.SortingCollator;

	public class EnhancedDropDownList extends DropDownList
	{
		private var _sorter:SortingCollator=new SortingCollator();
		private var _sortItems:Boolean;
		private var sortItemsChanged:Boolean;

		private var _localeAwareDataProvider:IList;
		private var _localeAwarePrompt:String;

		private var _indexField:String="code";

		private var localeAwarePromptChanged:Boolean;
		private var localeAwareDataProviderChanged:Boolean;
		private var indexFieldChanged:Boolean;

		private var oldSelectedItem:Object;

		[Bindable("localeAwareDataProviderChanged")]
		[Bindable("localeAwarePromptChanged")]
		[Bindable("indexFieldChanged")]

		public function EnhancedDropDownList()
		{
			super();
			ResourceManager.getInstance().addEventListener(Event.CHANGE, localeChangeHandler);
		}

		protected function localeChangeHandler(event:Event):void
		{
			if (localeAwareDataProvider)
			{
				updateLocalizedList();
			}
			if (localeAwarePrompt)
			{
				updateLocalizedPrompt();
			}
		}

		override public function set dataProvider(value:IList):void
		{
			if (selectedIndex != -1)
			{
				oldSelectedItem=this.selectedItem;
			}
			super.dataProvider=value;
			sortItemsChanged=true;
			invalidateProperties();
		}

		override protected function commitProperties():void
		{
			if (sortItemsChanged)
			{
				sortItemsChanged=false;
				if (_sortItems)
				{
					//Save the internal sorting index before reordering the collection
					if (selectedIndex != -1)
					{
						var internalIndex:int=-1;
						if (oldSelectedItem && oldSelectedItem.hasOwnProperty(this.indexField))
						{
							internalIndex=oldSelectedItem[this.indexField];
						}
					}
					if (dataProvider && dataProvider.length)
					{
						//Sort the collection
						(dataProvider as ArrayCollection).source.sort(this.localizedSorting);
						//Restore the internal sorting index
						if(internalIndex !=-1){
							var collection:ICollectionView=new ListCollectionView(IList(dataProvider));
							var iterator:IViewCursor=collection.createCursor();
							while (!iterator.afterLast)
							{
								var item:Object=iterator.current;
								if (item && item.hasOwnProperty(this.indexField) && item[this.indexField] === internalIndex)
								{
									this.selectedItem=item;
									break;
								}
								iterator.moveNext();
							}
						}
					}	
				}
			}

			super.commitProperties();

			var widestItem:Object=getWidestItem();
			if (widestItem)
			{
				this.typicalItem=widestItem;
				invalidateDisplayList();
			}
		}

		private function updateLocalizedList():void
		{
			dataProvider=localizeList(_localeAwareDataProvider);
		}

		private function updateLocalizedPrompt():void
		{
			prompt=ResourceManager.getInstance().getString('myResources', _localeAwarePrompt);
		}

		protected function localizeList(value:IList):ArrayCollection
		{
			var localizedCollection:ArrayCollection=new ArrayCollection();
			if (value)
			{
				var collection:ICollectionView=new ListCollectionView(IList(value));
				var iterator:IViewCursor=collection.createCursor();
				while (!iterator.afterLast)
				{
					var item:Object=iterator.current;
					var itemCopy:Object=ObjectUtil.clone(item);
					if (item is String)
					{
						itemCopy=ResourceManager.getInstance().getString('myResources', (item as String));
					}
					else
					{
						if (item.hasOwnProperty(labelField))
						{
							itemCopy[labelField]=ResourceManager.getInstance().getString('myResources', item[labelField]);
						}
					}
					localizedCollection.addItem(itemCopy);

					iterator.moveNext();
				}
			}
			return localizedCollection;
		}

		protected function localizedSorting(item1:Object, item2:Object):int
		{
			var label1:String=getItemLabel(item1);
			var label2:String=getItemLabel(item2);
			_sorter.setStyle('locale', ResourceManager.getInstance().localeChain[0]);
			_sorter.ignoreCase=true;
			return _sorter.compare(label1, label2);
		}

		protected function getWidestItem():Object
		{
			var widestItem:Object=null;
			var twidth:uint=this.minWidth;
			var format:TextFormat=new TextFormat();
			format.font=this.getStyle("font-family");
			format.size=this.getStyle("font-size");
			var textField:TextField=new TextField;
			textField.setTextFormat(format);

			var o:Object;
			var text:String;
			if (this.dataProvider)
			{
				for (var i:uint=0; i < this.dataProvider.length; i++)
				{
					o=this.dataProvider.getItemAt(i);
					text=getItemLabel(o);
					textField.text=text ? text : "";
					if (textField.textWidth > twidth)
					{
						twidth=textField.textWidth;
						widestItem=o;
					}
				}
			}
			return widestItem;
		}

		protected function getItemLabel(item:Object):String
		{
			if (!item)
				return "";

			var label:String;
			if (this.labelFunction != null)
			{
				label=this.labelFunction(item);
			}
			else
			{
				label=item.hasOwnProperty(this.labelField) ? item[this.labelField] : item as String;
			}
			return label;
		}


		public function get localeAwareDataProvider():IList
		{
			return _localeAwareDataProvider;
		}

		public function set localeAwareDataProvider(value:IList):void
		{
			if (localeAwareDataProvider === value)
				return;

			_localeAwareDataProvider=value;
			localeAwareDataProviderChanged=true;

			dataProvider=localizeList(_localeAwareDataProvider);

			dispatchEvent(new Event("localeAwareDataProviderChanged"));
		}

		public function set localeAwarePrompt(value:String):void
		{
			if (localeAwarePrompt === value)
				return;
			_localeAwarePrompt=value;
			localeAwarePromptChanged=true;

			prompt=ResourceManager.getInstance().getString('myResources', _localeAwarePrompt);

			dispatchEvent(new Event("localeAwarePromptChanged"));
		}

		public function get localeAwarePrompt():String
		{
			return _localeAwarePrompt;
		}

		public function get indexField():String
		{
			return _indexField;
		}

		public function set indexField(value:String):void
		{
			if (value == _indexField)
				return;
			
			_indexField=value;
			indexFieldChanged=true;
			invalidateProperties();
		}

		public function set sortItems(value:Boolean):void
		{
			if (value == _sortItems)
				return;

			_sortItems=value;
			sortItemsChanged=true;
			invalidateProperties();
		}

		public function get sortItems():Boolean
		{
			return _sortItems;
		}
	}
}
