(defpackage mysite
  (:use :cl)
  (:export main swank))

(defpackage mysite.js
  (:use :cl))

; Import arrow macros into parenscript
(parenscript:import-macros-from-lisp 'arrow-macros:->)

(in-package :mysite)


(defvar *app* (make-instance 'ningle:<app>))

;; A dummy hash table of users. This is just a demo, you should use a real database
(defparameter *users* (make-hash-table :test #'equal))

(defun make-user (username pass roles)
  (setf (gethash username *users*)
        (list :pass (cl-pass:hash pass :type :pbkdf2-sha256
                                        :iterations 10000)
              :roles roles)))

(make-user "admin" "admin" (list :user :staff :admin))
(make-user "joe.avg" "pass" (list :user))

(defmacro get-user (username)
  `(gethash ,username *users*))

; Set up hermetic using the dummy hash table
(hermetic:setup
 :user-p #'(lambda (user) (get-user user))
 :user-pass #'(lambda (user) (getf (get-user user) :pass))
 :user-roles #'(lambda (user) (getf (get-user user) :roles))
 :session ningle:*session*
 :denied #'(lambda (&optional params)
             (spinneret:with-html-string (:h1 "Generic auth denied page"))))


;; Logout helper
; Removes the session from the store if the user is logged in
(defmacro logout (on-success on-failure)
  `(progn
     (if (hermetic:logged-in-p)
         (progn (remhash :username ,hermetic::*session*)
                (remhash :roles ,hermetic::*session*)
                ,on-success)
         ,on-failure)))


;; The main page
; It renders the login form, or the welcome page if the user is logged in
; It also demonstrates how to integrate parenscript, which also demos how to use
; existing libraries, in this case how to import arrow macros and use them
(setf (ningle:route *app* "/")
      (lambda (params)
        (if (hermetic:logged-in-p)
            (spinneret:with-html-string
                (:p (format nil "Welcome, ~A!" (hermetic:logged-in-p)))
              (:script :src "app.js")
              (:a :href "/logout" "Logout"))
            (spinneret:with-html-string
                (:form :action "/login" :method "post"
                       "Username:" (:input :type "text" :name :|username|) (:br)
                       "Password:" (:input :type "password" :name :|password|) (:br)
                       (:input :type "submit" :value "Login"))))))


(setf (ningle:route *app* "/login" :method :POST)
      (lambda (params)
        (let* ((username (cdr (assoc "username" params :test #'equal)))
               (password (cdr (assoc "password" params :test #'equal)))
               (params (list :|username| username :|password| password)))
          (hermetic:login params
                          (spinneret:with-html-string (:h1 "You are logged in"))
                          (spinneret:with-html-string (:h1 "Wrong password :c"))
                          (spinneret:with-html-string (:h1 "No such username " username))))))


(setf (ningle:route *app* "/logout" :method :GET)
      (lambda (params)
        (logout
         (spinneret:with-html-string (:h1 "You are logged out"))
         (spinneret:with-html-string (:h1 "You are not logged in.")))))


(setf (ningle:route *app* "/users-only" :method :GET)
      (lambda (params)
        (hermetic:auth (:user)
                       (spinneret:with-html-string (:h1 "If you are seeing this, you are a user.")))))


(setf (ningle:route *app* "/admins-only" :method :GET)
      (lambda (params)
        (hermetic:auth (:admin)
                       (spinneret:with-html-string (:h1 "If you are seeing this, you are an admin."))
                       (spinneret:with-html-string (:h1 "Custom auth denied page. You are not authorized!")))))


(setf (ningle:route *app* "/app.js" :method :GET)
      (lambda (params)
        (declare (ignore params))
        `(200 (:content-type "text/javascript")
              (,(parenscript:ps-compile-file
                 (merge-pathnames #P"src/main.js.lisp" (asdf:system-source-directory :mysite)))))))


(defun main ()
  (progn
    ; Creates a swank server in development -- useful if you're connecting via a container
    ; Remove this if you don't plan on using swank
    (unless (string= (uiop:getenv "LISP_ENV") "PRODUCTION")
      (bt:make-thread (lambda ()
                        (swank:create-server :port 4006))))

    (clack:clackup
     (lack.builder:builder :session *app*)
     :port 8080)))
