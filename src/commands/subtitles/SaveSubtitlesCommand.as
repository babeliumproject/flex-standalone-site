package commands.subtitles
{
	import business.SubtitleDelegate;
	
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import events.CreditEvent;
	import events.SubtitleEvent;
	
	import model.DataModel;
	
	import mx.controls.Alert;
	import mx.rpc.IResponder;
	import mx.rpc.events.FaultEvent;
	import mx.utils.ObjectUtil;
	
	import view.common.CustomAlert;
	
	import vo.UserVO;

	public class SaveSubtitlesCommand implements ICommand, IResponder
	{

		public function execute(event:CairngormEvent):void
		{
			new SubtitleDelegate(this).saveSubtitles((event as SubtitleEvent).subtitle);
		}

		public function result(data:Object):void
		{
			var result:Object=data.result;
			if (!result is UserVO)
			{
				CustomAlert.error("Your subtitles couldn't be properly saved.");
			}
			else
			{
				var userData:UserVO=result as UserVO;
				DataModel.getInstance().loggedUser.creditCount=userData.creditCount;
				DataModel.getInstance().subtitleSaved=true;
				DataModel.getInstance().creditUpdateRetrieved=true;
			}
		}

		public function fault(info:Object):void
		{
			var faultEvent:FaultEvent=FaultEvent(info);
			CustomAlert.error("Error while saving your subtitles. Try again later.");
			trace(ObjectUtil.toString(info));
		}

	}
}