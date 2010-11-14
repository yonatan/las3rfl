package {
    import flash.display.Sprite;
    import flash.net.LocalConnection;
    import flash.text.TextField;
	import com.las3r.io.OutputStream;
	import com.las3r.io.InputStream;
	import com.las3r.runtime.RT;

    public class EvalSWF extends Sprite {
		public static var rt:RT;
        private var recvConn:LocalConnection;
        private var sendConn:LocalConnection;
        private var output:TextField;
		private var parameters:Object;
		private var connToken:String;
        
        public function EvalSWF() {
			parameters = root.loaderInfo.parameters;
			connToken = (parameters.connToken || "");
			
            buildUI();
            
			// setup las3r
			rt = new RT(stage, new OutputStream(stdout), new OutputStream(stderr));
			rt.loadStdLib(stdlibLoaded, trace, trace);
        }

		private function stdlibLoaded(val:*):void {
			rt.evalStr(
				"(in-ns 'user)" +
				"(las3r.core/refer 'las3r.core :exclude '(run-tests))"
			);

			// setup local connections
            recvConn = new LocalConnection();
            sendConn = new LocalConnection();
            recvConn.client = this;
            try {
                recvConn.connect("eval-in-" + connToken);
				output.text = "Listening on eval-in-" + connToken;
            } catch (error:ArgumentError) {
                trace("Can't connect... eval-in-" + connToken + " is already being used by another SWF");
            }
        }

		private function stdout(s:String):void {
			sendConn.send("eval-out-" + connToken, "printToStdout", s || "nil");
		}

		private function stderr(s:String):void {
			sendConn.send("eval-out-" + connToken, "printToStderr", s || "nil");
		}
        
        public function eval(code:String):void {
			rt.evalStr(code, stdout, null, stderr);
            output.appendText("eval: " + code + "\n");
        }
        
        private function buildUI():void {
            output = new TextField();
            output.background = true;
            output.border = true;
            output.wordWrap = true;
			output.width = stage.stageWidth;
			output.height = stage.stageHeight;
            addChild(output);
        }
    }
}