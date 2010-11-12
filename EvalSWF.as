package {
    import flash.display.Sprite;
    import flash.net.LocalConnection;
    import flash.text.TextField;
	import com.las3r.io.OutputStream;
	import com.las3r.io.InputStream;
	import com.las3r.runtime.RT;

    public class EvalSWF extends Sprite {
		public static var rt:RT;
        private var inConn:LocalConnection;
        private var outConn:LocalConnection;
        private var output:TextField;
		private var parameters:Object;
		private var connToken:String;
        
        public function EvalSWF() {
			parameters = root.loaderInfo.parameters;
			connToken = (parameters.connToken || "");
			
            buildUI();
            
            inConn = new LocalConnection();
            inConn.client = this;
            try {
                inConn.connect("eval-in-" + connToken);
            } catch (error:ArgumentError) {
                trace("Can't connect...the connection name is already being used by another SWF");
            }

            outConn = new LocalConnection();

        }
        
        public function eval(code:String):void {
            output.appendText("eval: " + code + "\n");
			outConn.send("eval-out-" + connToken, "printToStdout", "Echo to stdout: " + code + "\n");
			outConn.send("eval-out-" + connToken, "printToStderr", "Echo to stderr: " + code + "\n");
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