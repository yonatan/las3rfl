// $Id: openid_selector_inline.js,v 1.1 2010/10/18 13:27:34 agerasika Exp $

openid.init__inline = openid.init;
openid.init = function(input_id) {
  $("li.openid-link, li.user-link").hide();
  $("#edit-name-wrapper, #edit-pass-wrapper, #edit-openid-identifier-wrapper").css("display", "block");
  this.init__inline(input_id);
  $("#" + this.form_id).append('<br/><hr/>').append($("#edit-openid-identifier-wrapper"));
}

openid.useInputBox__inline = openid.useInputBox;
openid.useInputBox = function(provider) {
  this.useInputBox__inline(provider);
  $('#openid_input_area').append('<input id="openid_submit" type="submit" value="'+this.signin_text+'"/>');
}

openid.final_submit__inline = openid.final_submit;
openid.final_submit = function(inner_form) {
  if (inner_form) {
	  this.final_submit__inline(inner_form);
  } else {
	  // no action
  }
}
