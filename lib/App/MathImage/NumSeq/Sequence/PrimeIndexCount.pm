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

package App::MathImage::NumSeq::Sequence::PrimeIndexCount;
use 5.004;
use strict;
use List::Util 'min', 'max';
use POSIX ();

use App::MathImage::NumSeq::Sequence::Primes;
use App::MathImage::NumSeq::Base '__';
use base 'App::MathImage::NumSeq::Sequence';

use vars '$VERSION';
$VERSION = 62;

# uncomment this to run the ### lines
#use Smart::Comments;

use constant name => __('Prime Numbers');
use constant description => __('The primes which are at prime number index positions, 3, 5, 11, 17, 31, etc.');
use constant characteristic_count => 1;
use constant values_min => 0;

# cf A049076 number of steps for the N'th prime
#  use constant oeis_anum => undef;

sub new {
  my ($class, %options) = @_;
  my $lo = $options{'lo'} || 0;
  my $hi = $options{'hi'};
  my $level = $options{'level'};
  if (! defined $level) { $level = 1; }

  my @array = App::MathImage::NumSeq::Sequence::Primes::_my_primes_list ($lo, $hi);
  my %hash = map { $array[$_] => $_+1 } 0 .. $#array;
  return $class->SUPER::new (%options,
                             hash => \%hash);
}

sub rewind {
  my ($self) = @_;
  $self->{'i'} = 0;
}
sub next {
  my ($self) = @_;
  my $i = $self->{'i'}++;
  return ($i, $self->ith($i));
}

sub ith {
  my ($self, $i) = @_;
  my $count = 0;
  while ($i = $self->{'hash'}->{$i}) {
    $count++;
  }
  return $count;
}

sub pred {
  my ($self, $value) = @_;
  return $value >= 0;
}

1;
__END__