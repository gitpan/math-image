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
$VERSION = 85;

use Math::PlanePath 54; # v.54 for _max()
@ISA = ('Math::PlanePath');
*_max = \&Math::PlanePath::_max;
*_is_infinite = \&Math::PlanePath::_is_infinite;
*_round_nearest = \&Math::PlanePath::_round_nearest;

use Math::PlanePath::CellularRule54 54; # v.54 for _rect_for_V()
*_rect_for_V = \&Math::PlanePath::CellularRule54::_rect_for_V;


# uncomment this to run the ### lines
#use Smart::Comments;


use constant n_start => 1;
use constant y_negative => 0;

use constant parameter_info_array =>
  [ { name      => 'rule',
      type      => 'integer',
      default   => 30,
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
  $self->{'left'} = 0;
  $self->{'right'} = 0;

  my $rule = $self->{'rule'};
  if (! defined $rule) { $rule = 135; }
  $self->{'rule_table'} = [ map { ($rule >> $_) & 1 } 0 .. 7 ];

  ### rule_table: $self->{'rule_table'}

  return $self;
}

#
# Y=2   L 0 1 2 3 4 R     right=2*Y+2
# Y=1     L 0 1 2 R
# Y=0       L 0 R

sub _extend {
  my ($self) = @_;
  ### _extend()

  my $rule_table = $self->{'rule_table'};
  my $rows = $self->{'rows'};
  my $row = $rows->[-1];
  my $newrow = '';
  my $rownum = $#$rows;
  my $count = 0;
  my $bits = $self->{'left'} * 7;
  $self->{'left'} = $rule_table->[$bits];

  ### $row
  ### $rownum

  foreach my $i (0 .. 2*$rownum) {
    $bits = (($bits<<1) + vec($row,$i,1)) & 7;

    ### $i
    ### $bits
    ### new: $rule_table->[$bits]
    $count +=
      (vec($newrow,$i,1) = $rule_table->[$bits]);
  }

  my $rbit = $self->{'right'};
  $self->{'right'} = $rule_table->[7*$rbit];
  ### $rbit
  ### new right: $self->{'right'}

  # right, second last
  $bits = (($bits<<1) + $rbit) & 7;
  $count +=
    (vec($newrow,2*$rownum+1,1) = $rule_table->[$bits]);
  ### $bits
  ### new second last: $rule_table->[$bits]

  # right end
  $bits = (($bits<<1) + $rbit) & 7;
  $count +=
    (vec($newrow,2*$rownum+2,1) = $rule_table->[$bits]);
  ### $bits
  ### new right end: $rule_table->[$bits]

  ### $count
  ### $newrow
  push @$rows, $newrow;

  my $row_end_n = $self->{'row_end_n'};
  push @$row_end_n, $row_end_n->[-1] + $count;
}

sub n_to_xy {
  my ($self, $n) = @_;
  ### MathImageCellularRule n_to_xy(): $n

  if (_is_infinite($n)) { return ($n,$n); }

  my $int = int($n);
  $n -= $int;   # now fraction part
  if (2*$n >= 1) {
    $n -= 1;
    $int += 1;
  }
  # -0.5 <= $n < 0.5 fractional part
  ### assert: 2*$n >= -1
  ### assert: 2*$n < 1

  if ($int < 1) { return; }

  my $row_end_n = $self->{'row_end_n'};
  my $y = 0;
  for (;;) {
    if ($y > $#$row_end_n) {
      _extend($self);
    }
    if ($int <= $row_end_n->[$y]) {
      last;
    }
    if ($y > 2
        && $row_end_n->[$y] == $row_end_n->[$y-1]
        && $row_end_n->[$y-1] == $row_end_n->[$y-2]) {
      ### no more cells in three rows means rest is blank ...
      return;
    }
    $y++;
  }

  ### $y
  ### row_end_n: $row_end_n->[$y]
  ### remainder: $int - $row_end_n->[$y]

  $int -= $row_end_n->[$y];
  my $row = $self->{'rows'}->[$y];
  my $x = 2*$y+1;   # for first vec 2*Y
  ### $row

  for ($x = 2*$y+1; $x >= 0; $x--) {
    if (vec($row,$x,1)) {
      ### step bit: "x=$x"
      if (++$int > 0) {
        last;
      }
    }
  }

  ### result: ($n + $x - $y).",$y"

  return ($n + $x - $y,
          $y);
}

sub xy_to_n {
  my ($self, $x, $y) = @_;
  ### MathImageCellularRule xy_to_n(): "$x, $y"

  $x = _round_nearest ($x);
  $y = _round_nearest ($y);
  if ($y < 0 || ! ($x <= $y && ($x+=$y) >= 0)) {
    return undef;
  }
  if (_is_infinite($x)) { return $x; }
  if (_is_infinite($y)) { return $y; }

  my $row_end_n = $self->{'row_end_n'};
  while ($y > $#$row_end_n) {
    _extend($self);
  }

  my $row = $self->{'rows'}->[$y];
  if (! vec($row,$x,1)) {
    return undef;
  }
  my $n = $row_end_n->[$y];
  foreach my $i ($x+1 .. 2*$y) {
    $n -= vec($row,++$x,1);
  }
  return $n;
}

# not exact
sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;
  ### MathImageCellularRule rect_to_n_range(): "$x1,$y1  $x2,$y2"

  ($x1,$y1, $x2,$y2) = _rect_for_V ($x1,$y1, $x2,$y2)
    or return (1,0);  # rect outside pyramid

  if (_is_infinite($y1)) { return $y1; }  # for nan
  if (_is_infinite($y2)) { return $y2; }  # for nan or inf

  my $row_end_n = $self->{'row_end_n'};
  while ($#$row_end_n < $y2) {
    _extend($self);
  }
  return ($y1 == 0 ? 1 : $row_end_n->[$y1-1]+1,
          $row_end_n->[$y2]);
}

1;
__END__

=for stopwords PyramidRows Ryde Math-PlanePath PlanePath ie Xmax-Xmin

=head1 NAME

Math::PlanePath::MathImageCellularRule -- cellular automaton points for binary rule

=head1 SYNOPSIS

 use Math::PlanePath::MathImageCellularRule;
 my $path = Math::PlanePath::MathImageCellularRule->new (rule => 135);
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

This is the patterns of Stephen Wolfram's bit-rule based cellular automaton

    http://mathworld.wolfram.com/ElementaryCellularAutomaton.html

Points are numbered left to right in rows so for example C<rule =E<gt> 30>
is

    51 52    53 54 55 56    57 58       59          60 61 62       9
       44 45       46          47 48 49                50          8
          32 33    34 35 36 37       38 39 40 41 42 43             7
             27 28       29             30       31                6
                18 19    20 21 22 23    24 25 26                   5
                   14 15       16          17                      4
                       8  9    10 11 12 13                         3
                          5  6        7                            2
                             2  3  4                               1
                                1                              <- Y=0

    -9 -8 -7 -6 -5 -4 -3 -2 -1 X=0 1  2  3  4  5  6  7  8  9

The current implementation is not particularly efficient as it builds and
holds onto the bit pattern for all rows up to the highest N or X,Y used.
There's no doubt better ways to iterate, but this module does it in
PlanePath style.

The automaton starts from a single point N=1 at the origin and grows into
the rows above.  The C<rule> parameter specifies what a set of 3 cells below
will produce above.  It's a value 0 to 255 inclusive used as bits,

    cells below     rule value
 
        1,1,1    ->   bit7
        1,1,0    ->   bit6
        1,0,1    ->   bit5
        ...
        0,0,1    ->   bit1
        0,0,0    ->   bit0

When cells 0,0,0 become 1, which means bit0 in C<rule> is 1, ie. an odd
number, the off cells either side of the initial N=1 become all on
infinitely to either side.  When the 1,1,1 bit7 is a 0, ie. ruleE<lt>128,
they turn on and off in odd and even rows.  Only the pyramid part
-YE<lt>=XE<lt>=Y is in the N numbering, but any infinite cells to the sides
are included in the pattern calculation.

The full set of patterns can be seen at the Math World web page above.  They
range from simple to quite complex.  For some the N=1 cell doesn't grow to
anything at all, there's only that single point, for example rule 0 or
rule 8.  Some grow to mere straight lines such as rule 2 or rule 5.  But
others make columns or patterns with "quadratic" style stepping over 1 or 2
rows, or self-similar patterns such as the Sierpinski triangle.  Some rule
values even give complicated non-repeating patterns when there's feedback
across from one half to the other, for example rule 30.

=head1 FUNCTIONS

See L<Math::PlanePath/FUNCTIONS> for the behaviour common to all path
classes.

=over 4

=item C<$path = Math::PlanePath::MathImageCellularRule-E<gt>new (rule =E<gt> 123)>

Create and return a new path object.  C<rule> should be an integer between 0
and 255 inclusive.

A C<rule> should be given always.  There is a default, but it's secret and
is likely to change.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the X,Y coordinates of point number C<$n> on the path.

=item C<$n = $path-E<gt>xy_to_n ($x,$y)>

Return the point number for coordinates C<$x,$y>.  C<$x> and C<$y> are each
rounded to the nearest integer, which has the effect of treating each cell
as a square of side 1.  If C<$x,$y> is outside the pyramid or on a skipped
cell the return is C<undef>.

=back

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::CellularRule54>,
L<Math::PlanePath::CellularRule190>,
L<Math::PlanePath::PyramidRows>

http://mathworld.wolfram.com/ElementaryCellularAutomaton.html

=cut

# Local variables:
# compile-command: "math-image --path=MathImageCellularRule --all --scale=10"
# End:
#
# math-image --path=MathImageCellularRule --all --output=numbers --size=80x50
