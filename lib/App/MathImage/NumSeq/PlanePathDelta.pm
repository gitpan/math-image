# path(n-1) to path(n), or
# path(n) to path(n+1)


# dX
# ENWS
# Dir60


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

package App::MathImage::NumSeq::PlanePathDelta;
use 5.004;
use strict;
use Carp;

use vars '$VERSION','@ISA';
$VERSION = 81;
use Math::NumSeq;
@ISA = ('Math::NumSeq');

use Math::NumSeq::PlanePathCoord;

# uncomment this to run the ### lines
#use Devel::Comments;


use constant characteristic_smaller => 1;
use constant description => Math::NumSeq::__('Coordinates from a PlanePath');

use constant::defer parameter_info_array =>
  sub {
    return [
            Math::NumSeq::PlanePathCoord::_parameter_info_planepath(),
            {
             name    => 'delta_type',
             display => Math::NumSeq::__('Delta Type'),
             type    => 'enum',
             default => 'dX',
             choices => ['dX','dY','dDist','dDistSquared',
                         'ENWS',
                        ],
             # description => Math::NumSeq::__(''),
            },
           ];
  };

my %oeis_anum
  = ('Math::PlanePath::HilbertCurve' =>
     {
      # delta a(n)-a(n-1), so initial dx=0 at i=0 ...
      # dX => 'A163538',
      # # OEIS-Catalogue: A163538 planepath=HilbertCurve delta_type=dX
      # dY => 'A163539',
      # # OEIS-Catalogue: A163539 planepath=HilbertCurve delta_type=dY

      # A163540 0=east,1=south,2=west,3=north treated as down the page,
      # which is 1=north,2=south for directions of HilbertCurve
      ENWS => 'A163540',
      # OEIS-Catalogue: A163540 planepath=HilbertCurve delta_type=ENWS

      # cf A163541    absolute direction, transpose X,Y
      # would be N=0,E=1,S=2,W=3
     },

     'Math::PlanePath::PeanoCurve,radix=3' =>
     {
      # delta a(n)-a(n-1), so initial dx=0 at i=0 ...
      # dX => 'A163532',
      # # OEIS-Catalogue: A163532 planepath=PeanoCurve delta_type=dX
      # dY => 'A163533',
      # # OEIS-Catalogue: A163533 planepath=PeanoCurve delta_type=dY

      # A163534 0=east,1=south,2=west,3=north treated as down the page,
      # which is 1=north (incr Y), 3=south (decr Y) for directions of
      # HilbertCurve here
      ENWS => 'A163534',
      # OEIS-Catalogue: A163534 planepath=PeanoCurve delta_type=ENWS
     },
    );

sub oeis_anum {
  my ($self) = @_;
  return $oeis_anum{Math::NumSeq::PlanePathCoord::_planepath_oeis_key($self->{'planepath_object'})} -> {$self->{'delta_type'}};
}


sub new {
  my $class = shift;
  ### NumSeq-PlanePathN new(): @_
  my $self = $class->SUPER::new(@_);

  my $planepath_object = ($self->{'planepath_object'}
                          ||= Math::NumSeq::PlanePathCoord::_planepath_name_to_object($self->{'planepath'}));

  $self->{'delta_func'}
    = $self->can("_delta_func_$self->{'delta_type'}")
      || croak "Unrecognised delta_type: ",$self->{'delta_type'};

  $self->rewind;
  return $self;
}

sub i_start {
  my ($self) = @_;
  my $planepath_object = $self->{'planepath_object'} || return 0;
  return $planepath_object->n_start + 1;
}
sub rewind {
  my ($self) = @_;
  my $planepath_object = $self->{'planepath_object'} || return;
  ($self->{'prev_x'}, $self->{'prev_y'})
    = $planepath_object->n_to_xy (($self->{'i'} = $self->i_start)
                                  - 1);
}

sub next {
  my ($self) = @_;
  ### NumSeq-PlanePath next(): $self->{'i'}
  ### n_next: $self->{'n_next'}

  my $i = $self->{'i'}++;
  my ($x, $y) = $self->{'planepath_object'}->n_to_xy($i)
    or return;
  my $ret = &{$self->{'delta_func'}}($x,$y,
                                     $self->{'prev_x'},$self->{'prev_y'});
  $self->{'prev_x'} = $x;
  $self->{'prev_y'} = $y;
  return ($i, $ret);
}

