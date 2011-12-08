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


# http://sodwana.uni-ak.ac.at/geom/mitarbeiter/wallner/wunderlich/pdf/125.pdf
# [8.5mb]
#
# Walter Wunderlich. Uber Peano-Kurven. Elemente der Mathematik, 28(1):1-10, 1973.
# Coil order 111 111 111
# 


package Math::PlanePath::MathImageWunderlichSerpentine;
use 5.004;
use strict;
use List::Util qw(min max);

use vars '$VERSION', '@ISA';
$VERSION = 83;

use Math::PlanePath;
@ISA = ('Math::PlanePath');
*_is_infinite = \&Math::PlanePath::_is_infinite;
*_round_nearest = \&Math::PlanePath::_round_nearest;

# uncomment this to run the ### lines
#use Smart::Comments;


use constant parameter_info_array =>
  [ { name      => 'serpentine_type',
      type      => 'integer',
      default   => 0b101_010_101,
      minimum   => 0,
      width     => 4,
    },
    { name      => 'radix',
      share_key => 'radix_3',
      type      => 'integer',
      minimum   => 2,
      default   => 3,
      width     => 3,
    },
  ];

use constant n_start => 0;
use constant x_negative => 0;
use constant y_negative => 0;

sub new {
  my $class = shift;
  my $self = $class->SUPER::new(@_);
  if (! $self->{'radix'} || $self->{'radix'} < 2) {
    $self->{'radix'} = 3;
  }
  $self->{'serpentine_type'} ||= ~0;
  return $self;
}

sub n_to_xy {
  my ($self, $n) = @_;
  ### WunderlichSerpentine n_to_xy(): $n

  if ($n < 0) {
    return;
  }
  if (_is_infinite($n)) {
    return ($n,$n);
  }

  {
    # ENHANCE-ME: for odd radix the ends join and the direction can be had
    # without a full N+1 calculation
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
    $n = $int; # BigFloat int() gives BigInt, use that
  }

  # high to low
  my $radix = $self->{'radix'};
  my $radix_minus_1 = $radix - 1;
  # my (@digits);
  # while ($n) {
  #   push @digits, $n % $radix; $n = int($n/$radix);
  #   push @digits, $n % $radix; $n = int($n/$radix);
  # }

  my $serpentine = $self->{'serpentine_type'};
  my $x = 0;
  my $y = 0;
  my $power = $x + 1;      # inherit bignum 1
  my $odd = 1;
  while ($n) {
    $odd ^= 1;
    ### $n
    ### $power

    my $xdigit = $n % $radix;
    $n = int($n/$radix);
    my $ydigit = $n % $radix;
    $n = int($n/$radix);

    ### $xdigit
    ### $ydigit

    if (($serpentine >> ($xdigit + $radix*$ydigit)) & 1) {
      ($x,$y) = ($y,$x);
      ### transpose to: "$x,$y"
    }

    if ($xdigit & 1) {
      $y = $power-1 - $y;   # 99..99 - Y
    }
    $x += $power * $xdigit;

    $y += $power * $ydigit;
    $power *= $radix;
    if ($ydigit & 1) {
      $x = $power-1 - $x;
    }
  }

  if ($odd && ($serpentine & 1)) {
    ($x,$y) = ($y,$x);
    ### transpose to: "$x,$y"
  }

  return ($x, $y);





  # my $xk = 0;
  # my $yk = 0;
  # my $transpose = 0;
  #
  # while (@digits) {
  #   my $ydigit = pop @digits;
  #   my $xdigit = pop @digits;
  #
  #   if ($transpose) {
  #     ($xdigit,$ydigit) = ($ydigit,$xdigit);
  #   }
  #   $transpose ^= ($serpentine >> ($xdigit + $radix*$ydigit)) & 1;
  #   # if ($xdigit & 1) {
  #   #   $ydigit = $radix_minus_1 - $ydigit;
  #   # }
  #   if ($ydigit & 1) {
  #     $xdigit = $radix_minus_1 - $xdigit;
  #   }
  #
  #   $x *= $radix;
  #   $x += $xdigit;
  #
  #   $y *= $radix;
  #   $y += $ydigit;
  # }

  ### is: "$x,$y"
  return ($x, $y);
}

