# Copyright 2010, 2011 Kevin Ryde

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

package App::MathImage::NumSeq::RepdigitRadix;
use 5.004;
use strict;

use vars '$VERSION', '@ISA';
$VERSION = 81;
use Math::NumSeq;
@ISA = ('Math::NumSeq');

# uncomment this to run the ### lines
#use Smart::Comments;


use constant description => Math::NumSeq::__('First base in which N is a repdigit (of 3 or more digits), or 0 if no such radix.');
use constant values_min => 0;
use constant characteristic_smaller => 1;
use constant characteristic_monotonic => 0;
use constant i_start => 1;

# cf A059711 smallest base in which n is a repdigit
#
# use constant oeis_anum => '';

# b^2 + b + 1 = k
# (b+0.5)^2 + .75 = k
# (b+0.5)^2 = (k-0.75)
# b = sqrt(k-0.75)-0.5;

sub rewind {
  my ($self) = @_;
  $self->{'i'} = $self->i_start;
  $self->{'ones'}   = [ undef, undef, 7 ];
  $self->{'digits'} = [ undef, undef, 1 ];
}

# (r+1)^2 + (r+1) + 1
#   = r^2 + 2r + 1 + r +1 + 1
#   = r^2 + 3r + 3
#   = (r + 3)*r + 3

sub next {
  my ($self) = @_;
  ### RepdigitRadix next(): $self->{'i'}

  my $i = $self->{'i'}++;
  my $ones = $self->{'ones'};
  my $digits = $self->{'digits'};

  if ($i == 0) {
    return 2;
  }

  for (my $radix = 2; ; $radix++) {
    ### $radix
    ### ones: $ones->[$radix]
    ### digit: $digits->[$radix]

    my $one;
    if ($radix > $#$ones) {
      ### maybe extend array: $radix
      $one = ($radix + 1) * $radix + 1;
      if ($one > $i) {
        ### not repdigit in any radix ...
        return ($i, 0);
      }
      $ones->[$radix] = $one;
      $digits->[$radix] = 1;

    } else {
      $one = $ones->[$radix];
    }

    my $repdigit = $one * $digits->[$radix];
    while ($repdigit < $i) {
      my $digit = ++$digits->[$radix];
      if ($digit >= $radix) {
        $digit = $digits->[$radix] = 1;
        $one = $ones->[$radix] = ($one * $radix + 1);
      }
      $repdigit = $one * $digit;
    }
    ### consider repdigit: $repdigit
    if ($repdigit == $i) {
      ### found radix: $radix
      return ($i, $radix);
    }
  }
}

sub ith {
  my ($self, $i) = @_;
  ### RepdigitRadix ith(): $i

  for (my $radix = 2; ; $radix++) {
    ### $radix

    my $one = ($radix + 1) * $radix + 1;  # 111 in $radix
    if ($one > $i) {
      ### stop at ones too big not a repdigit: $one
      return 0;
    }
    ### $one

    do {
      if ($one == $i) {
        return $radix;
      }
      foreach my $digit (2 .. $radix-1) {
        ### $digit
        if ((my $repdigit = $digit * $one) <= $i) {
          if ($repdigit == $i) {
            return $radix;
          }
        }
      }
    } while (($one = $one * $radix + 1) <= $i);
  }
}

sub pred {
  my ($self, $value) = @_;
  return ($value == int($value)
          && ($value == 0 || $value >= 2));
}

1;
__END__

# Local variables:
# compile-command: "math-image --values=RepdigitRadix"
# End:
