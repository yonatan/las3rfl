// js code for nomacs, requires jQuery and SWFObject

// unique id for LocalConnection objects: timestamp + random number
var token = (new Date).getTime() + "-" + Math.floor(Math.random() * 1e+16);

// Reloads evaluator swf
function resetEvalSWF() {
  swfobject.embedSWF("EvalSWF.swf", "evaluatorSWF", "465", "465", "9.0.0", null, {connToken: token});
}

$(function() {
    $("#resetBtn").click(resetEvalSWF);

    swfobject.embedSWF("Nomacs.swf", "editorSWF", "100%", "100%", "9.0.0", null, {connToken: token});
    resetEvalSWF();
});
