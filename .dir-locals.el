;;; Directory Local Variables         -*- no-byte-compile: t; -*-
;;; For more information see (info "(emacs) Directory Variables")

((nil . ((tab-width . 8)
         (sentence-end-double-space . t)
         (fill-column . 70)
	 (emacs-lisp-docstring-fill-column . 65)
         (vc-git-annotate-switches . "-w")
         (bug-reference-url-format . "https://debbugs.gnu.org/%s")
	 (diff-add-log-use-relative-names . t)
         (vc-prepare-patches-separately . nil)))
 (c-mode . ((c-file-style . "GNU")
            (c-noise-macro-names . ("INLINE" "NO_INLINE" "ATTRIBUTE_NO_SANITIZE_UNDEFINED"
                                    "UNINIT" "CALLBACK" "ALIGN_STACK" "ATTRIBUTE_MALLOC"
                                    "ATTRIBUTE_DEALLOC_FREE"))
            (electric-quote-comment . nil)
            (electric-quote-string . nil)
            (indent-tabs-mode . t)
	    (mode . bug-reference-prog)))
 (objc-mode . ((c-file-style . "GNU")
               (electric-quote-comment . nil)
               (electric-quote-string . nil)
	       (mode . bug-reference-prog)))
 (c-ts-mode . ((c-ts-mode-indent-style . gnu)
               (indent-tabs-mode . t)
               (mode . bug-reference-prog)))
 (log-edit-mode . ((log-edit-font-lock-gnu-style . t)
                   (log-edit-setup-add-author . t)
		   (vc-git-log-edit-summary-target-len . 50)))
 (change-log-mode . ((add-log-time-zone-rule . t)
		     (fill-column . 74)
		     (mode . bug-reference)))
 (diff-mode . ((mode . whitespace)))
 (emacs-lisp-mode . ((indent-tabs-mode . nil)
                     (electric-quote-comment . nil)
                     (electric-quote-string . nil)
	             (mode . bug-reference-prog)))
 (lisp-data-mode . ((indent-tabs-mode . nil)))
 (texinfo-mode . ((electric-quote-comment . nil)
                  (electric-quote-string . nil)
	          (mode . bug-reference-prog)))
 (outline-mode . ((mode . bug-reference))))
