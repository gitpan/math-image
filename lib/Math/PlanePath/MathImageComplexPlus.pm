# rect range wrong ?


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


package Math::PlanePath::MathImageComplexPlus;
use 5.004;
use strict;

use vars '$VERSION', '@ISA';
$VERSION = 85;

use Math::PlanePath 54; # v.54 for _max()
@ISA = ('Math::PlanePath');
*_max = \&Math::PlanePath::_max;
*_is_infinite = \&Math::PlanePath::_is_infinite;
*_round_nearest = \&Math::PlanePath::_round_nearest;

# uncomment this to run the ### lines
#use Smart::Comments;


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
      description => 'Real part r in the i+r complex base.',
    },
    { name      => 'arms',
      share_key => 'arms_2',
      type      => 'integer',
      minimum   => 1,
      maximum   => 2,
      default   => 1,
      width     => 1,
      description => 'Arms',
      when_name   => 'realpart',
      when_value  => '1',
    },
  ];

sub new {
  my $class = shift;
  my $self = $class->SUPER::new(@_);

  my $realpart = $self->{'realpart'};
  if (! defined $realpart || $realpart < 1) {
    $self->{'realpart'} = $realpart = 1;
  }
  $self->{'norm'} = $realpart*$realpart + 1;

  my $arms = $self->{'arms'};
  if (! defined $arms || $arms <= 0 || $realpart != 1) { $arms = 1; }
  elsif ($arms > 2) { $arms = 2; }
  $self->{'arms'} = $arms;

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

  my $realpart = $self->{'realpart'};
  my $norm = $self->{'norm'};

  my $x;
  my $y;
  my $dx;
  my $dy = 0;

  my $arms = $self->{'arms'};
  ### $arms
  if ($n % $arms) {
    $x = 0;
    $y = 1;
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
  if (_is_infinite($x)) { return ($x); }
  $y = _round_nearest ($y);
  if (_is_infinite($y)) { return ($y); }

  my $orig_x = $x;
  my $orig_y = $y;

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

  if ($self->{'arms'} > 1) {
    if ($y) {
      ### re-run as: -$orig_x, 1-$orig_y
      local $self->{'arms'} = 1;
      $n = $self->xy_to_n(-$orig_x,1-$orig_y); # 180 degrees
      ### re-run got: $n
      ### assert: defined $n
      return 2*$n+1;
    } else {
      return 2*$n;
    }
  } else {
    if ($y == 0) {
      return $n;
    }
  }
  return undef;
}

sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;
  ### MathImageComplexPlus rect_to_n_range(): "$x1,$y1  $x2,$y2"

  $x1 = _round_nearest ($x1);
  $x2 = _round_nearest ($x2);
  $y1 = _round_nearest ($y1);
  $y2 = _round_nearest ($y2);

  foreach ($x1,$y1,$x2,$y2) {
    if (_is_infinite($_)) { return (0, abs($_)); }
  }

  ($x1,$x2) = ($x2,$x1) if $x1 > $x2;
  ($y1,$y2) = ($y2,$y1) if $y1 > $y2;

  my $realpart = $self->{'realpart'};
  my $norm = $self->{'norm'};

  my $max = _max (abs($x1),
                  abs($y1),
                  abs($x2),
                  abs($y2));
  my $level = 2*int(log(($max || 1) + $realpart) / log($realpart+1)) + 4;
  ### $level
  return (0, $self->{'arms'} * $norm**$level - 1);




  # my $zero = ($x1 * 0 * $y1 * $x2 * $y2);  # inherit bignum 0
  # my $one = $zero + 1;                     # inherit bignum 1
  # 
  # my $xlo = $zero;
  # my $xhi = $zero;
  # my $ylo = $zero;
  # my $yhi = $zero;
  # my $power = $one;
  # 
  # my $xd = 1;
  # my $yd = 0;
  # 
  # for (;;) {
  #   ### at: "X=$xlo,$xhi  Y=$ylo,$yhi   power=$power"
  #   if ($x1 >= $xlo
  #       && $x2 <= $xhi
  #       && $y1 >= $ylo
  #       && $y2 <= $yhi) {
  #     return (0, $power-1);
  #   }
  #   $power *= $norm;
  # 
  #   if ($yd >= 0) {
  #     $yhi += $yd * ($norm-1);
  #   } else {
  #     $ylo += $yd * ($norm-1);
  #   }
  #   if ($xd >= 0) {
  #     $xhi += $xd * ($norm-1);
  #   } else {
  #     $xlo += $xd * ($norm-1);
  #   }
  #   $xlo += $xd;
  #   $xhi += $xd;
  #   $ylo += $yd;
  #   $yhi += $yd;
  # 
  #   # (x+yi) * (i+r) = (x+yr)i + (xr-y)
  #   ($xd,$yd) = ($xd*$realpart - $yd,
  #                $xd + $yd*$realpart);
  # }

}

1;
__END__

