# Copyright 2011 Kevin Ryde


# coordinates => PQ, UV, MN, RS, ST





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


# math-image --path=MathImagePythagoreanTree --all --scale=3


# http://www.math.uconn.edu/~kconrad/blurbs/ugradnumthy/pythagtriple.pdf
#
# http://www.fq.math.ca/Scanned/30-2/waterhouse.pdf
#
# http://www.math.ou.edu/~dmccullough/teaching/pythagoras1.pdf
# http://www.math.ou.edu/~dmccullough/teaching/pythagoras2.pdf
#
# Euclid Book X prop 28,29 that u,v makes a triple, also Babylonians 
#
# Daniel Shanks. Solved and Unsolved Problems in Number Theory, 4th ed.  New
# York: Chelsea, pp. 121 and 141, 1993.
#
#     http://books.google.com.au/books?id=KjhM9pZEGCkC&lpg=PR1&dq=Solved%20and%20Unsolved%20Problems%20in%20Number%20Theory&pg=PA122#v=onepage&q&f=false
#
# B. Berggren 1934, "Pytagoreiska trianglar", Tidskrift
# for elementar matematik, fysik och kemi 17: 129-139.
#
# http://arxiv.org/abs/math/0406512
# http://www.mendeley.com/research/dynamics-pythagorean-triples/
#    Dan Romik
#
# Biscuits of Number Theory By Arthur T. Benjamin
#    Reproducing Hall, "Genealogy of Pythagorean Triads" 1970
#
# http://www.math.sjsu.edu/~alperin/Pythagoras/ModularTree.html
# http://www.math.sjsu.edu/~alperin/pt.pdf
#
# http://oai.cwi.nl/oai/asset/7151/7151A.pdf
#
# http://arxiv.org/abs/0809.4324
#
# http://www.math.ucdavis.edu/~romik/home/Publications_files/pythrevised.pdf
#
# http://www.microscitech.com/pythag_eigenvectors_invariants.pdf
#

package Math::PlanePath::MathImagePythagoreanTree;
use 5.004;
use strict;
use List::Util qw(min max);
use POSIX qw(floor ceil);
use Math::Libm 'hypot';

use vars '$VERSION', '@ISA';
$VERSION = 56;

use Math::PlanePath;
@ISA = ('Math::PlanePath');

# uncomment this to run the ### lines
#use Smart::Comments;

use constant x_negative => 0;
use constant y_negative => 0;

use constant x_parameter_list => ({
                                   name    => 'wider',
                                   type    => 'integer',
                                   minimum => 0,
                                   default => 0,
                                  },
                                  {
                                   name    => 'step',
                                   type    => 'integer',
                                   minimum => 0,
                                   default => 2,
                                  });

sub new {
  my $class = shift;
  my $self = $class->SUPER::new (@_);
  $self->{'coordinates'} ||= 'UV';
  $self->{'tree_type'} ||= 'FB';
  return $self;
}

sub n_to_xy {
  my ($self, $n) = @_;
  ### PythagoreanTree n_to_xy(): $n
  return if $n < 1;

  if (int($n) != $n) {
    my ($x1,$y1) = $self->n_to_xy(floor($n));
    my ($x2,$y2) = $self->n_to_xy(ceil($n));
    return (($x1+$x2)/2, ($y1+$y2)/2);
  }

  my $h = 2*($n-1)+1;
  my $level = int(log($h)/log(3));
  my $range = 3**$level;
  my $base = ($range - 1)/2 + 1;
  my $rem = $n - $base;

  if ($rem < 0) {
    $rem += $range/3;
    $level--;
    $range /= 3;
  }
  if ($rem >= $range) {
    $rem -= $range;
    $level++;
    $range *= 3;
  }

  ### $n
  ### $h
  ### $level
  ### $range
  ### $base
  ### $rem

  my @digits;
  while ($level--) {
    push @digits, $rem%3;
    $rem = int($rem/3);
  }
  ### @digits

  my $q = 1;
  my $p = 2;

  if ($self->{'tree_type'} eq 'UAD') {
    ### UAD
    foreach my $digit (reverse @digits) {  # high digit first
      ### $p
      ### $q
      ### $digit
      if ($digit == 0) {
        ($p,$q) = (2*$p-$q, $p);
      } elsif ($digit == 1) {
        ($p,$q) = (2*$p+$q, $p);
      } else {
        $p += 2*$q;
      }
    }
  } else {
    ### FB
    foreach my $digit (reverse @digits) {  # high digit first
      ### $p
      ### $q
      ### $digit
      if ($digit == 0) {
        ($q,$p) = (2*$q, $p+$q);
      } elsif ($digit == 1) {
        ($q,$p) = ($p-$q, 2*$p);
      } else {
        ($q,$p) = ($p+$q, 2*$p);
      }
    }
  }

  ### final
  ### $p
  ### $q

  if ($self->{'coordinates'} eq 'UV') {
    return ($p,$q);
  }

  my $a = $p*$p-$q*$q;
  my $b = 2*$p*$q;
  if ($self->{'coordinates'} eq 'BA'
      || ($self->{'coordinates'} eq 'Octant'
          && $a < $b)) {
    return ($b,$a);
  } else {
    return ($a,$b);
  }
}

