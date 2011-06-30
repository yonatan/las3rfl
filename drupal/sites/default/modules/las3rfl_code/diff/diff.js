$(function() {
    var container = $("#main");
    if(container.length == 0) container = $("body");
    container.css("padding", "0");
    var a = difflib.stringAsLines($("#diff-left").text());
    var b = difflib.stringAsLines($("#diff-right").text());
    var aTitle = $("#diff-left-title").text();
    var bTitle = $("#diff-right-title").text();
    var sm = new difflib.SequenceMatcher(a, b);
    var opcodes = sm.get_opcodes();
    container.empty();
    container.append(
      diffview.buildView(
	{
	  baseTextLines: a,
	  newTextLines: b,
	  opcodes: opcodes,
	  baseTextName: aTitle,
	  newTextName: bTitle,
	  viewType: 0
	}));
    container.find("tr:odd").addClass("odd");
    container.find("tr:even").addClass("even");
  });