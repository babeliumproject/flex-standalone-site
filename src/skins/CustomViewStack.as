package skins
{
	import mx.core.IVisualElement;
	
	import spark.components.Group;
	import spark.events.IndexChangeEvent;
	
	[Event(name="change", type="spark.events.IndexChangeEvent")]
	
	[DefaultProperty("content")]
	public class CustomViewStack extends Group
	{
		
		[ArrayElementType("mx.core.IVisualElement")]
		protected var _content:Array;
		protected var _selectedIndex:int = -1;
		protected var _selectedChild:IVisualElement
		protected var _pendingSelectedIndex:int = -1;
		
		override protected function commitProperties() : void
		{
			super.commitProperties();
			// if pending change to selectedIndex property.
			if( _pendingSelectedIndex != -1 )
			{
				// commit the change.
				updateSelectedIndex( _pendingSelectedIndex );
				// set pending back to default.
				_pendingSelectedIndex = -1;
			}
		}
		
		protected function updateSelectedIndex( index:int ):void
		{
			// store old for event.
			var oldIndex:int = _selectedIndex;
			// set new.
			_selectedIndex = index;
			
			// remove old element.
			if( numElements > 0 ) 
				removeElementAt( 0 );
			
			// add new element.
			selectedChild = _content[_selectedIndex];
			addElement( _selectedChild );
			
			// dispatch index change.
			var event:IndexChangeEvent = new IndexChangeEvent( IndexChangeEvent.CHANGE, 
				false, false, 
				oldIndex, _selectedIndex );
			dispatchEvent( event );
		}
		
		private function getElementIndexFromContent( element:IVisualElement ):int
		{
			if( _content == null ) return -1;
			
			var i:int = _content.length;
			var contentElement:IVisualElement;
			while( --i > -1 )
			{
				contentElement = _content[i] as IVisualElement;
				if( contentElement == element )
				{
					break;
				}
			}
			return i;
		}
		
		[Bindable]
		[ArrayElementType("mx.core.IVisualElement")]
		public function get content():Array /*IVisualElement*/
		{
			return _content;
		}
		public function set content( value:Array /*IVisualElement*/ ):void
		{
			_content = value;
			// update selected index based on pending operations.
			selectedIndex = _pendingSelectedIndex == -1 ? 0 : _pendingSelectedIndex;
		}
		
		[Bindable]
		public function get selectedIndex():int
		{
			return _pendingSelectedIndex != -1 ? _pendingSelectedIndex : _selectedIndex;
		}
		public function set selectedIndex( value:int ):void
		{
			if( _selectedIndex == value ) return;
			
			_pendingSelectedIndex = value;
			invalidateProperties();
		}
		
		[Bindable]
		public function get selectedChild():IVisualElement
		{
			return _selectedChild;
		}
		public function set selectedChild( value:IVisualElement ):void
		{
			if( _selectedChild == value ) return;
			
			// if not pending operation on selectedIndex, induce.
			if( _pendingSelectedIndex == -1 )
			{
				var proposedIndex:int = getElementIndexFromContent( value );
				selectedIndex = proposedIndex;
			}
				// else just hold a reference for binding update.
			else _selectedChild = value;
		}
		
	}
}