# a = p^2 - q^2
# b = 2pq
# q = b/2p
# a = p^2 - (b/2p)^2
#   = p^2 - b^2/4p^2
# 4ap^2 = 4p^4 - b^2
# 4(p^2)^2 - 4a(p^2) - b^2 = 0
# p^2 = [ 4a +/- sqrt(16a^2 + 16*b^2) ] / 2*4
#     = [ a +/- sqrt(a^2 - b^2) ] / 2
#     = (a +/- c) / 2
# p = sqrt((a+c)/2)    since c>a
# a = (a+c)/2 - q^2
# q^2 = (a+c)/2 - a
#     = (c-a)/2
# q = sqrt((c-a)/2)
#
# (3*pow+1)/2 - (pow+1)/2
#     = (3*pow + 1 - pow - 1)/2
#     = (2*pow)/2
#     = pow
#
sub xy_to_n {
  my ($self, $x, $y) = @_;
  $x = floor($x + 0.5);
  $y = floor($y + 0.5);
  ### PythagoreanTree xy_to_n(): "$x, $y"

  my ($p, $q);
  if ($self->{'coordinates'} eq 'UV') {
    $p = $x;
    $q = $y;
  } else {
    if ($self->{'coordinates'} eq 'Octant' && $y > $x) {
      return undef;
    }
    if ($self->{'coordinates'} eq 'BA'
        || ($y&1)) {  # for Octant
      ($x,$y) = ($y,$x);
    }

    # if ($x < 4 || $y < 3 || $y > $x) {
    #   return undef;
    # }

    my $z = hypot ($x, $y);
    ### $z
    if (int($z) != $z || ! ($z & 1)) {
      return undef;
    }

    $p = sqrt(($z+$x)/2);
    ### p^2: ($z+$x)/2
    ### $p
    if ($p != int($p)) {
      return undef;
    }

    $q = sqrt(($z-$x)/2);
    ### $q
    if ($q != int($q)) {
      return undef;
    }
  }

  if ($p-1 == $p || $q-1 == $q  # infinity
      || $p < 1 || $q < 1       # negatives
      || ! (($p ^ $q) & 1)      # must be oppostite parity
     ) {
    return undef;
  }

  my $power = 1;
  my $n = 1;
  if ($self->{'tree_type'} eq 'UAD') {
    for (;;) {
      ### $p
      ### $q
      if ($q <= 0 || $p <= 0 || $p <= $q) {
        return undef;
      }
      last if $q <= 1 && $p <= 2;

      if ($p > 2*$q) {
        $n += $power;
        if ($p > 3*$q) {
          ### digit 2
          $n += $power;
          $p -= 2*$q;
        } else {
          ### digit 1
          ($p,$q) = ($q, $p - 2*$q);
        }

      } else {
        ### digit 0
        ($q,$p) = (2*$q-$p, $q);
      }
      ### descend: "$q / $p"
      $n += $power;  # step the base
      $power *= 3;
    }

  } else {
    for (;;) {
      if ($q <= 0 || $p <= 0) {
        return undef;
      }
      last if $q <= 1 && $p <= 2;

      if ($q & 1) {
        # q odd, p even
        $p /= 2;
        $n += $power; # digit 1 or 2
        if ($q > $p) {
          $q = $q - $p;  # opp parity of p, and < new p
          $n += $power;  # digit 2
        } else {
          $q = $p - $q;  # opp parity of p, and < p
        }
      } else {
        # q even, p odd
        $q /= 2;
        $p -= $q;  # opp parity of q
      }
      ### descend: "$q / $p"
      $n += $power;  # step the base
      $power *= 3;
    }
  }

  ### base: ($power+1)/2
  ### $n
  return $n;
}


