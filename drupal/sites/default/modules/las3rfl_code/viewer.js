$(function() {
    var modulePath = Drupal.settings.basePath + Drupal.settings.modulePath + '/';
    var viewerUrl =
      "http://" +
      Drupal.settings.swfDomain +
      modulePath +
      "Viewer.swf?" + (new Date).getTime();
      // TODO: remove cachebuster

    var codeUrl =
      "http://" +
      Drupal.settings.swfDomain +
      "/node/" +
      Drupal.settings.nid +
      "/raw";

    $("ul.tabs.primary").append("<li id='playStop'><a href='javascript:void(0);'>Play</a></li>");

    var swfParams = {allowscriptaccess: "never", allowfullscreen: "true"};
    function play() {
      $("#playStop a").text("Stop").unbind().click(stop);
      $(".captured-image *").css("display", "none");
      swfobject.embedSWF(viewerUrl, "viewer-swf", "465", "465", "10.0.0", false, {url: codeUrl}, swfParams);
    }

    function stop() {
      $("#playStop a").text("Play").unbind().click(play);
      $(".captured-image *").css("display", "inherit");
      $("#viewer-swf").css("display", "none");
    }

    $("#playStop").css("float", "right");
    $("#play-button").click(play);
    stop();
  });
