/* Copyright 2011 Kevin Ryde

   This file is part of Math-Image.

   Math-Image is free software; you can redistribute it and/or modify it under
   the terms of the GNU General Public License as published by the Free
   Software Foundation; either version 3, or (at your option) any later
   version.

   Math-Image is distributed in the hope that it will be useful, but WITHOUT
   ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
   FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
   more details.

   You should have received a copy of the GNU General Public License along
   with Math-Image.  If not, see <http://www.gnu.org/licenses/>.  */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <locale.h>
#include <wchar.h>
#include <X11/Xlib.h>
#include <X11/Xutil.h>

int
main (void)
{
  Display *display;

  setlocale (LC_ALL, NULL);
  setlocale (LC_ALL, "ar_IN.UTF-8");
  setlocale (LC_ALL, "en_AU.ISO-8859-1");

  display = XOpenDisplay(NULL);
  printf ("display %p\n", display);

  {
    static char ctext[] = "\x1B\x28\x4A\x7E";
    /* "\x1B\x28\x49\x7C\x7D"; */
    static XTextProperty text_prop;
    int ret;
    char **tlist;
    int tcount;
    int i;

    text_prop.encoding = XInternAtom(display,"COMPOUND_TEXT",0);
    text_prop.format = 8;
    text_prop.nitems = strlen(ctext);
    text_prop.value = (unsigned char *) ctext;

    ret = Xutf8TextPropertyToTextList (display,
                                       &text_prop,
                                       &tlist,
                                       &tcount);
    printf ("  Xutf8TextPropertyToTextList ret %d\n", ret);

    printf ("  got utf8  ");
    for (i = 0; i < strlen(tlist[0]); i++) {
      printf (" %02X", (int) (unsigned char) tlist[0][i]);
    }
    printf ("\n");
    return 0;
  }
  {
    /* static char ustr[] = "\xCB\x9A"; */
    static char ustr[] = "\xE2\x80\xBE"; /* 203E overline */
    static char *ulist[2];
    static XTextProperty text_prop;
    int ret;
    int i;

    ulist[0] = ustr;
    ret = Xutf8TextListToTextProperty (display,
                                       ulist,
                                       1,
                                       XCompoundTextStyle,
                                       &text_prop);
    printf ("ret %d\n", ret);
    if (ret >= 0) {
      printf ("text encoding %lu\n", text_prop.encoding);
      printf ("text encoding %s\n", XGetAtomName(display,text_prop.encoding));
      printf ("text format %d\n", text_prop.format);
      printf ("text nitems %lu\n", text_prop.nitems);
      printf ("text value: ");
      for (i = 0; i < text_prop.nitems; i++) {
        printf (" %02X", text_prop.value[i]);
      }
      printf ("\n");
    }
    return 0;
  }

  {
    const char *str = XDefaultString();
    int i;
    printf ("XDefaultString [len %d] ", strlen(str));
    for (i = 0; i < strlen(str); i++) {
      printf (" %02X", (int) (unsigned char) str[i]);
    }
    printf ("\n");
    printf ("\"Success\" is %d\n", Success);
  }
  

  {
    FILE *fp = fopen ("encode-emacs23.utf8","r");
    if (! fp) { printf ("cannot open\n"); abort(); }
    char buf[500000];
    size_t len = fread (buf, 1, 500000, fp);
    fclose (fp);
    buf[len] = '\0';
    
    static char *ulist[2];
    static XTextProperty text_prop;
    int ret;

    ulist[0] = buf;
    ret = Xutf8TextListToTextProperty (display,
                                       ulist,
                                       1,
                                       XCompoundTextStyle,
                                       &text_prop);
    printf ("ret %d\n", ret);
    if (ret >= 0) {
      printf ("text encoding %lu\n", text_prop.encoding);
      printf ("text encoding %s\n", XGetAtomName(display,text_prop.encoding));
      printf ("text format %d\n", text_prop.format);
      printf ("text nitems %lu\n", text_prop.nitems);
      printf ("text value: ");
      /* for (i = 0; i < text_prop.nitems; i++) { */
      /*   printf (" %02X", text_prop.value[i]); */
      /* } */
      /* printf ("\n"); */

      FILE *fp = fopen ("encode-emacs23xc.ctext","w");
      if (! fp) { printf ("cannot open\n"); abort(); }
      fwrite (text_prop.value, text_prop.nitems, 1, fp);
      fclose(fp);
    }
    return 0;
  }

  {
    static wchar_t wstr[2];
    static wchar_t *wlist[2];
    static XTextProperty text_prop;
    int ret;
    wchar_t c;
    int i;

    for (c = 32; c < 1000; c++) {
      wstr[0] = c;
      wlist[0] = wstr;
      ret = XwcTextListToTextProperty (display,
                                       wlist,
                                       1,
                                       XCompoundTextStyle,
                                       &text_prop);
      printf ("c=%d ret %d\n", c, ret);
      if (ret == 0) {
        printf ("text encoding %lu\n", text_prop.encoding);
        printf ("text encoding %s\n", XGetAtomName(display,text_prop.encoding));
        printf ("text format %d\n", text_prop.format);
        printf ("text nitems %lu\n", text_prop.nitems);
        printf ("text value: ");
        for (i = 0; i < text_prop.nitems; i++) {
          printf (" %02X", text_prop.value[i]);
        }
        printf ("\n");
      }
    }
    return 0;
  }
  


  return 0;
}
