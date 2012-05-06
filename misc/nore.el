;; nore.el
;; Search nore in Emacs

;; ## Setup
;;     (require 'nore)
;;     (add-hook 'javascript-mode-hook
;;               '(lambda ()
;;                  (define-key javascript-mode-map (kbd "<f1> n") 'nore-search-doc-at-point)))
;;     (add-hook 'coffee-mode-hook
;;               '(lambda ()
;;                  (define-key coffee-mode-map (kbd "<f1> n") 'nore-search-doc-at-point)))

(defvar nore-command "nore"
  "nore command"
)

(defun nore-region-string-or-currnet-word ()
  "Get region string if region is set, else get current word."
  (if mark-active
      (buffer-substring (region-beginning) (region-end))
    (current-word)))

(defun nore-search-doc-at-point (&optional item)
  (interactive)
  (setq item
        (if item item
          (nore-region-string-or-currnet-word)))
  (nore-search-nore item))

(defun nore-search-doc (&optional item)
  (interactive)
  (setq item (read-string "Search symbol: "
                          (if item item
                            (nore-region-string-or-currnet-word))))
  (nore-search-nore item)
)

(defun nore-search-doc-for-nore (&optional item)
  (interactive)
  (setq item (thing-at-point 'filename))
  (setq item (if (string-match "," item)
                 (replace-match "" nil nil item)))
  (nore-search-doc item)
)

(defun nore-search-nore (&optional item)
  (if item
      (let ((buf (buffer-name)))
        (unless (string= buf "*nore*")
          (switch-to-buffer-other-window "*nore*"))
        (setq buffer-read-only nil)
        (kill-region (point-min) (point-max))
        (message (concat "Please wait..."))
        (call-process nore-command nil "*nore*" t item)
        (local-set-key [f1] 'nore-search-doc)
        (local-set-key [return] 'nore-search-doc-for-nore)
        (local-set-key "q" 'kill-buffer-and-window)
        (ansi-color-apply-on-region (point-min) (point-max))
        (setq buffer-read-only t)
        (goto-char (point-min)))))

(provide 'nore)

;;; nore.el ends here
