(defsystem "mysite"
  :version "0.1.0"
  :author "Risto Stevcev"
  :license "MIT"
  :depends-on (:alexandria
               :arrow-macros
               :clack
               :hunchentoot
               :ningle
               :hermetic
               :spinneret
               :parenscript
               :trivia
               :postmodern
               :swank)
  :components ((:module "src"
                :components
                ((:file "main"))))
  :description "My personal website")