sub ith {
  my ($self, $i) = @_;
  ### NumSeq-PlanePath ith(): $i

  my $planepath_object = $self->{'planepath_object'};
  my ($x, $y) = $planepath_object->n_to_xy ($i)
    or return undef;
  my ($next_x, $next_y) = $planepath_object->n_to_xy ($i + 1)
    or return undef;
  return &{$self->{'delta_func'}}($self, $x,$y, $next_x,$next_y);
}

sub _delta_func_dX {
  my ($x,$y, $prev_x,$prev_y) = @_;
  return $x - $prev_x;
}
sub _delta_func_dY {
  my ($x,$y, $prev_x,$prev_y) = @_;
  return $y - $prev_y;
}
sub _delta_func_dDist {
  return sqrt(_delta_func_dDistSquared(@_));
}
sub _delta_func_dDistSquared {
  my ($x,$y, $prev_x,$prev_y) = @_;
  $x -= $prev_x;
  $y -= $prev_y;
  return $x*$x + $y*$y;
}

#      N
#      1
#  W 2   0 E
#      3
#      S
sub _delta_func_ENWS {
  my ($x,$y, $prev_x,$prev_y) = @_;
  ### _delta_func_ENWS(): "$x,$y,  $prev_x,$prev_y"

  my $dx = $x - $prev_x;
  my $dy = $y - $prev_y;
  ### dxdy: "$dx $dy"

  #        dx<dy /
  #             /
  #        \ N / dx>dy
  #         \ /
  #       W  X  E
  #         / \
  #        / S \ dx>-dy,dy>-dx
  #             \
  #       dx<-dy \
  #
  if ($dx <= $dy && $dx > -$dy) {
    return 1;  # north
  }
  if ($dx <= -$dy && $dx < $dy) {
    return 2;  # west
  }
  if ($dx >= $dy && $dx < -$dy) {
    return 3;  # south
  }
  return 0;  # east
}
# if ($y < $prev_y) { return 3 }  # south
# if ($x < $prev_x) { return 2 }  # west
# if ($y > $prev_y) { return 1 }  # north
#
# my @dir = ([0,  # x>y and x>-y  E
#             0,  # x>y and x==-y impossible
#             3,  # x>y and x<-y  S
#            ],
#            [0,  # x==y and x>-y impossible
#             1,  # x==y and x==-y  ... but which line ?
#             0,  # x==y and x<-y impossible
#            ],
#            [1,  # x<y and x>-y  N
#             0,  # x<y and x==-y impossible
#             2,  # x<y and x<-y  W
#            ]);
#   return $dir[($x <=> $y) + 1]->[($x <=> -$y) + 1];


#------------------------------------------------------------------------------

sub values_min {
  my ($self) = @_;
  my $planepath_object = $self->{'planepath_object'};
  my $func;
  return (($func = $planepath_object->can("_NumSeq_Delta_$self->{'delta_type'}_min"))
          ? $planepath_object->$func()
          : undef);
}
sub values_max {
  my ($self) = @_;
  my $planepath_object = $self->{'planepath_object'};
  my $func;
  return (($func = $planepath_object->can("_NumSeq_Delta_$self->{'delta_type'}_max"))
          ? $planepath_object->$func()
          : undef);
}

{ package Math::PlanePath;

  # use constant MathImage__NumSeq_Delta_dX_min => undef;
  # use constant MathImage__NumSeq_Delta_dX_max => undef;
  # 
  # use constant MathImage__NumSeq_Delta_dY_min => undef;
  # use constant MathImage__NumSeq_Delta_dY_max => undef;

  sub MathImage__NumSeq_Delta_dDist_min {
    my ($self) = @_;
    sqrt($self->MathImage__NumSeq_Delta_dDistSquared_min);
  }
  sub MathImage__NumSeq_Delta_dDist_max {
    my ($self) = @_;
    my $max;
    return (defined ($max = $self->MathImage__NumSeq_Delta_dDistSquared_max)
            ? sqrt($max)
            : undef);
  }
  use constant MathImage__NumSeq_Delta_dDistSquared_min => 0;
  use constant MathImage__NumSeq_Delta_dDistSquared_max => undef;

  use constant MathImage__NumSeq_Delta_ENWS_min => 0;
  use constant MathImage__NumSeq_Delta_ENWS_max => 3;
}

