import FroalaEditor from 'froala-editor'

import 'froala-editor/js/plugins/align.min.js'
import 'froala-editor/js/plugins/colors.min.js'
import 'froala-editor/js/plugins/emoticons.min.js'
import 'froala-editor/js/plugins/entities.min.js'
import 'froala-editor/js/plugins/font_family.min.js'
import 'froala-editor/js/plugins/font_size.min.js'
import 'froala-editor/js/plugins/help.min.js'
import 'froala-editor/js/plugins/line_breaker.min.js'
import 'froala-editor/js/plugins/lists.min.js'
import 'froala-editor/js/plugins/paragraph_format.min.js'
import 'froala-editor/js/plugins/paragraph_style.min.js'
import 'froala-editor/js/plugins/quote.min.js'
import 'froala-editor/js/plugins/special_characters.min.js'
import 'froala-editor/js/plugins/table.min.js'
import 'froala-editor/js/plugins/url.min.js'
import 'froala-editor/js/plugins/word_paste.min.js'

import 'froala-editor/css/froala_editor.pkgd.min.css'
import 'froala-editor/css/plugins/colors.min.css'
import 'froala-editor/css/plugins/help.min.css'
import 'froala-editor/css/plugins/line_breaker.min.css'
import 'froala-editor/css/plugins/special_characters.min.css'
import 'froala-editor/css/plugins/table.min.css'

window.TranslationEditor = () => {
  const htmlButtonClass = 'translation-value-html-enable'
  const buttons = document.getElementsByClassName(htmlButtonClass)
  for (let i=0; i<=buttons.length;i++) {
    if (buttons[i] != undefined) {
      let textareaid= buttons[i].getAttribute('data-target')
      buttons[i].addEventListener('click', function(e){
        new FroalaEditor('#' + textareaid)
        e.target.style.display = 'none'
      })
    }
  }
}
document.addEventListener("turbolinks:load", window.TranslationEditor)
