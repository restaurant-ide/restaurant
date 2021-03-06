;;; restaurant-common.el --- common restaurant features  -*- lexical-binding: t -*-

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

(require 'cl-lib)
(require 'user-directories)
(require 'redo+)
(require 'f)
(require 'notify)
(require 'ansi-color)
;; (require 'github-notifier)
;; (require 'popup)
(require 'ssh)

;;;
;;; Global config
;;;

;;;; Global default configuration parameters

(custom-set-variables
 '(yes-or-no-p 'y-or-n-p)   ;replace y-e-s by y
 '(inhibit-startup-message t)   ;no splash screen
 ;; backup
 '(make-backup-files restaurant/autobackup)
 '(use-backup-dir restaurant/autobackup) ;use backup directory
 '(version-control t) ;; Enable versioning with default values (keep five last versions, I think!)
 '(backup-by-copying t)
 '(delete-old-versions t)
 '(backup-directory-alist
   `((".*" . ,restaurant/backup-directory))) ; don't litter my fs tree
 '(auto-save-file-name-transforms
   `((".*" ,restaurant/backup-directory t)))
 `(auto-save-interval ,restaurant/autobackup-interval)
 ;; other
 '(query-replace-highlight t)           ;highlight during query
 '(search-highlight t)                  ;highlight incremental search
 '(ls-lisp-dirs-first t)                ;display dirs first in dired
 '(initial-frame-alist (quote ((fullscreen . maximized)))) ; start maximized
 )

;;;; visual mode
(global-visual-line-mode t) ;; wrap long lines visually to several lines
;; Remove visual line from buffer
(add-hook 'minibuffer-setup-hook '(lambda ()
                                   (visual-line-mode -1)))

;;;; enable cua mode
(defhooklet restaurant/cua-mode emacs-startup restaurant/familiar-copy-paste-cut
  ;; https://www.emacswiki.org/emacs/CuaMode
  (cua-mode t))

(defhooklet restaurant/cua-mode text-mode restaurant/familiar-copy-paste-cut
  (cua-mode t))

(defhooklet restaurant/cua-mode prog-mode restaurant/familiar-copy-paste-cut
  (cua-mode t))

(custom-set-variables
;;;; Sync linux and eamcs clipboards
 ;; after copy Ctrl+c in Linux X11, you can paste by `yank' in emacs
 '(x-select-enable-clipboard t)

 ;; after mouse selection in X11, you can paste by `yank' in emacs
 '(x-select-enable-primary t)
 )

;;;; Move lines/regions up/down
(require 'drag-stuff)
(drag-stuff-global-mode 1)
;; Drag line
;; To drag a line up and down. Put the cursor on that line and press <M-up> and <M-down>.
;; Drag lines
;; To drag several lines up and down. Select the lines you want to drag and press <M-up> and <M-down>.
;; Drag region
;; A region can be dragged to the left and right. Select the region you want to drag and press <M-left> and <M-right>.
;; Drag word
;; To drag a word. Place the cursor on the word and press <M-left> and <M-right>.
;; For more information, see comments in drag-stuff.el.

;;;; Recently edited files in menu
(recentf-mode 1)

;;;; Dired customizations
(setq dired-listing-switches "-Al")

;;;; Word completion customizations
(setq dabbrev-always-check-other-buffers t)
;; (setq dabbrev-abbrev-char-regexp "\\sw\\|\\s_")

;; load cedet components
(load "cedet")
(load "semantic")
(load "srecode")
(load "eieio")
(load "ede")

;; move semanticDB, srecode and ede to cache
(mkdir restaurant/user-cache-directory t)
(custom-set-variables
 '(ede-project-placeholder-cache-file (locate-user-cache-file "restaurant-ede-projects.el"))
 '(semanticdb-default-save-directory (locate-user-cache-file "restaurant-semanticdb"))
 '(srecode-map-save-file (locate-user-cache-file "restaurant-srecode-map.el")))

;; setup semantic/imenu autorefresh
(custom-set-variables
 '(imenu-auto-rescan t)
 )

;; semantic global mode
(global-semantic-idle-completions-mode t)
(global-semantic-decoration-mode t)
(global-semantic-highlight-func-mode t)
(global-semantic-show-unmatched-syntax-mode t)

;;;; Column & line numbers in mode bar
(column-number-mode t)
(line-number-mode t)

;;;; Tabbar mode
(when restaurant/enable-tabbar
  (tabbar-mode 1)
  (setq tabbar-use-images nil)
  (global-set-key [S-left] 'tabbar-backward-tab)
  (global-set-key [S-right] 'tabbar-forward-tab))


;;;; Set visible bell
(setq visible-bell t)

;; ;; set frame (window in window-managers terms) size
;; (when window-system (set-frame-size (selected-frame) 190 96))

;;;; Set time format to display
(load-library "time")
(setq display-time-24hr-format t
      display-time-mail-file t
      display-time-form-list (list 'time 'load)
      display-time-day-and-date t)
(display-time)

;;;;
;;;; helm
;;;;
(require 'helm-config)
(require 'helm-grep)
(require 'helm-themes)

;; To fix error at compile:
;; Error (bytecomp): Forgot to expand macro with-helm-buffer in
;; (with-helm-buffer helm-echo-input-in-header-line)
(if (version< "26.0.50" emacs-version)
    (eval-when-compile (require 'helm-lib)))

(setq helm-candidate-number-limit 100)

(setq helm-idle-delay 0.0 ; update fast sources immediately (doesn't).
      helm-input-idle-delay 0.01	; this actually updates things
                                        ; reeeelatively quickly.
      helm-yas-display-key-on-candidate t
      helm-quick-update t
      helm-M-x-requires-pattern nil
      helm-ff-skip-boring-files t)

(global-set-key (kbd "M-x") 'helm-M-x)
(global-set-key (kbd "C-x r b") #'helm-filtered-bookmarks)
(global-set-key (kbd "C-x C-f") #'helm-find-files)
(global-set-key (kbd "M-y") 'helm-show-kill-ring)

(helm-mode 1)

;;; helm-swoop
(require 'helm-swoop)

;; Change the keybinds to whatever you like :)
(global-set-key (kbd "M-i") 'helm-swoop)
(global-set-key (kbd "M-I") 'helm-swoop-back-to-last-point)
;; (global-set-key (kbd "C-c M-i") 'helm-multi-swoop) ;; FIXME: not working for unknown reason
;; (global-set-key (kbd "C-x M-i") 'helm-multi-swoop-all)

;; When doing isearch, hand the word over to helm-swoop
(define-key isearch-mode-map (kbd "M-i") 'helm-swoop-from-isearch)
;; From helm-swoop to helm-multi-swoop-all
(define-key helm-swoop-map (kbd "M-i") 'helm-multi-swoop-all-from-helm-swoop)
;; When doing evil-search, hand the word over to helm-swoop
;; (define-key evil-motion-state-map (kbd "M-i") 'helm-swoop-from-evil-search)

;; Instead of helm-multi-swoop-all, you can also use helm-multi-swoop-current-mode
;; (define-key helm-swoop-map (kbd "M-m") 'helm-multi-swoop-current-mode-from-helm-swoop) ;; FIXME: not working for unknown reason

;; Move up and down like isearch
(define-key helm-swoop-map (kbd "C-r") 'helm-previous-line)
(define-key helm-swoop-map (kbd "C-s") 'helm-next-line)
(define-key helm-multi-swoop-map (kbd "C-r") 'helm-previous-line)
(define-key helm-multi-swoop-map (kbd "C-s") 'helm-next-line)

;; Save buffer when helm-multi-swoop-edit complete
(setq helm-multi-swoop-edit-save t)

;; If this value is t, split window inside the current window
(setq helm-swoop-split-with-multiple-windows nil)

;; Split direcion. 'split-window-vertically or 'split-window-horizontally
(setq helm-swoop-split-direction 'split-window-vertically)

;; If nil, you can slightly boost invoke speed in exchange for text color
(setq helm-swoop-speed-or-color nil)

;; ;; Go to the opposite side of line from the end or beginning of line
(setq helm-swoop-move-to-line-cycle t)

;; Optional face for line numbers
;; Face name is `helm-swoop-line-number-face`
(setq helm-swoop-use-line-number-face t)

;; If you prefer fuzzy matching
(setq helm-swoop-use-fuzzy-match t)

;; (helm-linum-relative-mode 1)

;; set key to enable whitespace mode
(global-set-key (kbd "C-c w") 'whitespace-mode)
(global-set-key (kbd "C-c C-w") 'whitespace-mode)

;;;; If we read a compressed file, uncompress it on the fly:
;;;; (this works with .tar.gz and .tgz file as well)
(custom-set-variables
 '(auto-compression-mode 1))

;;;; fill-column
(defun restaurant/fill-column ()
  (when restaurant/fill-column
    (setq-default fill-column restaurant/max-line-length)))

(add-hook 'prog-mode-hook 'restaurant/fill-column)

;;;; Uniquify buffers
(require 'uniquify)
(setq uniquify-buffer-name-style 'reverse)

;;;
;;; Prog mode configuration
;;;

(defvar restaurant-max-line-length (concat "^[^\n]\\{"
             (number-to-string restaurant/max-line-length)
             "\\}\\(.*\\)$"))

;;;
;;; activate generic options
;;;
(require 'magit)
(require 'magit-gh-pulls)

(defhooklet restaurant/generic-prog-mode-improvements prog-mode t
  ;; highlight FIXME/TODO/BUG keywords
  (font-lock-add-keywords nil '(("\\<\\(FIXME\\|TODO\\|BUG\\):" 1 font-lock-warning-face t)))
  (font-lock-add-keywords nil '(("\\<\\(DONE\\):" 1 font-lock-doc-face t)))
  ;; auto-fill mode
  (auto-fill-mode -1)
  ;; projectile
  (require 'projectile)
  
  ;;
  (subword-mode 1)
  (font-lock-mode 1)
  ;; Drag and move selcted
  (drag-stuff-mode 1)
  ;; set global indent-tabs-mode
  (setq indent-tabs-mode restaurant/indent-tabs-mode)
  ;; highlight-symbol-mode
  (highlight-symbol-mode restaurant/highlight-symbol)

  (local-set-key (kbd "C-c C-f") 'flash-cross)
  (local-set-key (kbd "RET") 'newline-and-indent)

  (message "Prog mode enabled. USE Shift+SPACE to show or hide blocks"))

;; Remove trailing whitespaces
(defhooklet restaurant/delete-trailing-whitespaces before-save t
  (delete-trailing-whitespace 1))

;;
(when (and restaurant/check-parens-before-save buffer-file-name)
  (add-hook 'before-save-hook
      'check-parens
      nil t))

;; magit-gh-pulls
(add-hook 'magit-mode-hook 'turn-on-magit-gh-pulls)
;;;
;;; indicate paren
;;;
(defhooklet restaurant/parenth-management prog-mode restaurant/indicate-parentheses
  (require 'paren)
  (require 'highlight-parentheses)
  ;; show pait to current parenth
  (show-paren-mode 1)
  (setq show-paren-delay 0)
  ;; indicate other parentheses
  (highlight-parentheses-mode 1)
  ;; 'parenthesis of 'expression highlight just parens/highlight entire expression
  (setq show-paren-style 'parenthesis))

;;;
;;; linum
;;;
(defhooklet restaurant/linum prog-mode restaurant/linum-mode
    (require 'linum)
    (linum-mode 1))

;;;
;;; highlight-current-column
;;;
(defhooklet restaurant/highlight-current-column prog-mode restaurant/highlight-current-column
  (require 'col-highlight)
  (column-highlight-mode 1))

;;;
;;; highlight-current-line
;;;
(defhooklet restaurant/hl-line prog-mode restaurant/highlight-current-line
    (require 'hl-line+)
    (hl-line-mode 1))

;;;
;;; nyan
;;;
(defhooklet restaurant/nyan prog-mode restaurant/why-so-serious
    (nyan-mode 1))

;;;
;;; fill-column-indicator
;;;
(defvar restaurant-last-max-line-length restaurant/max-line-length)

(defhooklet restaurant/fill-column-indicator prog-mode restaurant/fill-column
  (require 'fill-column-indicator)
  (fci-mode 1)
  (setq fci-rule-column restaurant/max-line-length)
  ;; highlight too long lines
  (when restaurant/highlight-too-long-lines
    (let ((restaurant-max-line-length (concat "^[^\n]\\{"
                (number-to-string restaurant/max-line-length)
                "\\}\\(.*\\)$"))
    (restaurant-previous-max-line-length (concat "^[^\n]\\{"
                   (number-to-string restaurant-last-max-line-length)
                   "\\}\\(.*\\)$")))
      (font-lock-remove-keywords nil (list (list (concat "^[^\n]\\{" restaurant-previous-max-line-length "\\}\\(.*\\)$") 1 font-lock-warning-face t)))
      (font-lock-add-keywords nil (list (list restaurant-max-line-length 1 font-lock-warning-face t)))))
  (setq restaurant-max-line-length restaurant/max-line-length))

;;;
;;; hideshow
;;;
(defhooklet restaurant/hideshow prog-mode restaurant/enable-hide-show-blocks
  (require 'hideshow)
  (require 'hideshowvis)
  (hs-minor-mode 1)
  (hideshowvis-enable)
  (hideshowvis-symbols)
  (hs-hide-initial-comment-block)
  (local-set-key (kbd "S-SPC") 'hs-toggle-hiding))

;;;
;;; ispell
;;;
;; (defhooklet restaurant/ispell prog-mode restaurant/enable-spell-checking
;;   (flyspell-prog-mode)) ;; Check strings for spelling errors

;;;
;;; projectile
;;;
(require 'projectile)
(projectile-global-mode 1)
;; use helm with projectile
(helm-projectile-on)
(setq projectile-completion-system 'helm)
(setq projectile-indexing-method 'alien)

;;;
;;; require-final-newline
;;;
(defhooklet restaurant/require-final-newline prog-mode restaurant/require-final-newline
  (setq require-final-newline 1))

;;;
;;; indent-level
;;;
(defhooklet restaurant/indent-level prog-mode t
  (custom-set-variables
   '(standard-indent restaurant/indent-level)))

;;;
;;; ssh
;;;
(defhooklet restaurant/ssh ssh-mode t
  (setq ssh-directory-tracking-mode t)
  (shell-dirtrack-mode t)
  (setq dirtrackp nil))

;;;
;;; Ediff customizations
;;;
(setq ediff-ignore-similar-regions t)
(setq ediff-use-last-dir t)
(setq ediff-diff-options " -b ")

;;;
;;; common compilation options
;;;

;;;; Notify result from compilation buffer
(add-to-list 'compilation-finish-functions
       'notify-compilation-result)

;;;
;;; helm-swoop
;;;
;; (require 'helm-swoop)
;; (global-set-key (kbd "C-M-S") 'helm-swoop)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; set some generic keys
(global-set-key (kbd "<f12>") 'open-console)
(global-set-key (kbd "<S-f12>") 'ielm)

(global-set-key (kbd "<f7>") 'isearch-forward)
(global-set-key (kbd "<S-f7>") 'highlight-regexp)
(global-set-key (kbd "<C-S-f7>") 'unhighlight-regexp)
(global-set-key (kbd "<M-f7>") 'projectile-grep)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;
;;; initialize package
;;;
(require 'package)

(setq package-archives '(("gnu" . "http://elpa.gnu.org/packages/")
                         ("marmalade" . "http://marmalade-repo.org/packages/")
                         ("melpa" . "http://melpa.milkbox.net/packages/")
       ("org" . "http://orgmode.org/elpa/")))

(package-initialize)

;;;
;;; automatically remove old backups
;;;
(when restaurant/clear-autobackups
  (message "Deleting old backup files...")
  (let ((week (* 60 60 24 7))
  (current (float-time (current-time))))
    (dolist (file (directory-files temporary-file-directory t))
      (when (and (backup-file-name-p file)
     (> (- current (float-time (fifth (file-attributes file))))
        week))
  (message "%s" file)
  (delete-file file)))))

;; set scratch message
(setq initial-scratch-message ";; Welcome to Restaurant's CUTTING BOARD\n;; Feel free to use it, like your scratchpad\n;; and perform temporary text editings here\n")

(defhooklet restaurant/rename-scratch-buffer after-change-major-mode t
  ;; Rename scratch buffer
  (if (and (get-buffer "*scratch*") (not (get-buffer "scratch")))
      (with-current-buffer "*scratch*"
  (rename-buffer "*cutting-board*")
  ;;
  (insert (propertize initial-scratch-message)))))

;;; restaurant-common.el ends here
