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

package App::MathImage::NumSeq::Sequence::NumaronsonA;
use 5.004;
use strict;
use warnings;
# use Locale::TextDomain 'App-MathImage';

use base 'App::MathImage::NumSeq::Sequence';

use vars '$VERSION';
$VERSION = 46;

# uncomment this to run the ### lines
#use Smart::Comments;

use constant values_min => 0;
use constant oeis => 'A079000';
# OeisCatalogue: A079000

sub new {
  my ($class, %options) = @_;

  return bless { p2k => 0,
                 j   => -1,
               }, $class;
}
sub next {
  my ($self) = @_;
  my $p2k = $self->{'p2k'};
  my $j = ++$self->{'j'};

  if ($p2k == 0) {
    # low special cases initial 1,4,
    if ($j < 2) {
      return $j*3 + 1;
    }
    $p2k = $self->{'p2k'} = 1;    # 2**k for k=0
    $j   = $self->{'j'}   = -3;   # -3*(2**k) for k=0
  } elsif ($j >= 3 * $p2k) {
    $self->{'p2k'} = ($p2k <<= 1);
    $j = $self->{'j'} = -3 * $p2k;
  }
  return 12*$p2k - 3 + (3*$j + abs($j))/2;
}

1;
__END__
