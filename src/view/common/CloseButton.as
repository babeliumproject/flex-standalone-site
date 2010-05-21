package view.common
{
	import mx.controls.Button;
	
	public class CloseButton extends Button
	{
		[Bindable]
		[Embed(source="../../resources/images/cross.png")]
		public var CloseIcon:Class;		
		
		public function CloseButton()
		{
			super();
			this.label = resourceManager.getString('myResources','BUTTON_CLOSE');
			this.setStyle('cornerRadius',8);
			this.setStyle('paddingLeft',6);
			this.setStyle('paddingRight',6);
			this.setStyle('icon', CloseIcon);
		}
	}
}