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

    $("ul.tabs.primary").append(
      "<li id='playStop'><a href='javascript:void(0);'>Play</a></li>" +
      "<li id='reload'><a href='javascript:void(0);'>Reload</a></li>");

    function play() {
      $("#playStop a").text("Stop").unbind().click(stop);
      $("#reload").css("display", "inherit");

      $(".captured-image *").css("display", "none");
      var params = {allowscriptaccess: "never", allowfullscreen: "true"};
      swfobject.embedSWF(viewerUrl, "viewer-swf", "465", "465", "9.0.0", false,	{url: codeUrl}, params);
    }

    function stop() {
      $("#playStop a").text("Play").unbind().click(play);
      $("#reload").css("display", "none");
      $(".captured-image *").css("display", "inherit");
      $("#viewer-swf").css("display", "none");
    }

    function reload() {
      stop();
      play();
    }

    $("#reload").css("float", "right");
    $("#playStop").css("float", "right");
    $("#play-button").click(play);
    $("#reload").click(reload);
    stop();
  });
