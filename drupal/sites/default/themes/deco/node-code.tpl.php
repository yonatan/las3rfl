<?php
if ($page == 0) {
  if ($teaser) {
    include 'node-code-teaser.tpl.php'; 
  } else {
    include 'node-code-block.tpl.php'; 
  }
} else {
    include 'node-code-page.tpl.php';
}
