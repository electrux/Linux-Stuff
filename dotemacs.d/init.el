;;; Package --- Summary

;;; Commentary:
;;    All the settings are here.
;;    First is the required settings for package management,
;;    which also contains packages.
;;    Then there is custom settings for better customization.

;;; Code:


;; Required settings for package management.

(require 'package) ;; You might already have this line
(let* ((no-ssl (and (memq system-type '(windows-nt ms-dos))
                    (not (gnutls-available-p))))
       (url (concat (if no-ssl "http" "https") "://melpa.org/packages/")))
  (add-to-list 'package-archives (cons "melpa" url) t))
(when (< emacs-major-version 24)
  ;; For important compatibility libraries like cl-lib
  (add-to-list 'package-archives '("gnu" . "http://elpa.gnu.org/packages/")))
(package-initialize) ;; You might already have this line
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   (quote
    ("ff7625ad8aa2615eae96d6b4469fcc7d3d20b2e1ebc63b761a349bebbb9d23cb" default)))
 '(package-selected-packages
   (quote
    (markdown-preview-mode markdown-mode markdown-mode+ markdownfmt polymode use-package cargo company company-ycmd dracula-theme eldoc-eval exec-path-from-shell flycheck flycheck-rust flycheck-ycmd neotree racer rust-mode yasnippet ycmd))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )



;; Custom settings.

;; Set theme.
(load-theme 'dracula)

;; Fira code and its ligatures.
(when (window-system)
  (set-frame-font "Fira Code Retina"))

(mac-auto-operator-composition-mode)

;; Set default style for C/C++ language.
(setq-default c-default-style "bsd")

;; Set settings for editing.
(global-linum-mode t)
(setq-default c-basic-offset 8
	      tab-width 8
	      indent-tabs-mode t)

;; Settings to disable tool bar and scroll bar from
;; window for a clear and clean view.
(tool-bar-mode -1)
(toggle-scroll-bar -1)

;; Disable Auto Backup feature. No more freaking '~' files!!
(setq auto-save-default nil)
(setq make-backup-files nil)

;; Set the backup and autosave file location to /tmp
(setq backup-directory-alist
      `((".*" . ,temporary-file-directory)))
(setq auto-save-file-name-transforms
      `((".*" ,temporary-file-directory t)))

;; Set PATH variable for emacs.
(when (memq window-system '(mac ns x))
  (exec-path-from-shell-initialize))

;; Use either toggle-frame-fullscreen or toggle-frame-maximized as required.
(toggle-frame-maximized)

;; R mode using polymode
(use-package polymode
  :init
  ;; MARKDOWN
  (add-to-list 'auto-mode-alist '("\\.md" . poly-markdown-mode))

  ;; R modes
  (add-to-list 'auto-mode-alist '("\\.Snw" . poly-noweb+r-mode))
  (add-to-list 'auto-mode-alist '("\\.Rnw" . poly-noweb+r-mode))
  (add-to-list 'auto-mode-alist '("\\.Rmd" . poly-markdown+r-mode)))

;; Setup the neotree directory viewer.
(use-package neotree
  :bind ([f8] . neotree-toggle)
  :init (add-to-list 'load-path "~/")
  :config (setq neo-smart-open t))

;; Need to add a hook to the cc-mode to reset the delete key to delete last character.
;; This fixes the tab character treatment when pressing backspace.
(defun c-reset-del nil "Reset the delete character to default."
  (local-set-key (kbd "DEL") 'delete-backward-char))
(add-hook 'c-mode-common-hook 'c-reset-del)

;; Need to add a hook to the rust-mode-hook for setting indent mode to tabs.
(defun rust-indent-hook nil "Alters indentation to tabs for rust files."
  (setq-local indent-tabs-mode t))
(add-hook 'rust-mode-hook #'rust-indent-hook)

;; Rust auto format by default for rust-mode.
(use-package rust-mode
  :init
  (add-hook 'rust-mode-hook #'rust-indent-hook)
  (add-hook 'rust-mode-hook #'racer-mode)
  :config
  ;;(setq rust-format-on-save t)
  (setq rust-indent-offset 8))


;; YCMD + Company + Yasnippet + FlyCheck setup.

;; YA - Snippets
(use-package yasnippet
  :ensure t
  :diminish yas-minor-mode
  :init (yas-global-mode t))

;; Autocomplete
(use-package company
  :defer 10
  :diminish company-mode
  :bind (:map company-active-map
              ("M-j" . company-select-next)
              ("M-k" . company-select-previous))
  :preface
  ;; enable yasnippet everywhere
  (defvar company-mode/enable-yas t
    "Enable yasnippet for all backends.")
  (defun company-mode/backend-with-yas (backend)
    (if (or
         (not company-mode/enable-yas)
         (and (listp backend) (member 'company-yasnippet backend)))
        backend
      (append (if (consp backend) backend (list backend))
              '(:with company-yasnippet))))

  :init (global-company-mode t)
  :config
  ;; no delay no autocomplete
  (setq-default
   company-idle-delay 0
   company-minimum-prefix-length 2
   company-tooltip-limit 20)

  (setq-default company-backends
                 (mapcar #'company-mode/backend-with-yas company-backends)))

;;; On-the-fly syntax checking
(use-package flycheck
  :ensure t
  :diminish flycheck-mode
  :init
  (global-flycheck-mode t)
  (add-hook 'rust-mode-hook #'flycheck-rust-setup))

;; Show argument list in echo area
(use-package eldoc
  :diminish eldoc-mode
  :init (add-hook 'ycmd-mode-hook 'ycmd-eldoc-setup))

; Code-comprehension server
(use-package ycmd
  :ensure t
  :init (add-hook 'after-init-hook #'global-ycmd-mode)
  :config
  ;; Need absolute path in ycmd-server-command to work correctly.
  (set-variable 'ycmd-server-command '("python3" "/Users/electrux/Git/ycmd/ycmd/"))
  (set-variable 'ycmd-global-config (expand-file-name "~/Git/OS-Stuff/MacOS/Dotfiles/.ycm_extra_conf.py"))

  (set-variable 'ycmd-extra-conf-whitelist '("~/Programming/*" "~/Git/*"))

  (use-package flycheck-ycmd
    :commands (flycheck-ycmd-setup)
    :init (add-hook 'ycmd-mode-hook 'flycheck-ycmd-setup))

  (use-package company-ycmd
    :ensure t
    :init (company-ycmd-setup)
    :config (add-to-list 'company-backends (company-mode/backend-with-yas 'company-ycmd))))


(provide 'init)
;;; init.el ends here
