# Copyright 2011 Kevin Ryde

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

package App::MathImage::Encode::X11;
use 5.008;
use strict;
use warnings;
use Carp;

use Encode::Encoding;
our @ISA = ('Encode::Encoding');

our $VERSION = 58;

__PACKAGE__->Define('x11-compound-text');

# /usr/share/doc/xorg-docs/specs/CTEXT/ctext.txt.gz
# lcCT.c
# RFC2237 2022-jp
# RFC1557 2022-kr

my %coding_is_lo = ('ascii' => 1,
                    'jis0208-raw' => 1,
                    'jis0212-raw' => 1,
                    'ksc5601-raw' => 1,
                    'gb2312'      => 1,
                    'cns11643-1' => 1,
                    'cns11643-2' => 1,
                    'cns11643-3' => 1,
                    'cns11643-4' => 1,
                    'cns11643-5' => 1,
                    'cns11643-6' => 1,
                    'cns11643-7' => 1,
                   );
my %coding_is_hi = ('big5-eten' => 1,
                   );

my @coding = ('iso-8859-1',
              'iso-8859-2',
              'iso-8859-3',
              'iso-8859-4',
              'iso-8859-7',
              'iso-8859-6',
              'iso-8859-8',
              'iso-8859-5',
              'iso-8859-9',
              'jis0201-raw',

              'jis0208-raw',
              'ksc5601-raw',
              'jis0212-raw',
              'gb2312',
             );
# Esc 0x2D switch GR 0x80-0xFF
my @esc = ("\033\055\101", # iso-8859-1 GR
           "\033\055\102", # iso-8859-2 GR
           "\033\055\103", # iso-8859-3 GR
           "\033\055\104", # iso-8859-4 GR
           "\033\055\106", # iso-8859-7 GR
           "\033\055\107", # iso-8859-6 GR
           "\033\055\110", # iso-8859-8 GR
           "\033\055\114", # iso-8859-5 GR
           "\033\055\115", # iso-8859-9 GR
           "\x1B\x29\x4A", # jis 201  GR

           "\x1B\x24\x28\x42", # jis 208  GL
           "\x1B\x24\x28\x43", # ksc 5601 GL
           "\x1B\x24\x28\x44", # jis 212  GL
           "\x1B\x24\x28\x41", # gb 2312  GL

           # "\x1B\x24\x28\x47" => 'cns11643-1', # Encode::HanExtra
           # "\x1B\x24\x28\x48" => 'cns11643-2',
           # "\x1B\x24\x28\x49" => 'cns11643-3',
           # "\x1B\x24\x28\x4A" => 'cns11643-4',
           # "\x1B\x24\x28\x4B" => 'cns11643-5',
           # "\x1B\x24\x28\x4C" => 'cns11643-6',
           # "\x1B\x24\x28\x4D" => 'cns11643-7',
          );

# xfree86 utf8 in compound: ESC % G --UTF-8-BYTES-- ESC % @
#                              25 47                    25 40