# numprims(H) = how many with hypot < H
# limit H->inf  numprims(H) / H -> 1/2pi
#
sub rect_to_n_range {
  my ($self, $x1,$y1, $x2,$y2) = @_;
  ### rect_to_n_range()

  $x1 = floor($x1 + 0.5);
  $y1 = floor($y1 + 0.5);
  $x2 = floor($x2 + 0.5);
  $y2 = floor($y2 + 0.5);

  ($x1,$x2) = ($x2,$x1) if $x1 > $x2;
  ($y1,$y2) = ($y2,$y1) if $y1 > $y2;
  ### $x2
  ### $y2

  if ($self->{'coordinates'} eq 'BA') {
    ($x2,$y2) = ($y2,$x2);
  }
  if ($self->{'coordinates'} eq 'Octant') {
    $x2 = $y2 = max($x2,$y2);
  }

  if ($x2 < 3 || $y2 < 0) {
    return (1,0);
  }

  my $level;
  if ($self->{'tree_type'} eq 'UAD') {
    if ($self->{'coordinates'} eq 'UV') {
      my $level = $x2+1;
    } else {
      $level = min (int (($x2+1) / 2),
                    int (($y2+31) / 4));
    }
  } else {
    # FB
    if ($self->{'coordinates'} eq 'UV') {
      $x2 *= 3;
    }
    $x2--;
    for (my $k = 1; ; $k++) {
      if ($x2 <= (3 * 2**$k + 1)) {
        $level = 2*$k+1;
        last;
      }
      if ($x2 <= (2**($k+2)) + 1) {
        $level = 2*$k+2;
        last;
      }
    }
  }
  ### $level
  return (0, (3**$level - 1) / 2);
}

1;
__END__



  # my $a = 1;
  # my $b = 1;
  # my $c = 2;
  # my $d = 3;

    # ### at: "$a,$b,$c,$d   digit $digit"
    # if ($digit == 0) {
    #   ($a,$b,$c) = ($a,2*$b,$d);
    # } elsif ($digit == 1) {
    #   ($a,$b,$c) = ($d,$a,2*$c);
    # } else {
    #   ($a,$b,$c) = ($a,$d,2*$c);
    # }
    # $d = $b+$c;
  #   ### final: "$a,$b,$c,$d"
  # #  print "$a,$b,$c,$d\n";
  #   my $x = $c*$c-$b*$b;
  #   my $y = 2*$b*$c;
  #   return (max($x,$y), min($x,$y));

  # return $x,$y;




=for stopwords eg Ryde OEIS

=head1 NAME

Math::PlanePath::MathImagePythagoreanTree -- primitive pythagorean triples by tree

=head1 SYNOPSIS

 use Math::PlanePath::MathImagePythagoreanTree;
 my $path = Math::PlanePath::MathImagePythagoreanTree->new
              (tree_type => 'UAD',
               coordinates => 'AB');
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

I<In progress.>

This path enumerates primitive Pythagorean triples by a breadth-first
traversal of a ternary tree, either a  "UAD" or "FB" tree.

Each point is an integer X,Y = A,B with an integer hypotenuse A^2+B^2=C^2.
A primitive triple is one where A and B have no common factor.  A primitive
triple always has one leg odd and the other even and the trees here give
them ordered as A odd and B even.

In this breadth-first order both trees go out to rather large A,B values
while smaller ones have yet to come out.  The UAD tree goes out further than
the FB.

=head2 UAD Tree

The UAD tree by Berggren (1934), later independently by Barning (1963), Hall
(1970), and a number of others, uses three matrices U, A and D which can be
multiplied onto an existing primitive triple to form three new triples.

    my $path = Math::PlanePath::MathImagePythagoreanTree->new
                 (tree_type => 'UAD');

Starting from A=3,B=4,C=5 (the well-known 3^2 + 4^2 = 5^2) this visits all
and only primitive triples.

   Y=40 |          14
        |
        |
        |
        |                                              7
   Y=24 |        5
        |
   Y=20 |                      3
        |
   Y=12 |      2                             13
        |
        |                4
    Y=4 |    1
        |
        +--------------------------------------------------
           X=3         X=15  X=20           X=35      X=45

The starting point N=1 is X=3,Y=4, from which three further N=2,3,4 are
derived, then three more from each of those, etc,

     N=1     N=2..4      N=5..13    N=14...

                      +-> 7,24
          +-> 5,12  --+-> 55,48
          |           +-> 45,28
          |
          |           +-> 39,80
    3,4 --+-> 21,20 --+-> 119,120
          |           +-> 77,36
          |
          |           +-> 33,56
          +-> 15,8  --+-> 65,72
                      +-> 35,12

Counting N=1 as level k=1, each level has 3^(k-1) many points so the first N
for a level is

    N = 1 + 3 + 3^2 + ... + 3^(k-1)
      = (3^k + 1) / 2

Taking the middle "A" direction at each node, so 21,20 then 119,120 then
697,696, etc, gives the triples with legs differing by 1 and thus just below
the X=Y leading diagonal.  These are at N=3^k.

