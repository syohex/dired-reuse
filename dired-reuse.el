;;; dired-reuse.el --- Reuse the current dired buffer to visit another directory
;;; @(#) $Id: dired-reuse.el,v 1.7 2008/10/30 01:49:22 joe Exp $

;; This file is not part of Emacs

;; Copyright (C) 2000-2001 by Joseph L. Casadonte Jr.
;; Author:          Joe Casadonte (emacs@northbound-train.com)
;; Maintainer:      Joe Casadonte (emacs@northbound-train.com)
;; Created:         August 17, 2000
;; Keywords:        dired reuse buffer
;; Latest Version:  http://www.northbound-train.com/emacs.html

;; COPYRIGHT NOTICE

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program; see the file COPYING.  If not, write to the
;; Free Software Foundation, Inc., 59 Temple Place - Suite 330,
;; Boston, MA 02111-1307, USA.

;;; Commentary:
;;
;;  This package provides a way to reuse the current dired buffer to visit
;;  another directory (rather than creating a new buffer for the new directory).
;;  Optionally, it allows the user to specify a name that all such buffers will
;;  have, regardless of the directory they point to.

;;; Installation:
;;
;;  Put this file on your Emacs-Lisp load path and add the following to your
;;  ~/.emacs startup file
;;
;;     (require 'dired-reuse)
;;
;;  or you can load the package via autoload:
;;
;;     (autoload 'dired-reuse-buffer "dired-reuse" "" t)
;;     (autoload 'dired-reuse-buffer-mouse "dired-reuse" "" t)
;;     (autoload 'dired-reuse-magic-buffer "dired-reuse" "" t)
;;     (autoload 'dired-reuse-toggle-buffer-name "dired-reuse" "" t)
;;
;;  To add a directory to your load-path, use something like the following:
;;
;;      (setq load-path (cons (expand-file-name "/some/load/path") load-path))
;;
;;  See below for key-binding suggestions.

;;; Usage:
;;
;;  M-x `dired-reuse-buffer'
;;     Visits the selected directory in the current buffer, replacing the
;;     current contents with the contents of the new directory.  This doesn't
;;     prevent you from having more than one dired buffer.  The main difference
;;     is that a given dired buffer will not spawn off a new buffer every time
;;     a new directory is visited.
;;
;;     If the variable dired-reuse-use-magic-buffer is non-nil, and the current
;;     buffer's name is the same as that specified by the variable
;;     dired-reuse-magic-buffer-name, then the new directory's buffer will retain
;;     that same name (i.e. not only will dired only use a single buffer, but
;;     its name will not change every time a new directory is entered).
;;
;;     See below for key-binding recommendations.
;;
;;  M-x `dired-reuse-buffer-mouse'
;;     Essentially this is the same as `dired-reuse-buffer', except that the
;;     action is initiated by a mouse-click instead of a keystroke.
;;
;;     See below for key-binding recommendations.
;;
;;  M-x `dired-reuse-magic-buffer'
;;     Switch to an existing buffer whose name is the value of
;;     dired-reuse-magic-buffer-name. If no such buffer exists, launch dired in a
;;     new buffer and rename that buffer to the value of
;;     dired-reuse-magic-buffer-name.  If the current buffer is the magic buffer,
;;     it will prompt for a new directory to visit.
;;
;;     See below for key-binding recommendations.
;;
;;  M-x `dired-reuse-toggle-buffer-name'
;;     Toggle between the 'magic' buffer name and the 'real' dired buffer
;;     name.  Will also seek to uniquify the 'real' buffer name.
;;
;;     See below for key-binding recommendations.

;;; Recomended Keybindings:
;;
;;  To use the single-buffer feature most effectively, I recommend adding the
;;  following code to your .emacs file.  Basically, it remaps the [Return] key
;;  to call the `dired-reuse-buffer' function instead of its normal
;;  function (`dired-advertised-find-file').  Also, it maps the caret ("^")
;;  key to go up one directory, using the `dired-reuse-buffer' command
;;  instead of the normal one (`dired-up-directory'), which has the same effect
;;  as hitting [Return] on the parent directory line ("..")).  Finally, it maps
;;  a button-one click to the `dired-reuse-buffer-mouse' function, which
;;  does some mouse selection stuff, and then calls into the main
;;  `dired-reuse-buffer' function.
;;
;;  NOTE: This should only be done for the `dired-mode-map' (NOT globally!).
;;
;;  The following code will work whether or not dired has been loaded already.
;;
;;      (defun my-dired-init ()
;;        "Bunch of stuff to run for dired, either immediately or when it's
;;         loaded."
;;        ;; <add other stuff here>
;;        (define-key dired-mode-map [return] 'dired-reuse-buffer)
;;        (define-key dired-mode-map [mouse-1] 'dired-reuse-buffer-mouse)
;;        (define-key dired-mode-map "^"
;;      	(function
;;      	 (lambda nil (interactive) (dired-reuse-buffer "..")))))
;;
;;      ;; if dired's already loaded, then the keymap will be bound
;;      (if (boundp 'dired-mode-map)
;;      	;; we're good to go; just add our bindings
;;      	(my-dired-init)
;;        ;; it's not loaded yet, so add our bindings to the load-hook
;;        (add-hook 'dired-load-hook 'my-dired-init))
;;
;;  To use the magic-buffer function, you first need to start dired in a buffer
;;  whose name is the value of dired-reuse-magic-buffer-name.  Once the buffer
;;  has this name, it will keep it unless explicitly renamed.  Use the function
;;  dired-reuse-magic-buffer to start this initial dired magic buffer (or you can
;;  simply rename an existing dired buffer to the magic name).  I bind this
;;  function globally, so that I can always get back to my magic buffer from
;;  anywhere.  Likewise, I bind another key to bring the magic buffer up in the
;;  current default-directory, allowing me to move around fairly easily.  Here's
;;  what I have in my .emacs file:
;;
;;      (global-set-key [(f5)] 'dired-reuse-magic-buffer)
;;      (global-set-key [(control f5)] (function
;;      	(lambda nil (interactive)
;;              (dired-reuse-magic-buffer default-directory))))
;;      (global-set-key [(shift f5)] (function
;;	        (lambda nil (interactive)
;;              (message "Current directory is: %s" default-directory))))
;;      (global-set-key [(meta f5)] 'dired-reuse-toggle-buffer-name)
;;
;;  Of course, these are only suggestions.

;;; Customization:
;;
;;  M-x `dired-reuse-customize' to customize all package options.
;;
;;  The following variables can be customized:
;;
;;  o `dired-reuse-use-magic-buffer'
;;        Boolean used to determine if the dired-reuse functions should look
;;        for and retain a specific buffer name.  The buffer name to look for
;;        is specified with `dired-reuse-magic-buffer-name'.
;;
;;  o `dired-reuse-magic-buffer-name'
;;        Name of buffer to use if `dired-reuse-use-magic-buffer' is true.  Once a
;;        dired buffer has this name, it will always keep this name (unless it's
;;        explicitly renamed by you).

;;; To Do:
;;
;;  o Nothing, at the moment.

;;; Credits:
;;
;;  The single buffer code is loosely based on code posted to the NT-Emacs
;;  mailing list by Steve Kemp & Rob Davenport.  The magic buffer name code
;;  is all mine.

;;; Comments:
;;
;;  Any comments, suggestions, bug reports or upgrade requests are welcome.
;;  Please send them to Joe Casadonte (emacs@northbound-train.com).
;;
;;  This version of dired-reuse was developed and tested with NTEmacs 20.5.1
;;  under Windows NT 4.0 SP6 and Emacs 20.7.1 under Linux (RH7).  Please, let
;;  me know if it works with other OS and versions of Emacs.

;;; **************************************************************************
;;; **************************************************************************
;;; **************************************************************************
;;; **************************************************************************
;;; **************************************************************************
;;; Code:

(eval-when-compile
  (defvar byte-compile-dynamic nil) ; silence the old byte-compiler
  (set (make-local-variable 'byte-compile-dynamic) t))

(eval-and-compile
  (autoload 'dired-get-filename "dired"))

;;; **************************************************************************
;;; ***** customization routines
;;; **************************************************************************
(defgroup dired-reuse nil
  "dired-reuse package customization"
  :group 'tools)

;; ---------------------------------------------------------------------------
(defun dired-reuse-customize ()
  "Customization of the group `dired-reuse'."
  (interactive)
  (customize-group "dired-reuse"))

;; ---------------------------------------------------------------------------
(defcustom dired-reuse-use-magic-buffer t
  "Boolean that indicates the use of a single dired buffer name.

It is used to determine if the dired-reuse functions should look for and
retain a specific buffer name.  The buffer name to look for is specified
with `dired-reuse-magic-buffer-name'."
  :group 'dired-reuse
  :type 'boolean)

;; ---------------------------------------------------------------------------
(defcustom dired-reuse-magic-buffer-name "*dired*"
  "Name of buffer to use if `dired-reuse-use-magic-buffer' is true.

Once a dired buffer has this name, it will always keep this name (unless it's
   explicitly renamed by you)."
  :group 'dired-reuse
  :type 'string)

;; ---------------------------------------------------------------------------
(defcustom dired-reuse-load-hook nil
  "Hook to run when package is loaded."
  :type 'hook
  :group 'dired-reuse)

;;; **************************************************************************
;;; ***** version related routines
;;; **************************************************************************
(defconst dired-reuse-version
  "$Revision: 1.7 $"
  "Version number for dired-reuse package.")

;; ---------------------------------------------------------------------------
(defun dired-reuse-version-number ()
  "Return dired-reuse version number."
  (string-match "[0123456789.]+" dired-reuse-version)
  (match-string 0 dired-reuse-version))

;; ---------------------------------------------------------------------------
(defun dired-reuse-display-version ()
  "Display dired-reuse version."
  (interactive)
  (message "dired-reuse version <%s>." (dired-reuse-version-number)))

;;; **************************************************************************
;;; ***** interactive functions
;;; **************************************************************************
;;;###autoload
(defun dired-reuse-buffer (&optional default-dirname)
  "Visit selected directory in current buffer.

Visits the selected directory in the current buffer, replacing the
   current contents with the contents of the new directory.  This doesn't
   prevent you from having more than one dired buffer.  The main difference
   is that a given dired buffer will not spawn off a new buffer every time
   a new directory is visited.

If the variable `dired-reuse-use-magic-buffer' is non-nil, and the current
   buffer's name is the same as that specified by the variable
`dired-reuse-magic-buffer-name', then the new directory's buffer will retain
   that same name (i.e. not only will dired only use a single buffer, but
its name will not change every time a new directory is entered).

Optional argument DEFAULT-DIRNAME specifies the directory to visit; if not
specified, the directory or file on the current line is used (assuming it's
a dired buffer).  If the current line represents a file, the file is visited
in another window."
  (interactive)
  ;; use arg passed in or find name of current line
  (let ((name (or default-dirname (dired-get-filename nil t))))
	(save-excursion
	  (save-match-data
		;; See if the selection is a directory or not.
		(end-of-line)
		(let ((eol (point)))
		  (beginning-of-line)
		  ;; assume directory if arg passed in
		  (if (or default-dirname (re-search-forward "^  d" eol t))
			  ;; save current buffer's name
			  (let ((current-buffer-name (buffer-name)))
				;; go ahead and read in the directory
				(find-alternate-file name)
				;; if the saved buffer's name was the magic name, rename this buffer
				(if (and dired-reuse-use-magic-buffer
						 (string= current-buffer-name dired-reuse-magic-buffer-name))
					(rename-buffer dired-reuse-magic-buffer-name)))
			;; it's just a file
		  (find-file name)))))))

;;;; ------------------------------------------------------------------------
;;;###autoload
(defun dired-reuse-buffer-mouse (click)
  "Mouse-initiated version of `dired-reuse-buffer' (which see).

Argument CLICK is the mouse-click event."
  (interactive "e")
  (let* ( (start (event-start click))
		  (window (car start))
		  (pos (car (cdr start))) )
	(select-window window)
	(goto-char pos))
  (dired-reuse-buffer))

;;;; ------------------------------------------------------------------------
;;;###autoload
(defun dired-reuse-magic-buffer (&optional default-dirname)
  "Switch to buffer whose name is the value of `dired-reuse-magic-buffer-name'.

If no such buffer exists, launch dired in a new buffer and rename that buffer
to the value of `dired-reuse-magic-buffer-name'.  If the current buffer is the
magic buffer, it will prompt for a new directory to visit.

Optional argument DEFAULT-DIRNAME specifies the directory to visit (defaults to
the currently displayed directory)."
  (interactive)
  ;; do we not have one or are we already in it?
  (let ((magic-dired-buffer (get-buffer dired-reuse-magic-buffer-name)))
	(if (or (eq magic-dired-buffer nil)
			(eq magic-dired-buffer (current-buffer)))
		;; nothing to switch to
		;; get directory name to start in
		(let ((dirname (or default-dirname
						   (read-file-name (format "Dired %s(directory): " "")
										   nil default-directory t))))

		  ;; make sure it's really a directory
		  (if (not (file-directory-p dirname))
			  (error "Error: <%s> is not a directory" dirname))

		  ;; do we need a new buffer?
		  (if (eq magic-dired-buffer nil)
			  ;; find the file in new buffer, current window
			  (find-file dirname)
			;; just find in place of current buffer
			(find-alternate-file dirname))
		  ;; rename the buffer, where ever we found it
		  (rename-buffer dired-reuse-magic-buffer-name))
	  ;; we're not there (we have one already), so simply switch to it
	  (switch-to-buffer magic-dired-buffer)
	  ;; if called with a default, try it again
	  (if default-dirname
		  (dired-reuse-magic-buffer default-dirname)))))

;;;; ------------------------------------------------------------------------
;;;###autoload
(defun dired-reuse-toggle-buffer-name ()
  "Toggle between the 'magic' buffer name and the 'real' dired buffer name.

Will also seek to uniquify the 'real' buffer name."
  (interactive)

  ;; make sure it's a dired buffer
  (if (not (string= major-mode "dired-mode"))
          (error "Error: not a dired buffer"))

  ;; do we have magic name currently?
  (if (string= (buffer-name) dired-reuse-magic-buffer-name)
          (rename-buffer
           (abbreviate-file-name
                (expand-file-name (directory-file-name default-directory))) t)

        ;; make sure the buffer doesn't currently exist
        (let ((existing-buffer (get-buffer dired-reuse-magic-buffer-name)))
          (if existing-buffer
                  (kill-buffer existing-buffer))
          (rename-buffer dired-reuse-magic-buffer-name))))

;;; **************************************************************************
;;; ***** we're done
;;; **************************************************************************
(provide 'dired-reuse)
(run-hooks 'dired-reuse-load-hook)

;;; dired-reuse.el ends here