{ package Math::PlanePath::SquareSpiral;
  use constant MathImage__NumSeq_Delta_dX_min => -1;
  use constant MathImage__NumSeq_Delta_dX_max => 1;
  use constant MathImage__NumSeq_Delta_dY_min => -1;
  use constant MathImage__NumSeq_Delta_dY_max => 1;
  use constant MathImage__NumSeq_Delta_dDistSquared_min => 1;
  use constant MathImage__NumSeq_Delta_dDistSquared_max => 1;
}
{ package Math::PlanePath::PyramidSpiral;
  use constant MathImage__NumSeq_Delta_dX_min => -1;
  use constant MathImage__NumSeq_Delta_dX_max => 1;
  use constant MathImage__NumSeq_Delta_dY_min => -1;
  use constant MathImage__NumSeq_Delta_dY_max => 1;
  use constant MathImage__NumSeq_Delta_dDistSquared_min => 1;
  use constant MathImage__NumSeq_Delta_dDistSquared_max => 2;
}
{ package Math::PlanePath::TriangleSpiral;
  use constant MathImage__NumSeq_Delta_dX_min => -1;
  use constant MathImage__NumSeq_Delta_dX_max => 2;
  use constant MathImage__NumSeq_Delta_dY_min => -1;
  use constant MathImage__NumSeq_Delta_dY_max => 1;
  use constant MathImage__NumSeq_Delta_dDistSquared_min => 2;
  use constant MathImage__NumSeq_Delta_dDistSquared_max => 4;
}
{ package Math::PlanePath::TriangleSpiralSkewed;
  use constant MathImage__NumSeq_Delta_dX_min => -1;
  use constant MathImage__NumSeq_Delta_dX_max => 1;
  use constant MathImage__NumSeq_Delta_dY_min => -1;
  use constant MathImage__NumSeq_Delta_dY_max => 1;
  use constant MathImage__NumSeq_Delta_dDistSquared_min => 1;
  use constant MathImage__NumSeq_Delta_dDistSquared_max => 2;
}
{ package Math::PlanePath::DiamondSpiral;
  use constant MathImage__NumSeq_Delta_dX_min => -1;
  use constant MathImage__NumSeq_Delta_dX_max => 1;
  use constant MathImage__NumSeq_Delta_dY_min => -1;
  use constant MathImage__NumSeq_Delta_dY_max => 1;
  use constant MathImage__NumSeq_Delta_dDistSquared_min => 1;
  use constant MathImage__NumSeq_Delta_dDistSquared_max => 2;
}
{ package Math::PlanePath::PentSpiralSkewed;
  use constant MathImage__NumSeq_Delta_dX_min => -1;
  use constant MathImage__NumSeq_Delta_dX_max => 1;
  use constant MathImage__NumSeq_Delta_dY_min => -1;
  use constant MathImage__NumSeq_Delta_dY_max => 1;
  use constant MathImage__NumSeq_Delta_dDistSquared_min => 1;
  use constant MathImage__NumSeq_Delta_dDistSquared_max => 2;
}
{ package Math::PlanePath::HexSpiral;
  use constant MathImage__NumSeq_Delta_dX_min => -2;
  use constant MathImage__NumSeq_Delta_dX_max => 2;
  use constant MathImage__NumSeq_Delta_dY_min => -1;
  use constant MathImage__NumSeq_Delta_dY_max => 1;
  use constant MathImage__NumSeq_Delta_dDistSquared_min => 2;
  use constant MathImage__NumSeq_Delta_dDistSquared_max => 4;
}
{ package Math::PlanePath::HexSpiralSkewed;
  use constant MathImage__NumSeq_Delta_dX_min => -1;
  use constant MathImage__NumSeq_Delta_dX_max => 1;
  use constant MathImage__NumSeq_Delta_dY_min => -1;
  use constant MathImage__NumSeq_Delta_dY_max => 1;
  use constant MathImage__NumSeq_Delta_dDistSquared_min => 1;
  use constant MathImage__NumSeq_Delta_dDistSquared_max => 2;
}
{ package Math::PlanePath::HeptSpiralSkewed;
  use constant MathImage__NumSeq_Delta_dX_min => -1;
  use constant MathImage__NumSeq_Delta_dX_max => 1;
  use constant MathImage__NumSeq_Delta_dY_min => -1;
  use constant MathImage__NumSeq_Delta_dY_max => 1;
  use constant MathImage__NumSeq_Delta_dDistSquared_min => 1;
  use constant MathImage__NumSeq_Delta_dDistSquared_max => 2;
}
{ package Math::PlanePath::OctagramSpiral;
  use constant MathImage__NumSeq_Delta_dX_min => -1;
  use constant MathImage__NumSeq_Delta_dX_max => 1;
  use constant MathImage__NumSeq_Delta_dY_min => -1;
  use constant MathImage__NumSeq_Delta_dY_max => 1;
  use constant MathImage__NumSeq_Delta_dDistSquared_min => 1;
  use constant MathImage__NumSeq_Delta_dDistSquared_max => 2;
}
{ package Math::PlanePath::KnightSpiral;
  use constant MathImage__NumSeq_Delta_dX_min => -2;
  use constant MathImage__NumSeq_Delta_dX_max => 2;
  use constant MathImage__NumSeq_Delta_dY_min => -2;
  use constant MathImage__NumSeq_Delta_dY_max => 2;
  use constant MathImage__NumSeq_Delta_dDistSquared_min => 5;
  use constant MathImage__NumSeq_Delta_dDistSquared_max => 5;
}
# { package Math::PlanePath::SquareArms;
# }
# { package Math::PlanePath::DiamondArms;
# }
# { package Math::PlanePath::HexArms;
# }
{ package Math::PlanePath::GreekKeySpiral;
  use constant MathImage__NumSeq_Delta_dX_min => -1;
  use constant MathImage__NumSeq_Delta_dX_max => 1;
  use constant MathImage__NumSeq_Delta_dY_min => -1;
  use constant MathImage__NumSeq_Delta_dY_max => 1;
  use constant MathImage__NumSeq_Delta_dDistSquared_min => 1;
  use constant MathImage__NumSeq_Delta_dDistSquared_max => 1;
}
{ package Math::PlanePath::SacksSpiral;
  use constant MathImage__NumSeq_Delta_dDistSquared_min => 1;
}
# { package Math::PlanePath::VogelFloret;
# }
{ package Math::PlanePath::TheodorusSpiral;
  use constant MathImage__NumSeq_Delta_dX_min => -1;
  use constant MathImage__NumSeq_Delta_dX_max => 1;
  use constant MathImage__NumSeq_Delta_dY_min => -1;
  use constant MathImage__NumSeq_Delta_dY_max => 1;
  use constant MathImage__NumSeq_Delta_dDistSquared_min => 1;
  use constant MathImage__NumSeq_Delta_dDistSquared_max => 1;
}
{ package Math::PlanePath::ArchimedeanChords;
  use constant MathImage__NumSeq_Delta_dX_min => -1;
  use constant MathImage__NumSeq_Delta_dX_max => 1;
  use constant MathImage__NumSeq_Delta_dY_min => -1;
  use constant MathImage__NumSeq_Delta_dY_max => 1;
  use constant MathImage__NumSeq_Delta_dDistSquared_min => 1;
  use constant MathImage__NumSeq_Delta_dDistSquared_max => 1;
}
{ package Math::PlanePath::MultipleRings;
  use constant MathImage__NumSeq_Delta_dX_min => -1;
  use constant MathImage__NumSeq_Delta_dY_min => -1;
  use constant MathImage__NumSeq_Delta_dY_max => 1;
  use constant MathImage__NumSeq_Delta_dDistSquared_min => 1;
  use constant MathImage__NumSeq_Delta_dDistSquared_max => 1;
  # FIXME: dDistSquared bit bigger actually
}
{ package Math::PlanePath::PixelRings;
  use constant MathImage__NumSeq_Delta_dX_min => -1;
  use constant MathImage__NumSeq_Delta_dX_max => 1;
  use constant MathImage__NumSeq_Delta_dY_min => -1;
  use constant MathImage__NumSeq_Delta_dY_max => 1;
  use constant MathImage__NumSeq_Delta_dDistSquared_min => 1;
  use constant MathImage__NumSeq_Delta_dDistSquared_max => 2;
}
# { package Math::PlanePath::Hypot;
# }
# { package Math::PlanePath::HypotOctant;
# }
# { package Math::PlanePath::TriangularHypot;
# }
# { package Math::PlanePath::PythagoreanTree;
# }
# { package Math::PlanePath::RationalsTree;
# }
{ package Math::PlanePath::PeanoCurve;
  sub MathImage__NumSeq_Delta_dX_min {
    my ($self) = @_;
    return ($self->{'radix'} % 2
            ? -1
            : undef);
  }
  sub MathImage__NumSeq_Delta_dX_max {
    my ($self) = @_;
    return ($self->{'radix'} % 2
            ? 1
            : undef);
  }
  sub MathImage__NumSeq_Delta_dY_min {
    my ($self) = @_;
    return ($self->{'radix'} % 2
            ? -1
            : undef);
  }
  sub MathImage__NumSeq_Delta_dY_max {
    my ($self) = @_;
    return ($self->{'radix'} % 2
            ? 1
            : undef);
  }
  sub MathImage__NumSeq_Delta_dDistSquared_min {
    my ($self) = @_;
    return ($self->{'radix'} % 2
            ? 1
            : undef);
  }
  sub MathImage__NumSeq_Delta_dDistSquared_max {
    my ($self) = @_;
    return ($self->{'radix'} % 2
            ? 1
            : undef);
  }
}
{ package Math::PlanePath::HilbertCurve;
  use constant MathImage__NumSeq_Delta_dX_min => -1;
  use constant MathImage__NumSeq_Delta_dX_max => 1;
  use constant MathImage__NumSeq_Delta_dY_min => -1;
  use constant MathImage__NumSeq_Delta_dY_max => 1;
  use constant MathImage__NumSeq_Delta_dDistSquared_min => 1;
  use constant MathImage__NumSeq_Delta_dDistSquared_max => 1;
}
{ package Math::PlanePath::ZOrderCurve;
  use constant MathImage__NumSeq_Delta_dX_max => 1;
  use constant MathImage__NumSeq_Delta_dY_max => 1;
  use constant MathImage__NumSeq_Delta_dDistSquared_min => 1;
}
# { package Math::PlanePath::ImaginaryBase;
# }
{ package Math::PlanePath::Flowsnake;
  sub MathImage__NumSeq_Delta_dX_min {
    my ($self) = @_;
    return ($self->{'arms'} == 1
            ? -2
            : undef);
  }
  sub MathImage__NumSeq_Delta_dX_max {
    my ($self) = @_;
    return ($self->{'arms'} == 1
            ? 2
            : undef);
  }
  sub MathImage__NumSeq_Delta_dY_min {
    my ($self) = @_;
    return ($self->{'arms'} == 1
            ? -1
            : undef);
  }
  sub MathImage__NumSeq_Delta_dY_max {
    my ($self) = @_;
    return ($self->{'arms'} == 1
            ? 1
            : undef);
  }
  sub MathImage__NumSeq_Delta_dDistSquared_min {
    my ($self) = @_;
    return ($self->{'arms'} == 1
            ? 2
            : undef);
  }
  sub MathImage__NumSeq_Delta_dDistSquared_max {
    my ($self) = @_;
    return ($self->{'arms'} == 1
            ? 4
            : undef);
  }
}
{ package Math::PlanePath::FlowsnakeCentres;
  # inherit from Flowsnake
}
{ package Math::PlanePath::GosperIslands;
  use constant MathImage__NumSeq_Delta_dDistSquared_min => 2;
}
{ package Math::PlanePath::GosperSide;
  use constant MathImage__NumSeq_Delta_dX_min => -2;
  use constant MathImage__NumSeq_Delta_dX_max => 2;
  use constant MathImage__NumSeq_Delta_dY_min => -1;
  use constant MathImage__NumSeq_Delta_dY_max => 1;
  use constant MathImage__NumSeq_Delta_dDistSquared_min => 2;
  use constant MathImage__NumSeq_Delta_dDistSquared_max => 4;
}