sub xy_to_n {
  my ($self, $x, $y) = @_;
  ### WunderlichSerpentine xy_to_n(): "$x, $y"

  $x = _round_nearest ($x);
  $y = _round_nearest ($y);
  if ($x < 0 || $y < 0
      || _is_infinite($x)
      || _is_infinite($y)) {
    return undef;
  }

  return undef;

  # my $radix = $self->{'radix'};
  # my $power = 1;
  # my $xn = my $yn = ($x * 0); # inherit
  # while ($x || $y) {
  #   {
  #     my $digit = $x % $radix;
  #     $x = int($x/$radix);
  #     if ($digit & 1) {
  #       $yn = $power-1 - $yn;
  #     }
  #     $xn += $power * $digit;
  #   }
  #   {
  #     my $digit = $y % $radix;
  #     $y = int($y/$radix);
  #     $yn += $power * $digit;
  #     $power *= $radix;
  #     if ($digit & 1) {
  #       $xn = $power-1 - $xn;
  #     }
  #   }
  # }
  #
  # my $n = ($x * 0); # inherit
  # $power = 1;
  # while ($xn || $yn) {
  #   $n += ($xn % $radix) * $power;
  #   $power *= $radix;
  #   $n += ($yn % $radix) * $power;
  #   $power *= $radix;
  #   $xn = int($xn/$radix);
  #   $yn = int($yn/$radix);
  # }
  # return $n;


  my $radix = $self->{'radix'};
  my $radix_minus_1 = $radix - 1;
  my @x;
  my @y;
  while ($x || $y) {
    push @x, $x % $radix; $x = int($x/$radix);
    push @y, $y % $radix; $y = int($y/$radix);
  }

  my $xk = 0;
  my $yk = 0;
  my $n = 0;
  while (@x) {
    if (($xk ^ $yk) & 1) {
      {
        my $digit = pop @x;
        if ($xk & 1) {
          $digit = $radix_minus_1 - $digit;
        }
        $n = ($n * $radix) + $digit;
        $yk ^= $digit;
      }
      {
        my $digit = pop @y;
        if ($yk & 1) {
          $digit = $radix_minus_1 - $digit;
        }
        $n = ($n * $radix) + $digit;
        $xk ^= $digit;
      }
    } else {
      {
        my $digit = pop @y;
        if ($yk & 1) {
          $digit = $radix_minus_1 - $digit;
        }
        $n = ($n * $radix) + $digit;
        $xk ^= $digit;
      }
      {
        my $digit = pop @x;
        if ($xk & 1) {
          $digit = $radix_minus_1 - $digit;
        }
        $n = ($n * $radix) + $digit;
        $yk ^= $digit;
      }
    }
  }
  return $n;
}

sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;

  $x1 = _round_nearest ($x1);
  $y1 = _round_nearest ($y1);
  $x2 = _round_nearest ($x2);
  $y2 = _round_nearest ($y2);
  ($x1,$x2) = ($x2,$x1) if $x1 > $x2;
  ($y1,$y2) = ($y2,$y1) if $y1 > $y2;
  ### rect_to_n_range(): "$x1,$y1 to $x2,$y2"

  if ($x2 < 0 || $y2 < 0) {
    return (1, 0);
  }

  my $radix = $self->{'radix'};
  my $power = 1;
  {
    my $max = max($x2,$y2);
    if ($max-1 == $max) {
      return (0,$max);  # infinity
    }
    until ($power > $max) {
      $power *= $radix;
    }
  }

  my $n_power = $power * $power;
  my $max_x = 0;
  my $max_y = 0;
  my $max_n = 0;
  my $max_xk = 0;
  my $max_yk = 0;

  my $min_x = 0;
  my $min_y = 0;
  my $min_n = 0;
  my $min_xk = 0;
  my $min_yk = 0;

  # l<=c<h doesn't overlap c1<=c<=c2 if
  #     l>c2 or h-1<c1
  #     l>c2 or h<=c1
  # so does overlap if
  #     l<=c2 and h>c1
  #
  my $radix_minus_1 = $radix - 1;
  my $overlap = sub {
    my ($c,$ck,$digit, $c1,$c2) = @_;
    if ($ck & 1) {
      $digit = $radix_minus_1 - $digit;
    }
    ### overlap consider: "inv@{[$ck&1]}digit=$digit ".($c+$digit*$power)."<=c<".($c+($digit+1)*$power)." cf $c1 to $c2 incl"
    return ($c + $digit*$power <= $c2
            && $c + ($digit+1)*$power > $c1);
  };

  while ($power > 1) {
    $power = int($power/$radix);
    $n_power = int($n_power/$radix);

    my $min_swap = ($min_xk ^ $min_yk) & 1;
    my $max_swap = ($min_xk ^ $min_yk) & 1;

    ### $power
    ### $n_power
    ### $max_n
    ### $min_n
    if ($max_swap) {
      my $digit;
      for ($digit = $radix_minus_1; $digit > 0; $digit--) {
        last if &$overlap ($max_x,$max_xk,$digit, $x1,$x2);
      }
      $max_n += $n_power * $digit;
      $max_yk ^= $digit;
      if ($max_xk&1) { $digit = $radix_minus_1 - $digit; }
      $max_x += $power * $digit;
      ### max x digit (complemented): $digit
      ### $max_x
      ### $max_n
    } else {
      my $digit;
      for ($digit = $radix_minus_1; $digit > 0; $digit--) {
        last if &$overlap ($max_y,$max_yk,$digit, $y1,$y2);
      }
      $max_n += $n_power * $digit;
      $max_xk ^= $digit;
      if ($max_yk&1) { $digit = $radix_minus_1 - $digit; }
      $max_y += $power * $digit;
      ### max y digit (complemented): $digit
      ### $max_y
      ### $max_n
    }

    if ($min_swap) {
      my $digit;
      for ($digit = 0; $digit < $radix_minus_1; $digit++) {
        last if &$overlap ($min_x,$min_xk,$digit, $x1,$x2);
      }
      $min_n += $n_power * $digit;
      $min_yk ^= $digit;
      if ($min_xk&1) { $digit = $radix_minus_1 - $digit; }
      $min_x += $power * $digit;
      ### min x digit (complemented): $digit
      ### $min_x
      ### $min_n
    } else {
      my $digit;
      for ($digit = 0; $digit < $radix_minus_1; $digit++) {
        last if &$overlap ($min_y,$min_yk,$digit, $y1,$y2);
      }
      $min_n += $n_power * $digit;
      $min_xk ^= $digit;
      if ($min_yk&1) { $digit = $radix_minus_1 - $digit; }
      $min_y += $power * $digit;
      ### min y digit (complemented): $digit
      ### $min_y
      ### $min_n
    }

    $n_power = int($n_power/$radix);
    if ($max_swap) {
      my $digit;
      for ($digit = $radix_minus_1; $digit > 0; $digit--) {
        last if &$overlap ($max_y,$max_yk,$digit, $y1,$y2);
      }
      $max_n += $n_power * $digit;
      $max_xk ^= $digit;
      if ($max_yk&1) { $digit = $radix_minus_1 - $digit; }
      $max_y += $power * $digit;
      ### max y digit (complemented): $digit
      ### $max_y
      ### $max_n
    } else {
      my $digit;
      for ($digit = $radix_minus_1; $digit > 0; $digit--) {
        last if &$overlap ($max_x,$max_xk,$digit, $x1,$x2);
      }
      $max_n += $n_power * $digit;
      $max_yk ^= $digit;
      if ($max_xk&1) { $digit = $radix_minus_1 - $digit; }
      $max_x += $power * $digit;
      ### max x digit (complemented): $digit
      ### $max_x
      ### $max_n
    }

    if ($min_swap) {
      my $digit;
      for ($digit = 0; $digit < $radix_minus_1; $digit++) {
        last if &$overlap ($min_y,$min_yk,$digit, $y1,$y2);
      }
      $min_n += $n_power * $digit;
      $min_xk ^= $digit;
      if ($min_yk&1) { $digit = $radix_minus_1 - $digit; }
      $min_y += $power * $digit;
      ### min y digit (complemented): $digit
      ### $min_y
      ### $min_n
    } else {
      my $digit;
      for ($digit = 0; $digit < $radix_minus_1; $digit++) {
        last if &$overlap ($min_x,$min_xk,$digit, $x1,$x2);
      }
      $min_n += $n_power * $digit;
      $min_yk ^= $digit;
      if ($min_xk&1) { $digit = $radix_minus_1 - $digit; }
      $min_x += $power * $digit;
      ### min x digit (complemented): $digit
      ### $min_x
      ### $min_n
    }
  }
  ### is: "$min_n at $min_x,$min_y  to  $max_n at $max_x,$max_y"
  return ($min_n, $max_n);
}

