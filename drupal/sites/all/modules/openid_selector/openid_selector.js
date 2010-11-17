// $Id: openid_selector.js,v 1.4 2010/10/18 13:27:34 agerasika Exp $

if (providers_large.openid) {
  providers_large.openid.label = '<a href="http://openid.net/">' + Drupal.t('What is OpenID?') + '</a>';
  providers_large.openid.url = '{username}';
} else
if (providers_small.openid) {
  providers_small.openid.label = '<a href="http://openid.net/">' + Drupal.t('What is OpenID?') + '</a>';
  providers_small.openid.url = '{username}';
}

openid.init__ = openid.init;
openid.init = function(input_id) {
  openid.img_path = Drupal.settings.basePath + Drupal.settings.openid_selector.img_path;
  openid.all_small = Drupal.settings.openid_selector.form_id == 'user-login-form';
  openid.form_id = Drupal.settings.openid_selector.form_id;
  $('#edit-openid-identifier').val('')[0].id = 'old-edit-openid-identifier';
  $('#edit-openid-identifier-wrapper')
      .wrapInner('<div style="display: none;"/>')
      .prepend(
          '<div id="edit-openid-identifier"/> \
           <form action="javascript:openid_inner_submit()" \
              id="openid_form" style="display: inline;"> \
              <div id="openid_choice">\
                 <p>' + (this.intro_text ? this.intro_text : Drupal.t('Click your account provider:')) + '</p>\
                 <div id="openid_btns"/>\
                 <div id="openid_input_area" class="form-item"/> \
             </div> \
           </form>');
  this.init__(input_id);
  $('#' + this.form_id).submit(openid_outer_submit);
}

function openid_outer_submit() {
  openid.final_submit(false);
}

function openid_inner_submit() {
  openid.final_submit(true);
}

openid.final_submit = function(inner_form) {
  openid.submit();
  if ($('#edit-openid-identifier-wrapper:visible').length > 0) {
    var val = $('#' + this.input_id).val();
    if (val != null && val.indexOf("javascript:") == 0) {
      val = val.substr("javascript:".length);
      eval(val);
    } else {
      $('#old-edit-openid-identifier').val(val);
      if (inner_form) {
        $('#' + this.form_id).submit(); // submit outer form
      } else {
        // no action to avoid recursion
      }
    }
  }
}

// ui customization, overrides openid methods
openid.useInputBox = function(provider) {
  var is_block = this.form_id == 'user-login-form';
  var is_openid = provider['name'] == 'OpenID';
  $('#openid_input_area')
      .empty()
      .append(
          '<label for="openid_username">' +
          		Drupal.t('Log in with !provider:', {'!provider': provider['name']})
              + '</label> \
           <input id="openid_username" type="text" style="'
              + (is_openid ? 'background:#FFF url('
                  + this.img_path
                  + 'openid-inputicon.gif) no-repeat scroll 0 50%; padding-left:18px;'
                  : '') + '" name="openid_username" value="'
              + (is_openid ? 'http://' : '') + '" maxlength="255" size="'
              + (is_block ? 15 : 58)
              + '" class="form-text"/> \
           <div class="description">'
              + provider['label'] + '</div>');
  $('#openid_username').focus();
}

openid.getBoxHTML__ = openid.getBoxHTML;
openid.getBoxHTML = function (box_id, provider, box_size, index) {
  if (this.all_small && box_size == 'small' && index == 10 - (providers_large.facebook ? 1 : 0) - (providers_large.drupal ? 1 : 0)) {
	  return '<br/>' + this.getBoxHTML__(box_id, provider, box_size, index);
  }
  return this.getBoxHTML__(box_id, provider, box_size, index);
}

Drupal.behaviors.openid_selector = function (context) {
  if (openid.initialized) {
    return;
  }
  if (openid.version != '1.2') {
    alert(Drupal.t('Website configuration error:') + '\n' +
        Drupal.t('Drupal OpenID Selector requires Javascript OpenID Selector !version', {'!version': '1.2'}) + '\n' +
        Drupal.t('Please contact website administrator.'));
    return;
  }
  openid.init('openid_url');
  openid.initialized = true;
};
