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

(define-module (nonfree packages mozilla)
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
  #:use-module (gnu packages fontutils)
  #:use-module (gnu packages glib)
  #:use-module (gnu packages gtk)
  #:use-module (gnu packages bash))

(define-public firefox
  (let*
      ((archive-base-name
        "firefox-49.0.1")
       (archive-name
        (string-append archive-base-name ".tar.bz2"))
       (archive-uri
        (string-append "https://download-installer.cdn.mozilla.net/pub/firefox/releases/" archive-base-name "/linux-x86_64/en-US/" archive-name)))
    (package
      (name "firefox")
      (version "49.0.1")
      (source
       (origin
         (method url-fetch)
         (uri archive-uri)
         (sha256
          (base32
           "04yh2sf9khy37c9pl568znaq4h40n5kqskp2nvpfiaizcv4jhcjz"))))
      (supported-systems '("x86_64-linux"))
      (inputs
       `(("tar" ,tar)
         ("bzip2" ,bzip2)
         ("coreutils" ,coreutils)
         ("glibc" ,glibc)
         ("gcc" ,gcc-4.9 ,"lib")
         ("libstdc++" ,libstdc++-4.9)
         ("libx11" ,libx11)
         ("libxext" ,libxext)
         ("libxdamage" ,libxdamage)
         ("libxfixes" ,libxfixes)
         ("libxcomposite" ,libxcomposite)
         ("libxrender" ,libxrender)
         ("libxt" ,libxt)
         ("alsa-lib" ,alsa-lib)
         ("freetype" ,freetype)
         ("fontconfig" ,fontconfig)
         ("dbus-glib" ,dbus-glib)
         ("glib" ,glib)
         ("gtk+" ,gtk+)
         ("atk" ,atk)
         ("pango" ,pango)
         ("cairo" ,cairo)
         ("gdk-pixbuf" ,gdk-pixbuf)
         ("dbus" ,dbus)
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
                  (assoc-ref %build-inputs "freetype") "/lib" ":"
                  (assoc-ref %build-inputs "fontconfig") "/lib" ":"
                  (assoc-ref %build-inputs "libx11") "/lib" ":"
                  (assoc-ref %build-inputs "libxrender") "/lib" ":"
                  (assoc-ref %build-inputs "libxext") "/lib" ":"
                  (assoc-ref %build-inputs "libxdamage") "/lib" ":"
                  (assoc-ref %build-inputs "libxfixes") "/lib" ":"
                  (assoc-ref %build-inputs "libxt") "/lib" ":"
                  (assoc-ref %build-inputs "libxcomposite") "/lib" ":"
                  (assoc-ref %build-inputs "alsa-lib") "/lib" ":"
                  (assoc-ref %build-inputs "dbus-glib") "/lib" ":"
                  (assoc-ref %build-inputs "glib") "/lib" ":"
                  (assoc-ref %build-inputs "gtk+") "/lib" ":"
                  (assoc-ref %build-inputs "atk") "/lib" ":"
                  (assoc-ref %build-inputs "pango") "/lib" ":"
                  (assoc-ref %build-inputs "cairo") "/lib" ":"
                  (assoc-ref %build-inputs "gdk-pixbuf") "/lib" ":"
                  (assoc-ref %build-inputs "dbus") "/lib" ":"
                  (assoc-ref %build-inputs "libstdc++") "/lib" ":"
                  (assoc-ref %build-inputs "glibc") "/lib" ":"
                  (assoc-ref %build-inputs "gcc") "/lib"))
                (ln (string-append (assoc-ref %build-inputs "coreutils") "/bin/ln")))
             (mkdir-p out)
             (mkdir-p (string-append out "/bin"))
             (with-directory-excursion out
               (setenv "PATH" PATH)
               (system* tar "xf" source)
               (system* patchelf "--set-interpreter" (string-append ld "/ld-linux-x86-64.so.2") (string-append out "/firefox/firefox"))
               (system* patchelf "--set-rpath" RPATH (string-append out "/firefox/firefox"))
               (system* patchelf "--set-rpath" RPATH (string-append out "/firefox/libxul.so"))
               (system* patchelf "--set-rpath" RPATH (string-append out "/firefox/libmozgtk.so"))
               (system* ln "-s" (string-append out "/firefox/firefox") (string-append out "/bin/firefox")))))))
      (synopsis "Firefox")
      (description "Pretty cool")
      (home-page "http://mozilla.com/firefox")
      (license "somewhat shaky"))))

(define-public thunderbird
  (let*
      ((archive-base-name
        "thunderbird-38.4.0")
       (archive-name
        (string-append archive-base-name ".tar.bz2"))
       (archive-uri
        (string-append "http://download.cdn.mozilla.net/pub/thunderbird/releases/38.4.0/linux-x86_64/en-US/" archive-name)))
    (package
      (name "thunderbird")
      (version "38.4.0")
      (source
       (origin
         (method url-fetch)
         (uri archive-uri)
         (sha256
          (base32
           "10bpvajf4r7588pgzh7kalzanwsxcmp10wk3xkpr3nx66was7ng8"))))
      (supported-systems '("x86_64-linux"))
      (inputs
       `(("tar" ,tar)
         ("bzip2" ,bzip2)
         ("coreutils" ,coreutils)
         ("glibc" ,glibc)
         ("gcc" ,gcc-4.9 ,"lib")
         ("libstdc++" ,libstdc++-4.9)
         ("libx11" ,libx11)
         ("libxext" ,libxext)
         ("libxdamage" ,libxdamage)
         ("libxfixes" ,libxfixes)
         ("libxcomposite" ,libxcomposite)
         ("libxrender" ,libxrender)
         ("libxt" ,libxt)
         ("alsa-lib" ,alsa-lib)
         ("freetype" ,freetype)
         ("fontconfig" ,fontconfig)
         ("dbus-glib" ,dbus-glib)
         ("glib" ,glib)
         ("gtk+" ,gtk+-2)
         ("atk" ,atk)
         ("pango" ,pango)
         ("cairo" ,cairo)
         ("gdk-pixbuf" ,gdk-pixbuf)
         ("dbus" ,dbus)
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
                  (assoc-ref %build-inputs "freetype") "/lib" ":"
                  (assoc-ref %build-inputs "fontconfig") "/lib" ":"
                  (assoc-ref %build-inputs "libx11") "/lib" ":"
                  (assoc-ref %build-inputs "libxrender") "/lib" ":"
                  (assoc-ref %build-inputs "libxext") "/lib" ":"
                  (assoc-ref %build-inputs "libxdamage") "/lib" ":"
                  (assoc-ref %build-inputs "libxfixes") "/lib" ":"
                  (assoc-ref %build-inputs "libxt") "/lib" ":"
                  (assoc-ref %build-inputs "libxcomposite") "/lib" ":"
                  (assoc-ref %build-inputs "alsa-lib") "/lib" ":"
                  (assoc-ref %build-inputs "dbus-glib") "/lib" ":"
                  (assoc-ref %build-inputs "glib") "/lib" ":"
                  (assoc-ref %build-inputs "gtk+") "/lib" ":"
                  (assoc-ref %build-inputs "atk") "/lib" ":"
                  (assoc-ref %build-inputs "pango") "/lib" ":"
                  (assoc-ref %build-inputs "cairo") "/lib" ":"
                  (assoc-ref %build-inputs "gdk-pixbuf") "/lib" ":"
                  (assoc-ref %build-inputs "dbus") "/lib" ":"
                  (assoc-ref %build-inputs "libstdc++") "/lib" ":"
                  (assoc-ref %build-inputs "glibc") "/lib" ":"
                  (assoc-ref %build-inputs "gcc") "/lib"))
                (ln (string-append (assoc-ref %build-inputs "coreutils") "/bin/ln")))
             (mkdir-p out)
             (mkdir-p (string-append out "/bin"))
             (with-directory-excursion out
               (setenv "PATH" PATH)
               (system* tar "xf" source)
               (system* patchelf "--set-interpreter" (string-append ld "/ld-linux-x86-64.so.2") (string-append out "/thunderbird/thunderbird"))
               (system* patchelf "--set-rpath" RPATH (string-append out "/thunderbird/thunderbird"))
               (system* patchelf "--set-rpath" RPATH (string-append out "/thunderbird/libxul.so"))
               (system* ln "-s" (string-append out "/thunderbird/thunderbird") (string-append out "/bin/thunderbird")))))))
      (synopsis "Thunderbird")
      (description "Pretty cool")
      (home-page "http://mozilla.com/thunderbird")
      (license "somewhat shaky"))))

