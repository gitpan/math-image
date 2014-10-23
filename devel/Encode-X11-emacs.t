#!/usr/bin/perl -w

# Copyright 2011 Kevin Ryde

# This file is part of Math-Image.
#
# Math-Image is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by the Free
# Software Foundation; either version 3, or (at your option) any later
# version.
#
# Math-Image is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
# or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# for more details.
#
# You should have received a copy of the GNU General Public License along
# with Math-Image.  If not, see <http://www.gnu.org/licenses/>.


# Check that emacs decodes the Encode::X11 output successfully.

use 5.004;
use strict;
use warnings;
use Test;
use FindBin;
use File::Spec;

use lib 't';
use MyTestHelpers;
MyTestHelpers::nowarnings();

# uncomment this to run the ### lines
#use Devel::Comments;

my $test_count = 3;
plan tests => $test_count;

if (! eval { require Encode }) {
  MyTestHelpers::diag ('Encode.pm module not available -- ',$@);
  foreach (1 .. $test_count) {
    skip ('No Encode module', 1, 1);
  }
  exit 0;
}

require App::MathImage::Encode::X11;

#------------------------------------------------------------------------------

# emacs23 decodes 0x1B 0x28 0x49 0x7E as ascii 0x7E instead of overline U+203E
# skip that one for now
my @ords = grep { ! ($_ == 0x7E
                     || ($_ >= 0x7F && $_ <= 0x9F)
                     || ($_ >= 0xD800 && $_ <= 0xDFFF)
                     || ($_ >= 0xFDD0 && $_ <= 0xFDEF)
                     || ($_ >= 0xFFFE && $_ <= 0xFFFF)
                     || ($_ >= 0x1FFFE && $_ <= 0x1FFFF)) }
#  32 .. 0x2FA1;
  32 .. 0x2FA1D;

{
  my $chars = '';
  my $bytes = '';

  foreach my $i (@ords) {
    ### i: sprintf("0x%X",$i)
    my $chr = chr($i);
    my $input_chr = $chr;
    my $encode = Encode::encode('x11-compound-text', $input_chr,
                                Encode::FB_QUIET());
    if (length $input_chr) {
      MyTestHelpers::diag ("skip unencodable ",to_hex($chr));
      next;
    }

    $bytes .= $encode;
    $chars .= $chr;
  }

  {
    open my $fh, '> :raw', 'tempfile.ctext' or die;
    print $fh $bytes or die;
    close $fh or die;
  }
  {
    open my $fh, '> :encoding(utf-8)', 'tempfile.utf8' or die;
    print $fh $chars or die;
    close $fh or die;
  }
}

my $elfile = File::Spec->catfile ($FindBin::Bin, 'Encode-X11-emacs.el');
ok (system("emacs21 -batch -q -no-site-file -l $elfile -f my-try-decode"),
    0);
ok (system("emacs22 -batch -q -no-site-file -l $elfile -f my-try-decode"),
    0);
ok (system("emacs23 -batch -q -no-site-file -l $elfile -f my-try-decode"),
    0);

exit 0;
