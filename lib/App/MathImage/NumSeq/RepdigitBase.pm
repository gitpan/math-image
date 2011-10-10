# progressive sieve


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

package App::MathImage::NumSeq::RepdigitBase;
use 5.004;
use strict;

use vars '$VERSION', '@ISA';
$VERSION = 76;
use Math::NumSeq::Base::Array;
@ISA = ('Math::NumSeq::Base::Array');


# uncomment this to run the ### lines
#use Smart::Comments;

use constant description => Math::NumSeq::__('First base in which N is a repdigit.');
use constant values_min => 2;
use constant characteristic_count => 1;
use constant characteristic_smaller => 1;
use constant characteristic_monotonic => 0;
# use constant oeis_anum => '';

# b^2 + b + 1 = k
# (b+0.5)^2 + .75 = k
# (b+0.5)^2 = (k-0.75)
# b = sqrt(k-0.75)-0.5;

sub new {
  my ($class, %options) = @_;
  my $lo = $options{'lo'} || 0;
  my $hi = $options{'hi'};

  ### bases to: 2+int(sqrt($hi-0.75))
  my @ret = (2, (0) x ($hi-1)); # zero considered 000...
  foreach my $base (2 .. 1+int(sqrt($hi-0.75))) {
    my $n = ($base + 1) * $base + 1;  # 111 in $base
    while ($n <= $hi) {
      $ret[$n] ||= $base;
      foreach my $digit (2 .. $base-1) {
        if ((my $mult = $digit * $n) <= $hi) {
          $ret[$mult] ||= $base;
        }
      }
      $n = $n * $base + 1;
    }
  }
  return $class->SUPER::new (%options,
                             array => \@ret);
}

sub ith {
  my ($self, $i) = @_;
  ### bases to: 2+int(sqrt($i-0.75))
  if ($i == 0) {
    return 2;
  }

  foreach my $base (2 .. 1+int(sqrt($i-0.75))) {
    my $n = ($base + 1) * $base + 1;  # 111 in $base
    while ($n <= $i) {
      if ($n == $i) {
        return $base;
      }
      foreach my $digit (2 .. $base-1) {
        if ((my $mult = $digit * $n) <= $i) {
          if ($mult == $i) {
            return $base;
          }
        }
      }
      $n = $n * $base + 1;
    }
  }
  return 0; # not a repdigit in any base
}

sub pred {
  my ($self, $value) = @_;
  return ($value == int($value) && ($value == 0 || $value >= 2));
}

1;
__END__
