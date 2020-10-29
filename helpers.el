;;; helpers.el --- description -*- lexical-binding: t; -*-
;;
;; Copyright (C) 2020 Felix1Koch
;;
;; Author: Felix1Koch <http://github/cr0c0>
;; Maintainer: Felix1Koch <Felix1Koch@gmail.com>
;; Created: Oktober 28, 2020
;; Modified: Oktober 28, 2020
;; Version: 0.0.1
;; Keywords:
;; Homepage: https://github.com/cr0c0/helpers
;; Package-Requires: ((emacs 26.3) (cl-lib "0.5"))
;;
;; This file is not part of GNU Emacs.
;;
;;; Commentary:
;;
;;  description
;;
;;; Code:
(setq r2pipe-file "r2pipe.el")
(load-file
 (expand-file-name r2pipe-file
                   (file-name-directory (buffer-file-name))))
(require 'r2pipe)

(defun rabin2 (process)
  (json-read-from-string (r2-cmd-json process "iIj"))


(provide 'helpers)
;;; helpers.el ends here
