<?php

/**
 * Implementation of hook_content_default_fields().
 */
function las3rfl_code_content_default_fields() {
  $fields = array();

  // Exported field: field_capture
  $fields['code-field_capture'] = array(
    'field_name' => 'field_capture',
    'type_name' => 'code',
    'display_settings' => array(
      'weight' => '31',
      'parent' => '',
      'label' => array(
        'format' => 'above',
      ),
      'teaser' => array(
        'format' => '200x100_linked',
        'exclude' => 0,
      ),
      'full' => array(
        'format' => 'image_plain',
        'exclude' => 0,
      ),
      '4' => array(
        'format' => 'image_plain',
        'exclude' => 0,
      ),
    ),
    'widget_active' => '1',
    'type' => 'filefield',
    'required' => '0',
    'multiple' => '0',
    'module' => 'filefield',
    'active' => '1',
    'list_field' => '0',
    'list_default' => 1,
    'description_field' => '0',
    'widget' => array(
      'file_extensions' => 'png gif jpg jpeg',
      'file_path' => 'capture',
      'progress_indicator' => 'bar',
      'max_filesize_per_file' => '200K',
      'max_filesize_per_node' => '',
      'max_resolution' => '465x465',
      'min_resolution' => '',
      'alt' => '',
      'custom_alt' => 0,
      'title' => '',
      'custom_title' => 0,
      'title_type' => 'textfield',
      'default_image' => array(
        'filename' => 'nocapture.png',
        'filepath' => 'sites/default/files/imagefield_default_images/nocapture.png',
        'filemime' => 'image/png',
        'source' => 'default_image_upload',
        'destination' => 'sites/default/files/imagefield_default_images/nocapture.png',
        'filesize' => 9690,
        'uid' => '1',
        'status' => 1,
        'timestamp' => 1290031730,
        'fid' => '1',
      ),
      'use_default_image' => 1,
      'label' => 'Captured image',
      'weight' => '31',
      'description' => '',
      'type' => 'imagefield_widget',
      'module' => 'imagefield',
    ),
  );

  // Exported field: field_forked_from
  $fields['code-field_forked_from'] = array(
    'field_name' => 'field_forked_from',
    'type_name' => 'code',
    'display_settings' => array(
      'weight' => '32',
      'parent' => '',
      'label' => array(
        'format' => 'above',
      ),
      'teaser' => array(
        'format' => 'default',
        'exclude' => 0,
      ),
      'full' => array(
        'format' => 'default',
        'exclude' => 0,
      ),
      '4' => array(
        'format' => 'default',
        'exclude' => 0,
      ),
    ),
    'widget_active' => '1',
    'type' => 'nodereference',
    'required' => '0',
    'multiple' => '0',
    'module' => 'nodereference',
    'active' => '1',
    'referenceable_types' => array(
      'code' => 'code',
      'forum' => 0,
      'page' => 0,
      'story' => 0,
    ),
    'advanced_view' => '--',
    'advanced_view_args' => '',
    'widget' => array(
      'autocomplete_match' => 'contains',
      'size' => 60,
      'default_value' => array(
        '0' => array(
          'nid' => '',
        ),
      ),
      'default_value_php' => NULL,
      'label' => 'Forked from',
      'weight' => '32',
      'description' => '',
      'type' => 'nodereference_select',
      'module' => 'nodereference',
    ),
  );

  // Translatables
  // Included for use with string extractors like potx.
  t('Captured image');
  t('Forked from');

  return $fields;
}
