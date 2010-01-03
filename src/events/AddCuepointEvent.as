// ActionScript file
package events {

   import flash.events.Event;

   public class AddCuepointEvent extends Event {

      public var izena:String;

      public function AddCuepointEvent( type:String, izena:String ) {

         super( type );
         this.izena = izena;

      }

      override public function clone():Event {
         return new AddCuepointEvent( type, izena );
      }

   }
}