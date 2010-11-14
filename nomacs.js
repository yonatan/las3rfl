// js code for nomacs, requires jQuery and SWFObject

$(function() {
    function resetEvalSWF() {
      swfobject.embedSWF("EvalSWF.swf", "evaluatorSWF", "465", "465", "9.0.0");
      }

    $("#resetBtn").click(resetEvalSWF);

    swfobject.embedSWF("Nomacs.swf", "editorSWF", "100%", "100%", "9.0.0");
    swfobject.embedSWF("EvalSWF.swf", "evaluatorSWF", "465", "465", "9.0.0");
  });
