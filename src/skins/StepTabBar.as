package skins
{
	import spark.components.TabBar;
	
	
	[Style(name="icon", type="*")]
	
	[Style(name="gradientColors", type="Array", arrayType="uint", format="Color", inherit="yes" )]
	
	[Style(name="gradientColorsOver", type="Array", arrayType="uint", format="Color", inherit="yes" )]
	
	[Style(name="gradientColorsDown", type="Array", arrayType="uint", format="Color", inherit="yes" )]
	
	[Style(name="gradientColorsSelectedUp", type="Array", arrayType="uint", format="Color", inherit="yes")]
	
	[Style(name="gradientColorsSelectedOver", type="Array", arrayType="uint", format="Color", inherit="yes" )]
	
	[Style(name="borderColors", type="Array", arrayType="uint", format="Color", inherit="yes" )]
	
	[Style(name="borderSize", type="uint", format="Length", inherit="yes" )]
	
	[Style(name="colorOver", type="uint", format="Color", inherit="yes" )]
	
	[Style(name="colorDown", type="uint", format="Color", inherit="yes" )]
	
	[Style(name="padding", type="uint", format="Length", inherit="yes" )]
	
	[Style(name="tabGap", type="uint", format="Length")]
	
	public class StepTabBar extends TabBar
	{
		public function StepTabBar()
		{
			super();
		}
	}
}