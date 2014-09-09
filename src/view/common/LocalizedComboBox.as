package view.common
{
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	import mx.collections.ICollectionView;
	import mx.collections.IList;
	import mx.collections.IViewCursor;
	import mx.collections.ListCollectionView;
	import mx.collections.XMLListCollection;
	import mx.controls.ComboBox;
	import mx.events.FlexEvent;
	import mx.events.ListEvent;
	import mx.managers.ICursorManager;
	import mx.resources.ResourceManager;
	import mx.utils.ObjectUtil;
	
	import spark.globalization.SortingCollator;
	
	public class LocalizedComboBox extends ComboBox
	{
		private var sorter:SortingCollator = new SortingCollator();
		
		protected var translatableCollection:ICollectionView;
		
		private var translatablePromptChanged:Boolean = false;
		private var _translatablePrompt:String;
		
		public function LocalizedComboBox()
		{
			super();
			ResourceManager.getInstance().addEventListener(Event.CHANGE, onLocaleChainChange);
		}
		
		public function onLocaleChainChange(e:Event):void
		{
			if(translatableCollection)
				updateLocalizedComboBox();	
		}
		
		protected function localeCompareFunction(item1:Object, item2:Object):int
		{
			var language1:String=item1.label;
			var language2:String=item2.label;
			
			sorter.setStyle('locale',ResourceManager.getInstance().localeChain[0]);
			sorter.ignoreCase=true;
			return sorter.compare(language1,language2);
			//return language1.localeCompare(language2);
		}
		
		private function updateLocalizedComboBox():void
		{
			if(translatableCollection){
				
				//Save the internal sorting index before rearranging
				if(selectedIndex !=-1){
					var oldSelectedItem:Object=selectedItem;
					var internalSortingIndex:int=oldSelectedItem['code'];
				}
				
				dataProvider = localizeCollection(translatableCollection);
				//Sort the dataProvider
				//dataProvider.sort(localeCompareFunction);
				(dataProvider as ArrayCollection).source.sort(localeCompareFunction);
				
				//Restore the saved selectedIndex
				dataProvider.createCursor();
				while(!iterator.afterLast){
					var item:Object = iterator.current;
					if(item.hasOwnProperty('code') && item['code']==internalSortingIndex)
						break;
					iterator.moveNext();
				}
				selectedItem=item;
			}
		}
		
		public function set translatableDataProvider(value:Object):void{
			if (value is Array)
			{
				translatableCollection = new ArrayCollection(value as Array);
			}
			else if (value is ICollectionView)
			{
				translatableCollection = ICollectionView(value);
			}
			else if (value is IList)
			{
				translatableCollection = new ListCollectionView(IList(value));
			}
			else if (value is XMLList)
			{
				translatableCollection = new XMLListCollection(value as XMLList);
			}
			else
			{
				// convert it to an array containing this one item
				var tmp:Array = [value];
				translatableCollection = new ArrayCollection(tmp);
			}
			
			dataProvider = localizeCollection(translatableCollection);
		}
		
		public function get localizedDataProvider():Object{
			return translatableCollection;
		}
		
		private function localizeCollection(value:ICollectionView):ArrayCollection{
			var collectionCopy:ArrayCollection = new ArrayCollection();
			var iterator:IViewCursor = value.createCursor();
			while(!iterator.afterLast){
				var item:Object = iterator.current;
				var itemCopy:Object = ObjectUtil.copy(item);
				
				itemCopy.label = ResourceManager.getInstance().getString('myResources',item.label);
				collectionCopy.addItem(itemCopy);
				
				iterator.moveNext();
			}
			return collectionCopy;
		}
		
		public function set translatablePrompt(value:String):void
		{
			_translatablePrompt = value;
			translatablePromptChanged = true;
			prompt = ResourceManager.getInstance().getString('myResources',_translatablePrompt);
		}
		
		public function get translatablePrompt():String{
			return _translatablePrompt;
		}
	}
}