;;; ruby.el --- ruby language support  -*- lexical-binding: t -*-

;; Copyright (C) 2016 Alexander aka 'CosmonauT' Vynnyk

;; Maintainer: cosmonaut.ok@zoho.com
;; Keywords: internal
;; Package: restaurant

;; This file is part of Restaurant.

;; Restaurant is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; Restaurant is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with Restaurant.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; TODO:

;;; Code:

;;; Package --- Restaurant

;;; Commentary:

;;; Code:

;;;
;;; Generic
;;;

(require 'enh-ruby-mode)
(require 'ruby-mode)

;; inf-ruby and robe

(defvar restaurant/ruby-present-p nil)
(if (and
     (executable-find "ruby")
     (or (executable-find "irb")
	 (executable-find "pry")))
    (progn
      (require 'robe)
      (require 'inf-ruby)
      (when (executable-find "pry")
	(setq inf-ruby-default-implementation "pry"))
      (inf-ruby)
      (when (executable-find "pry")
	(robe-start))
      (custom-set-variables '(restaurant/ruby-present-p t)))
  (warn "WARNING! ``Ruby'' and/or ``irb'' are not installed in your system. You can install it, by clicking ``Menu'' -> ``Help'' -> ``Install Restaurant required dependencies'',\nor via RVM (``Menu'' -> ``Tools'' -> ``RVM'' -> ``install gemfile'' -> ``irb'') and irb/pry via gems or in your preferred way, else only restricted ruby support available"))

;; (defalias 'ruby-mode 'enh-ruby-mode)

;; Adapted from the method used by TextMate, this library provides a command
;; ruby-toggle-hash-syntax which attempts to automatically convert the
;; selected region of ruby code between 1.8 and 1.9 hash styles.
(require 'ruby-hash-syntax)

(if restaurant/ruby-present-p
    ;; add auto-modes
    (add-auto-mode 'enh-ruby-mode
		   "Rakefile\\'" "\\.rake\\'" "\\.rxml\\'" "\\/spec\\/" "\\.rb\\'"
		   "\\.rjs\\'" "\\.irbrc\\'" "\\.pryrc\\'" "\\.builder\\'" "\\.ru\\'"
		   "\\.gemspec\\'" "Gemfile\\'")
  (add-auto-mode 'ruby-mode
		 "Rakefile\\'" "\\.rake\\'" "\\.rxml\\'" "\\/spec\\/" "\\.rb\\'"
		 "\\.rjs\\'" "\\.irbrc\\'" "\\.pryrc\\'" "\\.builder\\'" "\\.ru\\'"
		 "\\.gemspec\\'" "Gemfile\\'")
  )

(eval-after-load 'enh-ruby-mode
  '(define-key ruby-mode-map (kbd "TAB") 'indent-for-tab-command))

(eval-after-load 'ruby-mode
  '(define-key ruby-mode-map (kbd "TAB") 'indent-for-tab-command))

(when restaurant/ruby-present-p
  (eval-after-load 'enh-ruby-mode
    '(define-key enh-ruby-mode-map (kbd "TAB") 'indent-for-tab-command)))

(defhooklet restaurant/ruby-indent (enh-ruby-mode ruby-mode) t
  (custom-set-variables
   ;; set ruby indent level
   '(ruby-indent-level restaurant/indent-level)
   ;; set ruby indent tabs mode
   '(ruby-indent-tabs-mode restaurant/indent-tabs-mode)))

;;;; When folding, take these delimiters into consideration
(add-to-list 'hs-special-modes-alist
             '(ruby-mode
               "\\(class\\|def\\|do\\|if\\|.each\\)" "\\(end\\)" "#"
               (lambda (arg) (ruby-end-of-block)) nil))

(add-to-list 'hs-special-modes-alist
             '(enh-ruby-mode
               "\\(class\\|def\\|do\\|if\\|.each\\)" "\\(end\\)" "#"
               (lambda (arg) (ruby-end-of-block)) nil))

(defhooklet restaurant/ruby-generic enh-ruby-mode t
  (inf-ruby-minor-mode 1)
  (local-set-key (kbd "<C-f12>") 'ruby-switch-to-inf)
  )

;;;
;;; ruby-electric
;;;
(defhooklet restaurant/ruby-electric (enh-ruby-mode ruby-mode) restaurant/enable-electric
  (require 'ruby-electric)
  (ruby-electric-mode t))

;;;
;;; ruby-tools
;;;
(defhooklet restaurant/ruby-tools (enh-ruby-mode ruby-mode) restaurant/enable-ruby-tools
  (require 'ruby-tools)
  (ruby-tools-mode 1))

;;;
;;; ruby-refactor
;;;
(defhooklet restaurant/ruby-refactor (enh-ruby-mode ruby-mode) restaurant/enable-ruby-refactor
  (require 'ruby-refactor)
  (ruby-refactor-mode-launch))

;;;
;;; robe mode: code navigtion, documentation
;;;
(defhooklet restaurant/robe-ruby (enh-ruby-mode inf-ruby-mode html-erb-mode) restaurant/enable-robe
  (custom-set-variables
   '(robe-turn-on-eldoc t))
  (robe-mode 1)
  ;; integrate with company mode
  (require 'company-robe)
  (restaurant/local-push-company-backend 'company-robe))

;;;
;;; inf-ruby-mode
;;;
(defhooklet restaurant/inf-ruby (enh-ruby-mode inf-ruby-mode html-erb-mode) t
  (inf-ruby-minor-mode t)
  (require 'company-inf-ruby)
  (restaurant/local-push-company-backend 'company-inf-ruby))

(defhooklet restaurant/inf-ruby-with-debugging-development compilation-filter t
  (inf-ruby-auto-enter))

;;;
;;; rubocop
;;;
;; patch for original rubocop.el

(defun rubocop-bundled-p ()
  "Check if RuboCop has been bundled."
  (let ((gemfile-lock (expand-file-name "Gemfile.lock" (rubocop-project-root))))
    (when (and (file-exists-p gemfile-lock) restaurant/enable-bundler)
      (with-temp-buffer
        (insert-file-contents gemfile-lock)
        (re-search-forward "rubocop" nil t)))))

(defun rubocop-chefdked-p ()
  (and restaurant/enable-chef restaurant/enable-chefdk (file-directory-p restaurant/chefdk-home)))

(defun rubocop-build-command (command path)
  "Build the full command to be run based on COMMAND and PATH.
The command will be prefixed with `bundle exec` if RuboCop is bundled."
  (concat
   (cond ((rubocop-chefdked-p)
	  (concat
	   (file-name-as-directory restaurant/chefdk-home)
	   (file-name-as-directory "bin")
	   "chef" "exec "))
	 ((rubocop-bundled-p) "bundle exec ")
	 (t ""))
   command
   (rubocop-build-requires)
   " "
   path))

;; /patch for original rubocop.el

(defhooklet restaurant/rubocop enh-ruby-mode restaurant/enable-rubocop
  (require 'rubocop)
  (rubocop-mode 1)
  (auto-revert-mode 1) ;; TODO: is it needed here?
  (custom-set-variables
   '(rubocop-check-command "rubocop -r cookstyle -D --format emacs")
   )
  (local-set-key (kbd "<f6>") 'rubocop-check-project)
  (local-set-key (kbd "<S-f6>") 'rubocop-check-current-file)
  )

;;;
;;; flycheck
;;;
(defhooklet restaurant/flycheck-ruby restaurant/enable-flycheck
  ;; (require 'flycheck) already activated in prog-mode
  ;; (setq flycheck-disabled-checkers restaurant/flycheck-disabled-checkers)
  ;; (setq flycheck-check-syntax-automatically '(save mode-enabled))
  (flycheck-mode 1))

;;;
;;; flymake
;;;
;; (defhooklet restaurant/flymake-ruby enh-ruby-mode restaurant/enable-flymake
;;   ;; (require 'flymake) already activated in prog-mode
;;   (require 'flymake-ruby)
;;   (flymake-ruby-load) ;; FIXME: not loading automatically
;;   (flymake-mode 1))

;;;
;;; ri
;;;
(defhooklet restaurant/ri-yari enh-ruby-mode restaurant/enable-ri
  (require 'yari)
  (defalias 'ri 'yari)
  (local-set-key [f1] 'yari))

;;;
;;; ruby-block-mode
;;;
(defhooklet restaurant/ruby-block enh-ruby-mode t
  (require 'ruby-block)
  (ruby-block-mode 1)
  (custom-set-variables
   '(ruby-block-delay 0)
   '(ruby-block-highlight-toggle t)))

;;;
;;; RVM form enh-ruby-mode
;;;
(defhooklet restaurant/ruby-rvm enh-ruby-mode restaurant/enable-rvm
  ;; (rvm-use-default)
  (require 'rvm)
  ;; connect rvm+robe
  (when restaurant/enable-robe
    (defadvice inf-ruby-console-auto (before activate-rvm-for-robe activate)
      (rvm-activate-corresponding-ruby))))

;;; ruby.el ends here