sub encode {
  my ($self, $str, $chk) = @_;
  require Encode;

  # as much initial latin1 as possible
  my $ret = Encode::encode ('iso-8859-1', $str, Encode::FB_QUIET());

  my $in_latin1 = 1;

  while (length($str)) {
    ### str length: length($str)

    my $longest_bytes = '';
    my $esc;
    my $remainder = $str;
    foreach my $i (0 .. $#coding) {
      last unless length($remainder);
      my $input = $str;
      my $bytes = Encode::encode ($coding[$i], $input, Encode::FB_QUIET());
      if (length($input) < length($remainder)) {
        $longest_bytes = $bytes;
        $esc = $esc[$i];
        $remainder = $input;
        $in_latin1 = ($i == 0);
      }
    }
    ### $longest_bytes
    ### $esc

    if (length($longest_bytes)) {
      if (length($esc) == 3) {
        ### want ascii in GL
        $ret .= _encode_ensure_ascii($self);
      } else {
        $self->{'gl_non_ascii'} = 1;
      }
      $ret .= $esc;
      $ret .= $longest_bytes;
      $str = $remainder;

    } else {
      ### unconvertable: ord(substr($str,0,1))
      if ($chk) {
        ### stop
        last;
      } else {
        ### substitute "?" char
        $ret .= _encode_ensure_ascii($self);
        $ret .= '?';
        $str = substr ($str, 1);
      }
    }
  }
  # if (! $in_latin1) {
  #   $ret .= $esc[0];
  # }
  if ($chk) {
    $_[1] = $str;  # unconverted part, if any
  }
  return $ret;
}
sub _encode_ensure_ascii {
  my ($self) = @_;
  if ($self->{'gl_non_ascii'}) {
    $self->{'gl_non_ascii'} = 0;
    return "\x1B\x28\x42"; # ascii GL
  } else {
    return '';
  }
}

    # foreach my $coding ('jp', 'kr') {
    #   last unless length($remainder);
    #   my $input = $str;
    #   my $bytes = Encode::encode ("euc-$coding", $input, Encode::FB_QUIET());
    #   ### coding: "euc-$coding"
    #   ### $bytes
    #   ### remainder: length($input)
    #   if (length($input) < length($remainder)) {
    #     my $input2 = substr ($str, 0, length($str)-length($input));
    #     ### $input2
    #     $bytes = Encode::encode ("iso-2022-$coding", $input2,
    #                              Encode::FB_QUIET());
    #     ### coding: "iso-2022-$coding"
    #     ### $bytes
    #     ### remainder: length($input2)
    #     ### assert: length($input2) == 0
    #     if (length($input2) == 0) {
    #       $longest_bytes = $bytes;
    #       $esc = '';
    #       $remainder = $input;
    #       $in_latin1 = 0;
    #       $in_ascii = 0;
    #     }
    #   }
    # }


#------------------------------------------------------------------------------
# decode()

# xfree86 utf8 in compound: ESC % G --UTF-8-BYTES-- ESC % @
#                              25 47                    25 40

