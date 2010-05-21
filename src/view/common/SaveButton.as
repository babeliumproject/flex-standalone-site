package view.common
{
	public class SaveButton
	{
		[Bindable]
		[Embed(source="../../resources/images/disk.png")]
		public var CloseIcon:Class;		
		
		public function SaveButton()
		{
			super();
			this.label = resourceManager.getString('myResources','BUTTON_SAVE');
			this.setStyle('cornerRadius',8);
			this.setStyle('paddingLeft',6);
			this.setStyle('paddingRight',6);
			this.setStyle('icon', CloseIcon);
		}
	}
}