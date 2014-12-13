(import dlaunch-plugin-api)
(use posix extras irregex data-structures srfi-1)
(foreign-declare "#include <sys/stat.h>")

(let ()
  (define stat-is-directory?
    (foreign-lambda bool "S_ISDIR" int))

  ;; A list with regexes, which specify which paths should be ignored.
  (define ignore-list
    (map
      irregex
      (if (file-exists? (get-config-path "ignore-files.scm"))
        (read-file (get-config-path "ignore-files.scm"))
        '("^.*\\.(a|o|so|dll|class|pyc|bin)$"
          "^.*\\/\\.(gconf|mozilla|claws-mail|git|cache)$"
          "^.*\\/\\.(fontconfig|thumbnails|icons|themes|wine)$"))))

  ;; A function, which checks if a given path can be ignored.
  (define (ignore? path)
    (find
      (lambda (pattern)
        (irregex-match pattern path))
      ignore-list))

  (define (new-hidelevel prev-hidelevel filename)
    (if (char=? (string-ref filename 0) #\.)
      (add1 prev-hidelevel) prev-hidelevel))

  (define (get-scored-filetree root)
    (let fold-filetree ((dirpath "") (filetree '()) (hidelevel 0))
      (fold
        (lambda (filename lst)
          (define full-path (string-append root dirpath filename))
          (if (ignore? full-path)
            lst
            (begin
              (define stats
                (condition-case
                  (file-stat full-path #t)
                  ((exn file) #f)))
              (cond
                ((not stats) lst)
                ((stat-is-directory? (vector-ref stats 1))
                 (fold-filetree
                   (string-append dirpath filename "/")
                   lst (new-hidelevel hidelevel filename)))
                (else
                  (cons
                    (cons
                      (string-append dirpath filename)
                      (new-hidelevel hidelevel filename))
                    lst))))))
        filetree (directory (string-append root dirpath) #t))))

  (define (gather-home-files)
    (map
      car
      (sort
        (get-scored-filetree
          (string-append (get-environment-variable "HOME") "/"))
        (lambda (a b)
          (cond
            ((= (cdr a) (cdr b))
             (< (string-length (car a)) (string-length (car b))))
            (else (< (cdr a) (cdr b))))))))

  (register-source "home-files" gather-home-files async: #t)
  (register-handler
    (lambda (selected-string source-name)
      (if (equal? source-name "home-files")
        (process-run "xdg-open" (list selected-string))))))
