package modules.search
{
	import flash.events.MouseEvent;
	
	import model.DataModel;
	
	import mx.containers.Box;
	import mx.controls.Button;

	public class VideoPaginator
	{
		
		[Bindable]
		[Embed(source="resources/images/first.png")]
		public static var firstI:Class;
		[Bindable]
		[Embed(source="resources/images/previous.png")]
		public static var previousI:Class;
		[Bindable]
		[Embed(source="resources/images/next.png")]
		public static var nextI:Class;
		[Bindable]
		[Embed(source="resources/images/last.png")]
		public static var lastI:Class;
		
		public static function createPaginationMenu(totalItemCount:int, itemsPerPage:int, currentPageNumber:int, displayedPageCount:int, container:Box, buttonClickHandler:Function):void
		{
			var buttonCountInPaginationBox:int=displayedPageCount;
			var limit:int=(buttonCountInPaginationBox + 1) / 2;
			var itemsPerPage:int=itemsPerPage;
			var itemCount:int=totalItemCount;
			var currentPage:int=currentPageNumber;
			var searchPageCount:int=(itemCount % itemsPerPage == 0) ? (itemCount / itemsPerPage) : itemCount / itemsPerPage + 1;
			
			//Destroy the previous navigation menu
			destroyPaginationMenu(container);
			
			if (itemCount / itemsPerPage > 1)
			{
				if (currentPage > 1)
				{
					container.addChild(createControlButton(1, firstI, buttonClickHandler));
					container.addChild(createControlButton(currentPage -1, previousI, buttonClickHandler));
				}
				if (currentPage <= limit)
				{
					for (var i:int=1; (i <= searchPageCount && i <= buttonCountInPaginationBox); i++)
					{
						container.addChild(createPageButton(i, buttonClickHandler));
					}
				}
				else if (currentPage > searchPageCount - limit)
				{
					for (var j:int=searchPageCount - buttonCountInPaginationBox + 1; j <= searchPageCount; j++)
					{
						container.addChild(createPageButton(j, buttonClickHandler));
					}
				}
				else
				{
					for (var k:int=currentPage - limit + 1; k <= currentPage + limit - 1; k++)
					{
						container.addChild(createPageButton(k, buttonClickHandler));
					}
				}
				if (currentPage < searchPageCount)
				{
					container.addChild(createControlButton(currentPage+1, nextI, buttonClickHandler));
					container.addChild(createControlButton(searchPageCount, lastI, buttonClickHandler));
				}
			}
			for each (var b:Button in container.getChildren()){
				if(int(b.id) == currentPage){
					b.enabled=false;
					break;
				}
			}
		}
		
		private static function destroyPaginationMenu(container:Box):void
		{
			container.removeAllChildren();
		}
		
		private static function createPageButton(label:int, clickHandler:Function):Button
		{
			var navButton:Button=new Button();
			navButton.id=label.toString();
			navButton.label=label.toString();
			navButton.setStyle('cornerRadius', 4);
			navButton.setStyle('paddingLeft', 0);
			navButton.setStyle('paddingRight', 0);
			navButton.setStyle('hihglightAlphas', [0, 0]);
			navButton.setStyle('fillAlphas', [0, 0, 1, 1]);
			navButton.setStyle('fillColors', [0xffffff, 0xcccccc, 0xaadeff, 0xaadeff]);
			navButton.setStyle('fontFamily', 'Arial');
			navButton.setStyle('fontSize', 12);
			navButton.minWidth=24;
			navButton.measuredWidth=24;
			navButton.height=24;
			navButton.addEventListener(MouseEvent.CLICK, clickHandler);
			
			return navButton;
		}
		
		private static function createControlButton(target:int, icon:Class, clickHandler:Function):Button{
			var ctrlButton:Button=new Button();
			ctrlButton.id=target.toString();
			ctrlButton.setStyle('cornerRadius', 4);
			ctrlButton.setStyle('paddingLeft', 1);
			ctrlButton.setStyle('paddingRight', 1);
			ctrlButton.setStyle('fontFamily', 'Arial');
			ctrlButton.setStyle('fontSize', 12);
			ctrlButton.setStyle('icon', icon);
			ctrlButton.width=24;
			ctrlButton.height=24;
			
			ctrlButton.addEventListener(MouseEvent.CLICK, clickHandler);
			
			return ctrlButton;
		}	
		
	}
}