my %esc_to_coding = ((map { $esc[$_] => $coding[$_] } 0 .. $#coding),
                     "\x1B\x28\x42" => 'ascii',

                     "\x1B\x28\x4A" => 'ascii',       # jis0201 GL is ascii
                     "\x1B\x29\x4A" => 'jis0201-raw', # GR

                     # \x24 means 2-bytes per char
                     # "\x1B\x24\x28\x41" => 'gb2312',
                     # "\x1B\x24\x28\x42" => 'jis0208-raw',# 208-1983 or 208-1990
                     # "\x1B\x24\x28\x43" => 'ksc5601-raw',
                     # "\x1B\x24\x28\x44" => 'jis0212-raw',# 212-1990

                     # http://www.itscj.ipsj.or.jp/ISO-IR/2-4.htm
                     "\x1B\x24\x28\x47" => 'cns11643-1', # Encode::HanExtra
                     "\x1B\x24\x28\x48" => 'cns11643-2',
                     "\x1B\x24\x28\x49" => 'cns11643-3',
                     "\x1B\x24\x28\x4A" => 'cns11643-4',
                     "\x1B\x24\x28\x4B" => 'cns11643-5',
                     "\x1B\x24\x28\x4C" => 'cns11643-6',
                     "\x1B\x24\x28\x4D" => 'cns11643-7',

                     # Emacs extensions ... are these big5-eten ?
                     # "\x1B\x24\x28\x30" => 'big5-eten', # E0
                     # "\x1B\x24\x28\x31" => 'big5-eten', # E1

                     # XFree86
                     # http://www.itscj.ipsj.or.jp/ISO-IR/2-8-1.htm
                     "\x1B\x25\x47" => 'utf-8',
                     "\x1B\x25\x40" => 'ascii',  # back to GL/GR style ...
                    );

sub decode {
  my ($self, $bytes, $chk) = @_;
  ### _decode_compound(): 'len='.length($bytes)
  require Encode;

  my $gl_coding = 'ascii';
  my $gr_coding = 'iso-8859-1';
  my $lo_to_hi = 0;
  my $ret = '';
 OUTER: while ((pos($bytes)||0) < length $bytes) {
    $bytes =~ m{\G(.*?)  # $1 part
                (\x1B    # $2 esc
                  (?:[\x28\x2D].   # 1-byte
                  |\x24[\x28\x29]. # 2-byte
                  |\x25\x47        # xfree86 utf-8
                  )
                |$)
             }gx or die;
    my $part_bytes = $1;
    my $esc = $2;

    for (;;) {
      my $coding;
      if ($part_bytes =~ /\G([\x00-\x7F]+)/gc) {
        $coding = $gl_coding;
        if ($coding_is_hi{$coding}) {
          $part_bytes =~ tr/\x21-\x7E/\xA1-\xFE/;
        }
      } elsif ($part_bytes =~ /\G([^\x00-\x7F]+)/gc) {
        $coding = $gr_coding;
        if ($coding_is_lo{$coding}) {
          $part_bytes =~ tr/\xA1-\xFE/\x21-\x7E/;
        }
      } else {
        last;
      }
      my $half_bytes = $1;

      while (length $half_bytes) {
        ### $half_bytes
        ### $coding
        $ret .= Encode::decode ($coding, $half_bytes,
                                $chk ? Encode::FB_QUIET() : Encode::FB_DEFAULT());
        ### now ret: $ret
        if (length $half_bytes) {
          if ($chk) {
            $_[1] = substr ($bytes,
                            pos($bytes) - length($esc)
                            - length($part_bytes) - length($half_bytes));
            last OUTER;
          } else {
            $ret .= chr(0xFFFD);
            $half_bytes = substr($half_bytes, 1);
          }
        }
      }
    }

    my $coding;
    my $gref;
    if (($esc =~ s/\x1B\x24?\x29/\x1B\x24\x28/)
        ||
        ($esc =~ s/\x1B\x24?\x29/\x1B\x24\x28/)) {
      $gref = \$gl_coding;
    } else {
      $gref = \$gr_coding;
    }
    $coding = $esc_to_coding{$esc};
    if (! defined $coding
        || ($coding =~ /^cns/
            && ! eval { require Encode::HanConvert; 1 })) {
      ### no coding: $coding
      if ($chk) {
        $_[1] = substr ($bytes, pos($bytes) - length($esc));
        last;
      } else {
        $ret .= chr(0xFFFD);
      }
    }
    $$gref = $coding;
  }
  ### final ret: $ret
  return $ret;
}

1;
__END__

=for stopwords Math-Image Ryde

=head1 NAME

App::MathImage::Encode::X11 -- character encodings for X11

=for test_synopsis my ($bytes)

=head1 SYNOPSIS

 use Encode;
 use App::MathImage::Encode::X11;
 my $chars = Encode::decode ('x11-compound-text', $bytes);

=head1 DESCRIPTION

In progress, partly working ...

This module encodes and decodes X11 ICCCM "compound text" encoded strings,

    x11-compound-text     COMPOUND_TEXT type

Compound text is basically runs of various basic encodings, with escape
sequences to switch between them.

Some characters can be represented in more than one encoding.  The current
code tries to do something sensible and compatible.  (Maybe variant names or
encode object settings could control preferences in that area.)

Recent compound text specs for example include utf-8, so an encode could
actually be as simple as sticking "Esc % G" in front of utf-8 bytes.  But
for the benefit of inter-operation with older clients the original
iso-8859-N, jisx, ksc and gb encodings are preferred when they suffice, then
the cns pages, and only then utf-8.  Emacs has some big5 forms too, but not
sure quite how that works so they're not used currently.

Decode might be as easy as passing straight to a full iso-2022, if such a
thing exists now or in the future, but as yet it's done with explicit code.

One of the motivations for the compound text style is that iso, jisx, etc
runs can be treated as separate parts.  To draw on screen for instance a
font can be found for each, then draw 8-bit or 16-bit chars in the font.
For that sort of thing a decode to Perl wide chars is not really wanted.

=head1 SEE ALSO

L<Encode>

=head1 HOME PAGE

L<http://user42.tuxfamily.org/math-image/index.html>

=head1 LICENSE

Copyright 2011 Kevin Ryde

Math-Image is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by the
Free Software Foundation; either version 3, or (at your option) any later
version.

Math-Image is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
more details.

You should have received a copy of the GNU General Public License along with
Math-Image.  If not, see L<http://www.gnu.org/licenses/>.

=cut
