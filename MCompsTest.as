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
	import jp.psyark.utils.StringComparator;
	import net.hires.debug.Stats;

	// classes used by las3r code
	com.bit101.components.TextArea;
	com.bit101.components.ProgressBar;
	jp.psyark.psycode.core.TextEditUI;
	jp.psyark.utils.StringComparator;
	net.hires.debug.Stats;

    [SWF(width=950,height=600,backgroundColor=0xFFFFFF,frameRate=30)]
    public class MCompsTest extends Sprite {
        [Embed(source="psymacs.parser.lsr", mimeType="application/octet-stream")]
        protected const PsymacsLsr:Class;
        protected var las3rCode:String

        public static var repl:Repl;
        public var rt:RT;
        
        public function MCompsTest() {
            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.align = StageAlign.TOP_LEFT;

            las3rCode = ByteArray(new PsymacsLsr).toString();

			repl = new Repl(400, 400, stage);
			stage.addChild(repl);
			repl.addEventListener("inited", init);
		}

		private function init(e:Event):void {
			repl.evalLibrary(las3rCode, trace);
        }
    }
}

