// js code for nomacs, requires jQuery and SWFObject
var modulePath = "";

// unique id for LocalConnection objects: timestamp + random number
var token = (new Date).getTime() + "-" + Math.floor(Math.random() * 1e+16);

// Reloads evaluator swf
function resetEvalSWF() {
  swfobject.embedSWF(modulePath + "EvalSWF.swf", "evaluatorSWF", "465", "465", "9.0.0", null, {connToken: token});
}

// Enables/disables a warning about unsaved changes when leaving the page.
var _warnOnLeave = false;
function warnOnLeave(val) {
  _warnOnLeave = val;
}

$(function() {
    function addMessageCloseBtn() {
      $(".messages").prepend('<a class="closeBtn" title="Close" href="#">X</a>');
      $(".closeBtn").click(function() {
			     $(this).parent().css("display", "none");
			     $(window).resize();
			   });
    }

    function enterFullscreen() {
      var saved = [];
      function setAndSave(selector, property, value) {
	saved.push({selector: selector, property: property, value: $(selector).css(property)});
	$(selector).css(property, value);
      }

      function exitFullscreen() {
	while(saved.length) {
	  var x = saved.pop();
	  $(x.selector).css(x.property, x.value);
	}
	$("#fullscreenBtn").unbind("click").click(enterFullscreen).text("Fullscreen");
	$(window).unbind("resize");
	$("#editor-container").css("height", "auto");
      }

      setAndSave("#main", "padding", "0 5px");
      setAndSave("#squeeze", "padding", "0");
      setAndSave(
	"#header .region-content, #sidebar-wrapper, #breadcrumb .region-content, #featured .region-content, #content-bottom .region-content, #footer .region-content, #top-bar .region-content",
	"max-width",
	"1465px");
      setAndSave(
	"#header, #featured, #breadcrumb, #sidebar-right, #content-bottom, #footer, #squeeze > h2, #squeeze > .content-bar",
	"display",
	"none");
      if(!$.browser.mozilla) { // causes swfs to reload on firefox
	setAndSave("body", "overflow-y", "hidden");
      }

      resize();
      $(window).resize(resize);

      $("#fullscreenBtn").unbind("click").click(exitFullscreen).text("Exit fullscreen");
    }

    // Resize handler - sets editor height to window height.
    function resize() {
      $("#editor-container").css({ height: $(window).height() - $("#editor-container").position().top });
    }

    $(window).bind('beforeunload',
		   function() {
		     if(_warnOnLeave) return 'You have unsaved changes.';
		   });

    $("#fullscreenBtn").click(enterFullscreen);
    enterFullscreen();

    if(Drupal) {
      modulePath = Drupal.settings.basePath + Drupal.settings.modulePath + '/';
      addMessageCloseBtn();
    }

    var params = Drupal ? Drupal.settings.editorParams : {};
    params.connToken = token;
    // Embed the editor
    swfobject.embedSWF(modulePath + "Nomacs.swf", "editorSWF", "100%", "100%", "9.0.0", null, params);
    // Embed the evaluator
    resetEvalSWF();

    $("#resetBtn").click(resetEvalSWF);
});