{ package Math::PlanePath::KochCurve;
  use constant MathImage__NumSeq_Delta_dX_min => -2;
  use constant MathImage__NumSeq_Delta_dX_max => 2;
  use constant MathImage__NumSeq_Delta_dDistSquared_min => 2;
  use constant MathImage__NumSeq_Delta_dDistSquared_max => 4;
}
{ package Math::PlanePath::KochPeaks;
  use constant MathImage__NumSeq_Delta_dX_max => 2;
  use constant MathImage__NumSeq_Delta_dY_max => 1;
  use constant MathImage__NumSeq_Delta_dDistSquared_min => 2;
}
{ package Math::PlanePath::KochSnowflakes;
  use constant MathImage__NumSeq_Delta_dX_min => 1;
  use constant MathImage__NumSeq_Delta_dDistSquared_min => 2;
}
{ package Math::PlanePath::KochSquareflakes;
  use constant MathImage__NumSeq_Delta_dX_max => 1;
  use constant MathImage__NumSeq_Delta_dY_max => 1;
  use constant MathImage__NumSeq_Delta_dDistSquared_min => 1;
}

{ package Math::PlanePath::QuadricCurve;
  use constant MathImage__NumSeq_Delta_dX_min => -1;
  use constant MathImage__NumSeq_Delta_dX_max => 1;
  use constant MathImage__NumSeq_Delta_dY_min => -1;
  use constant MathImage__NumSeq_Delta_dY_max => 1;
  use constant MathImage__NumSeq_Delta_dDistSquared_min => 1;
}
{ package Math::PlanePath::QuadricIslands;
  use constant MathImage__NumSeq_Delta_dX_max => 1;
  use constant MathImage__NumSeq_Delta_dY_max => 1;
  use constant MathImage__NumSeq_Delta_dDistSquared_min => 1;
}

