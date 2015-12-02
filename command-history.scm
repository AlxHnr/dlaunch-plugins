(import dlaunch-plugin-api)
(use posix extras irregex srfi-69)

(let*
  ((score-table (alist->hash-table (get-score-alist "cmd-hist")))
   (history-file-path (get-data-path "command-history.txt"))
   (history
     (filter
       (lambda (command)
         (hash-table-exists? score-table command))
       (if (file-exists? history-file-path)
         (read-lines history-file-path)
         '()))))

  (define (save-history)
    (call-with-output-file history-file-path
      (lambda (out)
        (for-each
          (lambda (command)
            (write-line command out))
          history))))

  (register-source "cmd-hist" (lambda () history))
  (register-handler
    (lambda (selected-string source-name)
      (cond
        ((equal? source-name "cmd-hist")
         (process-run selected-string))
        ((and (not source-name) (irregex-match "^\\w.*$" selected-string))
         (learn-selected-pair (cons selected-string "cmd-hist"))
         ; set! 'history' for the case of subsequent gatherings.
         (set! history (cons selected-string history))
         (save-history)
         (process-run selected-string))))))
