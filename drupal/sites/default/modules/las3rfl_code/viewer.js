$(function() {
    var modulePath = Drupal.settings.basePath + Drupal.settings.modulePath + '/';
    var viewerUrl =
      "http://" +
      Drupal.settings.swfDomain +
      modulePath +
      "Viewer.swf";

    var viewerVars = {
      url:
	"http://" +
	Drupal.settings.swfDomain +
	Drupal.settings.basePath +
	"node/" +
	Drupal.settings.nid +
	"/raw",
      basePath:
	Drupal.settings.basePath
    };

    $("ul.tabs.primary").append("<li id='playStop'><a href='javascript:void(0);'>Play</a></li>");

    var swfParams = {allowscriptaccess: "never", allowfullscreen: "true", wmode: "direct"};
    function play() {
      $("#playStop a").text("Stop").unbind().click(stop);
      $(".node-page .captured-image *").css("display", "none");
      swfobject.embedSWF(viewerUrl, "viewer-swf", "465", "465", "10.0.0", false, viewerVars, swfParams);
    }

    function stop() {
      $("#playStop a").text("Play").unbind().click(play);
      $(".node-page .captured-image *").css("display", "inherit");
      $("#viewer-swf").css("display", "none");
    }

    $("#playStop").css("float", "right");
    $("#play-button").click(play);
    stop();
  });
