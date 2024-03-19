
;; given some number of tokens (1 or more, though it gets crazy more than 3 or 4..), return a list of all
;; permutations of that token
;; 1 element -> a                                    (1 choice)
;; 2 element -> a.*b | b.*a                          (2 choice * 1 choice)
;; 3 element -> abc | acb | cba | bac | cab | bca    (3 choice * 2 choice * 1)
;; ...
(defun skeez/determine-permutations-of-list (tokens)
  "Return a list of all permutations of the elements in TOKENS."
  (if (null tokens)
      '(())
    (apply #'append
           (mapcar (lambda (x)
		     (mapcar (lambda (p) (cons x p))
			     (skeez/determine-permutations-of-list (remove x tokens))))
                   tokens))))
;; tests
;; (length (skeez/determine-permutations-of-list '(smoke on the water)))
;; (length (skeez/determine-permutations-of-list '(stand on zanzibar)))
;; (skeez/determine-permutations-of-list '(r2 d2))
;; (skeez/determine-permutations-of-list '(rygar))
;; (skeez/determine-permutations-of-list '())

(when t ;; enable isearch-ooo

  ;; since we can't use modern positive lookahead regexp, maybe we can max brute force
  ;;
  ;; foo bar -> \(foo.*bar\)\|\(bar.*foo\)
  ;; ... would get nuts with 3+ words and all permutations -> see below!
  ;;

  ;; create skeez/ooo (out of order) isearch regex mode
  (isearch-define-mode-toggle ooo-regex "o" skeez/ooo-regex-gen "Turning on skeez/ooo-regex search turns off built-in regexp mode.")

  ;; set as default mode, so we don't have to M-o or whatever to activate it
  ;; TODO: Make this configurable as to whethor is default or how to toggle when not default
  (setq-default search-default-mode #'skeez/ooo-regex-gen)

  ;; match string -> regex conversion
  (defun skeez/ooo-regex-gen (search-input &optional lax)
    "Return regexp that corresponds to SEARCH-INPUT."
    ;; transform the search input to a valid regexp and return it. I.e. You can define an entire new search language..

    ;; return a chunk: (blorp nugget) -> \(blorp.*nugget\)
    ;; ex: (skeez/ooo-add-chunk (split-string "foo bar" "[ \t]"))
    (defun skeez/ooo-add-chunk (tokens)
      (let ( (dest "\\(")
	     (do-prefix-ast nil) )
	(dolist (token tokens)
	  (if do-prefix-ast
	      (setq dest (concat dest ".*?" token)) ; .* = greedy, .*? = non-greedy
	    (setq dest (concat dest token))
	  )
	  (setq do-prefix-ast t)
	)
	(setq dest (concat dest "\\)"))
	dest
      )
    )

    ;; lame little hack so that we can handle 'escaped spaces' to mean literally a space, not out of order
    ;; ie: swap "\ " for an unlikely substring, do all the things, then swap it back
    ;; TODO: Remove the need for this, and/or make it configurable
    (setq search-input (string-replace "\\ " "_=" search-input))

    ;; repeat adding chunks to make the whole regexp
    (let ( (dest "") )
      (progn
	(if nil
	    ;; repeat adding chunks to make the whole regexp - cheese brute force method
	    (let ( (tokens (split-string search-input "[ \t]")) )
	      (setq dest (concat (skeez/ooo-add-chunk (list (nth 0 tokens) (nth 1 tokens) )) "\\|" (skeez/ooo-add-chunk (list (nth 1 tokens) (nth 0 tokens) ))     ))
	    )

	  ;; recursive general method
	  (let* ( (tokens (split-string search-input "[ \t]"))
		  (perms (skeez/determine-permutations-of-list tokens)) )

	    (dolist (perm perms)
	      (if (= (length dest) 0)
		  (setq dest (skeez/ooo-add-chunk perm))
		(setq dest (concat dest "\\|" (skeez/ooo-add-chunk perm)) )
	      )
	    )

	  ) ; let

	) ;; if
      ) ;; progn

      ;; swap things back..
      (setq dest (string-replace "_=" " " dest))

      ;; return value
      dest

    ) ;; let

  ) ;; defun

  ;; quickie tests to invoke:
  ;;   (skeez/ooo-regex-gen "blink wobble") -> "\\(blink.*wobble\\)\\|\\(wobble.*blink\\)"      - brute force method
  ;;   (skeez/ooo-regex-gen "blink wobble") -> "\\(blink.*wobble\\)\\|\\(wobble.*blink\\)"      - recursive method
  
  ;; (global-set-key (kbd "C-s") 'isearch-forward)   ;; M-r inside regular isearch to go to regexp mode
  ;; (global-set-key (kbd "C-r") 'isearch-backward)

)
