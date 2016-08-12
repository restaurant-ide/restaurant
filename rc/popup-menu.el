(defun choose-from-menu (menu-title menu-items)
  "Choose from a list of choices from a popup menu.
See `popup-commands' which calls this"
  (let ((item)
	(item-list))
    (while menu-items
      (setq item (car menu-items))
      (if (consp item)
	  (setq item-list (cons (cons (car item) (cdr item) ) item-list))
	(setq item-list (cons (cons item item) item-list)))
      (setq menu-items (cdr menu-items))
      )

    (x-popup-menu t (list menu-title (cons menu-title (nreverse item-list))))))

(defun right-popup ()
  "Show a popup menu of commands. See also `choose-from-menu'."
  (interactive)
  (eval-expression
   (car
    (read-from-string
     (choose-from-menu
      "Context menu"
      (list
       (cons "Open Terminal here" "(open-console)")
       (cons "-" "")
       (cons "Open File [C-x C-f]" "(call-interactively 'find-file)")
       (cons "Save File [C-x C-s]" "(call-interactively 'save-buffer)")
       (cons "-" "")
       (cons "Cut [C-w]" "(call-interactively 'kill-region)")
       (cons "Copy [M-w]" "(call-interactively 'kill-ring-save)")
       (cons "Paste/Yank [C-y]" "(yank)")
       (cons "-" "")
       (cons "Undo [C-x u]" "(undo)")
       (cons "Redo" "(redo)")
       (cons "-" "")
       (cons "Search [C-s]" "(call-interactively 'search-forward)")
       (cons "Search files" "(call-interactively 'grep)")
       (cons "Word completion [M-/]"  "(call-interactively 'dabbrev-expand)")
       (cons "-" "")
       (cons "Open current buffer in new window [C-x 5 2]"  "(make-frame-command)")
       (cons "Hide current buffer [C-x 0]"  "(delete-window)")
       (cons "-" "")
       (cons "-" "")
       (cons "Close current buffer [C-x k]"  "(kill-buffer)")
       ))))))

(global-set-key [mouse-3] 'right-popup)


