package vo
{
	[RemoteClass(alias="ThirdPartySoftwareVO")]
	[Bindable]
	public class ThirdPartySoftwareVO
	{
		
		public var product:String;
		public var licenseName:String;
		public var licenseUrl:String;
		public var productUrl:String;
		
		public function ThirdPartySoftwareVO(product:String, licenseName:String, licenseUrl:String, productUrl:String)
		{
			this.product=product;
			this.licenseName=licenseName;
			this.licenseUrl=licenseUrl;
			this.productUrl=productUrl;
		}
	}
}