=for stopwords eg Ryde Math-PlanePath ie Nstart Nlevel

=head1 NAME

Math::PlanePath::MathImageComplexPlus -- points in complex base i+r

=head1 SYNOPSIS

 use Math::PlanePath::MathImageComplexPlus;
 my $path = Math::PlanePath::MathImageComplexPlus->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

I<In progress.>

This path traverses points by a complex number base i+r with integer
rE<gt>=1.  The default is base i+1 which gives a dragon shape,

                         30  31          14  15                 5
                     28  29          12  13                     4
                         26  27  22  23  10  11   6   7         3
                     24  25  20  21   8   9   4   5             2
         62  63          46  47  18  19           2   3         1
     60  61          44  45  16  17           0   1         <- Y=0
         58  59  54  55  42  43  38  39                        -1
     56  57  52  53  40  41  36  37                            -2
                 50  51  94  95  34  35  78  79                -3
             48  49  92  93  32  33  76  77                    -4
                         90  91  86  87  74  75  70  71        -5
                     88  89  84  85  72  73  68  69            -6
        126 127         110 111  82  83          66  67        -7
    124 125         108 109  80  81          64  65            -8
        122 123 118 119 106 107 102 103                        -9
    120 121 116 117 104 105 100 101                           -10
                114 115          98  99                       -11
            112 113          96  97                           -12

      ^   ^   ^   ^   ^   ^   ^   ^   ^   ^   ^   ^   ^
    -10  -9  -8  -7  -6  -5  -4  -3  -2  -1  X=0  1   2

=head2 Real Part

C<realpart =E<gt> $r> selects another r for complex base b=i+r.  For example
C<realpart =E<gt> 2> is

                                     45 46 47 48 49      8
                               40 41 42 43 44            7
                         35 36 37 38 39                  6
                   30 31 32 33 34                        5
             25 26 27 28 29 20 21 22 23 24               4
                      15 16 17 18 19                     3
                10 11 12 13 14                           2
           5  6  7  8  9                                 1
     0  1  2  3  4                                   <- Y=0

     ^
    X=0 1  2  3  4  5  6  7  8  9 10

N is broken into base norm=r*r+1 digits, ie. digits 0 to r*r inclusive.

    norm = r*r + 1
    Nstart = 0
    Nlevel = norm^level - 1

The low "digit" makes horizontal runs of r*r+1 many points, such as N=0 to
N=4, then N=5 to N=9 etc above.  In the default r=1 these runs are 2 long.
For r=2 they're 2*2+1=5 long, or r=3 would be 3*3+1=10, etc.

The offset in each run such as the N=5 shown is i+r, so Y=1,X=r.  Then the
offset for the next level is (i+r)^2 = (2r*i + r^2-1) so N=25 begins at
Y=2*r=4, X=r*r-1=3.  In general each level adds an angle

    angle = atan(1/r)
    Nlevel_angle = level * angle

So the points spiral around anti-clockwise.  For r=1 the angle is
atan(1/1)=45 degrees, so that level=4 the angle is at 4*45=180 degrees,
putting N=2^4=16 is on the negative X axis as shown above.

As r becomes bigger the angle becomes smaller, making it spiral more slowly.
The points never fill the plane, but a set from N=0 to Nlevel are all
touching.

=head2 Arms

For C<realpart =E<gt> 1>, an optional C<arms =E<gt> 2> adds a second copy of
the curve rotated 180 degrees and starting from X=0,Y=1.  It meshes
perfectly to fill the plane.  Each arm advances successively so N=0,2,4,etc
is the plain path and N=1,3,5,7,etc is the copy

        60  62          28  30                                 5
    56  58          24  26                                     4
        52  54  44  46  20  22  12  14                         3
    48  50  40  42  16  18   8  10                             2
                36  38   3   1   4   6  35  33                 1
            32  34   7   5   0   2  39  37                 <- Y=0
                        11   9  19  17  43  41  51  49        -1
                    15  13  23  21  47  45  55  53            -2
                                27  25          59  57        -3
                            31  29          63  61            -4

                             ^   
    -6  -5  -4  -3  -2  -1  X=0  1   2   3   4   5   6

There's no C<arms> parameter for other C<realpart> values as yet, only the
i+1.  Is there a good rotated arrangement for them?  Do norm many copies
fill the plane in general?

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

L<Math::PlanePath>,
L<Math::PlanePath::ComplexMinus>,
L<Math::PlanePath::DragonCurve>

=cut

# Local variables:
# compile-command: "math-image --path=MathImageComplexPlus --all --scale=5"
# End:
#
# math-image --path=MathImageComplexPlus --expression='i<128?i:0' --output=numbers --size=132x40
#
# Realpart:
# math-image --path=MathImageComplexPlus,realpart=2 --expression='i<50?i:0' --output=numbers --size=180
#
# Arms:
# math-image --path=MathImageComplexPlus,arms=2 --expression='i<64?i:0' --output=numbers --size=79
