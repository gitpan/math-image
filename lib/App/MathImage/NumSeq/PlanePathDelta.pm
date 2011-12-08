# "Dir8"     direction 0=E, 1=NE, 2=N, .., 6=S, 7=SE

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
$VERSION = 83;
use Math::NumSeq;
@ISA = ('Math::NumSeq');

use Math::NumSeq::PlanePathCoord;
*_planepath_oeis_key = \&Math::NumSeq::PlanePathCoord::_planepath_oeis_key;
*_planepath_name_to_object = \&Math::NumSeq::PlanePathCoord::_planepath_name_to_object;

# uncomment this to run the ### lines
#use Smart::Comments;


use constant characteristic_smaller => 1;
use constant description => Math::NumSeq::__('Delta from a PlanePath');

use constant::defer parameter_info_array =>
  sub {
    [ Math::NumSeq::PlanePathCoord::_parameter_info_planepath(),
      {
       name    => 'delta_type',
       display => Math::NumSeq::__('Delta Type'),
       type    => 'enum',
       default => 'dX',
       choices => ['dX','dY',
                   'Dir4',
                   # 'TDir6',
                   # 'Dist','DistSquared',
                   # 'Dir360','TDir360',
                  ],
       # description => Math::NumSeq::__(''),
      },
    ];
  };

my %oeis_anum
  = ('Math::PlanePath::HilbertCurve' =>
     {
      # A163540 is 0=east,1=south,2=west,3=north for drawing down the page,
      # which corresponds to 1=north,3=south per the HilbertCurve planepath
      Dir4 => 'A163540',
      # OEIS-Catalogue: A163540 planepath=HilbertCurve delta_type=Dir4

      # delta path(n)-path(n-1) starting i=0 with path(-1)=0 for first value 0
      # dX => 'A163538',
      # # OEIS-Catalogue: A163538 planepath=HilbertCurve delta_type=dX
      # dY => 'A163539',
      # # OEIS-Catalogue: A163539 planepath=HilbertCurve delta_type=dY
      #
      # cf A163541    absolute direction, transpose X,Y
      # would be N=0,E=1,S=2,W=3
     },

     'Math::PlanePath::PeanoCurve,radix=3' =>
     {
      # A163534 is 0=east,1=south,2=west,3=north treated as down the page,
      # which corrsponds to 1=north (incr Y), 3=south (decr Y) for
      # directions of the PeanoCurve planepath here
      Dir4 => 'A163534',
      # OEIS-Catalogue: A163534 planepath=PeanoCurve delta_type=Dir4

      # delta a(n)-a(n-1), so initial dx=0 at i=0 ...
      # dX => 'A163532',
      # # OEIS-Catalogue: A163532 planepath=PeanoCurve delta_type=dX
      # dY => 'A163533',
      # # OEIS-Catalogue: A163533 planepath=PeanoCurve delta_type=dY
     },
    );

sub oeis_anum {
  my ($self) = @_;
  return $oeis_anum{_planepath_oeis_key($self->{'planepath_object'})} -> {$self->{'delta_type'}};
}


sub new {
  my $class = shift;
  ### NumSeq-PlanePathDelta new(): @_
  my $self = $class->SUPER::new(@_);

  my $planepath_object = ($self->{'planepath_object'}
                          ||= _planepath_name_to_object($self->{'planepath'}));
  ### $planepath_object

  $self->{'delta_func'}
    = $self->can("_delta_func_$self->{'delta_type'}")
      || croak "Unrecognised delta_type: ",$self->{'delta_type'};

  $self->rewind;
  return $self;
}

sub i_start {
  my ($self) = @_;
  my $planepath_object = $self->{'planepath_object'} || return 0;
  return $planepath_object->n_start;
}
sub rewind {
  my ($self) = @_;
  my $planepath_object = $self->{'planepath_object'} || return;

  $self->{'i'} = $self->i_start;
  undef $self->{'x'};
  undef $self->{'y'};
  $self->{'arms_count'} = $planepath_object->arms_count;
}

sub next {
  my ($self) = @_;
  ### NumSeq-PlanePath next(): $self->{'i'}
  ### n_next: $self->{'n_next'}

  my $planepath_object = $self->{'planepath_object'};
  my $i = $self->{'i'}++;
  my $x = $self->{'x'};
  my $y;
  if (defined $x) {
    $y = $self->{'y'};
  } else {
    ($x, $y) = $planepath_object->n_to_xy ($i)
      or return;
  }

  my $arms_count = $self->{'arms_count'};
  my ($next_x, $next_y) = $planepath_object->n_to_xy($i + $arms_count)
    or return;
  my $ret = &{$self->{'delta_func'}}($x,$y, $next_x,$next_y);

  if ($arms_count == 1) {
    $self->{'x'} = $next_x;
    $self->{'y'} = $next_y;
  }
  return ($i, $ret);
}