{ package Math::PlanePath::SierpinskiTriangle;
  use constant MathImage__NumSeq_Delta_dY_min => 0;
  use constant MathImage__NumSeq_Delta_dY_max => 1;
  use constant MathImage__NumSeq_Delta_dDistSquared_min => 2;
}
{ package Math::PlanePath::SierpinskiArrowhead;
  use constant MathImage__NumSeq_Delta_dX_min => -2;
  use constant MathImage__NumSeq_Delta_dX_max => 2;
  use constant MathImage__NumSeq_Delta_dY_min => -1;
  use constant MathImage__NumSeq_Delta_dY_max => 1;
  use constant MathImage__NumSeq_Delta_dDistSquared_min => 2;
  use constant MathImage__NumSeq_Delta_dDistSquared_max => 4;
}
{ package Math::PlanePath::SierpinskiArrowheadCentres;
  use constant MathImage__NumSeq_Delta_dX_min => -2;
  use constant MathImage__NumSeq_Delta_dX_max => 2;
  use constant MathImage__NumSeq_Delta_dY_min => -1;
  use constant MathImage__NumSeq_Delta_dY_max => 1;
  use constant MathImage__NumSeq_Delta_dDistSquared_min => 2;
  use constant MathImage__NumSeq_Delta_dDistSquared_max => 4;
}

