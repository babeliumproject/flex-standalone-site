package view.common
{
	import flash.display.DisplayObject;
	import flash.text.TextLineMetrics;

	import mx.controls.Button;
	import mx.core.IFlexDisplayObject;
	import mx.core.mx_internal;
	use namespace mx_internal;
	
	/**
	 * 
	 * @Author = http://www.forestandthetrees.com/2008/03/11/flex-multiline-button/
	 * 
	 **/

	public class MultiLineButton extends Button
	{
		public function MultiLineButton()
		{
			super();
		}

		override protected function createChildren():void
		{
			if (!textField)
			{
				textField=new NoTruncationUITextField();
				textField.styleName=this;
				addChild(DisplayObject(textField));
			}

			super.createChildren();

			textField.multiline=true;
			textField.wordWrap=true;
			textField.width=width;
		}

		override protected function measure():void
		{
			if (!isNaN(explicitWidth))
			{
				var tempIcon:IFlexDisplayObject=getCurrentIcon();
				var w:Number=explicitWidth;
				if (tempIcon)
					w-=tempIcon.width + getStyle("gap") + getStyle("paddingLeft") + getStyle("paddingRight");
				textField.width=w;
			}
			super.measure();

		}

		override public function measureText(s:String):TextLineMetrics
		{
			textField.text=s;
			var lineMetrics:TextLineMetrics=textField.getLineMetrics(0);
			lineMetrics.width=textField.textWidth + 4;
			lineMetrics.height=textField.textHeight + 4;
			return lineMetrics;
		}
	}
}
import mx.core.UITextField;

class NoTruncationUITextField extends UITextField
{
	public function NoTruncationUITextField()
	{
		super();
	}

	override public function truncateToFit(s:String=null):Boolean
	{
		return false;
	}
}