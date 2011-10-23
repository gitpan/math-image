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


# increment N+1 changes low 1111 to 10000
# X bits change 011 to 000, no carry, decreasing by number of low 1s
# Y bits change 011 to 100, plain +1




package Math::PlanePath::MathImageDigitGroups;
use 5.004;
use strict;

use vars '$VERSION', '@ISA';
$VERSION = 78;

use Math::PlanePath;
@ISA = ('Math::PlanePath');
*_is_infinite = \&Math::PlanePath::_is_infinite;
*_round_nearest = \&Math::PlanePath::_round_nearest;

# uncomment this to run the ### lines
#use Devel::Comments;

use constant n_start => 0;
use constant x_negative => 0;
use constant y_negative => 0;

use constant parameter_info_array => [{ name      => 'radix',
                                        share_key => 'radix_2',
                                        type      => 'integer',
                                        minimum   => 2,
                                        default   => 2,
                                        width     => 3,
                                      }];

sub new {
  my $class = shift;
  my $self = $class->SUPER::new(@_);
  if (! $self->{'radix'} || $self->{'radix'} < 2) {
    $self->{'radix'} = 2;
  }
  return $self;
}

sub n_to_xy {
  my ($self, $n) = @_;
  ### DigitGroups n_to_xy(): $n
  if ($n < 0) {
    return;
  }
  if (_is_infinite($n)) {
    return ($n,$n);
  }

  # what to do for fractions ?
  {
    my $int = int($n);
    ### $int
    if ($n != $int) {
      my $frac = $n - $int;  # inherit possible BigFloat/BigRat
      ### $frac
      my ($x1,$y1) = $self->n_to_xy($int);
      my ($x2,$y2) = $self->n_to_xy($int+1);
      my $dx = $x2-$x1;
      my $dy = $y2-$y1;
      return ($frac*$dx + $x1, $frac*$dy + $y1);
    }
    $n = $int; # BigFloat int() gives BigInt, use that
  }

  my $radix = $self->{'radix'};
  ### $radix
  my $x = my $y = $n * 0;          # inherit bignum 0
  my $xpower = my $ypower = $x+1;  # inherit bignum 1
  my $digit;
  for (;;) {
    do {
      $digit = ($n % $radix);
      ### digit to x: $digit
      $x += $digit * $xpower;
      $n = int ($n / $radix) || return ($x, $y);
      $xpower *= $radix;
    } while ($digit);

    do {
      $digit = ($n % $radix);
      ### digit to y: $digit
      $y += $digit * $ypower;
      $n = int ($n / $radix) || return ($x, $y);
      $ypower *= $radix;
    } while ($digit);
  }
}

sub xy_to_n {
  my ($self, $x, $y) = @_;
  ### DigitGroups xy_to_n(): "$x, $y"

  $x = _round_nearest ($x);
  $y = _round_nearest ($y);
  if ($x < 0 || $y < 0
      || _is_infinite($x)
      || _is_infinite($y)) {
    return undef;
  }

  if ($x == 0 && $y == 0) {
    return 0;
  }

  my $radix = $self->{'radix'};
  my $n = ($x * 0 * $y);   # inherit bignum
  my $power = $n+1;        # inherit bignum 1
  my $digit;
  while ($x || $y) {
    do {
      $digit = ($x % $radix);
      ### digit from x: $digit
      $n += $digit * $power;
      $power *= $radix;
      $x = int ($x / $radix);
    } while ($digit);

    do {
      $digit = ($y % $radix);
      ### digit from y: $digit
      $n += $digit * $power;
      $power *= $radix;
      $y = int ($y / $radix);
    } while ($digit);
  }
  return $n;
}

sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;

  if ($x1 > $x2) { ($x1,$x2) = ($x2,$x1); }  # x1 smaller
  if ($y1 > $y2) { ($y1,$y2) = ($y2,$y1); }  # y1 smaller

  if ($y2 < 0 || $x2 < 0) {
    return (1, 0); # rect all negative, no N
  }

  if ($x1 < 0) { $x1 = 0; }
  if ($y1 < 0) { $y1 = 0; }

  # monotonic increasing in $x and $y directions, so this is exact
  return ($self->xy_to_n ($x1, $y1),
          $self->xy_to_n ($x2, $y2));
}