{ package Math::PlanePath::DragonCurve;
  use constant MathImage__NumSeq_Delta_dX_min => -1;
  use constant MathImage__NumSeq_Delta_dX_max => 1;
  use constant MathImage__NumSeq_Delta_dY_min => -1;
  use constant MathImage__NumSeq_Delta_dY_max => 1;
  use constant MathImage__NumSeq_Delta_dDistSquared_min => 1;
  use constant MathImage__NumSeq_Delta_dDistSquared_max => 1;
}
{ package Math::PlanePath::DragonRounded;
  use constant MathImage__NumSeq_Delta_dX_min => -1;
  use constant MathImage__NumSeq_Delta_dX_max => 1;
  use constant MathImage__NumSeq_Delta_dY_min => -1;
  use constant MathImage__NumSeq_Delta_dY_max => 1;
  use constant MathImage__NumSeq_Delta_dDistSquared_min => 1;
  use constant MathImage__NumSeq_Delta_dDistSquared_max => 2;
}
{ package Math::PlanePath::DragonMidpoint;
  use constant MathImage__NumSeq_Delta_dX_min => -1;
  use constant MathImage__NumSeq_Delta_dX_max => 1;
  use constant MathImage__NumSeq_Delta_dY_min => -1;
  use constant MathImage__NumSeq_Delta_dY_max => 1;
  use constant MathImage__NumSeq_Delta_dDistSquared_min => 1;
  use constant MathImage__NumSeq_Delta_dDistSquared_max => 1;
}
{ package Math::PlanePath::ComplexMinus;
  use constant MathImage__NumSeq_Delta_dDistSquared_min => 1;
}
{ package Math::PlanePath::Rows;
  sub MathImage__NumSeq_Delta_dX_min {
    my ($self) = @_;
    return - ($self->{'width'}-1);
  }
  use constant MathImage__NumSeq_Delta_dX_max => 1;
  use constant MathImage__NumSeq_Delta_dY_min => 0;
  use constant MathImage__NumSeq_Delta_dY_max => 1;
  use constant MathImage__NumSeq_Delta_dDistSquared_min => 1;
}
{ package Math::PlanePath::Columns;
  use constant MathImage__NumSeq_Delta_dX_min => 0;
  use constant MathImage__NumSeq_Delta_dX_max => 1;
  sub MathImage__NumSeq_Delta_dY_min {
    my ($self) = @_;
    return - ($self->{'height'}-1);
  }
  use constant MathImage__NumSeq_Delta_dY_max => 1;
  use constant MathImage__NumSeq_Delta_dDistSquared_min => 1;
}
{ package Math::PlanePath::Diagonals;
  use constant MathImage__NumSeq_Delta_dX_max => 1;
  use constant MathImage__NumSeq_Delta_dY_min => -1;
  use constant MathImage__NumSeq_Delta_dDistSquared_min => 2;
}
{ package Math::PlanePath::Staircase;
  use constant MathImage__NumSeq_Delta_dX_max => 1;
  use constant MathImage__NumSeq_Delta_dY_min => -1;
  use constant MathImage__NumSeq_Delta_dDistSquared_min => 1;
}
{ package Math::PlanePath::Corner;
  use constant MathImage__NumSeq_Delta_dX_max => 1;
  use constant MathImage__NumSeq_Delta_dY_min => -1;
  use constant MathImage__NumSeq_Delta_dDistSquared_min => 1;
}
{ package Math::PlanePath::PyramidRows;
  use constant MathImage__NumSeq_Delta_dY_min => 0;
  use constant MathImage__NumSeq_Delta_dY_max => 1;
  use constant MathImage__NumSeq_Delta_dDistSquared_min => 1;
  sub MathImage__NumSeq_Delta_dDistSquared_max {
    my ($self) = @_;
    return ($self->{'step'} == 0
            ? 1    # X=0 vertical
            : undef);
  }

  # if step==0 then always north
  sub MathImage__NumSeq_Delta_ENWS_min {
    my ($self) = @_;
    return ($self->{'step'} > 0 ? 0 : 1);
  }
  sub MathImage__NumSeq_Delta_ENWS_max {
    my ($self) = @_;
    return ($self->{'step'} > 0 ? 3 : 1);
  }
}
{ package Math::PlanePath::PyramidSides;
  use constant MathImage__NumSeq_Delta_dX_max => 1;
  use constant MathImage__NumSeq_Delta_dY_min => -1;
  use constant MathImage__NumSeq_Delta_dY_max => 1;
  use constant MathImage__NumSeq_Delta_dDistSquared_min => 2;
}
{ package Math::PlanePath::CellularRule54;
  use constant MathImage__NumSeq_Delta_dX_max => 4;
  use constant MathImage__NumSeq_Delta_dY_min => 0;
  use constant MathImage__NumSeq_Delta_dY_max => 1;
  use constant MathImage__NumSeq_Delta_dDistSquared_min => 1;
}
{ package Math::PlanePath::CellularRule190;
  use constant MathImage__NumSeq_Delta_dX_max => 2;
  use constant MathImage__NumSeq_Delta_dY_min => 0;
  use constant MathImage__NumSeq_Delta_dY_max => 1;
  use constant MathImage__NumSeq_Delta_dDistSquared_min => 1;
}
{ package Math::PlanePath::CoprimeColumns;
  use constant MathImage__NumSeq_Delta_dX_min => 0;
  use constant MathImage__NumSeq_Delta_dX_max => 1;
  use constant MathImage__NumSeq_Delta_dY_max => 1;
  use constant MathImage__NumSeq_Delta_dDistSquared_min => 1;
}
{ package Math::PlanePath::DivisibleColumns;
  use constant MathImage__NumSeq_Delta_dX_min => 0;
  use constant MathImage__NumSeq_Delta_dX_max => 1;
  use constant MathImage__NumSeq_Delta_dY_max => 1;
  use constant MathImage__NumSeq_Delta_dDistSquared_min => 1;
}
# { package Math::PlanePath::File;
#   # FIXME: analyze points for dx/dy min/max etc
# }
{ package Math::PlanePath::MathImageQuintetCurve;
  sub MathImage__NumSeq_Delta_dX_min {
    my ($self) = @_;
    return ($self->{'arms'} == 1
            ? -1
            : undef);
  }
  sub MathImage__NumSeq_Delta_dX_max {
    my ($self) = @_;
    return ($self->{'arms'} == 1
            ? 1
            : undef);
  }
  sub MathImage__NumSeq_Delta_dY_min {
    my ($self) = @_;
    return ($self->{'arms'} == 1
            ? -1
            : undef);
  }
  sub MathImage__NumSeq_Delta_dY_max {
    my ($self) = @_;
    return ($self->{'arms'} == 1
            ? 1
            : undef);
  }
  sub MathImage__NumSeq_Delta_dDistSquared_min {
    my ($self) = @_;
    return ($self->{'arms'} == 1
            ? 1
            : undef);
  }
  sub MathImage__NumSeq_Delta_dDistSquared_max {
    my ($self) = @_;
    return ($self->{'arms'} == 1
            ? 1
            : undef);
  }
}
{ package Math::PlanePath::MathImageQuintetCentres;
  # inherit QuintetCurve, except
  sub MathImage__NumSeq_Delta_dDistSquared_max {
    my ($self) = @_;
    return ($self->{'arms'} == 1
            ? 2         # goes diagonally
            : undef);
  }
}
{ package Math::PlanePath::BetaOmega;    # NSEW
  use constant MathImage__NumSeq_Delta_dX_min => -1;
  use constant MathImage__NumSeq_Delta_dX_max => 1;
  use constant MathImage__NumSeq_Delta_dY_min => -1;
  use constant MathImage__NumSeq_Delta_dY_max => 1;
  use constant MathImage__NumSeq_Delta_dDistSquared_min => 1;
  use constant MathImage__NumSeq_Delta_dDistSquared_max => 1;
}
{ package Math::PlanePath::HIndexing;   # NSEW
  use constant MathImage__NumSeq_Delta_dX_min => -1;
  use constant MathImage__NumSeq_Delta_dX_max => 1;
  use constant MathImage__NumSeq_Delta_dY_min => -1;
  use constant MathImage__NumSeq_Delta_dY_max => 1;
  use constant MathImage__NumSeq_Delta_dDistSquared_min => 1;
  use constant MathImage__NumSeq_Delta_dDistSquared_max => 1;
}
{ package Math::PlanePath::DigitGroups;
  use constant MathImage__NumSeq_Delta_dDistSquared_min => 1;
}
{ package Math::PlanePath::CornerReplicate;
  use constant MathImage__NumSeq_Delta_dDistSquared_min => 1;
}
{ package Math::PlanePath::FibonacciWordFractal;  # NSEW
  use constant MathImage__NumSeq_Delta_dX_min => -1;
  use constant MathImage__NumSeq_Delta_dX_max => 1;
  use constant MathImage__NumSeq_Delta_dY_min => -1;
  use constant MathImage__NumSeq_Delta_dY_max => 1;
  use constant MathImage__NumSeq_Delta_dDistSquared_min => 1;
  use constant MathImage__NumSeq_Delta_dDistSquared_max => 1;
}

