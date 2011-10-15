# proper ... inc 1 ex N




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


# math-image --path=MathImageDivisibleColumns --all
# math-image --path=MathImageDivisibleColumns --output=numbers --all

package Math::PlanePath::MathImageDivisibleColumns;
use 5.004;
use strict;

use vars '$VERSION', '@ISA';
$VERSION = 77;

use Math::PlanePath;
@ISA = ('Math::PlanePath');
*_is_infinite = \&Math::PlanePath::_is_infinite;
*_round_nearest = \&Math::PlanePath::_round_nearest;

# uncomment this to run the ### lines
#use Devel::Comments;

use constant n_start => 0;
use constant x_negative => 0;
use constant y_negative => 0;

use constant parameter_info_array =>
  [ { name    => 'divisors_type',
      display => 'Divisors Type',
      type    => 'enum',
      choices => ['all','proper'],
      default => 'all',
      # description => '',
    },
  ];


my @x_to_n = (0,0,1);
sub _extend {
  ### _extend(): $#x_to_n
  my $x = $#x_to_n;
  push @x_to_n, $x_to_n[$x] + _divisors($x);

  # if ($x > 2) {
  #   if (($x & 3) == 2) {
  #     $x >>= 1;
  #     $next_n += $x_to_n[$x] - $x_to_n[$x-1];
  #   } else {
  #     $next_n +=
  #   }
  # }
  ### last x: $#x_to_n
  ### second last: $x_to_n[$#x_to_n-2]
  ### last: $x_to_n[$#x_to_n-1]
  ### diff: $x_to_n[$#x_to_n-1] - $x_to_n[$#x_to_n-2]
  ### divisors of: $#x_to_n - 2
  ### divisors: _divisors($#x_to_n-2)
  ### assert: $x_to_n[$#x_to_n-1] - $x_to_n[$#x_to_n-2] == _divisors($#x_to_n-2)
}

sub new {
  my $self = shift->SUPER::new (@_);
  $self->{'proper'} = (($self->{'divisors_type'}||'') eq 'proper');
  return $self;
}

sub n_to_xy {
  my ($self, $n) = @_;
  ### DivisibleColumns n_to_xy(): $n

  # $n<-0.5 works with Math::BigInt circa Perl 5.12, it seems
  if ($n < -0.5) {
    return;
  }
  if (_is_infinite($n)) {
    return ($n,$n);
  }

  my $frac;
  {
    my $int = int($n);
    if ($n == $int) {
      $frac = 0;
    } else {
      $frac = $n - $int; # -.5 <= $frac < 1
      $n = $int;         # BigFloat int() gives BigInt, use that
      if ($frac > .5) {
        $frac--;
        $n += 1;
        # now -.5 <= $frac < .5
      }
      ### $n
      ### $frac
      ### assert: $frac >= -.5
      ### assert: $frac < .5
    }
  }
  my $proper = $self->{'proper'};

  my $x;
  if ($proper) {
    $n += 6;
    $x = 5;
    ### proper adjusted n: $n
  } else {
    $x = 1;
  }

  for (;;) {
    while ($x > $#x_to_n) {
      _extend();
    }
    $n += $proper;
    ### consider: "n=$n x=$x  x_to_n=".$x_to_n[$x]
    if ($x_to_n[$x] > $n) {
      $x--;
      last;
    }
    $n += $proper;
    # if ($proper) {
    #   $n += 2;
    # }
    $x++;
  }
  $n -= $x_to_n[$x];
  $n -= $proper;
  $n -= $proper;
  ### $x
  ### x_to_n: $x_to_n[$x]
  ### x_to_n next: $x_to_n[$x+1]
  ### remainder: $n

  my $y = 1+$proper;
  for (;;) {
    unless ($x % $y) {
      if (--$n < 0) {
        return ($x, $frac + $y);
      }
    }
    if (++$y > $x) {
      ### oops, not enough in this column
      return;
    }
  }
}

sub _divisors {
  my ($x) = @_;
  my $ret = 1;
  unless ($x % 2) {
    my $count = 1;
    do {
      $x /= 2;
      $count++;
    } until ($x % 2);
    $ret *= $count;
  }
  my $limit = sqrt($x);
  for (my $d = 3; $d <= $limit; $d+=2) {
    unless ($x % $d) {
      my $count = 1;
      do {
        $x /= $d;
        $count++;
      } until ($x % $d);
      my $limit = sqrt($x);
      $ret *= $count;
    }
  }
  if ($x > 1) {
    $ret *= 2;
  }
  return $ret;
}

