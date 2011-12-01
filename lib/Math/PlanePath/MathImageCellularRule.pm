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


package Math::PlanePath::MathImageCellularRule;
use 5.004;
use strict;

use vars '$VERSION', '@ISA';
$VERSION = 82;

use Math::PlanePath 54; # v.54 for _max()
@ISA = ('Math::PlanePath');

*_max = \&Math::PlanePath::_max;
*_is_infinite = \&Math::PlanePath::_is_infinite;
*_round_nearest = \&Math::PlanePath::_round_nearest;

use Math::PlanePath::KochCurve 42;
*_round_down_pow = \&Math::PlanePath::KochCurve::_round_down_pow;

# uncomment this to run the ### lines
#use Smart::Comments;


use constant n_start => 1;
use constant y_negative => 0;

use constant parameter_info_array =>
  [ { name      => 'rule',
      type      => 'integer',
      default   => 190,
      minimum   => 0,
      maximum   => 255,
      width     => 3,
    },
  ];

sub new {
  my $class = shift;
  my $self = $class->SUPER::new(@_);

  $self->{'rows'} = [ "\001" ];
  $self->{'row_end_n'} = [1];

  my $rule = $self->{'rule'};
  if (! defined $rule) { $rule = 190; }
  $self->{'table'} = [ map { ($rule >> $_) & 1 } 0 .. 7 ];

  ### table: $self->{'table'}

  return $self;
}

sub _extend {
  my ($self) = @_;
  ### _extend(): $self->{'last_n'}
  
  my $table = $self->{'table'};
  my $rows = $self->{'rows'};
  my $row = $rows->[-1];
  my $newrow = '';
  my $rownum = $#$rows;
  my $bits = 0;
  my $count = 0;

  foreach my $i (0 .. 2*$rownum + 3) {
    $bits = (($bits<<1) + vec($row,$i,1)) & 7;
    $count += (vec($newrow,$i,1) = $table->[$bits]);

    ### $bits
    ### new: $table->[$bits]
  }

  ### $newrow
  push @$rows, $newrow;

  my $row_end_n = $self->{'row_end_n'};
  push @$row_end_n, ($self->{'last_n'} += $count);
}

sub n_to_xy {
  my ($self, $n) = @_;
  ### MathImageCellularRule n_to_xy(): $n

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

  my $row_end_n = $self->{'row_end_n'};
  my $y = 0;
  for (;;) {
    if ($y >= $#$row_end_n) {
      _extend($self);
    }
    last if $n <= $row_end_n->[$y];
    $y++;
  }

  ### $y
  ### row_end_n: $row_end_n->[$y]
  ### remainder: $n - $row_end_n->[$y]

  $n -= $row_end_n->[$y];
  my $row = $self->{'rows'}->[$y];
  my $x = 2*$y+3;
  while ($n < 0 && $x > 0) {
    $x--;
    if (vec($row,$x,1)) {
      $n++;
    }
  }

  return ($y - $x,
          $y);
}

sub xy_to_n {
  my ($self, $x, $y) = @_;
  ### MathImageCellularRule xy_to_n(): "$x, $y"

  return undef;

}

# not exact
sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;
  ### MathImageCellularRule rect_to_n_range(): "$x1,$y1  $x2,$y2"

  $x1 = _round_nearest ($x1);
  $y1 = _round_nearest ($y1);
  $x2 = _round_nearest ($x2);
  $y2 = _round_nearest ($y2);
  ($x1,$x2) = ($x2,$x1) if $x1 > $x2;
  ($y1,$y2) = ($y2,$y1) if $y1 > $y2;
  ### rect: "X = $x1 to $x2, Y = $y1 to $y2"

  if ($x2 < 0 || $y2 < 0) {
    ### rectangle outside first quadrant ...
    return (1, 0);
  }

  # _rect_for_V

  while ($y2 > $#{$self->{'row_end_n'}}) {
    _extend($self);
  }
  return (1, $self->{'row_end_n'}->[$y2]);
}

1;
__END__

# Local variables:
# compile-command: "math-image --path=MathImageCellularRule --lines --scale=10"
# End:
#
# math-image --path=MathImageCellularRule --all --output=numbers_dash --size=80x50
