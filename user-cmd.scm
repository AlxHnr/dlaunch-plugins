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
(use extras posix srfi-1 srfi-69)

(let ()
  (define-values (custom-commands custom-command-pairs)
    (if (file-exists? (get-config-path "custom-commands.scm"))
      (partition
        string?
        (read-file (get-config-path "custom-commands.scm")))
      (values '() '())))
  
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
