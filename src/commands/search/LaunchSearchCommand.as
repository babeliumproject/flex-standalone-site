package commands.search{
	
	import business.SearchDelegate;
	
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import model.DataModel;
	
	import mx.collections.ArrayCollection;
	import mx.messaging.messages.RemotingMessage;
	import mx.resources.ResourceManager;
	import mx.rpc.IResponder;
	import mx.rpc.events.FaultEvent;
	import mx.utils.ArrayUtil;
	import mx.utils.ObjectUtil;
	
	import view.common.CustomAlert;
	
	import vo.ExerciseVO;
	
	public class LaunchSearchCommand implements IResponder, ICommand{
		
		private var dataModel:DataModel=DataModel.getInstance();
			
		public function execute(event:CairngormEvent):void{
			new SearchDelegate(this).launchSearch(dataModel.searchField);
		}
		
		public function result(data:Object):void{
			var result:Object=data.result;
			var resultCollection:ArrayCollection;

			if (result is Array){
				resultCollection=new ArrayCollection(ArrayUtil.toArray(result));
				//There are matches and the data is well-formed
				if (resultCollection[0] is ExerciseVO)
					dataModel.videoSearches=resultCollection;		
				else
					dataModel.videoSearches=new ArrayCollection();
			} else {
				dataModel.videoSearches=new ArrayCollection();
			}
			//Binding watchers are notified of a possible value change
			dataModel.videoSearchesRetrieved=!dataModel.videoSearchesRetrieved;
		}
		
		public function fault(info:Object):void{
			var faultEvent:FaultEvent = FaultEvent(info);
			trace("[ERROR] operation: "+(faultEvent.token.message as RemotingMessage).operation+", code: "+faultEvent.fault.faultCode+", name: "+faultEvent.fault.faultString+", detail: "+faultEvent.fault.faultDetail);
			
			//We don't need to display an error, just display no matches for the searched term
			//CustomAlert.error(ResourceManager.getInstance().getString('myResources','ERROR_WHILE_PERFORMING_SEARCH'));
			dataModel.videoSearches=new ArrayCollection();
			dataModel.videoSearchesRetrieved=!dataModel.videoSearchesRetrieved;
		}
		
	}
}