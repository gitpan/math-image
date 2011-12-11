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

package App::MathImage::NumSeq::DigitMedian;
use 5.004;
use strict;

use vars '$VERSION', '@ISA';
$VERSION = 84;

use Math::NumSeq::Base::IterateIth;
use Math::NumSeq::Base::Digits;
@ISA = ('Math::NumSeq::Base::IterateIth',
        'Math::NumSeq::Base::Digits');

use Math::NumSeq 7; # v.7 for _is_infinite()
*_is_infinite = \&Math::NumSeq::_is_infinite;

# uncomment this to run the ### lines
#use Devel::Comments;


use constant description => Math::NumSeq::__('Median digit in i.');
use constant values_min => 0;
use constant characteristic_count => 1;
use constant characteristic_increasing => 0;

use constant parameter_info_array =>
  [
   Math::NumSeq::Base::Digits::parameter_common_radix(),
   {
    name    => 'round',
    # display => Math::NumSeq::__('Round'),
    type    => 'enum',
    default => 'down',
    choices => ['down','up'],
    description => Math::NumSeq::__('Rounding direction when even number of digits'),
   },
  ];

my %oeis_anum;
# $oeis_anum{'down'}->[10] = '';
# $oeis_anum{'up'}->[10] = '';

sub oeis_anum {
  my ($self) = @_;
  return $oeis_anum{$self->{'round'}}->[$self->{'radix'}];
}

sub new {
  my $class = shift;
  ### NumSeq-PlanePathN new(): @_
  my $self = $class->SUPER::new(@_);

  if (! defined $self->{'round'}) {
    $self->{'round'} = 'down';
  }
  return $self;
}

sub ith {
  my ($self, $i) = @_;
  ### DigitMedian ith(): $i

  $i = abs($i);
  if (_is_infinite($i)) {
    return $i;  # don't loop forever if $i is +infinity
  }

  my $radix = $self->{'radix'};

  my @digits;
  do {
    push @digits, $i % $radix;
    $i = int($i/$radix);
  } while ($i);

  # 6 digits 0,1,2,3,4,5 int(6/2)=3 is up
  # 6 digits 0,1,2,3,4,5 int((6-1)/2)=2 is down
  # 7 digits 0,1,2,3,4,5,6 int(7/2)=3
  # 7 digits 0,1,2,3,4,5,6 int((7-1)/2)=3 too
  return (sort {$a<=>$b} @digits)
    [int((scalar(@digits)-($self->{'round'} ne 'up')) / 2)];
}

1;
__END__

