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


# math-image --path=MathImagePythagoreanTree --all --scale=3

# Breadth-first advances $x slowly in the worst case

# B. Berggren. see: *Berggren, B. (1934), "Pytagoreiska trianglar", Tidskrift
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
$VERSION = 55;

use Math::PlanePath;
@ISA = ('Math::PlanePath');

# uncomment this to run the ### lines
#use Smart::Comments;

use constant x_negative => 0;
use constant y_negative => 0;

use constant parameter_list => ({
                                 name => 'tree_type',
                                 type => 'enum',
                                 choices => ['FB','UAD'],
                                 default => 'FB',
                                },
                                {
                                 name => 'coordinates',
                                 type => 'enum',
                                 choices => ['AB','BA','Octant','Euclid'],
                                 default => 'AB',
                                });

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
  $self->{'coordinates'} ||= 'AB';
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
    foreach my $digit (reverse @digits) {  # high digit first
      ### $digit
      ### $p
      ### $q
      if ($digit == 0) {
        ($q,$p) = ($p, 2*$p-$q);
      } elsif ($digit == 1) {
        ($q,$p) = ($p, 2*$p+$q);
      } else {
        $p += 2*$q;
      }
    }
  } else {
    foreach my $digit (reverse @digits) {  # high digit first
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

  if ($self->{'coordinates'} eq 'Euclid') {
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
  if ($self->{'coordinates'} eq 'Euclid') {
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

  if ($x2 <= 3 || $y2 <= 0) {
    return (1,0);
  }

  if ($self->{'tree_type'} eq 'UAD') {
    my ($x_level,$y_level);
    if ($self->{'coordinates'} eq 'Euclid') {
      my $level = $x2+1;
      return (0, (3**$level - 1) / 2);
    } else {
      my $x_level = int (($x2+1) / 2);
      my $y_level = int (($y2+31) / 4);
      return (0, (3**min($x_level,$y_level) - 1) / 2);
    }
  } else {
    # FB
    if ($self->{'coordinates'} eq 'Euclid') {
      $x2 *= 3;
    }

    my $x_nhi = $x2 ** 1.35;
    my $y_nhi = 0;
    ### $x_nhi
    return (0, $x_nhi);
  }

  # return (0, $x2*$x2 + 10000);
  # return (0, hypot (max(abs($x1),abs($x2)), max(abs($y1),abs($y2))));
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
 my $path = Math::PlanePath::MathImagePythagoreanTree->new;
 my ($x, $y) = $path->n_to_xy (123);

=head1 DESCRIPTION

I<In progress.>

This path enumerates primitive Pythagorean triples in a breadth-first
traversal of a ternary tree, either the "FB" Fibonacci boxes tree by H. Lee
Price, or the "UAD" tree of Berggren, Banning, Hall and others.

Each point is an integer X,Y with an integer hypotenuse X^2+Y^2=Z^2.
A primitive triple is one where X and Y have no common factor, which also
means one of X,Y odd and the other even, and has Z always odd.

=head2 UAD Tree

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

The first point N=1 is at X=3,Y=4 which is the well-known triple
3^2+4^2=5^2.  From it three further points N=2,3,4 are derived, then three
more from each of those, etc, in a ternary tree.

     N=1      N=2..4      N=5..13   ...

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

The middle path at each node, 20,21 then 119,120, etc, is all the triples
with legs differing by 1.

The lower path at each node, 15,8 then 35,12 etc, is the primitives among a
sequence of triples known to the ancient Babylonians,

     A=k^2-1, B=2*k, C=k^2+1

=head2 FB Tree

The FB tree is based on rearrangements of certain "Fibonacci boxes".  The
X,Y points reached are in a different sequence and a tree structure.

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

     N=1      N=2..4      N=5..13   ...

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

=head2 PQ Coordinates

Any Pythagorean triple can be parameterized as follows, taking A odd and B
even,

    A = u^2 - v^2,  B = 2*u*v,  C = u^2 + v^2

    u = sqrt((C+A)/2),  v = sqrt((C-A)/2)

The starting point A=3,B=4 is then u=2,v=1.

The C<coordinates> option on the path gives u,v as the returned X,Y values,

    my $path = Math::PlanePath::MathImagePythagoreanTree-E<gt>new
                  (coordinates => 'PQ');
    my ($u,$v) = $path->n_to_xy(1);  # u=2,v=1

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
