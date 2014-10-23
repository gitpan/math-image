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

# uncomment this to run the ### lines
#use Devel::Comments; # '###';

our $VERSION = 61;

__PACKAGE__->Define('x11-compound-text');

# /usr/share/doc/xorg-docs/specs/CTEXT/ctext.txt.gz
# lcCT.c
# RFC2237 2022-jp
# RFC1557 2022-kr

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
              'gb2312-raw',
             );
# Esc 0x2D switch GR 0x80-0xFF
my @esc = ("\x1B\x2D\x41", # iso-8859-1 GR
           "\x1B\x2D\x42", # iso-8859-2 GR
           "\x1B\x2D\x43", # iso-8859-3 GR
           "\x1B\x2D\x44", # iso-8859-4 GR
           "\x1B\x2D\x46", # iso-8859-7 GR
           "\x1B\x2D\x47", # iso-8859-6 GR
           "\x1B\x2D\x48", # iso-8859-8 GR
           "\x1B\x2D\x4C", # iso-8859-5 GR
           "\x1B\x2D\x4D", # iso-8859-9 GR
           "\x1B\x29\x49", # jis 201 right half  GR

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

sub _encodable_char {
  my ($str) = @_;
  foreach my $coding (@coding) {
    my $input = $str;
    my $bytes = Encode::encode ($coding, $input, Encode::FB_QUIET());
    if (! length($input)) {
      return 1;
    }
  }
  return 0;
}

my $use_utf8 = 1;

sub encode {
  my ($self, $str, $chk) = @_;
  ### Encode-X11 encode(): 'len='.length($str)
  require Encode;

  # FIXME: don't think want to preserve esc state across multiple encode()
  # calls, except for perlio ...
  local $self->{'gl_non_ascii'};

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
        ### coding: $coding[$i]
        ### length: length($bytes)
        $longest_bytes = $bytes;
        $esc = $esc[$i];
        $remainder = $input;
        $in_latin1 = ($i == 0);
      }
    }
    ### $longest_bytes
    ### $esc

    if (length($longest_bytes)) {
      if ($esc eq "\x1B\x29\x49") {  # 0x49 right half jis0201 in GR
        if ($longest_bytes !~ /[\x80-\xFF]/) {
          $esc = '';
        }
        if ($longest_bytes =~ /[\x00-\x7F]/) {
          # 0x7E overline U+203E switch GL to jis0201
          $esc .= "\x1B\x28\x4A"; # 0x4A left half in GL
          $self->{'gl_non_ascii'} = 1;
        }
      } elsif (length($esc) == 3) {
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

      if ($use_utf8) {
        my $ulen = 1;
        for (;;) {
          if (_encodable_char(substr($str,$ulen,1))) {
            last;
          }
          $ulen++;
        }
        my $input = substr($str,0,$ulen);
        $str = substr($str,$ulen);

        my $bytes = Encode::encode ('utf-8', $input, Encode::FB_QUIET());
        $ret .= "\x1B\x25\x47";
        $ret .= $bytes;
        $ret .= "\x1B\x25\x40";
        if (length($input)) {
          ### oops, unencodable as utf-8 too
          $str = $input . $str;
        } else {
          next;
        }
      }

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
  ### encode final: $ret
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

my %esc_to_coding =
 (
  # esc[] table above
  (map { $esc[$_] => $coding[$_] } 0 .. $#coding),
 
  "\x1B\x28\x4A" => 'jis0201-raw', # jis0201 GL ascii except 0x7E
  "\x1B\x29\x49" => 'jis0201-raw', # jis0201 right GR japanese

  # but supposed to have 0x4A jis0201 left only in GL, and 0x49 jis0201
  # right only in GR
  "\x1B\x28\x49" => 'ascii',       # jis0201 GL
  "\x1B\x29\x4A" => 'iso-8859-1',  # jis0201 GR
  
  "\x1B\x28\x42" => 'ascii',
  
  # "\x1B\x2D\x44" => 'jis0212-raw', # GL 1-bytes 96 chars
  
  # \x24 means 2-bytes per char
  # "\x1B\x24\x28\x41" => 'gb2312',
  # "\x1B\x24\x28\x42" => 'jis0208-raw',# 208-1983 or 208-1990
  "\x1B\x24\x28\x43" => 'ksc5601-raw',
  "\x1B\x24\x28\x44" => 'jis0212-raw',# 212-1990
  
  # http://www.itscj.ipsj.or.jp/ISO-IR/2-4.htm
  "\x1B\x24\x28\x47" => 'cns11643-1', # Encode::HanExtra
  "\x1B\x24\x28\x48" => 'cns11643-2',
  "\x1B\x24\x28\x49" => 'cns11643-3',
  "\x1B\x24\x28\x4A" => 'cns11643-4',
  "\x1B\x24\x28\x4B" => 'cns11643-5',
  "\x1B\x24\x28\x4C" => 'cns11643-6',
  "\x1B\x24\x28\x4D" => 'cns11643-7',
  
  
  # Emacs chinese-big5-1, A141-C67E
  # "\x1B\x24\x28\x30" => 'big5-eten', # E0
  
  # Emacs chinese-big5-2, C940-FEFE
  # "\x1B\x24\x28\x31" => 'big5-hkscs',
  
  # Emacs mule ipa or chinese-sisheng ?
  # "\x1B\x2D\x30" => 'ipa',
  # Emacs mule viscii ?
  # "\x1B\x2D\x31" => 'viscii-lower',
  # "\x1B\x2D\x32" => 'viscii-upper',
  
 );

my %coding_is_lo = ('ascii' => 1,
                    'jis0208-raw' => 1,
                    'jis0212-raw' => 1,
                    'ksc5601-raw' => 1,
                    'gb2312-raw'  => 1,
                    'cns11643-1' => 1,
                    'cns11643-2' => 1,
                    'cns11643-3' => 1,
                    'cns11643-4' => 1,
                    'cns11643-5' => 1,
                    'cns11643-6' => 1,
                    'cns11643-7' => 1,
                   );
my %coding_is_hi = ('big5-eten' => 1,
                    'big5-hkscs' => 1,
                   );

sub decode {
  my ($self, $bytes, $chk) = @_;
  ### Encode-X11 decode(): 'len='.length($bytes)

  require Encode;
  my $ret = '';  # wide chars to return
  my $gl_coding = 'ascii';
  my $gr_coding = 'iso-8859-1';
  my $in_utf8 = 0;

  while ((pos($bytes)||0) < length $bytes) {
    $bytes =~ m{\G(.*?)  # $1 part
                (\x1B    # $2 esc
                  (?:[\x28\x29\x2D].   # 1-byte 94, 94GR, or 96GR
                  |\x24[\x28\x29\x2D]. # 2-byte 94^2 or 96^2
                  |\x25[\x47\x40]      # xfree86 utf-8
                  )
                |$)
             }gx or die;
    my $part_bytes = $1;
    my $esc = $2;

    ### $gl_coding
    ### $gr_coding
    ### part_bytes len: length($part_bytes)
    #### part_bytes: $part_bytes
    for (;;) {
      my $coding;
      my $half_bytes;
      if ($in_utf8 && length($part_bytes) && ! pos($part_bytes))  {
        ### utf8 bytes
        $half_bytes = $part_bytes;
        pos($part_bytes) = length($part_bytes);
        $coding = 'utf-8';

      } elsif ($part_bytes =~ /\G([\x00-\x7F]+)/gc) {
        ### run of GL low bytes ...
        $half_bytes = $1;
        $coding = $gl_coding;
        if ($coding_is_hi{$coding}) {
          $half_bytes =~ tr/\x21-\x7E/\xA1-\xFE/;
        }
      } elsif ($part_bytes =~ /\G([^\x00-\x7F]+)/gc) {
        ### run of GR high bytes ...
        $half_bytes = $1;
        $coding = $gr_coding;
        if ($coding_is_lo{$coding}) {
          ### pos: pos($part_bytes)
          $half_bytes =~ tr/\xA1-\xFE/\x21-\x7E/;
          ### pos: pos($part_bytes)
        }
      } else {
        last;
      }

      while (length $half_bytes) {
        ### $coding
        ### half_bytes len: length($half_bytes)
        #### $half_bytes
        $ret .= Encode::decode ($coding, $half_bytes,
                                $chk ? Encode::FB_QUIET() : Encode::FB_DEFAULT());
        ### half_bytes left: length($half_bytes)
        ### now ret len: length($ret)
        #### now ret: $ret
        if (length $half_bytes) {
          ### decode error at: sprintf("%#X",pos($bytes))
          if ($chk) {
            $_[1] = substr ($bytes,
                            pos($bytes) - length($esc)
                            - length($part_bytes) + pos($part_bytes)
                            - length($half_bytes));
            return $ret;

          } else {
            $ret .= chr(0xFFFD);
            # or skip two for a 2-byte encoding ?
            $half_bytes = substr($half_bytes, 1);
          }
        }
      }
    }

    ### esc: join(' ',map {sprintf("%02X",ord(substr($esc,$_,1)))} 0 .. length($esc)-1)
    # XFree86
    # http://www.itscj.ipsj.or.jp/ISO-IR/2-8-1.htm
    if ($esc eq "\x1B\x25\x47") {
      $in_utf8 = 1;
      next;
    }
    if ($esc eq "\x1B\x25\x40") {
      $in_utf8 = 0;  # back to GL/GR style ...
      next;
    }

    my $coding = $esc_to_coding{$esc};
    my $gref;
    if (($esc =~ s/\x1B\x29/\x1B\x28/)   # 1-byte 94-char
        ||
        ($esc =~ s/\x1B\x24[\x29\x2D]/\x1B\x24\x28/)   # 2-byte 94^2-char
        ||
        ($esc =~ /\x1B\x2D/)   # 1-byte 96-char
       ) {
      $gref = \$gr_coding;
    } else {
      $gref = \$gl_coding;
    }
    ### mangled esc: join(' ',map {sprintf("%02X",ord(substr($esc,$_,1)))} 0 .. length($esc)-1)

    $coding ||= $esc_to_coding{$esc};
    if (! defined $coding
        || ($coding =~ /^cns/
            && ! eval { require Encode::HanConvert; 1 })) {
      ### no coding: $coding
      if ($chk) {
        pos($bytes) -= length($esc);
        last;
      } else {
        $ret .= chr(0xFFFD);
      }
    }
    $$gref = $coding;
  }

  ### final len: length($ret)
  #### final ret: $ret
  $_[1] = substr ($bytes, pos($bytes));
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

This module encodes and decodes X11 ICCCM "compound text" strings,

    x11-compound-text     COMPOUND_TEXT bytes

Compound text is ISO-2022 escape sequence runs of various basic encodings,
including the ISO-8859 series, JIS, KSC, and GB.

The plain "x11-compound-text" name tries to encode in a sensible and
compatible way.  Perhaps in the future there'll be some options variations
for which charsets to prefer in the encode.

The decode tries to recognise anything.  Perhaps it just go to a full
iso-2022, if/when that might exist, but for now it's done explicitly.

One of the motivations for compound text is that segments of the various
charsets can be handled separately, for instance finding a font with the
encoding and sending the bytes to the server to draw.  Decoding to Perl wide
chars doesn't suit that sort of thing.

=head2 XFree86 UTF-8

The UTF-8 escape from XFree86 and adopted as a variable encoding is
recognised in the decode and used in the encode.  For encode it's only used
for characters not encodable by the basic ICCCM charsets.  Preferring the
original charsets should help inter-operation with older clients.  Keeping
the utf-8 to just otherwise unencodable parts might let as much as possible
be understood by an older client.

=head2 Emacs

Emacs generates some "private encoding" escapes sequences.  Not sure which
of them are standard or semi-standard, so no promises whether they'll work.
The intention would be to recognise semi-standard ones on decode at least.

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

# =head2 Emacs
# 
# Emacs generates some big5-hkscs as "private encodings" 0x30 and 0x31.  In
# the current code they're recognised for decode, but are not generated by the
# encode.  Perhaps there should be options to control which private encodings
# are accepted and what they mean.

# =head2 UTF-8
# 
# Recent compound text specs include a utf-8 originally from XFree86.  That's
# recognised for decode, and for encode is generated if nothing else suffices.
# 
# This utf-8 could actually make an encode as simple as sticking "Esc % G" in
# front of utf-8 bytes.  But for the benefit of inter-operation with older
# clients the original iso-8859-N, jisx, ksc and gb encodings are preferred.

