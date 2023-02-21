# Pin npm packages by running ./bin/importmap

pin "application", preload: true
pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true
pin "@hotwired/stimulus", to: "stimulus.min.js", preload: true
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true
pin_all_from "app/javascript/controllers", under: "controllers"
pin "trix"
pin "@rails/actiontext", to: "actiontext.js"
pin "@tailwindcss/line-clamp", to: "https://ga.jspm.io/npm:@tailwindcss/line-clamp@0.4.0/src/index.js"
pin "tailwindcss/plugin", to: "https://ga.jspm.io/npm:tailwindcss@3.1.6/plugin.js"