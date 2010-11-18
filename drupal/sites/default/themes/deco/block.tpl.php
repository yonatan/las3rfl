<div id="block-<?php print $block->module .'-'. $block->delta; ?>" class="block block-<?php print $block->module ?><?php print (isset($block->subject) ? ' block-title' : '') ?><?php print ($zebra ? ' block-'.$zebra : '') ?>">  
  <div class="blockinner">
    <?php if (isset($block->subject)): ?><h2 class="title"><?php print $block->subject; ?></h2><?php endif; ?>
    <div class="content">
      <?php print $block->content; ?>
    </div>    
  </div>
</div>
