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
(use posix extras irregex srfi-69)

(let*
  ((score-table (alist->hash-table (get-score-alist "cmd-hist")))
   (history-file-path (get-data-path "command-history.txt"))
   (valid-commands (irregex "^(\\w|_).*$"))
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
        ((and (not source-name)
              (irregex-match valid-commands selected-string))
         (learn-selected-pair (cons selected-string "cmd-hist"))
         ; Update 'history' for the case of subsequent gatherings.
         (set! history (cons selected-string history))
         (save-history)
         (process-run selected-string))))))
