package {
    import flash.display.*;
    import flash.net.LocalConnection;
    import flash.text.TextField;
	import flash.utils.ByteArray;
	import com.las3r.io.OutputStream;
	import com.las3r.io.InputStream;
	import com.las3r.runtime.RT;
	import com.adobe.images.JPGEncoder;

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
				stdout("Evaluator ready.\n");
            } catch (error:ArgumentError) {
                trace("Can't connect... eval-in-" + connToken + " is already being used by another SWF");
            }
        }

		private function stdout(s:String):void {
			sendConn.send("eval-out-" + connToken, "printToStdout", s || "nil");
		}

		private function stdoutLine(s:String):void {
			stdout(s + "\n");
		}

		private function stderr(s:String):void {
			sendConn.send("eval-out-" + connToken, "printToStderr", s || "nil");
		}
        
        public function eval(code:String):void {
			rt.evalStr(code, stdoutLine, null, stderr);
            output.appendText("eval: " + code + "\n");
        }

		public function capture():void {
			var bmd:BitmapData = new BitmapData(465, 465, false);
			var jpeg:ByteArray;
			var encoder:JPGEncoder;

			bmd.draw(stage);

			// LocalConnection is only good for < 40k
			// try lower quality compression if neccesary
			for(var quality:int = 50; quality > 4; quality /= 2) {
				encoder = new JPGEncoder(quality);
				jpeg = encoder.encode(bmd);
				if(jpeg.length < 40000) break; 
			}
			
			if(quality > 4) {
				output.appendText("jpeg quality: " + quality + "\n");
				output.appendText("jpeg size: " + jpeg.length + "\n");
				sendConn.send("eval-out-" + connToken, "updateCapture", jpeg);
			}
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