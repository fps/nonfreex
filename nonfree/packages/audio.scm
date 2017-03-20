;;; GNU Guix is free software; you can redistribute it and/or modify it
;;; under the terms of the GNU General Public License as published by
;;; the Free Software Foundation; either version 3 of the License, or (at
;;; your option) any later version.
;;;
;;; GNU Guix is distributed in the hope that it will be useful, but
;;; WITHOUT ANY WARRANTY; without even the implied warranty of
;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;; GNU General Public License for more details.
;;;
;;; You should have received a copy of the GNU General Public License
;;; along with GNU Guix.  If not, see <http://www.gnu.org/licenses/>.

(define-module (nonfree packages audio)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix build-system trivial)
  #:use-module (guix licenses)
  #:use-module (gnu packages base)
  #:use-module (gnu packages xorg)
  #:use-module (gnu packages elf)
  #:use-module (gnu packages gcc)
  #:use-module (gnu packages linux)  
  #:use-module (gnu packages compression)
  #:use-module (gnu packages bash))

(define-public renoise-demo
  (let*
      ((archive-base-name
        "Renoise_3_0_1_Demo_x86_64")
       (archive-name
        (string-append archive-base-name ".tar.bz2"))
       (archive-uri
        (string-append "http://files.renoise.com/demo/" archive-name)))
    (package
      (name "renoise-demo")
      (version "3.0.1")
      (source
       (origin
         (method url-fetch)
         (uri archive-uri)
         (sha256
          (base32
           "1q7f94wz2dbz659kpp53a3n1qyndsk0pkb29lxdff4pc3ddqwykg"))))
      (supported-systems '("x86_64-linux"))
      (inputs
       `(("tar" ,tar)
         ("bzip2" ,bzip2)
         ("coreutils" ,coreutils)
         ("glibc" ,glibc)
         ("gcc" ,gcc-4.9 ,"lib")
         ("libstdc++" ,libstdc++-4.9)
         ("libx11" ,libx11)
         ("alsa-lib" ,alsa-lib)
         ("patchelf" ,patchelf)))
      (build-system trivial-build-system)
      (arguments
       '(#:modules
         ((guix build utils))
         #:builder
         (begin
           (use-modules (guix build utils))
           (let*
               ((out (assoc-ref %outputs "out"))
                (source (assoc-ref %build-inputs "source"))
                (tar (string-append (assoc-ref %build-inputs "tar") "/bin/tar"))
                (patchelf (string-append (assoc-ref %build-inputs "patchelf") "/bin/patchelf"))
                (ld (string-append (assoc-ref %build-inputs "glibc") "/lib/"))
                (PATH
                 (string-append
                  (assoc-ref %build-inputs "bzip2")
                  "/bin"
                  ":"
                  (assoc-ref %build-inputs "tar")
                  "/bin"
                  ))
                (RPATH
                 (string-append
                  (assoc-ref %build-inputs "libx11")
                  "/lib"
                  ":"
                  (assoc-ref %build-inputs "alsa-lib")
                  "/lib"
                  ":"
                  (assoc-ref %build-inputs "libstdc++")
                  "/lib"
                  ":"
                  (assoc-ref %build-inputs "glibc")
                  "/lib"
                  ":"
                  (assoc-ref %build-inputs "gcc")
                  "/lib"
                  ))
                (ln (string-append (assoc-ref %build-inputs "coreutils") "/bin/ln")))
             (mkdir-p out)
             (mkdir-p (string-append out "/bin"))
             (with-directory-excursion out
               (setenv "PATH" PATH)
               (system* tar "xf" source)
               (system* patchelf "--set-interpreter" (string-append ld "/ld-linux-x86-64.so.2") (string-append out "/Renoise_3_0_1_Demo_x86_64/renoise"))
               (system* patchelf "--set-rpath" RPATH (string-append out "/Renoise_3_0_1_Demo_x86_64/renoise"))
               (system* ln "-s" (string-append out "/Renoise_3_0_1_Demo_x86_64/renoise") (string-append out "/bin/renoise")))))))
      (synopsis "Renoise - A modern music tracker (demo version)")
      (description "Pretty cool")
      (home-page "http://renoise.com")
      (license "commercial"))))

