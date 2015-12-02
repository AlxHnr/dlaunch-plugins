(import dlaunch-plugin-api)
(use posix extras irregex data-structures srfi-1)
(foreign-declare "#include <sys/stat.h>")

(let ((stat-is-directory? (foreign-lambda bool "S_ISDIR" int))
      (ignore-file-path (get-config-path "ignore-files.txt"))
      (override-file-path (get-config-path "ignore-files-override.txt"))
      (default-ignore-patterns
        (list
          "^.*\\.(a|o|so|dll|class|pyc|bin)$"
          (string-append
            "^.*/\\.(thumbnails|icons|themes|wine|gconf|mozilla|claws-mail"
            "|cache|fontconfig|git|svn|hg|opam/repo|cargo/registry|Skype)$")
          "^.*/\\.local/share/(Trash|Steam|evolution/mail)$"
          "^.*/\\.minecraft/(?!screenshots(/.*)?$|.*\\.png$).*$")))

  ;; A list with regexes which specify the paths which should be ignored.
  (define ignore-list
    (map
      irregex
      (if (file-exists? override-file-path)
        (read-lines override-file-path)
        (append
          default-ignore-patterns
          (if (file-exists? ignore-file-path)
            (read-lines ignore-file-path)
            '())))))

  ;; A function, which checks if the given absolute path can be ignored.
  (define (ignore? path)
    (find
      (lambda (pattern)
        (irregex-match pattern path))
      ignore-list))

  ;; Increment the hide level, if a filename starts with a dot.
  (define (new-hidelevel prev-hidelevel filename)
    (if (char=? (string-ref filename 0) #\.)
      (add1 prev-hidelevel) prev-hidelevel))

  ;; Returns an alist, which associates a filepath with its hide level. The
  ;; filepath is relative to the specified root. The root directory is an
  ;; absolute path and must end with a slash.
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
        filetree
        (condition-case
          (directory (string-append root dirpath) #t)
          ((exn file) '())))))

  ;; Returns a presorted list of all files in the users home directory,
  ;; which are not matched by the patterns in 'ignore-list'.
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
        (let
          ((full-path
             (string-append
               (get-environment-variable "HOME") "/" selected-string)))
          (process-run "xdg-open" (list full-path)))))))
