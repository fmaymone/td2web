// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

// Rails Built-ins
require("@rails/ujs").start()
require("turbolinks").start()
require("@rails/activestorage").start()
require("channels")

// 3rd-Party Frameworks
global.$ = require("jquery")
require("bootstrap")

// Application javascript components
require("../src/froala_editor")
require("../src/translation_search")
require("../src/translation_editor")
require("../src/team_diagnostic_form")
require("../src/local_persistence")

// Application Stylesheets
require("../stylesheets/application.scss")

// Uncomment to copy all static images under ../images to the output folder and reference
// them with the image_pack_tag helper in views (e.g <%= image_pack_tag 'rails.png' %>)
// or the `imagePath` JavaScript helper below.
//
const images = require.context('../images', true)
const imagePath = (name) => images(name, true)
