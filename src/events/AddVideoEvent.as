/// ActionScript file
package events {

   import flash.events.Event;

   public class AddVideoEvent extends Event {

	  public static const CHANGE_OPTION:String = "changeOption";
      public var bideoIzena:String;

      public function AddVideoEvent( bideoIzena:String, bubbles:Boolean = false, cancelable : Boolean = false ) {

         super( CHANGE_OPTION,bubbles,cancelable );
         this.bideoIzena = bideoIzena;

      }
   }
}