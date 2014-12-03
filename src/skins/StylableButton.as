package skins
{
	import spark.components.Button;
	
	
	[Style(name="tColor", type="uint", format="Color", inherit="yes" )]	
	[Style(name="tColorOver", type="uint", format="Color", inherit="yes" )]	
	[Style(name="tColorDown", type="uint", format="Color", inherit="yes" )]
	[Style(name="tDecoration", inherit="yes", type="String")]
	[Style(name="tDecorationOver", inherit="yes", type="String")]
	[Style(name="tDecorationDown", inherit="yes", type="String")]
	
	[Style(name="bgrAlpha", inherit="yes", type="Number")]
	[Style(name="bgrColor", inherit="yes", type="uint", format="Color")]
	[Style(name="bgrColorOver", inherit="yes", type="uint", format="Color")]
	[Style(name="bgrColorDown", inherit="yes", type="uint", format="Color")]
	[Style(name="bAlpha", inherit="yes", type="Number")]
	[Style(name="bColor", inherit="yes", type="uint", format="Color")]
	[Style(name="bColorOver", inherit="yes", type="uint", format="Color")]
	[Style(name="bColorDown", inherit="yes", type="uint", format="Color")]
	
	public class StylableButton extends Button
	{
		public function StylableButton()
		{
			super();
		}
	}
}