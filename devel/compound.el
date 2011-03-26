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
        (encode-coding-char (decode-char 'ucs #x401) 'compound-text))
;; #x2572
("1b" "24" "28" ;; GL 94^N
 "47"
 "23" "4d") [2 times]
"$(G#M"

;; 65509 FFE5
("1b" "24" "28" ;; GL 94^N
 "41" ;; GB2312  942 chars
 "23" "24")
Esc $(A#$

(mapcar (lambda (c) (format "%03o" c))
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
