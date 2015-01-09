package modules.home.event
{
	import com.adobe.cairngorm.control.CairngormEvent;
	
	import flash.events.Event;
	
	public class MessageOfTheDayEvent extends CairngormEvent
	{
		
		public static const UNSIGNED_MESSAGES_OF_THE_DAY:String = "unsignedMessagesOfTheDay";
		public static const SIGNED_OF_THE_DAY:String = "signedMessagedOfTheDay";
		
		public var messageLocale:String;
		
		
		public function MessageOfTheDayEvent(type:String, messageLocale:String)
		{
			super(type);
			this.messageLocale = messageLocale;
		}
		
		override public function clone():Event{
			return new MessageOfTheDayEvent(type,messageLocale);
		}
		
	}
}