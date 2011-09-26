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


package App::MathImage::NumSeq::PlanePath;
use 5.004;
use strict;
use Carp;

use vars '$VERSION','@ISA';
$VERSION = 72;
use Math::NumSeq;
@ISA = ('Math::NumSeq');


# uncomment this to run the ### lines
#use Devel::Comments;

use constant characteristic_smaller => 1;
use constant characteristic_monotonic => 0;
use constant description => Math::NumSeq::__('Step directions in a PlanePath');

use constant::defer parameter_info_array =>
  sub {
    require Module::Util;
    my $width = 0;
    # cf App::MathImage::Generator->path_choices() order
    my @choices = sort map { s/.*:://;
                             if (length() > $width) { $width = length() }
                             $_ }
      Module::Util::find_in_namespace('Math::PlanePath');
    ### @choices
    [
     { name    => 'planepath',
       display => Math::NumSeq::__('PlanePath Class'),
       type    => 'string',
       default => 'SquareSpiral',
       choices => \@choices,
       width   => 5 + $width,
       # description => Math::NumSeq::__(''),
     },
     { name    => 'coord_type',
       display => Math::NumSeq::__('Delta Type'),
       type    => 'enum',
       default => 'X',
       choices => ['X','Y','Sum','Radius','RSquared',
                   'dX','dY','dDist','dSquared',
                   'ENSW'],
       # description => Math::NumSeq::__(''),
     },
    ]
  };

my %oeis_anum
  = ('Math::PlanePath::HilbertCurve' =>
     { Y => 'A059252',
       # OEIS-Catalogue: A059252 planepath=HilbertCurve coord_type=Y

       X => 'A059253',
       # OEIS-Catalogue: A059253 planepath=HilbertCurve coord_type=X

       dX => 'A059252',
       # OEIS-Catalogue: A163538 planepath=HilbertCurve coord_type=dX

       dY => 'A059252',
       # OEIS-Catalogue: A163539 planepath=HilbertCurve coord_type=dY
     },

     'Math::PlanePath::PeanoCurve,radix=3' =>
     { X => 'A163528',
       # OEIS-Catalogue: A163528 planepath=PeanoCurve coord_type=X

       Y => 'A163529',
       # OEIS-Catalogue: A163529 planepath=PeanoCurve coord_type=Y

       dX => 'A163532',
       # OEIS-Catalogue: A163532 planepath=PeanoCurve coord_type=x

       dY => 'A163533',
       # OEIS-Catalogue: A163533 planepath=PeanoCurve coord_type=y

       Sum => 'A16353',
       # OEIS-Catalogue: A163530 planepath=PeanoCurve coord_type=Sum

       SqDist => 'A163531',
       # OEIS-Catalogue: A163531 planepath=PeanoCurve coord_type=SqDist
     },
    );

sub oeis_anum {
  my ($self) = @_;
  ### oeis_anum() ...
  my $planepath_object = $self->{'planepath_object'};
  return $oeis_anum{ref($planepath_object)
                    . join(',',
                           map {
                             my $value = $planepath_object->{$_->{'name'}};
                             (defined $value ? "$_->{'name'}=$value"
                              : ())
                           }
                           $planepath_object->parameter_info_list)
                   }->{$self->{'coord_type'}};
}

sub values_min {
  my ($self) = @_;

  my $planepath_object = $self->{'planepath_object'};
  my $coord_type = $self->{'coord_type'};

  if ($coord_type eq 'X') {
    if (! $planepath_object->x_negative) {
      return 0;
    }

  } elsif ($coord_type eq 'Y') {
    if (! $planepath_object->y_negative) {
      return 0;
    }

  } elsif ($coord_type eq 'Sum') {
    return $planepath_object->MathImage__Sum_min;

  } elsif ($coord_type eq 'Radius'
           || $coord_type eq 'RSquared'
           || $coord_type eq 'dDist'
           || $coord_type eq 'dSquared'
           || $coord_type eq 'ENSW') {
    return 0;

  } elsif ($coord_type eq 'dX') {
    return $planepath_object->MathImage__dX_min;
  } elsif ($coord_type eq 'dY') {
    return $planepath_object->MathImage__dY_min;
  }

  return undef;
}