sub ith {
  my ($self, $i) = @_;
  ### NumSeq-PlanePath ith(): $i

  my $planepath_object = $self->{'planepath_object'};
  my ($x, $y) = $planepath_object->n_to_xy ($i)
    or return undef;
  my ($next_x, $next_y) = $planepath_object->n_to_xy ($i + $self->{'arms_count'})
    or return undef;
  return &{$self->{'delta_func'}}($x,$y, $next_x,$next_y);
}

sub _delta_func_dX {
  my ($x,$y, $next_x,$next_y) = @_;
  ### _delta_func_dX() ...
  return $next_x - $x;
}
sub _delta_func_dY {
  my ($x,$y, $next_x,$next_y) = @_;
  ### _delta_func_dY() ...
  return $next_y - $y;
}
sub _delta_func_Dist {
  return sqrt(_delta_func_DistSquared(@_));
}
sub _delta_func_DistSquared {
  my ($x,$y, $next_x,$next_y) = @_;
  $x -= $next_x;
  $y -= $next_y;
  return $x*$x + $y*$y;
}

sub _delta_func_Dir4 {
  my ($x,$y, $next_x,$next_y) = @_;
  ### _delta_func_Dir4(): "$x,$y,  $next_x,$next_y"

  return _delta_func_Dir360($x,$y, $next_x,$next_y) / 90;
}
sub _delta_func_TDir6 {
  my ($x,$y, $next_x,$next_y) = @_;
  ### _delta_func_TDir6(): "$x,$y,  $next_x,$next_y"

  return _delta_func_TDir360($x,$y, $next_x,$next_y) / 60;
}
sub _delta_func_Dir8 {
  my ($x,$y, $next_x,$next_y) = @_;
  return _delta_func_Dir360($x,$y, $next_x,$next_y) / 45;
}

use constant 1.02; # for leading underscore
use constant _PI => 4 * atan2(1,1);  # similar to Math::Complex

sub _delta_func_Dir360 {
  my ($x,$y, $next_x,$next_y) = @_;
  ### _delta_func_Dir360(): "$x,$y,  $next_x,$next_y"

  my $dx = $next_x - $x;
  my $dy = $next_y - $y;
  ### dxdy: "$dx $dy"

  if ($dy == 0) {
    return ($dx >= 0 ? 0 : 180);
  }
  if ($dx == 0) {
    return ($dy > 0 ? 90 : 270);
  }
  if ($dx > 0) {
    if ($dx == $dy) { return 45; }
    if ($dx == -$dy) { return 315; }
  } else {
    if ($dx == $dy) { return 270; }
    if ($dx == -$dy) { return 135; }
  }

  # Crib: atan2() returns -PI <= a <= PI, and is supposedly "not well
  # defined", though glibc gives 0
  #
  if ($dx == 0 && $dy == 0) {
    return 0;
  }
  my $degrees = atan2($dy,$dx) * 180 / _PI;
  return ($degrees < 0 ? $degrees + 360 : $degrees);
}

sub _delta_func_TDir360 {
  my ($x,$y, $next_x,$next_y) = @_;
  ### _delta_func_TDir360(): "$x,$y,  $next_x,$next_y"

  my $dx = $next_x - $x;
  my $dy = $next_y - $y;
  ### dxdy: "$dx $dy"

  if ($dy == 0) {
    return ($dx >= 0 ? 0 : 180);
  }
  if ($dx == 0) {
    return ($dy > 0 ? 90 : 270);
  }
  if ($dx > 0) {
    if ($dx == 3*$dy) { return 30; }
    if ($dx == $dy) { return 60; }
    if ($dx == -$dy) { return 300; }
    if ($dx == -3*$dy) { return 330; }
  } else {
    if ($dx == -$dy) { return 120; }
    if ($dx == -3*$dy) { return 150; }
    if ($dx == 3*$dy) { return 210; }
    if ($dx == $dy) { return 240; }
  }

  # Crib: atan2() returns -PI <= a <= PI, and is supposedly "not well
  # defined", though glibc gives 0
  #
  if ($dx == 0 && $dy == 0) {
    return 0;
  }
  my $degrees = atan2($dy*sqrt(3),$dx) * (180 / _PI);  # -180 to +180
  return ($degrees < 0 ? $degrees + 360 : $degrees);
}


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
  use constant MathImage__NumSeq_Delta_dX_max => undef;
  # 
  # use constant MathImage__NumSeq_Delta_dY_min => undef;
  use constant MathImage__NumSeq_Delta_dY_max => undef;

  sub MathImage__NumSeq_Delta_Dist_min {
    my ($self) = @_;
    sqrt($self->MathImage__NumSeq_Delta_DistSquared_min);
  }
  sub MathImage__NumSeq_Delta_Dist_max {
    my ($self) = @_;
    my $max;
    return (defined ($max = $self->MathImage__NumSeq_Delta_DistSquared_max)
            ? sqrt($max)
            : undef);
  }
  use constant MathImage__NumSeq_Delta_DistSquared_min => 0;
  sub MathImage__NumSeq_Delta_DistSquared_max {
    my ($self) = @_;
    if (defined (my $dx = $self->MathImage__NumSeq_Delta_dX_max)
        && defined (my $dy = $self->MathImage__NumSeq_Delta_dY_max)) {
      return $dx*$dx + $dy*$dy;
    }
    return undef;
  }
    
  use constant MathImage__NumSeq_Delta_Dir4_min => 0;
  use constant MathImage__NumSeq_Delta_Dir4_max => 3;

  use constant MathImage__NumSeq_Delta_Dir8_min => 0;
  use constant MathImage__NumSeq_Delta_Dir8_max => 7;

  use constant MathImage__NumSeq_Delta_TDir6_min => 0;
  use constant MathImage__NumSeq_Delta_TDir6_max => 5;

  use constant MathImage__NumSeq_Delta_Dir360_min => 0;
  use constant MathImage__NumSeq_Delta_Dir360_max => 360;
}

