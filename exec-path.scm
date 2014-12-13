(import dlaunch-plugin-api)
(use posix data-structures srfi-1)

(let ()
  (register-source
    "exec-path"
    (lambda ()
      (sort
        (fold
          (lambda (path lst)
            (fold
              cons lst
              (condition-case
                (directory path)
                ((exn file) '()))))
          '() (string-split (get-environment-variable "PATH") ":"))
        string<?)))

  (register-handler
    (lambda (selected-string source-name)
      (if (equal? source-name "exec-path")
        (process-run selected-string)))))
