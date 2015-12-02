(import dlaunch-plugin-api)
(use extras posix srfi-1 srfi-69)

(let-values
  (((custom-commands custom-command-pairs)
    (if (file-exists? (get-config-path "user-commands.scm"))
      (partition
        string?
        (read-file (get-config-path "user-commands.scm")))
      (values '() '()))))

  (register-source
    "user-cmd"
    (lambda ()
      (append
        custom-commands
        (map car custom-command-pairs))))

  (register-handler
    (lambda (selected-string source-name)
      (if (equal? source-name "user-cmd")
        (process-run
          (let ((pair (assoc selected-string custom-command-pairs)))
            (if pair
              (cdr pair)
              selected-string)))))))