sub values_max {
  my ($self) = @_;

  my $planepath_object = $self->{'planepath_object'};
  my $coord_type = $self->{'coord_type'};

  if ($coord_type eq 'dX') {
    return $planepath_object->MathImage__dX_max;
  } elsif ($coord_type eq 'dY') {
    return $planepath_object->MathImage__dY_max;

  } elsif ($coord_type eq 'ENSW') {
    return 3;
  }

  return undef;
}

sub new {
  my ($class, %options) = @_;
  ### NumSeq-PlanePath new(): @_

  my $planepath_object = $options{'planepath_object'}
    || do {
      my $planepath = $options{'planepath'} || 'SquareSpiral';
      ($planepath, my @args) = split /,+/, $planepath;
      unless ($planepath =~ /::/) {
        $planepath = "Math::PlanePath::$planepath";
      }
      require Module::Load;
      Module::Load::load ($planepath);
      $planepath->new (map {/(.*?)=(.*)/} @args);
    };
  ### $planepath_object

  my $coord_type = $options{'coord_type'} || 'X';
  my $coord_func = $class->can("coord_func_$coord_type")
    || croak "Unrecognised coord_type: ",$coord_type;

  my $n_start = $planepath_object->n_start;
  ### $n_start

  my $self = bless { planepath_object => $planepath_object,
                     coord_type => $coord_type, # for oeis_anum()
                     coord_func => $coord_func,
                     type_hash  => {},
                     n_start    => $n_start,
                   }, $class;
  $self->rewind;
  return $self;
}

sub rewind {
  my ($self) = @_;
  $self->{'i'} = 0;
  $self->{'prev_x'} = 0;
  $self->{'prev_y'} = 0;
  return $self;
}

sub next {
  my ($self) = @_;
  ### NumSeq-PlanePath next(): $self->{'i'}
  my $i = $self->{'i'}++;
  my ($x, $y) = $self->{'planepath_object'}->n_to_xy($i + $self->{'n_start'})
    or return;
  my $ret = &{$self->{'coord_func'}}($self, $x,$y,
                                     $self->{'prev_x'},$self->{'prev_y'});
  $self->{'prev_x'} = $x;
  $self->{'prev_y'} = $y;
  return ($i, $ret);
}

sub ith {
  my ($self, $i) = @_;
  my $planepath_object = $self->{'planepath_object'};
  my ($prev_x, $prev_y);
  if ($self->{'coord_type'} =~ /^d/) {
    ($prev_x, $prev_y) = $planepath_object->n_to_xy ($i + $self->{'n_start'} - 1)
      or return undef;
  }
  my ($x, $y)
    = $planepath_object->n_to_xy ($i + $self->{'n_start'})
      or return undef;
  return ($i, &{$self->{'coord_func'}}($self, $x,$y, $prev_x,$prev_y));
}

sub coord_func_X {
  my ($self, $x,$y) = @_;
  return $x;
}
sub coord_func_Y {
  my ($self, $x,$y) = @_;
  return $y;
}
sub coord_func_Sum {
  my ($self, $x,$y) = @_;
  return $x+$y;
}
sub coord_func_Radius {
  return sqrt(coord_func_RSquared(@_));
}
sub coord_func_RSquared {
  my ($self, $x,$y) = @_;
  return $x*$x + $y*$y;
}

sub coord_func_dX {
  my ($self, $x,$y, $prev_x,$prev_y) = @_;
  return $x - $prev_x;
}
sub coord_func_dY {
  my ($self, $x,$y, $prev_x,$prev_y) = @_;
  return $y - $prev_y;
}
sub coord_func_dDist {
  return sqrt(coord_func_dSquared(@_));
}
sub coord_func_dSquared {
  my ($self, $x,$y, $prev_x,$prev_y) = @_;
  $x -= $prev_x;
  $y -= $prev_y;
  return $x*$x + $y*$y;
}

