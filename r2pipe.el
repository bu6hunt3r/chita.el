;;; r2pipe.el --- description -*- lexical-binding: t; -*-
;;
;; Copyright (C) 2020 Felix1Koch
;;
;; Author: Felix1Koch <http://github/cr0c0>
;; Maintainer: Felix1Koch <Felix1Koch@gmail.com>
;; Created: Oktober 28, 2020
;; Modified: Oktober 28, 2020
;; Version: 0.0.1
;; Keywords:
;; Homepage: https://github.com/cr0c0/r2pipe
;; Package-Requires: ((emacs 26.3) (cl-lib "0.5"))
;;
;; This file is not part of GNU Emacs.
;;
;;; Commentary:
;;
;;  description
;;
;;; Code:
(require 'json)

;; Temporary storage for r2 process std output
(setq r2-pipe-out-string nil)

(defun r2-pipe-filter (process output)
  "This filter callback is used by emacs whenever a process has output"
  (setq r2-pipe-out-string (concat r2-pipe-out-string output)))

(defun r2-pipe-new (cmdline)
  "Spawn r2 with cmdline and return process object on success or nil on failure"
  (let ((process (start-process "radare2" nil "r2" "-q0" cmdline)))
    (if (equal (process-status process) 'run)
	(progn (set-process-filter process 'r2-pipe-filter) process)
      nil)))

(defun r2-cmd (process command)
  "Executes an r2 command and returns output in a string"
  (setq r2-pipe-out-string nil)
  (process-send-string process (format "%s\n" command))
  (accept-process-output process)
  r2-pipe-out-string)

(defun r2-cmd-json (process command)
  "Executes a json r2 command and returns output in an elisp object"
  (json-read-from-string (r2-cmd process command)))

(defun r2-pipe-close (process)
  "Closes r2"
  (process-send-string process "q!!\n"))

(defun r2-kill (process)
  "Kills r2"
  (kill-process process))

(defun rabin2 (choice)
  (interactive
   (list (completing-read "Select option from list: " '("Arch" "Bits" "Canary" "Class" "Endian" "Interpreter" "NX" "Relro" "Size") nil t)))
  (cond
   ((string= choice "Arch") (message (format "Architecture: %s " (cdr (assoc 'arch (r2-cmd-json process "iIj"))))))
   ((string= choice "Bits") (message (format "Bits: %s " (cdr (assoc 'bits (r2-cmd-json process "iIj"))))))
   ((string= choice "Canary") (message (format "Canary: %s " (cdr (assoc 'canary (r2-cmd-json process "iIj"))))))
   ((string= choice "Class") (message (format "Class: %s " (cdr (assoc 'class (r2-cmd-json process "iIj"))))))
   ((string= choice "Endian") (message (format "Endian: %s " (cdr (assoc 'endian (r2-cmd-json process "iIj"))))))
   ((string= choice "Interpreter") (message (format "Interpreter: %s " (cdr (assoc 'intrp (r2-cmd-json process "iIj"))))))
   ((string= choice "NX") (message (format "NX: %s " (cdr (assoc 'nx (r2-cmd-json process "iIj"))))))
   ((string= choice "Relro") (message (format "Relro: %s " (cdr (assoc 'relro (r2-cmd-json process "iIj"))))))
   ((string= choice "Size") (message (format "Size: %s " (cdr (assoc 'binsz (r2-cmd-json process "iIj"))))))
   (t (message "Requested info not available")))
  choice)

(defun chita/pattern-create (len)
  "Create an ASCII pattern with length provided by user."
  (interactive "nLength: ")
  (setq n (number-to-string len))
  (with-temp-buffer
    (kill-new (shell-command-to-string (concat "ragg2 -P " n "-r")))))

(defun buffer-round-up (hexstr bytes)
  (let ((hexstring (replace-regexp-in-string "0x" "" hexstr)))
    (if (= (% (length hexstring) 2) 0)
        (message "Modulus is zero.")
      (setq hexstring (concat "0" hexstring)))
    (let* ((padding (- bytes (/ (length hexstring) 2)))
           (result (concat "0x"(concat (make-string (* padding 2) ?0) hexstring))))
      (message "Padding would be: %s" result))))

(defun split-string-every (string chars)
  "Split STRING into substrings of length CHARS characters.

This returns a list of strings."
  (cond ((string-empty-p string)
         nil)
        ((< (length string)
            chars)
         (list string))

        (t (cons (substring string 0 chars)
                 (split-string-every (substring string chars)
                                     chars)))))

(defun chita/change-endianness (hexstr)
  (interactive "sEnter hex value: ")
  (let* ((substr (replace-regexp-in-string "0x" "" hexstr))
         (biglist (split-string-every substr 2)))
    (concat "0x"(mapconcat #'identity (reverse biglist) ""))))

(defun chita/change-endianness-escaped (hexstr)
  (interactive "sEnter hex value: ")
  (let* ((substr (replace-regexp-in-string "0x" "" hexstr))
         (biglist (split-string-every substr 2))
         (tempbuffer (mapconcat #'identity (reverse biglist) "")))
    (message "%s"(replace-regexp-in-string "\\(..\\)" "\\\\x\\&" tempbuffer))))

(defun chita/dec-2-hex ()
  (interactive "r")
  (setq end (copy-marker end))
  (save-match-data
    (save-excursion
      (skip-chars-backward "0123456789abcdefABCDEF#x")
      (setq $p1 (point))
      (skip-chars-forward "0123456789abcdefABCDEF#x")
      (setq $p2 (point))
      (setq $inputStr (buffer-substring-no-properties $p1 $p2))
      (let ((case-fold-search nil))
        (setq $tempStr (replace-regexp-in-string "\\`0x" "" $inputStr )) ; C, Perl, …
        (setq $tempStr (replace-regexp-in-string "\\`#x" "" $tempStr )) ; elisp …
        (setq $tempStr (replace-regexp-in-string "\\`#" "" $tempStr )) ; CSS …
        )
      (delete-region $p1 $p2)
      (insert "A")
      (set-marker end nil))))

(provide 'r2pipe)

;;; r2pipe.el ends here