1;
__END__


sub pred {
  my ($self, $value) = @_;

  my $planepath_object = $self->{'planepath_object'};
  my $figure = $planepath_object->figure;
  if ($figure eq 'square') {
    if ($value != int($value)) {
      return 0;
    }
  } elsif ($figure eq 'circle') {
    return 1;
  }

  my $delta_type = $self->{'delta_type'};
  if ($delta_type eq 'X') {
    if ($planepath_object->x_negative) {
      return 1;
    } else {
      return ($value >= 0);
    }
  } elsif ($delta_type eq 'Y') {
    if ($planepath_object->y_negative) {
      return 1;
    } else {
      return ($value >= 0);
    }
  } elsif ($delta_type eq 'Sum') {
    if ($planepath_object->x_negative || $planepath_object->y_negative) {
      return 1;
    } else {
      return ($value >= 0);
    }
  } elsif ($delta_type eq 'SqRadius') {
    # FIXME: only sum of two squares, and for triangular same odd/even
    return ($value >= 0);
  }

  return undef;
}


=for stopwords Ryde 

=head1 NAME

App::MathImage::NumSeq::PlanePathDelta -- sequences of coordinates from PlanePath modules

=head1 SYNOPSIS

 use App::MathImage::NumSeq::PlanePathDelta;
 my $seq = App::MathImage::NumSeq::PlanePathDelta->new (planepath => 'SquareSpiral',
                                                   delta_type => 'dX');
 my ($i, $value) = $seq->next;

=head1 DESCRIPTION

This is a tie-in to present coordinate changes from a C<Math::PlanePath>
module as a NumSeq sequence.  The coordinate choices are

    "dX"         change in X coordinate
    "dY"         change in Y coordinate

=head1 FUNCTIONS

=over 4

=item C<$seq = App::MathImage::NumSeq::PlanePathDelta-E<gt>new (key=E<gt>value,...)>

Create and return a new sequence object.

=back

=head1 SEE ALSO

L<Math::NumSeq>,
L<Math::NumSeq::PlanePathCoord>

=cut

# Local variables:
# compile-command: "math-image --values=PlanePathDelta"
# End:
