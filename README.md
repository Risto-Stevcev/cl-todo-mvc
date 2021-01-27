# cl-todo-mvc

This demos how you can setup all the basic building blocks you need to write a web app in common
lisp.

There's a general lack of documentation on how to get everything set up for web apps, so the
motivation behind this is to get people up to speed with everything they need so they can start
hacking with common lisp immediately.


## Installing quicklisp automatically

You can use this command to install quicklisp automatically and avoid the interactive prompt. This
is useful for provisioning.

Download and verify `quicklisp` from the website:

```sh
$ curl -o https://beta.quicklisp.org/release-key.txt
$ gpg --import release-key.txt
```

```sh
$ curl -O https://beta.quicklisp.org/quicklisp.lisp
$ curl -O https://beta.quicklisp.org/quicklisp.lisp.asc
$ gpg --verify quicklisp.lisp.asc quicklisp.lisp
```

And then run:

```sh
$ sbcl --load quicklisp.lisp \
       --eval '(quicklisp-quickstart:install)' \
       --eval '(ql::without-prompting (ql:add-to-init-file))' \
       --eval '(uiop:quit)'
```


## Load the site from the CLI

Make sure that the project is [discoverable by ASDF][1]. The quick and dirty way:

```sh
$ ln -s ~/absolute/path/to/this/project ~/common-lisp/mysite
```

And then run:

```sh
$ sbcl --eval '(ql:quickload :mysite)' --eval '(mysite:main)'
```

**Note**: Because this is a detached instance of the program, you'll need to use `swank` in
conjunction with this command (see code). If you don't then you'll lose one of the biggest value
propositions of common lisp: excellent debugging facilities and fault tolerance via the conditions
and restarts system!

[1]: https://www.common-lisp.net/project/asdf/asdf.html#Configuring-ASDF-to-find-your-systems
