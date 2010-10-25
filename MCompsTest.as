// forked from psyark's F-siteで紹介したエディタを無理やりWonderflに突っ込んでみた
package {
    import flash.display.*;
    import flash.events.*;
    import flash.net.*;
    import flash.system.*;
    import flash.utils.*;
	import com.las3r.io.OutputStream;
	import com.las3r.runtime.RT;
	import com.las3r.repl.Repl;
	import com.bit101.components.*;
	import jp.psyark.psycode.core.TextEditUI;
	import net.hires.debug.Stats;

	com.bit101.components.TextArea;
	com.bit101.components.ProgressBar;
	jp.psyark.psycode.core.TextEditUI;

    [SWF(width=950,height=600,backgroundColor=0xFFFFFF,frameRate=30)]
    public class MCompsTest extends Sprite {
		//[Embed(source="fonts/DroidSansMono.ttf", embedAsCFF="false", fontName="Droid Sans Mono", mimeType="application/x-font")]
		[Embed(source="fonts/DejaVuSansMono.ttf", embedAsCFF="false", fontName="Droid Sans Mono", mimeType="application/x-font")]
        protected const PsymacsFont:Class;
		
        [Embed(source="psymacs.parser.lsr", mimeType="application/octet-stream")]
        protected const PsymacsLsr:Class;
        protected var las3rCode:String

        public static var repl:Repl;
        public static var stats:Stats = new Stats;
        public var rt:RT;
        
        public function MCompsTest() {
            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.align = StageAlign.TOP_LEFT;

            las3rCode = ByteArray(new PsymacsLsr).toString();

			repl = new Repl(400, 400, stage);
			stage.addChild(repl);
			//stage.addChild(stats);
			repl.addEventListener("inited", init);
		}

		private function init(e:Event):void {
			// las3rCode = "(prn 'starting)" + las3rCode + "(prn 'loaded)" +  <![CDATA[
			// 		(def ta (new com.bit101.components.TextArea *stage* 300 300))
			// 		(def tf (. ta textField))
			// 		(set! (. tf embedFonts) false)
			// 		(set! (. tf wordWrap) false)
			// 		(set! (. tf defaultTextFormat)
			// 			  (new flash.text.TextFormat "Courier New", 13, 0x000000))
			// 		(def buff (attach-to-textfield-container ta))
			// 		;(. *stage* (addChild ta))
			// 		(. *stage* (addEventListener "enterFrame" frame-handler))
			// 	]]>;
			

			repl.evalLibrary(las3rCode += 
				'(init)' +
				'(. *stage* (addChild (. (get-def "MCompsTest") repl)))'
				, trace);
        }
    }
}

