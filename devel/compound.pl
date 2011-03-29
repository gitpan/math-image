#!/usr/bin/perl -w

# Copyright 2011 Kevin Ryde

# This file is part of Math-Image.
#
# Math-Image is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as published
# by the Free Software Foundation; either version 3, or (at your option) any
# later version.
#
# Math-Image is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General
# Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Math-Image.  If not, see <http://www.gnu.org/licenses/>.

use 5.004;
use strict;
use Encode;
use POSIX qw(setlocale LC_ALL LC_TIME);
# use Encode::JP;

# uncomment this to run the ### lines
use Smart::Comments;


{
  require App::MathImage::X11::Protocol::Splash;
  foreach my $ord (0x401 .. 0x4001) {
    my $input = chr($ord);
    my $bytes = App::MathImage::X11::Protocol::Splash->_encode_compound ($input, 1);
    if (! length $bytes) {
      next;
    }
    my $dec = App::MathImage::X11::Protocol::Splash->_decode_compound ($bytes, 1);
    if ($dec ne chr($ord)) {
      printf "ord %02X\n", $ord;
      print "bytes ", length($bytes),": ";
      foreach my $i (0 .. length($bytes)-1) {
        printf " %02X", ord(substr($bytes,$i,1));
      }
      print "\n";
      print "remainder ",length($input),": ";
      foreach my $i (0 .. length($input)-1) {
        printf " %02X", ord(substr($input,$i,1));
      }
      print "\n";
      print "dec ", length($dec),": ";
      foreach my $i (0 .. length($dec)-1) {
        printf " %02X", ord(substr($dec,$i,1));
      }
      print "\n";
    }
  }
  exit 0;
}

{
  open my $out, '>:utf8', '/tmp/x.utf8' or die;
  foreach my $i (32 .. 0x2FA1D) {
    next if $i >= 0x80 && $i <= 0x9F;
    next if $i >= 0xD800 && $i <= 0xDFFF;
    next if $i >= 0xFDD0 && $i <= 0xFDEF;
    next if $i >= 0xFFFE && $i <= 0xFFFF;
    next if $i >= 0x1FFFE && $i <= 0x1FFFF;
    printf $out "U+%04X = %s\n", $i, chr($i);
  }
  close $out or die;
  exit 0;
}

{
  require App::MathImage::X11::Protocol::Splash;
  my $input = "\x{2572}"; # wo
  $input = "\x{391}"; # capital alpha
  $input = "\x{6708}"; # month
  # my $bytes = Encode::encode ('iso-2022-jp', $input);
  my $bytes = App::MathImage::X11::Protocol::Splash->_encode_compound ($input);
  print "remainder ",length($input),"\n";
  foreach my $i (0 .. length($input)-1) {
    printf " %02X", ord(substr($input,$i,1));
  }
  print "\n";
  print "bytes ", length($bytes),"\n";
  foreach my $i (0 .. length($bytes)-1) {
    printf " %02X", ord(substr($bytes,$i,1));
  }
  print "\n";
  exit 0;
}

{
  require X11::Protocol;
  require App::MathImage::X11::Protocol::Splash;
  my $X = X11::Protocol->new;
  my $input = "\x{2572}"; # wo
  $input = "\x{391}"; # capital alpha
  $input = "\x{6708}"; # month
  $input = "\x{0401}\x{1234}\x{0401}";
  # my $bytes = Encode::encode ('iso-2022-jp', $input);
  my ($atom, @chunks) = App::MathImage::X11::Protocol::Splash::_str_to_text_chunks($X,$input);
  print $X->atom_name($atom),"\n";
  foreach my $bytes (@chunks) {
    print "bytes ", length($bytes),"\n";
    foreach my $i (0 .. length($bytes)-1) {
      printf " %02X", ord(substr($bytes,$i,1));
    }
    print "\n";
  }
  exit 0;
}

{
  require Encode;
  require Encode::KR;
  require Encode::KR::2022_KR;
  my $input;
  $input = "\x{0401}";
  $input = "\x{391}"; # capital alpha
  $input = "\x{1234}";
  $input = "\x{0401}\x{1234}\x{0401}";
  my $bytes = Encode::encode (
                              'iso-2022-kr',
                              $input,
                              # Encode::FB_DEFAULT(),
                              Encode::FB_QUIET(),
                             );
  print "remainder ",length($input),"\n";
  foreach my $i (0 .. length($input)-1) {
    printf " %02X", ord(substr($input,$i,1));
  }
  print "\n";
  print "bytes ", length($bytes),"\n";
  foreach my $i (0 .. length($bytes)-1) {
    printf " %02X", ord(substr($bytes,$i,1));
  }
  print "\n";
  exit 0;
}
{
  require Set::IntSpan::Fast;
  require App::MathImage::X11::Protocol::Splash;
  my $span = Set::IntSpan::Fast->new;
  my $prev = 0;
  # foreach my $i (32 .. 0x1000) {
  foreach my $i (32 .. 0x2FA1D) {
    next if $i >= 0xD800 && $i <= 0xDFFF;
    next if $i >= 0xFDD0 && $i <= 0xFDEF;
    next if $i >= 0xFFFE && $i <= 0xFFFF;
    next if $i >= 0x1FFFE && $i <= 0x1FFFF;
    my $str = chr($i);
    # App::MathImage::X11::Protocol::Splash->_encode_compound ($str, 1);
    Encode::encode ('euc-kr', $str, Encode::FB_QUIET());
    if (! length($str)) {
      $span->add($i);
      if ($i != $prev+1) {
        print "$i\n";
      }
      $prev = $i;
    }
  }
  print $span->as_string,"\n";
  print "count ",$span->cardinality,"\n";
  exit 0;
}


{
  $ENV{'LANG'} = 'en_IN.UTF8';
  $ENV{'LANG'} = 'ar_IN';
  $ENV{'LANG'} = 'ja_JP.UTF8';
  $ENV{'LANG'} = 'ja_JP';
  setlocale(LC_ALL, '') or die;
  my $bytes = POSIX::strftime ("%b", localtime(time()));
  ### $bytes
  foreach my $i (0 .. length($bytes)-1) {
    printf " %02X", ord(substr($bytes,$i,1));
  }
  print "\n";
  my $str = Encode::decode('euc-jp',$bytes);
  foreach my $i (0 .. length($str)-1) {
    printf " %02X", ord(substr($str,$i,1));
  }
  print "\n";
  exit 0;
}
{
  require Encode;
  my @all_encodings = Encode->encodings(":all");
  foreach my $encoding (@all_encodings) {
    print "$encoding\n";
  }
  exit 0;
}

