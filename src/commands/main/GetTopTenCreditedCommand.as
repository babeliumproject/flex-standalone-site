package commands.main
{
	import business.UserDelegate;
	
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import model.DataModel;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.resources.ResourceManager;
	import mx.rpc.IResponder;
	import mx.rpc.events.FaultEvent;
	import mx.utils.ArrayUtil;
	import mx.utils.ObjectUtil;
	
	import view.common.CustomAlert;
	
	import vo.UserVO;

	public class GetTopTenCreditedCommand implements ICommand, IResponder
	{


		public function execute(event:CairngormEvent):void
		{
			new UserDelegate(this).getTopTenCredited();
		}

		//Must return an array of UserVO objects retrieved from the server
		public function result(data:Object):void
		{
			var result:Object=data.result;

			if (result is Array)
			{
				var resultCollection:ArrayCollection=new ArrayCollection(ArrayUtil.toArray(result));

				//Check wheter the VO object is properly returned
				if (!(resultCollection[0] is UserVO))
				{
					CustomAlert.error(ResourceManager.getInstance().getString('myResources','ERROR_WHILE_RETRIEVING_TOP_USERS'));
				}
				else
				{
					//Set the data to the application's model
					DataModel.getInstance().topTenUsers=resultCollection;

					//Reflect the visual changes
					DataModel.getInstance().isTopTenRetrieved=true;
				}
			}
		}

		public function fault(info:Object):void
		{
			var faultEvent:FaultEvent=FaultEvent(info);
			CustomAlert.error(ResourceManager.getInstance().getString('myResources','ERROR_WHILE_RETRIEVING_TOP_USERS'));
			trace(ObjectUtil.toString(info));
		}

	}
}