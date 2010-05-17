package commands.search
{
	import business.TagCloudDelegate;
	
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import model.DataModel;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.rpc.IResponder;
	import mx.rpc.events.FaultEvent;
	import mx.utils.ArrayUtil;
	import mx.utils.ObjectUtil;
	
	import view.common.CustomAlert;
	
	import vo.TagVO;

	
	public class GetTagCloudCommand implements IResponder, ICommand{
		public function execute(event:CairngormEvent):void{
			new TagCloudDelegate(this).getTagCloud();
		}
		public function result(data:Object):void{
			var result:Object=data.result;
			var resultCollection:ArrayCollection;

			if (result is Array){
				resultCollection=new ArrayCollection(ArrayUtil.toArray(result));
				try{
					if (!(resultCollection[0] is TagVO)){
						CustomAlert.error("The Result is not a well-formed object.");
					}else{
						//Matches found
						//Set the data to the application's model
						DataModel.getInstance().tagCloud=resultCollection;
						//Reflect the visual changes
						DataModel.getInstance().tagCloudRetrieved =true;
					}
				}catch(e:Error){
						//No matches found
						//Set the data to the application's model
						DataModel.getInstance().tagCloud=resultCollection;
						//Reflect the visual changes
						DataModel.getInstance().tagCloudRetrieved =true;
				}				
			}else{}
		}
		public function fault(info:Object):void{
			var faultEvent:FaultEvent = FaultEvent(info);
			CustomAlert.error("Error while retrieving the cloud of tags.");
			trace(ObjectUtil.toString(info));
		}
	}
}