{ package Math::PlanePath::SquareSpiral;
  use constant MathImage__NumSeq_Delta_dX_min => -1;
  use constant MathImage__NumSeq_Delta_dX_max => 1;
  use constant MathImage__NumSeq_Delta_dY_min => -1;
  use constant MathImage__NumSeq_Delta_dY_max => 1;
  use constant MathImage__NumSeq_Delta_DistSquared_min => 1;
  use constant MathImage__NumSeq_Delta_DistSquared_max => 1;
}
{ package Math::PlanePath::PyramidSpiral;
  use constant MathImage__NumSeq_Delta_dX_min => -1;
  use constant MathImage__NumSeq_Delta_dX_max => 1;
  use constant MathImage__NumSeq_Delta_dY_min => -1;
  use constant MathImage__NumSeq_Delta_dY_max => 1;
  use constant MathImage__NumSeq_Delta_DistSquared_min => 1;
  use constant MathImage__NumSeq_Delta_DistSquared_max => 2;
}
{ package Math::PlanePath::TriangleSpiral;
  use constant MathImage__NumSeq_Delta_dX_min => -1;
  use constant MathImage__NumSeq_Delta_dX_max => 2;
  use constant MathImage__NumSeq_Delta_dY_min => -1;
  use constant MathImage__NumSeq_Delta_dY_max => 1;
  use constant MathImage__NumSeq_Delta_DistSquared_min => 2;
  use constant MathImage__NumSeq_Delta_DistSquared_max => 4;
}
{ package Math::PlanePath::TriangleSpiralSkewed;
  use constant MathImage__NumSeq_Delta_dX_min => -1;
  use constant MathImage__NumSeq_Delta_dX_max => 1;
  use constant MathImage__NumSeq_Delta_dY_min => -1;
  use constant MathImage__NumSeq_Delta_dY_max => 1;
  use constant MathImage__NumSeq_Delta_DistSquared_min => 1;
  use constant MathImage__NumSeq_Delta_DistSquared_max => 2;
}
{ package Math::PlanePath::DiamondSpiral;
  use constant MathImage__NumSeq_Delta_dX_min => -1;
  use constant MathImage__NumSeq_Delta_dX_max => 1;
  use constant MathImage__NumSeq_Delta_dY_min => -1;
  use constant MathImage__NumSeq_Delta_dY_max => 1;
  use constant MathImage__NumSeq_Delta_DistSquared_min => 1;
  use constant MathImage__NumSeq_Delta_DistSquared_max => 2;
}
{ package Math::PlanePath::PentSpiralSkewed;
  use constant MathImage__NumSeq_Delta_dX_min => -1;
  use constant MathImage__NumSeq_Delta_dX_max => 1;
  use constant MathImage__NumSeq_Delta_dY_min => -1;
  use constant MathImage__NumSeq_Delta_dY_max => 1;
  use constant MathImage__NumSeq_Delta_DistSquared_min => 1;
  use constant MathImage__NumSeq_Delta_DistSquared_max => 2;
}
{ package Math::PlanePath::HexSpiral;
  use constant MathImage__NumSeq_Delta_dX_min => -2;
  use constant MathImage__NumSeq_Delta_dX_max => 2;
  use constant MathImage__NumSeq_Delta_dY_min => -1;
  use constant MathImage__NumSeq_Delta_dY_max => 1;
  use constant MathImage__NumSeq_Delta_DistSquared_min => 2;
  use constant MathImage__NumSeq_Delta_DistSquared_max => 4;
}
{ package Math::PlanePath::HexSpiralSkewed;
  use constant MathImage__NumSeq_Delta_dX_min => -1;
  use constant MathImage__NumSeq_Delta_dX_max => 1;
  use constant MathImage__NumSeq_Delta_dY_min => -1;
  use constant MathImage__NumSeq_Delta_dY_max => 1;
  use constant MathImage__NumSeq_Delta_DistSquared_min => 1;
  use constant MathImage__NumSeq_Delta_DistSquared_max => 2;
}
{ package Math::PlanePath::HeptSpiralSkewed;
  use constant MathImage__NumSeq_Delta_dX_min => -1;
  use constant MathImage__NumSeq_Delta_dX_max => 1;
  use constant MathImage__NumSeq_Delta_dY_min => -1;
  use constant MathImage__NumSeq_Delta_dY_max => 1;
  use constant MathImage__NumSeq_Delta_DistSquared_min => 1;
  use constant MathImage__NumSeq_Delta_DistSquared_max => 2;
}
{ package Math::PlanePath::OctagramSpiral;
  use constant MathImage__NumSeq_Delta_dX_min => -1;
  use constant MathImage__NumSeq_Delta_dX_max => 1;
  use constant MathImage__NumSeq_Delta_dY_min => -1;
  use constant MathImage__NumSeq_Delta_dY_max => 1;
  use constant MathImage__NumSeq_Delta_DistSquared_min => 1;
  use constant MathImage__NumSeq_Delta_DistSquared_max => 2;
}
{ package Math::PlanePath::KnightSpiral;
  use constant MathImage__NumSeq_Delta_dX_min => -2;
  use constant MathImage__NumSeq_Delta_dX_max => 2;
  use constant MathImage__NumSeq_Delta_dY_min => -2;
  use constant MathImage__NumSeq_Delta_dY_max => 2;
  use constant MathImage__NumSeq_Delta_DistSquared_min => 5;
  use constant MathImage__NumSeq_Delta_DistSquared_max => 5;
}
{ package Math::PlanePath::SquareArms;  # NSEW
  use constant MathImage__NumSeq_Delta_dX_min => -1;
  use constant MathImage__NumSeq_Delta_dX_max => 1;
  use constant MathImage__NumSeq_Delta_dY_min => -1;
  use constant MathImage__NumSeq_Delta_dY_max => 1;
  use constant MathImage__NumSeq_Delta_DistSquared_min => 1;
  use constant MathImage__NumSeq_Delta_DistSquared_max => 1;
}
{ package Math::PlanePath::DiamondArms;  # diag always
  use constant MathImage__NumSeq_Delta_dX_min => -1;
  use constant MathImage__NumSeq_Delta_dX_max => 1;
  use constant MathImage__NumSeq_Delta_dY_min => -1;
  use constant MathImage__NumSeq_Delta_dY_max => 1;
  use constant MathImage__NumSeq_Delta_DistSquared_min => 2;
  use constant MathImage__NumSeq_Delta_DistSquared_max => 2;
}
{ package Math::PlanePath::HexArms;
  use constant MathImage__NumSeq_Delta_dX_min => -2;
  use constant MathImage__NumSeq_Delta_dX_max => 2;
  use constant MathImage__NumSeq_Delta_dY_min => -1;
  use constant MathImage__NumSeq_Delta_dY_max => 1;
  use constant MathImage__NumSeq_Delta_DistSquared_min => 2;
  use constant MathImage__NumSeq_Delta_DistSquared_max => 4;
}
{ package Math::PlanePath::GreekKeySpiral;
  use constant MathImage__NumSeq_Delta_dX_min => -1;
  use constant MathImage__NumSeq_Delta_dX_max => 1;
  use constant MathImage__NumSeq_Delta_dY_min => -1;
  use constant MathImage__NumSeq_Delta_dY_max => 1;
  use constant MathImage__NumSeq_Delta_DistSquared_min => 1;
  use constant MathImage__NumSeq_Delta_DistSquared_max => 1;
}
{ package Math::PlanePath::SacksSpiral;
  use constant MathImage__NumSeq_Delta_DistSquared_min => 1;
}
# { package Math::PlanePath::VogelFloret;
# }
{ package Math::PlanePath::TheodorusSpiral;
  use constant MathImage__NumSeq_Delta_dX_min => -1;
  use constant MathImage__NumSeq_Delta_dX_max => 1;
  use constant MathImage__NumSeq_Delta_dY_min => -1;
  use constant MathImage__NumSeq_Delta_dY_max => 1;
  use constant MathImage__NumSeq_Delta_DistSquared_min => 1;
  use constant MathImage__NumSeq_Delta_DistSquared_max => 1;
}
{ package Math::PlanePath::ArchimedeanChords;
  use constant MathImage__NumSeq_Delta_dX_min => -1;
  use constant MathImage__NumSeq_Delta_dX_max => 1;
  use constant MathImage__NumSeq_Delta_dY_min => -1;
  use constant MathImage__NumSeq_Delta_dY_max => 1;
  use constant MathImage__NumSeq_Delta_DistSquared_min => 1;
  use constant MathImage__NumSeq_Delta_DistSquared_max => 1;
}
{ package Math::PlanePath::MultipleRings;
  use constant MathImage__NumSeq_Delta_dX_min => -1;
  use constant MathImage__NumSeq_Delta_dY_min => -1;
  use constant MathImage__NumSeq_Delta_dY_max => 1;
  use constant MathImage__NumSeq_Delta_DistSquared_min => 1;
  use constant MathImage__NumSeq_Delta_DistSquared_max => 1;
  # FIXME: DistSquared bit bigger actually
}
{ package Math::PlanePath::PixelRings;
  use constant MathImage__NumSeq_Delta_dX_min => -1;
  use constant MathImage__NumSeq_Delta_dX_max => 1;
  use constant MathImage__NumSeq_Delta_dY_min => -1;
  use constant MathImage__NumSeq_Delta_dY_max => 1;
  use constant MathImage__NumSeq_Delta_DistSquared_min => 1;
  use constant MathImage__NumSeq_Delta_DistSquared_max => 2;
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
  sub MathImage__NumSeq_Delta_DistSquared_min {
    my ($self) = @_;
    return ($self->{'radix'} % 2
            ? 1
            : undef);
  }
  sub MathImage__NumSeq_Delta_DistSquared_max {
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
  use constant MathImage__NumSeq_Delta_DistSquared_min => 1;
  use constant MathImage__NumSeq_Delta_DistSquared_max => 1;
}
{ package Math::PlanePath::HilbertSpiral;
  use constant MathImage__NumSeq_Delta_dX_min => -1;
  use constant MathImage__NumSeq_Delta_dX_max => 1;
  use constant MathImage__NumSeq_Delta_dY_min => -1;
  use constant MathImage__NumSeq_Delta_dY_max => 1;
  use constant MathImage__NumSeq_Delta_DistSquared_min => 1;
  use constant MathImage__NumSeq_Delta_DistSquared_max => 1;
}
{ package Math::PlanePath::ZOrderCurve;
  use constant MathImage__NumSeq_Delta_dX_max => 1;
  use constant MathImage__NumSeq_Delta_dY_max => 1;
  use constant MathImage__NumSeq_Delta_DistSquared_min => 1;
}
# { package Math::PlanePath::ImaginaryBase;
# }
# { package Math::PlanePath::Flowsnake;
#   # inherit from FlowsnakeCentres
# }
{ package Math::PlanePath::FlowsnakeCentres;
  use constant MathImage__NumSeq_Delta_dX_min => -2;
  use constant MathImage__NumSeq_Delta_dX_max => 2;
  use constant MathImage__NumSeq_Delta_dY_min => -1;
  use constant MathImage__NumSeq_Delta_dY_max => 1;
  use constant MathImage__NumSeq_Delta_DistSquared_min => 2;
  use constant MathImage__NumSeq_Delta_DistSquared_max => 4;
}
{ package Math::PlanePath::GosperIslands;
  use constant MathImage__NumSeq_Delta_DistSquared_min => 2;
}
{ package Math::PlanePath::GosperSide;
  use constant MathImage__NumSeq_Delta_dX_min => -2;
  use constant MathImage__NumSeq_Delta_dX_max => 2;
  use constant MathImage__NumSeq_Delta_dY_min => -1;
  use constant MathImage__NumSeq_Delta_dY_max => 1;
  use constant MathImage__NumSeq_Delta_DistSquared_min => 2;
  use constant MathImage__NumSeq_Delta_DistSquared_max => 4;
}

{ package Math::PlanePath::KochCurve;
  use constant MathImage__NumSeq_Delta_dX_min => -2;
  use constant MathImage__NumSeq_Delta_dX_max => 2;
  use constant MathImage__NumSeq_Delta_dY_min => -1;
  use constant MathImage__NumSeq_Delta_dY_max => 1;
  use constant MathImage__NumSeq_Delta_DistSquared_min => 2;
  use constant MathImage__NumSeq_Delta_DistSquared_max => 4;
}
{ package Math::PlanePath::KochPeaks;
  use constant MathImage__NumSeq_Delta_dX_max => 2;
  use constant MathImage__NumSeq_Delta_dY_max => 1;
  use constant MathImage__NumSeq_Delta_DistSquared_min => 2;
}
{ package Math::PlanePath::KochSnowflakes;
  use constant MathImage__NumSeq_Delta_dX_min => 1;
  use constant MathImage__NumSeq_Delta_DistSquared_min => 2;
}
{ package Math::PlanePath::KochSquareflakes;
  use constant MathImage__NumSeq_Delta_dX_max => 1;
  use constant MathImage__NumSeq_Delta_dY_max => 1;
  use constant MathImage__NumSeq_Delta_DistSquared_min => 1;
}

{ package Math::PlanePath::QuadricCurve;
  use constant MathImage__NumSeq_Delta_dX_min => -1;
  use constant MathImage__NumSeq_Delta_dX_max => 1;
  use constant MathImage__NumSeq_Delta_dY_min => -1;
  use constant MathImage__NumSeq_Delta_dY_max => 1;
  use constant MathImage__NumSeq_Delta_DistSquared_min => 1;
}
{ package Math::PlanePath::QuadricIslands;
  use constant MathImage__NumSeq_Delta_dX_max => 1;
  use constant MathImage__NumSeq_Delta_dY_max => 1;
  use constant MathImage__NumSeq_Delta_DistSquared_min => 1;
}

{ package Math::PlanePath::SierpinskiTriangle;
  use constant MathImage__NumSeq_Delta_dY_min => 0;
  use constant MathImage__NumSeq_Delta_dY_max => 1;
  use constant MathImage__NumSeq_Delta_DistSquared_min => 2;
}
{ package Math::PlanePath::SierpinskiArrowhead;
  use constant MathImage__NumSeq_Delta_dX_min => -2;
  use constant MathImage__NumSeq_Delta_dX_max => 2;
  use constant MathImage__NumSeq_Delta_dY_min => -1;
  use constant MathImage__NumSeq_Delta_dY_max => 1;
  use constant MathImage__NumSeq_Delta_DistSquared_min => 2;
  use constant MathImage__NumSeq_Delta_DistSquared_max => 4;
}
{ package Math::PlanePath::SierpinskiArrowheadCentres;
  use constant MathImage__NumSeq_Delta_dX_min => -2;
  use constant MathImage__NumSeq_Delta_dX_max => 2;
  use constant MathImage__NumSeq_Delta_dY_min => -1;
  use constant MathImage__NumSeq_Delta_dY_max => 1;
  use constant MathImage__NumSeq_Delta_DistSquared_min => 2;
  use constant MathImage__NumSeq_Delta_DistSquared_max => 4;
}

{ package Math::PlanePath::DragonCurve;
  use constant MathImage__NumSeq_Delta_dX_min => -1;
  use constant MathImage__NumSeq_Delta_dX_max => 1;
  use constant MathImage__NumSeq_Delta_dY_min => -1;
  use constant MathImage__NumSeq_Delta_dY_max => 1;
  use constant MathImage__NumSeq_Delta_DistSquared_min => 1;
  use constant MathImage__NumSeq_Delta_DistSquared_max => 1;
}
{ package Math::PlanePath::DragonRounded;
  use constant MathImage__NumSeq_Delta_dX_min => -1;
  use constant MathImage__NumSeq_Delta_dX_max => 1;
  use constant MathImage__NumSeq_Delta_dY_min => -1;
  use constant MathImage__NumSeq_Delta_dY_max => 1;
  use constant MathImage__NumSeq_Delta_DistSquared_min => 1;
  use constant MathImage__NumSeq_Delta_DistSquared_max => 2;
}
{ package Math::PlanePath::DragonMidpoint;
  use constant MathImage__NumSeq_Delta_dX_min => -1;
  use constant MathImage__NumSeq_Delta_dX_max => 1;
  use constant MathImage__NumSeq_Delta_dY_min => -1;
  use constant MathImage__NumSeq_Delta_dY_max => 1;
  use constant MathImage__NumSeq_Delta_DistSquared_min => 1;
  use constant MathImage__NumSeq_Delta_DistSquared_max => 1;
}
{ package Math::PlanePath::ComplexMinus;
  use constant MathImage__NumSeq_Delta_DistSquared_min => 1;
}
{ package Math::PlanePath::Rows;
  sub MathImage__NumSeq_Delta_dX_min {
    my ($self) = @_;
    return - ($self->{'width'}-1);
  }
  use constant MathImage__NumSeq_Delta_dX_max => 1;
  use constant MathImage__NumSeq_Delta_dY_min => 0;
  use constant MathImage__NumSeq_Delta_dY_max => 1;
  use constant MathImage__NumSeq_Delta_DistSquared_min => 1;
}
{ package Math::PlanePath::Columns;
  use constant MathImage__NumSeq_Delta_dX_min => 0;
  use constant MathImage__NumSeq_Delta_dX_max => 1;
  sub MathImage__NumSeq_Delta_dY_min {
    my ($self) = @_;
    return 1 - $self->{'height'};
  }
  use constant MathImage__NumSeq_Delta_dY_max => 1;
  use constant MathImage__NumSeq_Delta_DistSquared_min => 1;
}
{ package Math::PlanePath::Diagonals;
  use constant MathImage__NumSeq_Delta_dX_max => 1;
  use constant MathImage__NumSeq_Delta_dY_min => -1;
  use constant MathImage__NumSeq_Delta_DistSquared_min => 2;
}
{ package Math::PlanePath::DiagonalsAlternating;
  use constant MathImage__NumSeq_Delta_dX_min => -1;
  use constant MathImage__NumSeq_Delta_dX_max => 1;
  use constant MathImage__NumSeq_Delta_dY_min => -1;
  use constant MathImage__NumSeq_Delta_dY_max => 1;
  use constant MathImage__NumSeq_Delta_DistSquared_min => 1;
  use constant MathImage__NumSeq_Delta_DistSquared_max => 2;
}
{ package Math::PlanePath::Staircase;
  use constant MathImage__NumSeq_Delta_dX_max => 1;
  use constant MathImage__NumSeq_Delta_dY_min => -1;
  use constant MathImage__NumSeq_Delta_DistSquared_min => 1;
}
{ package Math::PlanePath::Corner;
  use constant MathImage__NumSeq_Delta_dX_max => 1;
  use constant MathImage__NumSeq_Delta_dY_min => -1;
  use constant MathImage__NumSeq_Delta_DistSquared_min => 1;
}
{ package Math::PlanePath::PyramidRows;
  use constant MathImage__NumSeq_Delta_dY_min => 0;
  use constant MathImage__NumSeq_Delta_dY_max => 1;
  use constant MathImage__NumSeq_Delta_DistSquared_min => 1;
  sub MathImage__NumSeq_Delta_DistSquared_max {
    my ($self) = @_;
    return ($self->{'step'} == 0
            ? 1    # X=0 vertical
            : undef);
  }

  # if step==0 then always north
  sub MathImage__NumSeq_Delta_Dir4_min {
    my ($self) = @_;
    return ($self->{'step'} > 0 ? 0 : 1);
  }
  sub MathImage__NumSeq_Delta_Dir4_max {
    my ($self) = @_;
    return ($self->{'step'} > 0 ? 3 : 1);
  }
}
{ package Math::PlanePath::PyramidSides;
  use constant MathImage__NumSeq_Delta_dX_max => 1;
  use constant MathImage__NumSeq_Delta_dY_min => -1;
  use constant MathImage__NumSeq_Delta_dY_max => 1;
  use constant MathImage__NumSeq_Delta_DistSquared_min => 2;
}
{ package Math::PlanePath::CellularRule54;
  use constant MathImage__NumSeq_Delta_dX_max => 4;
  use constant MathImage__NumSeq_Delta_dY_min => 0;
  use constant MathImage__NumSeq_Delta_dY_max => 1;
  use constant MathImage__NumSeq_Delta_DistSquared_min => 1;
}
{ package Math::PlanePath::CellularRule190;
  use constant MathImage__NumSeq_Delta_dX_max => 2;
  use constant MathImage__NumSeq_Delta_dY_min => 0;
  use constant MathImage__NumSeq_Delta_dY_max => 1;
  use constant MathImage__NumSeq_Delta_DistSquared_min => 1;
}
{ package Math::PlanePath::CoprimeColumns;
  use constant MathImage__NumSeq_Delta_dX_min => 0;
  use constant MathImage__NumSeq_Delta_dX_max => 1;
  use constant MathImage__NumSeq_Delta_dY_max => 1;
  use constant MathImage__NumSeq_Delta_DistSquared_min => 1;
}
{ package Math::PlanePath::DivisibleColumns;
  use constant MathImage__NumSeq_Delta_dX_min => 0;
  use constant MathImage__NumSeq_Delta_dX_max => 1;
  use constant MathImage__NumSeq_Delta_dY_max => 1;
  use constant MathImage__NumSeq_Delta_DistSquared_min => 1;
}
# { package Math::PlanePath::File;
#   # FIXME: analyze points for dx/dy min/max etc
# }
{ package Math::PlanePath::QuintetCurve;  # NSEW
  # inherit QuintetCentres, except
  use constant MathImage__NumSeq_Delta_DistSquared_max => 1;
}
{ package Math::PlanePath::QuintetCentres;  # NSEW+diag
  use constant MathImage__NumSeq_Delta_dX_min => -1;
  use constant MathImage__NumSeq_Delta_dX_max => 1;
  use constant MathImage__NumSeq_Delta_dY_min => -1;
  use constant MathImage__NumSeq_Delta_dY_max => 1;
  use constant MathImage__NumSeq_Delta_DistSquared_min => 1;
  use constant MathImage__NumSeq_Delta_DistSquared_max => 2;
}
{ package Math::PlanePath::BetaOmega;    # NSEW
  use constant MathImage__NumSeq_Delta_dX_min => -1;
  use constant MathImage__NumSeq_Delta_dX_max => 1;
  use constant MathImage__NumSeq_Delta_dY_min => -1;
  use constant MathImage__NumSeq_Delta_dY_max => 1;
  use constant MathImage__NumSeq_Delta_DistSquared_min => 1;
  use constant MathImage__NumSeq_Delta_DistSquared_max => 1;
}
{ package Math::PlanePath::CincoCurve;    # NSEW
  use constant MathImage__NumSeq_Delta_dX_min => -1;
  use constant MathImage__NumSeq_Delta_dX_max => 1;
  use constant MathImage__NumSeq_Delta_dY_min => -1;
  use constant MathImage__NumSeq_Delta_dY_max => 1;
  use constant MathImage__NumSeq_Delta_DistSquared_min => 1;
  use constant MathImage__NumSeq_Delta_DistSquared_max => 1;
}
{ package Math::PlanePath::HIndexing;   # NSEW
  use constant MathImage__NumSeq_Delta_dX_min => -1;
  use constant MathImage__NumSeq_Delta_dX_max => 1;
  use constant MathImage__NumSeq_Delta_dY_min => -1;
  use constant MathImage__NumSeq_Delta_dY_max => 1;
  use constant MathImage__NumSeq_Delta_DistSquared_min => 1;
  use constant MathImage__NumSeq_Delta_DistSquared_max => 1;
}
{ package Math::PlanePath::DigitGroups;
  use constant MathImage__NumSeq_Delta_DistSquared_min => 1;
}
{ package Math::PlanePath::CornerReplicate;
  use constant MathImage__NumSeq_Delta_DistSquared_min => 1;
}
{ package Math::PlanePath::FibonacciWordFractal;  # NSEW
  use constant MathImage__NumSeq_Delta_dX_min => -1;
  use constant MathImage__NumSeq_Delta_dX_max => 1;
  use constant MathImage__NumSeq_Delta_dY_min => -1;
  use constant MathImage__NumSeq_Delta_dY_max => 1;
  use constant MathImage__NumSeq_Delta_DistSquared_min => 1;
  use constant MathImage__NumSeq_Delta_DistSquared_max => 1;
}
{ package Math::PlanePath::LTiling;  # NSEW
  use constant MathImage__NumSeq_Delta_dX_min => -1;
  use constant MathImage__NumSeq_Delta_dX_max => 1;
  use constant MathImage__NumSeq_Delta_dY_min => -1;
  use constant MathImage__NumSeq_Delta_dY_max => 1;
  # bigger minimum distance ?
  use constant MathImage__NumSeq_Delta_DistSquared_min => 1;
}

1;
__END__


# sub pred {
#   my ($self, $value) = @_;
# 
#   my $planepath_object = $self->{'planepath_object'};
#   my $figure = $planepath_object->figure;
#   if ($figure eq 'square') {
#     if ($value != int($value)) {
#       return 0;
#     }
#   } elsif ($figure eq 'circle') {
#     return 1;
#   }
# 
#   my $delta_type = $self->{'delta_type'};
#   if ($delta_type eq 'X') {
#     if ($planepath_object->x_negative) {
#       return 1;
#     } else {
#       return ($value >= 0);
#     }
#   } elsif ($delta_type eq 'Y') {
#     if ($planepath_object->y_negative) {
#       return 1;
#     } else {
#       return ($value >= 0);
#     }
#   } elsif ($delta_type eq 'Sum') {
#     if ($planepath_object->x_negative || $planepath_object->y_negative) {
#       return 1;
#     } else {
#       return ($value >= 0);
#     }
#   } elsif ($delta_type eq 'SqRadius') {
#     # FIXME: only sum of two squares, and for triangular same odd/even
#     return ($value >= 0);
#   }
# 
#   return undef;
# }


=for stopwords Ryde 

=head1 NAME

App::MathImage::NumSeq::PlanePathDelta -- sequence of changes in PlanePath X,Y coordinates

=head1 SYNOPSIS

 use App::MathImage::NumSeq::PlanePathDelta;
 my $seq = App::MathImage::NumSeq::PlanePathDelta->new (planepath => 'SquareSpiral',
                                                  delta_type => 'dX');
 my ($i, $value) = $seq->next;

=head1 DESCRIPTION

This is a tie-in to present coordinate changes from a C<Math::PlanePath>
module in the form of a NumSeq sequence.

The C<delta_type> choices are

    "dX"       change in X coordinate
    "dY"       change in Y coordinate
    "Dir4"     direction 0=East, 1=North, 2=West, 3=South

In each case the value at i in the sequence is the change from N=i to N=i+1
on the path, or from N=i to N=i+arms for paths with multiple "arms", thus
following a particular arm.  i values start from the usual path
C<n_start()>.

"Dir4" is a fraction when a delta is in between the cardinal directions.
For example North-West dX=-1,dY=+1 would be 1.5.

=head1 FUNCTIONS

=over 4

=item C<$seq = App::MathImage::NumSeq::PlanePathDelta-E<gt>new (key=E<gt>value,...)>

Create and return a new sequence object.

=back

=head1 SEE ALSO

L<Math::NumSeq>,
L<Math::NumSeq::PlanePathCoord>

L<Math::PlanePath>

=cut

# Local variables:
# compile-command: "math-image --values=PlanePathDelta"
# End:
