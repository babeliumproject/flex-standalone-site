package commands.userManagement
{
	import business.UserDelegate;

	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;

	import model.DataModel;

	import mx.controls.Alert;
	import mx.rpc.IResponder;
	import mx.rpc.events.FaultEvent;
	import mx.utils.ObjectUtil;

	import vo.UserVO;

	public class GetUserInfoCommand implements ICommand, IResponder
	{

		public function execute(event:CairngormEvent):void
		{
			new UserDelegate(this).getUserInfo();
		}

		public function result(data:Object):void
		{
			var result:Object=data.result;
			if (!result is UserVO)
			{
				Alert.show("Unexpected data recieved");
			}
			else
			{
				var userData:UserVO=result as UserVO;
				if (DataModel.getInstance().loggedUser.id == userData.id)
				{
					DataModel.getInstance().loggedUser.creditCount=userData.creditCount;
					DataModel.getInstance().creditUpdateRetrieved=true;
				}
			}
		}

		public function fault(info:Object):void
		{
			var faultEvent:FaultEvent=FaultEvent(info);
			Alert.show("Error while retrieving user data:" + faultEvent.message);
			trace(ObjectUtil.toString(info));
		}

	}
}