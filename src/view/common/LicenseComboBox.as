package view.common
{
	import flash.events.Event;
	
	import mx.events.FlexEvent;
	import mx.events.ListEvent;

	public class LicenseComboBox extends IconComboBox
	{
		
		[Bindable]
		[Embed(source="../../resources/images/licenses/cc-by.png")]
		public var LicenseCcBy:Class;
		
		[Bindable]
		[Embed(source="../../resources/images/licenses/cc-by-sa.png")]
		public var LicenseCcBySa:Class;
		
		[Bindable]
		[Embed(source="../../resources/images/licenses/cc-by-nd.png")]
		public var LicenseCcByNd:Class;
		
		[Bindable]
		[Embed(source="../../resources/images/licenses/cc-by-nc.png")]
		public var LicenseCcByNc:Class;
		
		[Bindable]
		[Embed(source="../../resources/images/licenses/cc-by-nc-sa.png")]
		public var LicenseCcByNcSa:Class;
		
		[Bindable]
		[Embed(source="../../resources/images/licenses/cc-by-nc-nd.png")]
		public var LicenseCcByNcNd:Class;
		
		[Bindable]
		[Embed(source="../../resources/images/licenses/copyrighted.png")]
		public var LicenseCopyrighted:Class;
		
		[Bindable]
		public var licenses:Array=new Array(
										{code: 'CC-BY', icon: LicenseCcBy},
										{code: 'CC-BY-SA', icon: LicenseCcBySa},
										{code: 'CC-BY-ND', icon: LicenseCcByNd},
										{code: 'CC-BY-NC', icon: LicenseCcByNc},
										{code: 'CC-BY-NC-SA', icon: LicenseCcByNcSa},
										{code: 'CC-BY-NC-ND', icon: LicenseCcByNcNd},
										{code: 'COPYRIGHTED', icon: LicenseCopyrighted}
		);
		
		public function LicenseComboBox()
		{
			super();
			this.addEventListener(FlexEvent.CREATION_COMPLETE, onComplete);
		}
		
		public function onComplete(event:FlexEvent):void{
			this.setStyle('fontWeight','normal');
			this.dataProvider = licenses;
			this.labelFunction = licenseLabelFunction;
			this.addEventListener(ListEvent.CHANGE, selectionChangeHandler);
		}
		
		private function licenseLabelFunction(item:Object):String{
			return resourceManager.getString('myResources', item.code);
		}
		
		private function selectionChangeHandler(event:Event):void{
			updateComboBox();
		}
		
		private function updateComboBox():void{
			var oldSelectedItem:Object = this.selectedItem;
			this.dataProvider = licenses;
			this.selectedItem = oldSelectedItem;
		}
		
		public function getLicenseAndIconGivenCode(code:String):Object{
			var licenseAndIcon:Object = null;
			for each(var licence:Object in licenses){
				if(licence.code == code.toUpperCase()){
					licenseAndIcon = licence;
					break;
				}
			}
			return licenseAndIcon;
		}
		
	}
}
