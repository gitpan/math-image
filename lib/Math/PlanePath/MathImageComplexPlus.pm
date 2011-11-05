# rect range ?
# how many arms ?


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


# math-image --path=MathImageComplexPlus --all --scale=5
# math-image --path=MathImageComplexPlus --all --output=numbers_dash --size=80x50

package Math::PlanePath::MathImageComplexPlus;
use 5.004;
use strict;
use POSIX 'ceil';

use vars '$VERSION', '@ISA';
$VERSION = 80;

use Math::PlanePath;
@ISA = ('Math::PlanePath');
*_is_infinite = \&Math::PlanePath::_is_infinite;
*_round_nearest = \&Math::PlanePath::_round_nearest;

# uncomment this to run the ### lines
#use Devel::Comments;

use constant n_start => 0;
sub arms_count {
  my ($self) = @_;
  return $self->{'arms'} || 1;
}

use constant parameter_info_array =>
  [ { name      => 'realpart',
      type      => 'integer',
      default   => 1,
      minimum   => 1,
      width     => 2,
    },
    { name      => 'arms',
      share_key => 'arms_2',
      type      => 'integer',
      minimum   => 1,
      maximum   => 2,
      default   => 1,
      width     => 1,
    },
  ];

sub new {
  my $class = shift;
  my $self = $class->SUPER::new(@_);

  my $arms = $self->{'arms'};
  if (! defined $arms || $arms <= 0) { $arms = 1; }
  elsif ($arms > 2) { $arms = 2; }
  $self->{'arms'} = $arms;

  my $realpart = $self->{'realpart'};
  if (! defined $realpart || $realpart < 1) {
    $self->{'realpart'} = $realpart = 1;
  }
  $self->{'norm'} = $realpart*$realpart + 1;

  return $self;
}

sub n_to_xy {
  my ($self, $n) = @_;
  ### MathImageComplexPlus n_to_xy(): $n

  if ($n < 0) { return; }
  if (_is_infinite($n)) { return ($n,$n); }

  {
    my $int = int($n);
    ### $int
    ### $n
    if ($n != $int) {
      my ($x1,$y1) = $self->n_to_xy($int);
      my ($x2,$y2) = $self->n_to_xy($int+1);
      my $frac = $n - $int;  # inherit possible BigFloat
      my $dx = $x2-$x1;
      my $dy = $y2-$y1;
      return ($frac*$dx + $x1, $frac*$dy + $y1);
    }
    $n = $int;       # BigFloat int() gives BigInt, use that
  }

  # $n += ($arms-1);

  my $realpart = $self->{'realpart'};
  my $norm = $self->{'norm'};

  my $x;
  my $y;
  my $dx;
  my $dy = 0;

  my $arms = $self->{'arms'};
  ### $arms
  if ($n % $arms) {
    $x = $norm;
    $y = $norm - 2;
    $dx = -1;
  } else {
    $x = 0;
    $y = 0;
    $dx = 1;
  }
  $n = int($n/$arms);

  while ($n) {
    my $digit = $n % $norm;
    $n = int($n/$norm);
    ### at: "$x,$y  n=$n"
    ### $digit

    $x += $dx * $digit;
    $y += $dy * $digit;

    # (dx,dy) = (dx + i*dy)*(i+$realpart)
    #
    ($dx,$dy) = ($realpart*$dx - $dy, $dx + $realpart*$dy);
  }

  ### final: "$x,$y"
  return ($x,$y);
}

sub xy_to_n {
  my ($self, $x, $y) = @_;
  ### ComplexPlus xy_to_n(): "$x, $y"

  $x = _round_nearest ($x);
  $y = _round_nearest ($y);
  if (_is_infinite($x)) { return ($x); }
  if (_is_infinite($y)) { return ($y); }

  my $realpart = $self->{'realpart'};
  my $norm = $self->{'norm'};

  my $n = 0;
  my $power = 1;
  my $prev_x = 0;
  my $prev_y = 0;
  while ($x || $y) {
    my $neg_y = $x - $y*$realpart;
    my $digit = $neg_y % $norm;
    ### at: "$x,$y  n=$n  digit $digit"

    $n += $digit * $power;
    $x -= $digit;
    $neg_y -= $digit;

    ### assert: ($neg_y % $norm) == 0
    ### assert: (($x * $realpart + $y) % $norm) == 0

    # divide i+r = mul (i-r)/(i^2 - r^2)
    #            = mul (i-r)/-norm
    # is (i*y + x) * (i-realpart)/-norm
    #  x = [ x*-realpart - y ] / -norm
    #    = [ x*realpart + y ] / norm
    #  y = [ y*-realpart + x ] / -norm
    #    = [ y*realpart - x ] / norm
    #
    ($x,$y) = (($x*$realpart+$y)/$norm, -$neg_y/$norm);
    $power *= $norm;

    if ($x == $prev_x && $y == $prev_y) {
      last;
    }
    $prev_x = $x;
    $prev_y = $y;
  }

  ### final: "$x,$y n=$n cf arms $self->{'arms'}"

  if ($y) {
    return undef;
  }
  # if ($y) {
  #   if ($y >= $self->{'arms'}) {
  #     return undef;
  #   }
  #   $n = 2*$n + $y;
  # }
  return $n;
}

sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;
  ### MathImageComplexPlus rect_to_n_range(): "$x1,$y1  $x2,$y2"

  my $realpart = $self->{'realpart'};
  my $norm = $self->{'norm'};

  $x1 = abs($x1);
  $y1 = abs($y1);
  $x2 = abs($x2);
  $y2 = abs($y2);
  my $xm = ($x1 > $x2 ? $x1 : $x2);
  my $ym = ($y1 > $y2 ? $y1 : $y2);
  my $max = ($xm > $ym ? $xm : $ym);
  my $level = 2*ceil(log(($max || 1) + $realpart) / log($realpart+1)) + 3;
  ### $level
  return (0, $self->{'arms'} * $norm**$level - 1);
}

1;
__END__

=for stopwords eg Ryde Math-PlanePath

=head1 NAME

Math::PlanePath::MathImageComplexPlus -- points in quater-imaginary base 2i

=head1 SYNOPSIS

 use Math::PlanePath::MathImageComplexPlus;
 my $path = Math::PlanePath::MathImageComplexPlus->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

I<In progress.>

This is 
               ^
    -2   -1   X=0   1    2    3    4    5

=head1 FUNCTIONS

See L<Math::PlanePath/FUNCTIONS> for the behaviour common to all path
classes.

=over 4

=item C<$path = Math::PlanePath::MathImageComplexPlus-E<gt>new ()>

Create and return a new path object.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the X,Y coordinates of point number C<$n> on the path.  Points begin
at 0 and if C<$n E<lt> 0> then the return is an empty list.

=back

=head1 SEE ALSO

L<Math::PlanePath>

=cut
