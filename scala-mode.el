;;; scala-mode.el - Major mode for editing scala
;;; Copyright (c) 2012 Heikki Vesalainen
;;; For information on the License, see the LICENSE file

;;; Based on Scala Language Specification (SLS) Version 2.9

(provide 'scala-mode)

(require 'scala-mode-lib)
(require 'scala-mode-syntax)
(require 'scala-mode-paragraph)
(require 'scala-mode-indent)
(require 'scala-mode-fontlock)
(require 'scala-mode-map)

;; Tested only for emacs 24
(unless (<= 24 emacs-major-version)
  (error
   (format "The Scala mode has been tested only on Emacs version 24.2 (and not your Emacs version %s.%s)"
           emacs-major-version  emacs-minor-version)))

(defgroup scala nil
  "A programming mode for the Scala language 2.9"
  :group 'languages)

(defmacro scala-mode:make-local-variables (&rest quoted-names)
  (cons 'progn (mapcar #'(lambda (quoted-name) `(make-local-variable ,quoted-name)) quoted-names)))


(defun scala-mode:forward-sexp-function (&optional count)
  (unless count (setq count 1))
  (if (< count 0)
      (dotimes (n (abs count))
        (scala-syntax:backward-sexp))
    (dotimes (n count)
      (scala-syntax:forward-sexp))))

;;;###autoload
(define-derived-mode scala-mode prog-mode "Scala"
  "Major mode for editing scala code.

When started, runs `scala-mode-hook'.

\\{scala-mode-map}"
  :syntax-table scala-syntax:syntax-table
;  :group
;  :abbrev

  (scala-mode:make-local-variables
   'post-self-insert-hook
   'syntax-propertize-function
   'font-lock-syntactic-face-function
   'font-lock-defaults
   'paragraph-start
   'paragraph-separate
   'fill-paragraph-function
   'adaptive-fill-function
   'adaptive-fill-first-line-regexp
   'comment-start
   'comment-end
   'comment-start-skip
   'comment-column
   'comment-multi-line
   'forward-sexp-function
   'indent-line-function
   'indent-tabs-mode)

  (add-hook 'syntax-propertize-extend-region-functions
            'scala-syntax:propertize-extend-region)
  (setq scala-mode:debug-messages       nil

        syntax-propertize-function      'scala-syntax:propertize
        parse-sexp-lookup-properties    t

        ;; TODO: font-lock
        font-lock-defaults              '(scala-font-lock:keywords
                                          nil)
        font-lock-syntactic-face-function 'scala-font-lock:syntactic-face-function

        ;; TODO: beginning-of-defun-function, end-of-defun-function

        ;; comments
        paragraph-start                 scala-paragraph:paragraph-start-re
        paragraph-separate              scala-paragraph:paragraph-separate-re
        fill-paragraph-function         'scala-paragraph:fill-paragraph
        adaptive-fill-function          'scala-paragraph:fill-function
        adaptive-fill-first-line-regexp scala-paragraph:fill-first-line-re
        comment-start                   "// "
        comment-end                     ""
        comment-start-skip              "\\(//+\\|/\\*+\\)[ \t]*"
        comment-column                  0
        comment-multi-line              t

        forward-sexp-function           'scala-mode:forward-sexp-function
        indent-line-function            'scala-indent:indent-line
        indent-tabs-mode                nil
        )
  (use-local-map scala-mode-map)
  (turn-on-font-lock)
  ;; add indent functionality to some characters
  (scala-mode-map:add-self-insert-hooks)
)

;; Attach .scala files to the scala-mode
(add-to-list 'auto-mode-alist '("\\.sbt\\'" . scala-mode))
(modify-coding-system-alist 'file "\\.sbt\\'" 'utf-8)

(add-to-list 'auto-mode-alist '("\\.scala\\'" . scala-mode))
(modify-coding-system-alist 'file "\\.scala\\'" 'utf-8)
