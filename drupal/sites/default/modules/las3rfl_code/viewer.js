$(function() {
    var modulePath = Drupal.settings.basePath + Drupal.settings.modulePath + '/';

    $("ul.tabs.primary").append(
      "<li id='playStop'><a href='javascript:void(0);'>Play</a></li>" +
      "<li id='reload'><a href='javascript:void(0);'>Reload</a></li>");

    function play() {
      $("#playStop a").text("Stop").unbind().click(stop);
      $("#reload").css("display", "inherit");

      $(".captured-image *").css("display", "none");
      // TODO: remove cachebuster
      swfobject.embedSWF(modulePath + "Viewer.swf?" + (new Date).getTime(), "viewer-swf", "465", "465", "9.0.0", null, {nid: Drupal.settings.nid});
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
