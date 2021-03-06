// js code for nomacs, requires jQuery and SWFObject
var modulePath = "";

// unique id for LocalConnection objects: timestamp + random number
var token = (new Date).getTime() + "-" + Math.floor(Math.random() * 1e+16);

// Reloads evaluator swf
var resetEvalSWF;

$(function() {
    if($.browser.msie) {
      $("body").append('<div id="big-warning">The editor doesn\'t work in Internet Explorer. Sorry.</div>');
    }

    resetEvalSWF = function() {
      var evalVars = {
	connToken: token,
	siteDomain: Drupal.settings.siteDomain,
	basePath: Drupal.settings.basePath
      };
      var evalParams = {allowscriptaccess: "never", allowfullscreen: "true", wmode: "direct"};
      var swfUrl = "http://" + Drupal.settings.editorVars.swfDomain + modulePath + "EvalSWF.swf";
      swfobject.embedSWF(swfUrl, "evaluatorSWF", "465", "465", "10.0.0", false, evalVars, evalParams);
    };

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

    $("#fullscreenBtn").click(enterFullscreen);
    enterFullscreen();

    if(Drupal) {
      modulePath = Drupal.settings.basePath + Drupal.settings.modulePath + '/';
      addMessageCloseBtn();
    }

    var editorVars = Drupal ? Drupal.settings.editorVars : {};
    editorVars.connToken = token;
    editorVars.basePath = Drupal.settings.basePath;

    // Embed the editor
    swfobject.embedSWF(modulePath + "Nomacs.swf", "editorSWF", "100%", "100%", "10.0.0", false, editorVars);
    // Embed the evaluator
    resetEvalSWF();

    $("#resetBtn").click(resetEvalSWF);
});