#      N
#      1
#  W 2   0 E
#      3
#      S
sub coord_func_ENSW {
  my ($self, $x,$y) = @_;
  my $dx = $x - $self->{'prev_x'};
  my $dy = $y - $self->{'prev_y'};
  $self->{'prev_x'} = $x;
  $self->{'prev_y'} = $y;

  if ($dx < $dy && $dy >= -$dx) {
    return 1;  # north
  }
  if ($dy < -$dx && $dy >= $dx) {
    return 2;  # west
  }
  if ($dx > -$dy && $dy < -$dx) {
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

{ package Math::PlanePath;
  use constant MathImage__X_max => undef;
  sub MathImage__Sum_min {
    my ($self) = @_;
    return ($self->x_negative || $self->y_negative
            ? undef
            : 0);  # X>=0 and Y>=0
  }
  use constant MathImage__dX_min => undef;
  use constant MathImage__dX_max => undef;
  use constant MathImage__dY_min => undef;
  use constant MathImage__dY_max => undef;
}
{ package Math::PlanePath::SquareSpiral;
  use constant MathImage__dX_min => -1;
  use constant MathImage__dX_max => 1;
  use constant MathImage__dY_min => -1;
  use constant MathImage__dY_max => 1;
}
{ package Math::PlanePath::PyramidSpiral;
  use constant MathImage__dX_min => -1;
  use constant MathImage__dX_max => 1;
  use constant MathImage__dY_min => -1;
  use constant MathImage__dY_max => 1;
}
{ package Math::PlanePath::TriangleSpiral;
  use constant MathImage__dX_min => -1;
  use constant MathImage__dX_max => 2;
  use constant MathImage__dY_min => -1;
  use constant MathImage__dY_max => 1;
}
{ package Math::PlanePath::TriangleSpiralSkewed;
  use constant MathImage__dX_min => -1;
  use constant MathImage__dX_max => 1;
  use constant MathImage__dY_min => -1;
  use constant MathImage__dY_max => 1;
}
{ package Math::PlanePath::DiamondSpiral;
  use constant MathImage__dX_min => -1;
  use constant MathImage__dX_max => 1;
  use constant MathImage__dY_min => -1;
  use constant MathImage__dY_max => 1;
}
{ package Math::PlanePath::PentSpiralSkewed;
  use constant MathImage__dX_min => -1;
  use constant MathImage__dX_max => 1;
  use constant MathImage__dY_min => -1;
  use constant MathImage__dY_max => 1;
}
{ package Math::PlanePath::HexSpiral;
  use constant MathImage__dX_min => -2;
  use constant MathImage__dX_max => 2;
  use constant MathImage__dY_min => -1;
  use constant MathImage__dY_max => 1;
}
{ package Math::PlanePath::HexSpiralSkewed;
  use constant MathImage__dX_min => -1;
  use constant MathImage__dX_max => 1;
  use constant MathImage__dY_min => -1;
  use constant MathImage__dY_max => 1;
}
{ package Math::PlanePath::HeptSpiralSkewed;
  use constant MathImage__dX_min => -1;
  use constant MathImage__dX_max => 1;
  use constant MathImage__dY_min => -1;
  use constant MathImage__dY_max => 1;
}
{ package Math::PlanePath::OctagramSpiral;
  use constant MathImage__dX_min => -1;
  use constant MathImage__dX_max => 1;
  use constant MathImage__dY_min => -1;
  use constant MathImage__dY_max => 1;
}
{ package Math::PlanePath::KnightSpiral;
  use constant MathImage__dX_min => -2;
  use constant MathImage__dX_max => 2;
  use constant MathImage__dY_min => -1;
  use constant MathImage__dY_max => 1;
}
{ package Math::PlanePath::SquareArms;
}
{ package Math::PlanePath::DiamondArms;
}
{ package Math::PlanePath::HexArms;
}
{ package Math::PlanePath::GreekKeySpiral;
  use constant MathImage__dX_min => -1;
  use constant MathImage__dX_max => 1;
  use constant MathImage__dY_min => -1;
  use constant MathImage__dY_max => 1;
}
{ package Math::PlanePath::SacksSpiral;
}
{ package Math::PlanePath::VogelFloret;
}
{ package Math::PlanePath::TheodorusSpiral;
  use constant MathImage__dX_min => -1;
  use constant MathImage__dX_max => 1;
  use constant MathImage__dY_min => -1;
  use constant MathImage__dY_max => 1;
}
{ package Math::PlanePath::ArchimedeanChords;
  use constant MathImage__dX_min => -1;
  use constant MathImage__dX_max => 1;
  use constant MathImage__dY_min => -1;
  use constant MathImage__dY_max => 1;
}
{ package Math::PlanePath::MultipleRings;
  use constant MathImage__dX_min => -1;
  use constant MathImage__dY_min => -1;
  use constant MathImage__dY_max => 1;
}
{ package Math::PlanePath::PixelRings;
  use constant MathImage__dX_min => -1;
  use constant MathImage__dX_max => 1;
  use constant MathImage__dY_min => -1;
  use constant MathImage__dY_max => 1;
}
{ package Math::PlanePath::Hypot;
}
{ package Math::PlanePath::HypotOctant;
}
{ package Math::PlanePath::TriangularHypot;
}
{ package Math::PlanePath::PythagoreanTree;
}
{ package Math::PlanePath::RationalsTree;
}
{ package Math::PlanePath::PeanoCurve;
  sub MathImage__dX_min {
    my ($self) = @_;
    return ($self->{'radix'} % 2
            ? -1
            : undef);
  }
  sub MathImage__dX_max {
    my ($self) = @_;
    return ($self->{'radix'} % 2
            ? 1
            : undef);
  }
  sub MathImage__dY_min {
    my ($self) = @_;
    return ($self->{'radix'} % 2
            ? -1
            : undef);
  }
  sub MathImage__dY_max {
    my ($self) = @_;
    return ($self->{'radix'} % 2
            ? 1
            : undef);
  }
}
{ package Math::PlanePath::HilbertCurve;
  use constant MathImage__dX_min => -1;
  use constant MathImage__dX_max => 1;
  use constant MathImage__dY_min => -1;
  use constant MathImage__dY_max => 1;
}
{ package Math::PlanePath::ZOrderCurve;
  use constant MathImage__dX_max => 1;
  use constant MathImage__dY_max => 1;
}
{ package Math::PlanePath::ImaginaryBase;
}
{ package Math::PlanePath::Flowsnake;
  use constant MathImage__dX_min => -2;
  use constant MathImage__dX_max => 2;
  use constant MathImage__dY_min => -1;
  use constant MathImage__dY_max => 1;
}
{ package Math::PlanePath::FlowsnakeCentres;
  # inherit from Flowsnake
}
{ package Math::PlanePath::GosperIslands;
}
{ package Math::PlanePath::GosperSide;
  use constant MathImage__dX_min => -2;
  use constant MathImage__dX_max => 2;
  use constant MathImage__dY_min => -1;
  use constant MathImage__dY_max => 1;
}

{ package Math::PlanePath::KochCurve;
  use constant MathImage__dX_min => -2;
  use constant MathImage__dX_max => 2;
}
{ package Math::PlanePath::KochPeaks;
  use constant MathImage__dX_max => 2;
  use constant MathImage__dY_max => 1;
}
{ package Math::PlanePath::KochSnowflakes;
  use constant MathImage__dX_min => 1;
}
{ package Math::PlanePath::KochSquareflakes;
  use constant MathImage__dX_max => 1;
  use constant MathImage__dY_max => 1;
}

{ package Math::PlanePath::QuadricCurve;
  use constant MathImage__dX_min => -1;
  use constant MathImage__dX_max => 1;
  use constant MathImage__dY_min => -1;
  use constant MathImage__dY_max => 1;
  use constant MathImage__Sum_min => 0;  # triangular X>=-Y
}
{ package Math::PlanePath::QuadricIslands;
  use constant MathImage__dX_max => 1;
  use constant MathImage__dY_max => 1;
}

{ package Math::PlanePath::SierpinskiTriangle;
  use constant MathImage__dY_min => 0;
  use constant MathImage__dY_max => 1;
  use constant MathImage__Sum_min => 0;  # triangular X>=-Y
}
{ package Math::PlanePath::SierpinskiArrowhead;
  use constant MathImage__dX_min => -2;
  use constant MathImage__dX_max => 2;
  use constant MathImage__dY_min => -1;
  use constant MathImage__dY_max => 1;
  use constant MathImage__Sum_min => 0;  # triangular X>=-Y
}
{ package Math::PlanePath::SierpinskiArrowheadCentres;
  use constant MathImage__dX_min => -2;
  use constant MathImage__dX_max => 2;
  use constant MathImage__dY_min => -1;
  use constant MathImage__dY_max => 1;
  use constant MathImage__Sum_min => 0;  # triangular X>=-Y
}

{ package Math::PlanePath::DragonCurve;
  use constant MathImage__dX_min => -1;
  use constant MathImage__dX_max => 1;
  use constant MathImage__dY_min => -1;
  use constant MathImage__dY_max => 1;
}
{ package Math::PlanePath::DragonRounded;
  use constant MathImage__dX_min => -1;
  use constant MathImage__dX_max => 1;
  use constant MathImage__dY_min => -1;
  use constant MathImage__dY_max => 1;
}
{ package Math::PlanePath::DragonMidpoint;
  use constant MathImage__dX_min => -1;
  use constant MathImage__dX_max => 1;
  use constant MathImage__dY_min => -1;
  use constant MathImage__dY_max => 1;
}
{ package Math::PlanePath::ComplexMinus;
}
{ package Math::PlanePath::Rows;
  sub MathImage__dX_min {
    my ($self) = @_;
    return - ($self->{'width'}-1);
  }
  use constant MathImage__dX_max => 1;
  use constant MathImage__dY_min => 0;
  use constant MathImage__dY_max => 1;
}
{ package Math::PlanePath::Columns;
  use constant MathImage__dX_min => 0;
  use constant MathImage__dX_max => 1;
  sub MathImage__dY_min {
    my ($self) = @_;
    return - ($self->{'height'}-1);
  }
  use constant MathImage__dY_max => 1;
}
{ package Math::PlanePath::Diagonals;
  use constant MathImage__dX_max => 1;
  use constant MathImage__dY_min => -1;
}
{ package Math::PlanePath::Staircase;
  use constant MathImage__dX_max => 1;
  use constant MathImage__dY_min => -1;
}
{ package Math::PlanePath::Corner;
  use constant MathImage__dX_max => 1;
  use constant MathImage__dY_min => -1;
}
{ package Math::PlanePath::PyramidRows;
  sub MathImage__Sum_min {
    my ($self) = @_;
    return ($self->{'step'} <= 2
            ? 0    # triangular X>=-Y for step=2, vertical X>=0 step=1,0
            : undef)
  }
  sub MathImage__X_max {
    my ($self) = @_;
    return ($self->{'step'} == 0
            ? 0    # X=0 vertical
            : undef)
  }
  use constant MathImage__dY_min => 0;
  use constant MathImage__dY_max => 1;
}
{ package Math::PlanePath::PyramidSides;
  use constant MathImage__dX_max => 1;
  use constant MathImage__dY_min => -1;
  use constant MathImage__dY_max => 1;
}
{ package Math::PlanePath::CellularRule54;
  use constant MathImage__dX_max => 4;
  use constant MathImage__dY_min => 0;
  use constant MathImage__dY_max => 1;
  use constant MathImage__Sum_min => 0;  # triangular X>=-Y
}
{ package Math::PlanePath::CoprimeColumns;
  use constant MathImage__dX_min => 0;
  use constant MathImage__dX_max => 1;
  use constant MathImage__dY_max => 1;
}
{ package Math::PlanePath::File;
  # File                   points from a disk file
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

  my $coord_type = $self->{'coord_type'};
  if ($coord_type eq 'X') {
    if ($planepath_object->x_negative) {
      return 1;
    } else {
      return ($value >= 0);
    }
  } elsif ($coord_type eq 'Y') {
    if ($planepath_object->y_negative) {
      return 1;
    } else {
      return ($value >= 0);
    }
  } elsif ($coord_type eq 'Sum') {
    if ($planepath_object->x_negative || $planepath_object->y_negative) {
      return 1;
    } else {
      return ($value >= 0);
    }
  } elsif ($coord_type eq 'SqDist') {
    # FIXME: only sum of two squares, and for triangular same odd/even
    return ($value >= 0);
  }

  return undef;
}

