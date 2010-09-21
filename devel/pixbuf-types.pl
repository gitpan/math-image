#!/usr/bin/perl -w

# Copyright 2010 Kevin Ryde

# This file is part of Math-Image.
#
# Math-Image is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by the
# Free Software Foundation; either version 3, or (at your option) any later
# version.
#
# Math-Image is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
# or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# for more details.
#
# You should have received a copy of the GNU General Public License along
# with Math-Image.  If not, see <http://www.gnu.org/licenses/>.

use 5.008;
use strict;
use warnings;
use Gtk2;

use FindBin;
my $progname = $FindBin::Script;


{
  foreach my $type ('png', 'jpeg', 'ico', 'tiff', 'bmp') {
    foreach my $i (6 .. 25) {
      my $width = 2 ** $i;
      my $pixbuf = Gtk2::Gdk::Pixbuf->new ('rgb', 0, 8, $width, 1);
      if (! eval {
        $pixbuf->save ('/tmp/xxx', $type);
        1
      }) {
        print "$type $width -- $@\n";
        last;
      }
    }
  }
  exit 0;
}

print "Gtk2::Gdk::Pixbuf->can('get_formats') ",
  Gtk2::Gdk::Pixbuf->can('get_formats'),"\n";
print "Gtk2->check_version (2,4,0) ",
  (Gtk2->check_version(2,4,0)||0), "\n";

my @formats = Gtk2::Gdk::Pixbuf->get_formats;
  require Data::Dumper;
  print Data::Dumper->new([\@formats],['formats'])->Dump;

@formats = sort {$a->{'name'} cmp $b->{'name'}} @formats;
foreach my $format (@formats) {
  print $format->{'name'},"\n";
  if ($format->can('is_writable')) {
    print "  is_writable() ", $format->is_writable, "\n";
  }
  print "  $format->{'description'}\n";
}
exit 0;
