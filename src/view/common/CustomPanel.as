package view.common
{
	import mx.containers.Panel;
	
	public class CustomPanel extends Panel
	{
		public function CustomPanel()
		{
			super();
			
			setStyle('backgroundColor', 0xffffff);
			setStyle('borderThickness',1);
			setStyle('borderStyle', "solid");
			setStyle('borderColor', 0xaaaaaa);
			setStyle('dropShadowEnabled', false);
			setStyle('cornerRadius',6);
			setStyle('color',0x2B333C);
			setStyle('fontSize',12);
			setStyle('paddingBottom', 2);
			setStyle('paddingLeft', 2);
			setStyle('paddingRight',2);
			setStyle('headerHeight', 19);
			setStyle('headerColors', [0x919191, 0xFFFFFF]);
			setStyle('footerColors', [0x9db6d9, 0xffffff]);
			setStyle('roundedBottomCorners',true);
		}
	}
}