sub xy_to_n {
  my ($self, $x, $y) = @_;
  ### DivisibleColumns xy_to_n(): "$x,$y"

  $x = _round_nearest ($x);
  $y = _round_nearest ($y);
  if (_is_infinite($x)) { return $x; }
  if (_is_infinite($y)) { return $y; }

  my $proper = $self->{'proper'};
  if ($proper) {
    if ($x < 4
        || $y < 2
        || $y >= $x
        || ($x%$y)) {
      return undef;
    }
  } else {
    if ($x < 1
        || $y < 1
        || $y > $x
        || ($x%$y)) {
      return undef;
    }
  }

  while ($#x_to_n < $x) {
    _extend();
  }
  ### x_to_n: $x_to_n[$x]

  my $n = $x_to_n[$x] - ($proper ? 2*$x-4 : 1);
  ### base n: $n

  $y -= $proper;
  for (my $i = 1+$proper; $i <= $y; $i++) {
    unless ($x % $i) {
      $n += 1;
    }
  }
  return $n;
}

sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;
  ### DivisibleColumns rect_to_n_range(): "$x1,$y1 $x2,$y2"

  $x1 = _round_nearest($x1);
  $y1 = _round_nearest($y1);
  $x2 = _round_nearest($x2);
  $y2 = _round_nearest($y2);

  ($x1,$x2) = ($x2,$x1) if $x1 > $x2;
  ($y1,$y2) = ($y2,$y1) if $y1 > $y2;

  ### rounded ...
  ### $x2
  ### $y2

  if ($self->{'proper'}) {
    if ($x2 < 4            # rect all negative
        || $y2 < 2         # rect all negative
        || $y1 >= $x2) {   # rect all above X=Y diagonal
      ### outside proper divisors ...
      return (1, 0);
    }
  } else {
    if ($x2 < 1           # rect all negative
        || $y2 < 1        # rect all negative
        || $y1 > $x2) {   # rect all above X=Y diagonal
      ### outside all divisors ...
      return (1, 0);
    }
  }
  if (_is_infinite($x2)) {
    return (1, $x2);
  }
  while ($#x_to_n <= $x2) {
    _extend();
  }

  ### rect use xy_to_n at: "x=".($x2+1)." x_to_n=".$x_to_n[$x2+1]

  if ($x1 < 0) { $x1 = 0; }
  my $n_lo = $x_to_n[$x1];
  my $n_hi = $x_to_n[$x2+1]-1;
  if ($self->{'proper'}) {
    $n_lo -= 2*$x1-3;
    $n_hi -= 2*$x2-1;
  }
  return ($n_lo, $n_hi);
}

1;
__END__

=for stopwords Ryde Math-PlanePath

=head1 NAME

Math::PlanePath::MathImageDivisibleColumns -- x divisible by y in columns

=head1 SYNOPSIS

 use Math::PlanePath::MathImageDivisibleColumns;
 my $path = Math::PlanePath::MathImageDivisibleColumns->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

This path visits points X,Y where X is divisible by Y, in columns from Y=1
to YE<lt>=X.

    18 |                                                      57
    17 |                                                   51
    16 |                                                49
    15 |                                             44
    14 |                                          40
    13 |                                       36
    12 |                                    34
    11 |                                 28
    10 |                              26
     9 |                           22                         56
     8 |                        19                      48
     7 |                     15                   39
     6 |                  13                33                55
     5 |                9             25             43
     4 |             7          18          32          47
     3 |          4       12       21       31       42       54
     2 |       2     6    11    17    24    30    38    46    53
     1 |    0  1  3  5  8 10 14 16 20 23 27 29 35 37 41 45 50 52
    Y=0|
       +---------------------------------------------------------
       X=0  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 18

The number of divisors in each column is ..., and starting N=0 at X=1,Y=1
means the values 1,3,5,8,etc horizontally along X=1 are the sums

     i=K
    sum   numdivisors(i)
     i=1

The pattern of divisors or not is the same going up a column as going down,
since X,X-Y has the same coprimeness as X,Y.  This means coprimes occur in
pairs from X=3 onwards.  (In X even the middle point Y=X/2 is not coprime
since they have common factor 2, from X=4 onwards.)  So there's an even
number of points in each column from X=2 onwards and the totals horizontally
along X=1 are even likewise.

The current implementation is pretty slack and is fairly slow on medium to
large N, but the resulting pattern is interesting.  Anything making a
straight line etc in the path will probably have to be related to phi sums
in some way.

=head1 FUNCTIONS

See L<Math::PlanePath/FUNCTIONS> for the behaviour common to all path
classes.

=over 4

=item C<$path = Math::PlanePath::MathImageDivisibleColumns-E<gt>new ()>

Create and return a new path object.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the X,Y coordinates of point number C<$n> on the path.  Points begin
at 0 and if C<$n E<lt> 0> then the return is an empty list.

=back

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::CoprimeColumns>

=cut