Taking the lower "D" direction at each node, ie. 15,8 then 35,12 then 63,16,
etc, is the primitives among a sequence of triples known to the ancients,

     A = k^2-1,  B = 2*k,  C = k^2+1

With k even these are primitive.  (If k is odd then A and B are both even,
ie. a common factor of 2, so not primitive.)  These points are the end of
each level, so N=(3^k-1)/2.

=head2 FB Tree

The FB tree by H. Lee Price is based on expressing triples in certain
"Fibonacci boxes" with q',q,p,p' having p=q+q' and p'=p+q, so each is the
sum of the preceding two similar to the Fibonacci sequence.  Any box where p
and q have no common factor corresponds to a primitive triple per L</UV
Coordinates> below.

    my $path = Math::PlanePath::MathImagePythagoreanTree->new
                 (tree_type => 'FB');

To a given box three transformations can be applied to go to new boxes
corresponding to new triples.  This visits all and only primitive triples,
but in a different order and different tree structure to the UAD above.

    Y=40 |         5
         |
         |
         |
         |                                             17
    Y=24 |       4
         |
         |                     8
         |
    Y=12 |     2                             6
         |
         |               3
    Y=4  |   1
         |
         +----------------------------------------------
           X=3         X=15   x=21         X=35

The first point N=1 is again at X=3,Y=4 and three further points N=2,3,4 are
derived, then three more from each of those, etc.

    N=1      N=2..4      N=5..13     N=14...

                      +-> 9,40
          +-> 5,12  --+-> 35,12
          |           +-> 11,60
          |
          |           +-> 21,20
    3,4 --+-> 15,8  --+-> 55,48
          |           +-> 39,80
          |
          |           +-> 13,84
          +-> 7,24  --+-> 63,16
                      +-> 15,112

=head2 UV Coordinates

Primitive Pythagorean triples can be parameterized as follows, taking A odd
and B even.

    A = u^2 - v^2,  B = 2*u*v,  C = u^2 + v^2

    u = sqrt((C+A)/2),  v = sqrt((C-A)/2)
    with u>v>=1, one odd, one even, and no common factor

The first u=2,v=1 is the triple A=3,B=4,C=5.  The C<coordinates> option on
the path gives these u,v values as the returned X,Y coordinates,

    my $path = Math::PlanePath::MathImagePythagoreanTree-E<gt>new
                  (tree_type => 'UAD',    # or 'FB'
                   coordinates => 'PQ');
    my ($u,$v) = $path->n_to_xy(1);  # u=2,v=1

Since u>v>=1, the values fall in an octant below the X=Y leading diagonal,

    11 |                      *
    10 |                    *  
     9 |                  *    
     8 |                *   *  
     7 |              *   *   *
     6 |            *       *  
     5 |          *   *       *
     4 |        *   *   *   *  
     3 |      *       *   *    
     2 |    *   *   *   *   *  
     1 |  *   *   *   *   *   *
       +------------------------
          2 3 4 5 6 7 8 9 ...

The correspondence between u,v and A,B means the trees visit all u,v with no
common factor and one of them even.  Of course there's other ways to iterate
through such u,v, such as simply u=2,3,etc, which would generate triples
too, in a different order from the trees here.

=head1 FUNCTIONS

=over 4

=item C<$path = Math::PlanePath::MathImagePythagoreanTree-E<gt>new ()>

Create and return a new path object.

=item C<($x,$y) = $path-E<gt>n_to_xy ($n)>

Return the X,Y coordinates of point number C<$n> on the path.  Points begin
at 0 and if C<$n E<lt> 0> then the return is an empty list.

Fractional positions give an X,Y position along a straight line between the
integer positions.  Integer positions are always just 1 apart either
horizontally or vertically, so the effect is that the fraction part appears
either added to or subtracted from X or Y.

=back

=head1 SEE ALSO

L<Math::PlanePath>

H. Lee Price, "The Pythagorean Tree: A New Species", 2008,
<http://arxiv.org/abs/0809.4324>.

L<Math::PlanePath::Hypot>

=head1 HOME PAGE

http://user42.tuxfamily.org/math-image/index.html

=head1 LICENSE

Math-Image is Copyright 2010, 2011 Kevin Ryde

Math-Image is free software; you can redistribute it and/or modify it
under the terms of the GNU General Public License as published by the Free
Software Foundation; either version 3, or (at your option) any later
version.

Math-Image is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
more details.

You should have received a copy of the GNU General Public License along with
Math-Image.  If not, see <http://www.gnu.org/licenses/>.

=cut