1;
__END__

=for stopwords Walter Wunderlich Wunderlich's there'll eg Ryde OEIS trit-twiddling ie bignums prepending trit Math-PlanePath versa Online PeanoCurve radix Uber Peano Kurven Elemente der Mathematik

=head1 NAME

Math::PlanePath::MathImageWunderlichSerpentine -- 3x3 self-similar quadrant traversal

=head1 SYNOPSIS

 use Math::PlanePath::MathImageWunderlichSerpentine;
 my $path = Math::PlanePath::MathImageWunderlichSerpentine->new (serpentine_type => 0b111000111;
 my ($x, $y) = $path->n_to_xy (123);

 # or another radix digits ...
 my $path5 = Math::PlanePath::MathImageWunderlichSerpentine->new (radix => 5);

=head1 DESCRIPTION

I<In progress.>

This is an integer version of Walter Wunderlich's variations on the
PeanoCurve.  A "serpentine type" controls which combination of the nine
sub-parts are transposed.  For example "010 101 010" gives

       8    60--61--62--63  68--69  78--79--80--81 
             |           |   |   |   |           | 
       7    59--58--57  64  67  70  77--76--75  ...
                     |   |   |   |           |  
       6    54--55--56  65--66  71--72--73--74  
             |                                  
       5    53  48--47  38--37--36--35  30--29  
             |   |   |   |           |   |   | 
       4    52  49  46  39--40--41  34  31  28 
             |   |   |           |   |   |   | 
       3    51--50  45--44--43--42  33--32  27 
                                             | 
       2     6-- 7-- 8-- 9  14--15  24--25--26 
             |           |   |   |   |         
       1     5-- 4-- 3  10  13  16  23--22--21 
                     |   |   |   |           | 
      Y=0    0-- 1-- 2  11--12  17--18--19--20 

           X=0   1   2   3   4   5   6   7   8

=head2 Coil Order

C<serpentine_type =E<gt> -1> transposes all parts, giving what is sometimes
called a "coil order",

     8      24--25--26--27--28--29  78--79--80--81--...
             |                   |   |          
     7      23--22--21  32--31--30  77--76--75  
                     |   |                   |  
     6      18--19--20  33--34--35  72--73--74  
             |                   |   |          
     5      17--16--15  38--37--36  71--70--69  
                     |   |                   |  
     4      12--13--14  39--40--41  66--67--68  
             |                   |   |          
     3      11--10-- 9  44--43--42  65--64--63  
                     |   |                   |  
     2       6-- 7-- 8  45--46--47  60--61--62  
             |                   |   |          
     1       5-- 4-- 3  50--49--48  59--58--57 
                     |   |                   |  
    Y=0      0-- 1-- 2  51--52--53--54--55--56 

           X=0   1   2   3   4   5   6   7   8


=head1 FUNCTIONS

See L<Math::PlanePath/FUNCTIONS> for the behaviour common to all path
classes.

=over 4

=item C<$path = Math::PlanePath::MathImageWunderlichSerpentine-E<gt>new ()>

=item C<$path = Math::PlanePath::MathImageWunderlichSerpentine-E<gt>new (radix =E<gt> $r)>

Create and return a new path object.

The optional C<radix> parameter gives the base for digit splitting.  The
default is ternary, radix 3.  The radix should be an odd number, 3, 5, 7, 9
etc.

=back

=head1 SEE ALSO

L<Math::PlanePath>,
L<Math::PlanePath::PeanoSerpentine>

Walter Wunderlich "Uber Peano-Kurven", Elemente der Mathematik, 28(1):1-10,
1973.

    http://sodwana.uni-ak.ac.at/geom/mitarbeiter/wallner/wunderlich/
    http://sodwana.uni-ak.ac.at/geom/mitarbeiter/wallner/wunderlich/pdf/125.pdf

=cut

# Local variables:
# compile-command: "math-image --path=MathImageWunderlichSerpentine --lines --scale=10"
# End:
#
# math-image --path=MathImageWunderlichSerpentine --all --output=numbers_dash
# math-image --path=MathImageWunderlichSerpentine,radix=5 --all --output=numbers_dash
# math-image --path=MathImageWunderlichSerpentine,serpentine_type=170 --all --output=numbers_dash
#