1;
__END__

=for stopwords Ryde Math-PlanePath Karatsuba undrawn

=head1 NAME

Math::PlanePath::MathImageDigitGroups -- 2x2 self-similar Z shape digits

=head1 SYNOPSIS

 use Math::PlanePath::MathImageDigitGroups;

 my $path = Math::PlanePath::MathImageDigitGroups->new;
 my ($x, $y) = $path->n_to_xy (123);

 # or another radix digits ...
 my $path3 = Math::PlanePath::MathImageDigitGroups->new (radix => 3);

=head1 DESCRIPTION

This is a split of N into X and Y values by groups of digits with a
leading 0.  For example,

    N = 120345007089

is grouped and split to X and Y as

    12 0345 0 07 089
     X   Y  X  Y  X

    X = 12 0 089 = 120089
    Y = 0345 07  = 34507

This is a one-to-one mapping between NE<gt>=0 and pairs XE<gt>=0,YE<gt>=0.

In decimal,

    1000 10001 10002 10003 10004 10005 10006 10007 10008 10009 10100
      90  901  902  903  904  905  906  907  908  909 1090
      80  801  802  803  804  805  806  807  808  809 1080
      70  701  702  703  704  705  706  707  708  709 1070
      60  601  602  603  604  605  606  607  608  609 1060
      50  501  502  503  504  505  506  507  508  509 1050
      40  401  402  403  404  405  406  407  408  409 1040
      30  301  302  303  304  305  306  307  308  309 1030
      20  201  202  203  204  205  206  207  208  209 1020
      10  101  102  103  104  105  106  107  108  109 1010
       0    1    2    3    4    5    6    7    8    9  100

In binary,

    11  |   38   77   86  155  166  173  182  311  550  333  342  347
    10  |   72  145  148  291  168  297  300  583  328  337  340  595
     9  |   66  133  138  267  162  277  282  535  322  325  330  555
     8  |  128  257  260  515  272  521  524 1031  320  545  548 1043
     7  |   14   29   46   59  142   93  110  119  526  285  302  187
     6  |   24   49   52   99   88  105  108  199  280  177  180  211
     5  |   18   37   42   75   82   85   90  151  274  165  170  171
     4  |   32   65   68  131   80  137  140  263  160  161  164  275
     3  |    6   13   22   27   70   45   54   55  262  141  150   91
     2  |    8   17   20   35   40   41   44   71  136   81   84   83
     1  |    2    5   10   11   34   21   26   23  130   69   74   43
    Y=0 |    0    1    4    3   16    9   12    7   64   33   36   19
        +-------------------------------------------------------------
           X=0    1    2    3    4    5    6    7    8    9   10   11

=head2 R <-> RxR

This construction is inspired by the similar digit grouping used in the
proof that the real line is the same cardinality as the plane (by Cantor was
it?).  In that case a bijection between interval z=(0,1) and pairs
x=(0,1),y=(0,1) is made by groups of fraction digits stopping at a non-zero
digit.

In that proof non-terminating fractions like 0.49999... are chosen over
terminating 0.5000... so there's infinitely many non-zero digits.  For the
integer form here there's infinitely many zero digits at the high ends of N,
X and Y, hence grouping by zero digits instead of non-zero.

=head1 FUNCTIONS

See L<Math::PlanePath/FUNCTIONS> for the behaviour common to all path
classes.

=over 4

=item C<$path = Math::PlanePath::MathImageDigitGroups-E<gt>new ()>

=item C<$path = Math::PlanePath::MathImageDigitGroups-E<gt>new (radix =E<gt> $r)>

Create and return a new path object.  The optional C<radix> parameter gives
the base for digit splitting (the default is binary, radix 2).

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the X,Y coordinates of point number C<$n> on the path.  Points begin
at 0 and if C<$n E<lt> 0> then the return is an empty list.

=back

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::ZOrderCurve>

=cut

# Local variables:
# compile-command: "math-image --path=MathImageDigitGroups,radix=2 --lines"
# End:
#
# math-image --path=MathImageDigitGroups --output=numbers_dash
# math-image --path=MathImageDigitGroups,radix=2 --all --output=numbers
#
