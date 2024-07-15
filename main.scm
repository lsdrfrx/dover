(import (chicken file posix))
(import (chicken file))
(import (chicken string))
(import (chicken format))
(import (chicken process))
(import inotify)
(import shell)
(import toml)

(define *config-table*)

(let ((user (string-chomp
                 (capture "echo $USER")
                 "\n"))
      (config-dir "/home/~a/.config/dover"))
  (set! config-dir (sprintf config-dir user))

  ;; Check if config exists
  ;; If not - create default one
  (if (not (directory-exists? config-dir))
    (system (sprintf "mkdir ~a" config-dir))
    '())

  (file-close (file-open
                   (sprintf "~a/dover.toml" config-dir)
                   (+ open/rdonly open/creat)))

  (set! *config-table* (table-from-file (sprintf "~a/dover.toml" config-dir))))

(print *config-table*)

;; TODO: Make properties for config file

(init!)
(on-exit clean-up!)

(add-watch! "/home/lsdrfrx/.config" '(close))

(define (reload-configurations filename)
  (printf "Updated ~a. Invoking configurations refresh\n" filename)
  (run "xdotool key super+control+r"))

(let loop ()
  (define filepath (event->pathname (next-event!)))
  (define filename (list-ref
                     (reverse (string-split filepath "/"))
                     0))
  (if (string=? filename "picom.conf")
    (print "Ignore picom.conf modifications")
    (reload-configurations filename))
  (loop))
