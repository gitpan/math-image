;; Copyright 2011 Kevin Ryde
;;
;; This file is part of Math-Image.
;;
;; Math-Image is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as published
;; by the Free Software Foundation; either version 3, or (at your option) any
;; later version.
;;
;; Math-Image is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General
;; Public License for more details.
;;
;; You should have received a copy of the GNU General Public License along
;; with Math-Image.  If not, see <http://www.gnu.org/licenses/>.

(mapcar (lambda (c) (format "%02x" c))
        (encode-coding-char (decode-char 'ucs #x2572) 'compound-text))
;; #x2572
("1b" "24" "28" ;; GL 94^N
 "47" ;; cns11643-7
 "23" "4d") [2 times]
Esc $(G#M

;; 65509 FFE5
("1b" "24" "28" ;; GL 94^N
 "41" ;; GB2312  942 chars
 "23" "24")
Esc $(A#$

(mapcar (lambda (c) (format "%02x" c))
        (encode-coding-string
         (concat (decode-coding-string (string-make-unibyte
                                        (string #xAB)) 'iso-8859-1)
                 (decode-coding-string (string-make-unibyte
                                        (string #xAB)) 'iso-8859-2)
                 (decode-coding-string (string-make-unibyte
                                        (string #xAB)) 'iso-8859-3)
                 (decode-coding-string (string-make-unibyte
                                        (string #xAB)) 'iso-8859-4)
                 (decode-coding-string (string-make-unibyte
                                        (string #xAB)) 'iso-8859-7)
                 (decode-coding-string (string-make-unibyte
                                        (string #xAB)) 'iso-8859-6)
                 (decode-coding-string (string-make-unibyte
                                        (string #xAB)) 'iso-8859-8)
                 (decode-coding-string (string-make-unibyte
                                        (string #xAB)) 'iso-8859-5)
                 (decode-coding-string (string-make-unibyte
                                        (string #xAB)) 'iso-8859-9)
                 )
         'compound-text)
        )
# Esc [ - F


(with-temp-buffer
  (insert-file-contents "/tmp/x.utf8" nil)
  (set-buffer-file-coding-system 'compound-text-with-extensions)
  (write-file "/tmp/x.ctext"))

(with-temp-buffer
  (dotimes (i #x2FA1)
    (unless (or (< i 32)
                (and (>= i #x80) (<= i #x9F))
                (and (>= i #xD800) (<= i #xDFFF))
                (and (>= i #xFDD0) (<= i #xFDEF))
                (and (>= i #xFFFE) (<= i #xFFFF))
                (and (>= i #x1FFFE) (<= i #x1FFFF)))
      (let* ((c   (decode-char 'ucs i))
             (str (encode-coding-char c 'compound-text-with-extensions)))
        (when str
          (setq str (mapconcat (lambda (c)
                                 (format "%02X" c))
                               str " "))
          (insert (format "U+%04X = %s\n" i str))))))
  (set-buffer-file-coding-system 'compound-text-with-extensions)
  (set-buffer-file-coding-system 'utf-8)
  (write-file "/tmp/e.ext"))

