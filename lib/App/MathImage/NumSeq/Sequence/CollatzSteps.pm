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

package App::MathImage::NumSeq::Sequence::CollatzSteps;
use 5.004;
use strict;
use List::Util 'min', 'max';

use App::MathImage::NumSeq::Base '__';
use base 'App::MathImage::NumSeq::Sequence';

use vars '$VERSION';
$VERSION = 61;

# uncomment this to run the ### lines
#use Smart::Comments;

use constant description => __('Number of steps to reach 1 in the Collatz "3n+1" problem.');
use constant characteristic_count => 1;
use constant values_min => 1;

use constant parameter_list =>
  ({ name    => 'step_type',
     display => __('Step Type'),
     type    => 'enum',
     default => 'up',
     choices => ['up','down','both'],
     description => __('Which steps to count, the 3*n+1 ups, the n/2 downs, or both.'),
   });

# cf
#    A075680 odd numbers only
#    A008908 both halvings and triplings, with +1
#
my %step_type_to_anum = (up   => 'A006667', # triplings
                         down => 'A006666', # halvings
                         both => 'A006577', # both halvings and triplings
                        );
sub oeis_anum {
  my ($self) = @_;
  return $step_type_to_anum{$self->{'step_type'}};
}

sub rewind {
  my ($self) = @_;
  $self->{'i'} = 1;
}

sub next {
  my ($self) = @_;
  my $i = $self->{'i'}++;
  return ($i, $self->ith($i));
}

my %step_type_to_up = (up   => 1,
                       down => 0,
                       both => 1);
my %step_type_to_down = (up   => 0,
                         down => 1,
                         both => 1);
sub ith {
  my ($self, $i) = @_;
  ### CollatzSteps ith(): $i
  my $count = 0;
  if ($i <= 1) {
    return $count;
  }
  my $step_type = $self->{'step_type'};
  my $count_up = $step_type_to_up{$step_type};
  my $count_down = $step_type_to_down{$step_type};
  for (;;) {
    until ($i & 1) {
      $i >>= 1;
      $count += $count_down;
    }
    ### odd: $i
    if ($i <= 1) {
      return $count;
    }
    $i = 3*$i + 1;
    $count += $count_up;
    ### tripled: "$i  count=$count"
  }
}

sub pred {
  my ($self, $value) = @_;
  return ($value >= 0);
}

1;
__END__



# Untouchables, not sum of proper divisors of any other integer
# p*q sum S=1+p+q
# so sums up to hi need factorize to (hi^2)/4
# 
