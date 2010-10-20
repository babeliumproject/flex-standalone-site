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
			var maxPageButtonsInPagination:int=displayedPageCount;
			var limit:int=(maxPageButtonsInPagination + 1) / 2;
			var itemsPerPage:int=itemsPerPage;
			var itemCount:int=totalItemCount;
			var currentPage:int=currentPageNumber;
			var neededPageButtons:int=(itemCount % itemsPerPage == 0) ? (itemCount / itemsPerPage) : itemCount / itemsPerPage + 1;

			//Destroy the previous navigation menu
			destroyPaginationMenu(container);

			if (itemCount / itemsPerPage > 1)
			{
				//Create the first and previous page buttons if needed
				if (currentPage > 1)
				{
					container.addChild(createControlButton(1, firstI, buttonClickHandler));
					container.addChild(createControlButton(currentPage - 1, previousI, buttonClickHandler));
				}

				//Create the numbered page buttons
				if (neededPageButtons > maxPageButtonsInPagination)
				{
					if (currentPage <= limit)
					{
						for (var i:int=1; (i <= neededPageButtons && i <= maxPageButtonsInPagination); i++)
						{
							container.addChild(createPageButton(i, buttonClickHandler));
						}
					}
					else if (currentPage > neededPageButtons - limit)
					{
						for (var j:int=neededPageButtons - maxPageButtonsInPagination + 1; j <= neededPageButtons; j++)
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
				}
				else
				{
					for (var h:int=1; (h <= neededPageButtons && h <= maxPageButtonsInPagination); h++)
					{
						container.addChild(createPageButton(h, buttonClickHandler));
					}
				}

				//Create the last and next page buttons if needed
				if (currentPage < neededPageButtons)
				{
					container.addChild(createControlButton(currentPage + 1, nextI, buttonClickHandler));
					container.addChild(createControlButton(neededPageButtons, lastI, buttonClickHandler));
				}
			}
			for each (var b:Button in container.getChildren())
			{
				if (int(b.id) == currentPage)
				{
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
			var navButton:Button = new Button();
			navButton.styleName = "paginationButton";
			navButton.id=label.toString();
			navButton.label=label.toString();
//			navButton.minWidth=18;
//			navButton.measuredWidth=18;
			navButton.height=40;
		
			navButton.addEventListener(MouseEvent.CLICK, clickHandler);

			return navButton;
		}

		private static function createControlButton(target:int, icon:Class, clickHandler:Function):Button
		{
			var ctrlButton:Button=new Button();
			ctrlButton.id=target.toString();
			ctrlButton.styleName = "paginationControlButton";
			ctrlButton.setStyle('icon', icon);
			ctrlButton.width=40;
			ctrlButton.height=40;

			ctrlButton.addEventListener(MouseEvent.CLICK, clickHandler);

			return ctrlButton;
		}

	}
}