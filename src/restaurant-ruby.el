;;; ruby.el --- TODO:  -*- lexical-binding: t -*-

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

(require 'enh-ruby-mode)
;; (defalias 'ruby-mode 'enh-ruby-mode)

;; inf-ruby and robe
(require 'robe)
(require 'inf-ruby)
(inf-ruby)
(robe-start)

;;;
;;; Generic
;;;

;; Adapted from the method used by TextMate, this library provides a command
;; ruby-toggle-hash-syntax which attempts to automatically convert the
;; selected region of ruby code between 1.8 and 1.9 hash styles.
(require 'ruby-hash-syntax)

;; add auto-modes
(add-auto-mode 'enh-ruby-mode
               "Rakefile\\'" "\\.rake\\'" "\\.rxml\\'" "\\/spec\\/" "\\.rb\\'"
               "\\.rjs\\'" "\\.irbrc\\'" "\\.pryrc\\'" "\\.builder\\'" "\\.ru\\'"
               "\\.gemspec\\'" "Gemfile\\'")

(eval-after-load 'ruby-mode
  '(define-key enh-ruby-mode-map (kbd "TAB") 'indent-for-tab-command))


(defhooklet restaurant/ruby-indent enh-ruby-mode t
  (custom-set-variables
   ;; set ruby indent level
   '(ruby-indent-level restaurant/indent-level)
   ;; set ruby indent tabs mode
   '(ruby-indent-tabs-mode restaurant/indent-tabs-mode)))

;;;
;;; ruby-electric
;;;
(defhooklet restaurant/ruby-electric enh-ruby-mode restaurant/enable-electric
  (require 'ruby-electric)
  (ruby-electric-mode t))

;;;
;;; ruby-tools
;;;
(defhooklet restaurant/ruby-tools enh-ruby-mode restaurant/enable-ruby-tools
  (require 'ruby-tools)
  (ruby-tools-mode 1))

;;;
;;; ruby-refactor
;;;
(defhooklet restaurant/ruby-refactor enh-ruby-mode restaurant/enable-ruby-refactor
  (require 'ruby-refactor)
  (ruby-refactor-mode-launch))

;;;
;;; robe mode: code navigtion, documentation
;;;
(defhooklet restaurant/robe-ruby enh-ruby-mode restaurant/enable-robe
  (custom-set-variables
   '(robe-turn-on-eldoc t))
  (robe-mode 1)
  ;; integrate with company mode
  (require 'company-robe)
  (restaurant/local-push-company-backend 'company-robe))

(defhooklet restaurant/robe-inf-ruby inf-ruby-mode restaurant/enable-robe
  (custom-set-variables
   '(robe-turn-on-eldoc t))
  (robe-mode 1)
  ;; integrate with company mode
  (require 'company-robe)
  (restaurant/local-push-company-backend 'company-robe))

(defhooklet restaurant/robe-erb html-erb-mode restaurant/enable-robe
  (custom-set-variables
   '(robe-turn-on-eldoc t))
  (robe-mode 1)
  ;; integrate with company mode
  (require 'company-robe)
  (restaurant/local-push-company-backend 'company-robe))

;;;
;;; inf-ruby-mode
;;;
(defhooklet restaurant/inf-ruby enh-ruby-mode t
  (inf-ruby-minor-mode t)
  (require 'company-inf-ruby)
  (restaurant/local-push-company-backend 'company-inf-ruby))

(defhooklet restaurant/inf-ruby-inf inf-ruby-mode t
  (inf-ruby-minor-mode t)
  (require 'company-inf-ruby)
  (restaurant/local-push-company-backend 'company-inf-ruby))

(defhooklet restaurant/inf-ruby-erb html-erb-mode t
  (inf-ruby-minor-mode t)
  (require 'company-inf-ruby)
  (restaurant/local-push-company-backend 'company-inf-ruby))

(defhooklet restaurant/inf-ruby-with-debugging-development compilation-filter t
  (inf-ruby-auto-enter))

;;;
;;; rubocop
;;;
(defhooklet restaurant/rubocop enh-ruby-mode restaurant/enable-rubocop
  (require 'rubocop)
  (rubocop-mode 1)
  (auto-revert-mode 1) ;; TODO: is it needed here?
  )

;;;
;;; flycheck
;;;
(defhooklet restaurant/flycheck-ruby restaurant/enable-flycheck
  ;; (require 'flycheck) already activated in prog-mode
  (flycheck-mode 1)
  (setq-default flycheck-check-syntax-automatically '(save mode-enabled)))

;;;
;;; flymake
;;;
(defhooklet restaurant/flymake-ruby enh-ruby-mode restaurant/enable-flymake
  ;; (require 'flymake) already activated in prog-mode
  (require 'flymake-ruby)
  (flymake-ruby-load) ;; FIXME: not loading automatically
  (flymake-mode 1))

;;;
;;; ri
;;;
(defhooklet restaurant/ri-yari enh-ruby-mode restaurant/enable-ri
  (require 'yari)
  (defalias 'ri 'yari)
  (local-set-key [f1] 'yari-helm))

;;;
;;; generic init
;;;
;; When folding, take these delimiters into consideration
(add-to-list 'hs-special-modes-alist
             '(ruby-mode
               "\\(class\\|def\\|do\\|if\\|.each\\)" "\\(end\\)" "#"
               (lambda (arg) (ruby-end-of-block)) nil))

(defhooklet restaurant/ruby-generic enh-ruby-mode t
  (inf-ruby-minor-mode 1)
  (when (executable-find "pry")
    (setq inf-ruby-default-implementation "pry")))

;;;
;;; ruby-block-mode
;;;
(defhooklet restaurant/ruby-block enh-ruby-mode t
  (require 'ruby-block)
  (custom-set-variables
   '(ruby-block-delay 0)
   '(ruby-block-highlight-toggle t)))

;;;
;;; RVM form enh-ruby-mode
;;;
(defhooklet restaurant/ruby-rvm enh-ruby-mode restaurant/enable-rvm
  (rvm-use-default)
  (require 'rvm)
  ;; connect rvm+robe
  (when restaurant/enable-robe
    (defadvice inf-ruby-console-auto (before activate-rvm-for-robe activate)
      (rvm-activate-corresponding-ruby))))

;;; ruby.el ends here