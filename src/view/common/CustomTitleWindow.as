package view.common
{
	import mx.containers.TitleWindow;
	
	public class CustomTitleWindow extends TitleWindow
	{
		public function CustomTitleWindow()
		{
			super();
			
			setStyle('backgroundColor', 0xffffff);
			setStyle('borderColor',0xE5E8EA);
			setStyle('borderThickness',1);
			setStyle('borderStyle', "solid");
			setStyle('dropShadowEnabled', true);
			setStyle('dropShadowColor', 0x000000);
			setStyle('cornerRadius',6);
			setStyle('color',0x2B333C);
			setStyle('fontSize',11);
			setStyle('paddingBottom', 2);
			setStyle('paddingLeft', 2);
			setStyle('paddingRight',2);
			setStyle('headerHeight', 19);
			setStyle('headerColors', [0x919191, 0xFFFFFF]);
			setStyle('footerColors', [0x9db6d9, 0xffffff]);
			setStyle('borderColor', 0xaaaaaa);
			setStyle('roundedBottomCorners',true);
			setStyle('highlightAlphas',[0,0]);
		}
	}
}