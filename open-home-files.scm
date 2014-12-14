; Copyright (c) 2014 Alexander Heinrich <alxhnr@nudelpost.de>
;
; This software is provided 'as-is', without any express or implied
; warranty. In no event will the authors be held liable for any damages
; arising from the use of this software.
;
; Permission is granted to anyone to use this software for any purpose,
; including commercial applications, and to alter it and redistribute it
; freely, subject to the following restrictions:
;
;    1. The origin of this software must not be misrepresented; you must
;       not claim that you wrote the original software. If you use this
;       software in a product, an acknowledgment in the product
;       documentation would be appreciated but is not required.
;
;    2. Altered source versions must be plainly marked as such, and must
;       not be misrepresented as being the original software.
;
;    3. This notice may not be removed or altered from any source
;       distribution.

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
        (process-run "xdg-open" (list selected-string))))))
