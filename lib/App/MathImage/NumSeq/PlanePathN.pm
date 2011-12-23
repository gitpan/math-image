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

# math-image --values=PlanePath

package App::MathImage::NumSeq::PlanePathN;
use 5.004;
use strict;
use Carp;

use vars '$VERSION','@ISA';
$VERSION = 86;
use Math::NumSeq;
@ISA = ('Math::NumSeq');

use Math::NumSeq::PlanePathCoord;

# uncomment this to run the ### lines
#use Smart::Comments;


use constant description => Math::NumSeq::__('N values from a PlanePath');

use constant::defer parameter_info_array =>
  sub {
    return [
            Math::NumSeq::PlanePathCoord::_parameter_info_planepath(),

            { name    => 'line_type',
              display => Math::NumSeq::__('Line Type'),
              type    => 'enum',
              default => 'X_axis',
              choices => ['X_axis','Y_axis',
                          'Diagonal',
                          # 'X_neg','Y_neg',
                          # 'NE','NW','SW','SE',
                         ],
              # description => Math::NumSeq::__(''),
            },
           ];
  };

# A062728 triangle spiral X axis, second 11-gonals
my %oeis_anum
  = (
     'Math::PlanePath::PeanoCurve,radix=3' =>
     { X_axis   => 'A163480',
       Y_axis   => 'A163481',
       Diagonal => 'A163343',
       # OEIS-Catalogue: A163480 planepath=PeanoCurve
       # OEIS-Catalogue: A163481 planepath=PeanoCurve line_type=Y_axis
       # OEIS-Catalogue: A163343 planepath=PeanoCurve line_type=Diagonal
     },

     'Math::PlanePath::HilbertCurve' =>
     { X_axis   => 'A163482',
       Y_axis   => 'A163483',
       Diagonal => 'A062880', # digits 0,2 in base 4
       # OEIS-Catalogue: A163482 planepath=HilbertCurve
       # OEIS-Catalogue: A163483 planepath=HilbertCurve line_type=Y_axis
       # OEIS-Catalogue: A062880 planepath=HilbertCurve line_type=Diagonal
     },

     'Math::PlanePath::ZOrderCurve,radix=2' =>
     { X_axis => 'A000695',  # base 4 digits 0 and 1 only
       # OEIS-Catalogue: A000695 planepath=ZOrderCurve
     },
     # but A037314 starts n=1, so N=0 not included
     # 'Math::PlanePath::ZOrderCurve,radix=3' =>
     # { X_axis => 'A037314',  # base 9 digits 0,1,2 only
     #   # OEIS-Catalogue: A037314 planepath=ZOrderCurve,radix=3
     # },
     # but A051022 starts n=1, so N=0 not included
     # 'Math::PlanePath::ZOrderCurve,radix=10' =>
     # { X_axis => 'A051022',  # base 10 insert 0s
     #   # OEIS-Catalogue: A051022 planepath=ZOrderCurve,radix=10
     # },

     'Math::PlanePath::AztecDiamondRings' =>
     { X_axis => 'A001844',  # centred squares 2n(n+1)+1
       # OEIS-Other: A001844 planepath=AztecDiamondRings
       # Y_axis hexagonal numbers A000384, but starting i=0 value=1
     },

     'Math::PlanePath::ComplexMinus,realpart=1' =>
     { X_axis => 'A066321', # binary base i-1
       # OEIS-Catalogue: A066321 planepath=ComplexMinus
     },

     'Math::PlanePath::DiamondSpiral' =>
     { X_axis => 'A130883', # 2*n^2-n+1
       Y_axis => 'A058331', # 2*n^2 + 1
       # OEIS-Catalogue: A130883 planepath=DiamondSpiral
       # OEIS-Catalogue: A058331 planepath=DiamondSpiral line_type=Y_axis
     },

     # but OFFSET=1
     # 'Math::PlanePath::DigitGroups,radix=2' =>
     # { X_axis => 'A084471', # 0 -> 00 in binary
     #   # OEIS-Catalogue: A084471 planepath=DigitGroups,radix=2
     # },

     'Math::PlanePath::FactorRationals' =>
     { Y_axis => 'A102631', # n^2/(squarefree kernel)
       # OEIS-Catalogue: A102631 planepath=FactorRationals line_type=Y_axis
       #
       # FactorRationals X_axis -- squares, but starting from i=1
     },

     'Math::PlanePath::HexSpiral' =>
     { X_axis   => 'A056105', # first spoke 3n^2-2n+1
       Diagonal => 'A056106', # second spoke 3n^2-n+1
       # OEIS-Other: A056105 planepath=HexSpiral
       # OEIS-Other: A056106 planepath=HexSpiral line_type=Diagonal
     },

     'Math::PlanePath::HexSpiralSkewed' =>
     { X_axis   => 'A056105', # first spoke 3n^2-2n+1
       Y_axis => 'A056106', # second spoke 3n^2-n+1
       # OEIS-Catalogue: A056105 planepath=HexSpiralSkewed
       # OEIS-Catalogue: A056106 planepath=HexSpiralSkewed line_type=Y_axis
       
       # wider=1 X_axis almost 3*n^2 but not initial X=0 value
       # wider=1 Y_axis almost A049451 twice pentagonal but not initial X=0
       # wider=2 Y_axis almost A028896 6*triangular but not initial Y=0
     },

     'Math::PlanePath::PentSpiral' =>
     { X_axis   => 'A192136', # (5*n^2-3*n+2)/2 
       # OEIS-Catalogue: A192136 planepath=PentSpiral
     },

     'Math::PlanePath::RationalsTree,tree_type=Bird' =>
     { X_axis   => 'A081254', # local max sumdisttopow2(m)/m^2
       # OEIS-Catalogue: A081254 planepath=RationalsTree,tree_type=Bird
       
       # Bird Y_axis -- almost A000975 no consecutive equal bits, but start=1
     },

     'Math::PlanePath::RationalsTree,tree_type=Drib' =>
     { X_axis   => 'A086893', # pos of fibonacci in Stern diatomic
       # OEIS-Catalogue: A086893 planepath=RationalsTree,tree_type=Drib
       
       # Drib Y_axis -- almost A061547 avoid derangements, but start=1
     },

     'Math::PlanePath::SquareSpiral,wider=0' =>
     { X_axis   => 'A054552', # spoke E
       Y_axis   => 'A054556', # spoke N
       Diagonal => 'A054554', # spoke NE
       # OEIS-Catalogue: A054552 planepath=SquareSpiral
       # OEIS-Catalogue: A054556 planepath=SquareSpiral line_type=Y_axis
       # OEIS-Catalogue: A054554 planepath=SquareSpiral line_type=Diagonal
     },

     # Math::PlanePath::CoprimeColumns X_axis -- cumulative totient but
     # start X=1 value=0; Diagonal A015614 cumulative-1 but start X=1
     # value=1
     #
     # DivisibleColumns X_axis nearly A006218 but start X=1, Diagonal nearly
     # A077597 but start X=1
     #
     # DiagonalRationals Diagonal -- cumulative totient but start X=1
     # value=1
     #
     # CellularRule190 -- A006578 triangular+quarter square, but start N=1
     #
     # SacksSpiral X_axis -- squares, but starting from i=1
     #
     # GcdRationals -- X_axis triangular row, but starting X=1
     # GcdRationals -- Y_axis A000124 triangular+1 but starting Y=1
     #
     # HeptSpiralSkewed -- Y_axis A140065 (7n^2 - 17n + 12)/2 but starting
     # Y=0 not n=1
     #
     # MPeaks -- X_axis A045944 matchstick n(3n+2) but initial N=3
     # MPeaks -- Diagonal,Y_axis hexagonal first,second spoke, but starting
     # from 3
     #
     # OctagramSpiral -- X_axis A125201 8*n^2-7*n+1 but initial N=1 
     # 
     # PentSpiralSkewed -- X_axis A140066 (5n^2-11n+8)/2 but start X=0
     #
     # RationalsTree SB -- X_axis 2^n-1 but starting X=1
     # RationalsTree SB,CW -- Y_axis A000079 2^n but starting Y=1
     # RationalsTree AYT -- Y_axis A083318 2^n+1 but starting Y=1
     #
     # Rows,height=1 -- integers 1,2,3, etc, but starting i=0
     # MultipleRings,step=0 -- integers 1,2,3, etc, but starting i=0
     #
     # Diagonals X_axis -- triangular 1,3,6,etc, but starting i=0 value=1
     #
     # PyramidRows Diagonal -- squares 1,4,9,16, but i=0 value=1
     # PyramidRows,step=1 Diagonal -- triangular 1,3,6,10, but i=0 value=1
     # PyramidRows,step=0 Y_axis -- 1,2,3,4, but i=0 value=1
     #
     # Corner X_axis -- squares, but starting i=0 value=1
     # PyramidSides X_axis -- squares, but starting i=0 value=1
    );

sub oeis_anum {
  my ($self) = @_;
  return $oeis_anum{Math::NumSeq::PlanePathCoord::_planepath_oeis_key($self->{'planepath_object'})} -> {$self->{'line_type'}};
}

sub new {
  my $class = shift;
  ### NumSeq-PlanePathN new(): @_

  my $self = $class->SUPER::new(@_);

  my $planepath_object = ($self->{'planepath_object'}
                          ||= Math::NumSeq::PlanePathCoord::_planepath_name_to_object($self->{'planepath'}));

  $self->{'i_func'}
    = $self->can('i_func_'.$self->{'line_type'})
      || croak "Unrecognised line_type: ",$self->{'line_type'};

  $self->{'A2_factor'} = ($planepath_object->MathImage__NumSeq_A2 ? 2 : 1);
  $self->rewind;
  return $self;
}

sub rewind {
  my ($self) = @_;
  $self->{'i'} = $self->i_start;
}

sub next {
  my ($self) = @_;
  ### NumSeq-PlanePath next(): $self->{'i'}

  my $i = $self->{'i'}++;
  return ($i, &{$self->{'i_func'}}($self,$i));
}
sub ith {
  my ($self, $i) = @_;
  ### NumSeq-PlanePath ith(): $i

  my $planepath_object = $self->{'planepath_object'};
  return ($i, &{$self->{'i_func'}}($self, $i));
}

sub i_func_X_axis {
  my ($self, $i) = @_;
  my $path_object = $self->{'planepath_object'};
  return $path_object->xy_to_n ($i * $self->{'A2_factor'},
                                $path_object->MathImage__NumSeq_X_axis_use_Y);
}
sub i_func_Y_axis {
  my ($self, $i) = @_;
  my $path_object = $self->{'planepath_object'};
  return $path_object->xy_to_n ($path_object->MathImage__NumSeq_Y_axis_use_X,
                                $i * $self->{'A2_factor'});
}
sub i_func_X_neg {
  my ($self, $i) = @_;
  return $self->{'planepath_object'}->xy_to_n (-$i * $self->{'A2_factor'},
                                              0);
}
sub i_func_Y_neg {
  my ($self, $i) = @_;
  return $self->{'planepath_object'}->xy_to_n (0,
                                               -$i * $self->{'A2_factor'});
}

sub i_func_Diagonal {
  my ($self, $i) = @_;
  my $path_object = $self->{'planepath_object'};
  return $path_object->xy_to_n ($i + $path_object->MathImage__NumSeq_Diagonal_X_offset,
                                $i);
}

#------------------------------------------------------------------------------

sub characteristic_increasing {
  my ($self) = @_;
  my $method = 'MathImage__NumSeq_' . $self->{'line_type'} . '_increasing';
  my $planepath_object = $self->{'planepath_object'};
  return $planepath_object->can($method) && $planepath_object->$method();
}

sub i_start {
  my ($self) = @_;
  my $method = 'MathImage__NumSeq_' . $self->{'line_type'} . '_i_start';
  my $planepath_object = $self->{'planepath_object'}
    # nasty hack allow no 'planepath_object' when SUPER::new() calls rewind()
    || return 0;
  if (my $func = $planepath_object->can($method)) {
    return $planepath_object->$func();
  } else {
    return 0; # default start i=0
  }
}
sub values_min {
  my ($self) = @_;
  my $method = 'MathImage__NumSeq_' . $self->{'line_type'} . '_min';
  return $self->{'planepath_object'}->$method();
}
sub values_max {
  my ($self) = @_;
  my $method = 'MathImage__NumSeq_' . $self->{'line_type'} . '_max';
  my $planepath_object = $self->{'planepath_object'};
  return ($planepath_object->can($method)
          ? $self->{'planepath_object'}->$method()
          : undef);
}

{ package Math::PlanePath;
  sub MathImage__NumSeq_X_axis_min {
    my ($path) = @_;
    return $path->xy_to_n($path->MathImage__NumSeq_X_axis_i_start,
                          $path->MathImage__NumSeq_X_axis_use_Y);
  }
  sub MathImage__NumSeq_Y_axis_min {
    my ($path) = @_;
    return $path->xy_to_n($path->MathImage__NumSeq_Y_axis_use_X,
                          $path->MathImage__NumSeq_Y_axis_i_start);
  }
  sub MathImage__NumSeq_X_neg_min {
    my ($path) = @_;
    return $path->xy_to_n(0,0);
  }
  sub MathImage__NumSeq_Y_neg_min {
    my ($path) = @_;
    return $path->xy_to_n(0,0);
  }
  sub MathImage__NumSeq_Diagonal_min {
    my ($path) = @_;
    my $i = $path->MathImage__NumSeq_X_axis_i_start;
    return $path->xy_to_n($i + $path->MathImage__NumSeq_Diagonal_X_offset,
                          $i);
  }

  use constant MathImage__NumSeq_X_axis_i_start => 0;
  use constant MathImage__NumSeq_Y_axis_i_start => 0;
  use constant MathImage__NumSeq_X_axis_use_Y => 0;
  use constant MathImage__NumSeq_Y_axis_use_X => 0;
  use constant MathImage__NumSeq_Diagonal_i_start => 0;
  use constant MathImage__NumSeq_Diagonal_X_offset => 0;

  # sub MathImage__NumSeq_pred_X_axis {
  #   my ($path, $value) = @_;
  #   return ($value == int($value)
  #           && ($path->x_negative || $value >= 0));
  # }
  # sub MathImage__NumSeq_pred_Y_axis {
  #   my ($path, $value) = @_;
  #   return ($value == int($value)
  #           && ($path->y_negative || $value >= 0));
  # }
}

{ package Math::PlanePath::SquareSpiral;
  use constant MathImage__NumSeq_X_axis_increasing => 1;
  use constant MathImage__NumSeq_Y_axis_increasing => 1;
  use constant MathImage__NumSeq_Diagonal_increasing => 1;
}
{ package Math::PlanePath::PyramidSpiral;
  use constant MathImage__NumSeq_X_axis_increasing => 1;
  use constant MathImage__NumSeq_Y_axis_increasing => 1;
  use constant MathImage__NumSeq_Diagonal_increasing => 1;
}
{ package Math::PlanePath::TriangleSpiral;
  use constant MathImage__NumSeq_X_axis_increasing => 1;
  use constant MathImage__NumSeq_Y_axis_increasing => 1;
  use constant MathImage__NumSeq_Diagonal_increasing => 1;
}
{ package Math::PlanePath::TriangleSpiralSkewed;
  use constant MathImage__NumSeq_X_axis_increasing => 1;
  use constant MathImage__NumSeq_Y_axis_increasing => 1;
  use constant MathImage__NumSeq_Diagonal_increasing => 1;
}
{ package Math::PlanePath::DiamondSpiral;
  use constant MathImage__NumSeq_X_axis_increasing => 1;
  use constant MathImage__NumSeq_Y_axis_increasing => 1;
  use constant MathImage__NumSeq_Diagonal_increasing => 1;
}
{ package Math::PlanePath::PentSpiralSkewed;
  use constant MathImage__NumSeq_X_axis_increasing => 1;
  use constant MathImage__NumSeq_Y_axis_increasing => 1;
  use constant MathImage__NumSeq_Diagonal_increasing => 1;
}
{ package Math::PlanePath::HexSpiral;
  use constant MathImage__NumSeq_X_axis_increasing => 1;
  use constant MathImage__NumSeq_Y_axis_increasing => 1;
  use constant MathImage__NumSeq_Diagonal_increasing => 1;
}
{ package Math::PlanePath::HexSpiralSkewed;
  use constant MathImage__NumSeq_X_axis_increasing => 1;
  use constant MathImage__NumSeq_Y_axis_increasing => 1;
  use constant MathImage__NumSeq_Diagonal_increasing => 1;
}
{ package Math::PlanePath::HeptSpiralSkewed;
  use constant MathImage__NumSeq_X_axis_increasing => 1;
  use constant MathImage__NumSeq_Y_axis_increasing => 1;
  use constant MathImage__NumSeq_Diagonal_increasing => 1;
}
{ package Math::PlanePath::OctagramSpiral;
  use constant MathImage__NumSeq_X_axis_increasing => 1;
  use constant MathImage__NumSeq_Y_axis_increasing => 1;
  use constant MathImage__NumSeq_Diagonal_increasing => 1;
}
# { package Math::PlanePath::KnightSpiral;
# }
# { package Math::PlanePath::SquareArms;
# }
# { package Math::PlanePath::DiamondArms;
# }
# { package Math::PlanePath::HexArms;
# }
# { package Math::PlanePath::GreekKeySpiral;
# }
{ package Math::PlanePath::SacksSpiral;
  use constant MathImage__NumSeq_X_axis_increasing => 1;
  use constant MathImage__NumSeq_Y_axis_increasing => 1;
}
# { package Math::PlanePath::VogelFloret;
# }
# { package Math::PlanePath::TheodorusSpiral;
# }
# { package Math::PlanePath::ArchimedeanChords;
# }
{ package Math::PlanePath::MultipleRings;
  use constant MathImage__NumSeq_X_axis_increasing => 1;
}
{ package Math::PlanePath::PixelRings;
  use constant MathImage__NumSeq_X_axis_increasing => 1;
  use constant MathImage__NumSeq_Y_axis_increasing => 1;
  use constant MathImage__NumSeq_Diagonal_increasing => 1; # where covered
}
{ package Math::PlanePath::Hypot;
  use constant MathImage__NumSeq_X_axis_increasing => 1;
  use constant MathImage__NumSeq_Y_axis_increasing => 1;
  use constant MathImage__NumSeq_Diagonal_increasing => 1;
}
{ package Math::PlanePath::HypotOctant;
  use constant MathImage__NumSeq_X_axis_increasing => 1;
  use constant MathImage__NumSeq_Y_axis_increasing => 1;
  use constant MathImage__NumSeq_Diagonal_increasing => 1;
}
{ package Math::PlanePath::TriangularHypot;
  use constant MathImage__NumSeq_X_axis_increasing => 1;
  use constant MathImage__NumSeq_Y_axis_increasing => 1;
  use constant MathImage__NumSeq_Diagonal_increasing => 1;
}
# { package Math::PlanePath::PythagoreanTree;
# }
{ package Math::PlanePath::RationalsTree;
  use constant MathImage__NumSeq_X_axis_increasing => 1;
  use constant MathImage__NumSeq_Y_axis_increasing => 1;
  use constant MathImage__NumSeq_X_axis_use_Y => 1;
  use constant MathImage__NumSeq_Y_axis_use_X => 1;
  use constant MathImage__NumSeq_X_axis_i_start => 1;
  use constant MathImage__NumSeq_Y_axis_i_start => 1;
}
{ package Math::PlanePath::DiagonalRationals;
  use constant MathImage__NumSeq_X_axis_increasing => 1;
  use constant MathImage__NumSeq_Y_axis_increasing => 1;
  use constant MathImage__NumSeq_X_axis_use_Y => 1;
  use constant MathImage__NumSeq_Y_axis_use_X => 1;
  use constant MathImage__NumSeq_X_axis_i_start => 1;
  use constant MathImage__NumSeq_Y_axis_i_start => 1;
}
{ package Math::PlanePath::FactorRationals;
  use constant MathImage__NumSeq_X_axis_increasing => 1;
  use constant MathImage__NumSeq_Y_axis_increasing => 1;
  use constant MathImage__NumSeq_X_axis_use_Y => 1;
  use constant MathImage__NumSeq_Y_axis_use_X => 1;
  use constant MathImage__NumSeq_X_axis_i_start => 1;
  use constant MathImage__NumSeq_Y_axis_i_start => 1;
}
{ package Math::PlanePath::GcdRationals;
  use constant MathImage__NumSeq_X_axis_increasing => 1;
  use constant MathImage__NumSeq_Y_axis_increasing => 1;
  use constant MathImage__NumSeq_X_axis_use_Y => 1;
  use constant MathImage__NumSeq_Y_axis_use_X => 1;
  use constant MathImage__NumSeq_X_axis_i_start => 1;
  use constant MathImage__NumSeq_Y_axis_i_start => 1;
}
{ package Math::PlanePath::PeanoCurve;
  use constant MathImage__NumSeq_X_axis_increasing => 1;
  use constant MathImage__NumSeq_Y_axis_increasing => 1;
  use constant MathImage__NumSeq_Diagonal_increasing => 1;
}
{ package Math::PlanePath::HilbertCurve;
  use constant MathImage__NumSeq_X_axis_increasing => 1;
  use constant MathImage__NumSeq_Y_axis_increasing => 1;
  use constant MathImage__NumSeq_Diagonal_increasing => 1;
}
{ package Math::PlanePath::ZOrderCurve;
  use constant MathImage__NumSeq_X_axis_increasing => 1;
  use constant MathImage__NumSeq_Y_axis_increasing => 1;
  use constant MathImage__NumSeq_Diagonal_increasing => 1;
}
# { package Math::PlanePath::ImaginaryBase;
# }
# { package Math::PlanePath::Flowsnake;
# }
# { package Math::PlanePath::FlowsnakeCentres;
#   # inherit from Flowsnake
# }
# { package Math::PlanePath::GosperIslands;
# }
# { package Math::PlanePath::GosperSide;
# }
# { package Math::PlanePath::KochCurve;
# }
# { package Math::PlanePath::KochPeaks;
# }
# { package Math::PlanePath::KochSnowflakes;
# }
# { package Math::PlanePath::KochSquareflakes;
# }
# { package Math::PlanePath::QuadricCurve;
# }
# { package Math::PlanePath::QuadricIslands;
# }
# { package Math::PlanePath::SierpinskiTriangle;
# }
# { package Math::PlanePath::SierpinskiArrowhead;
# }
# { package Math::PlanePath::SierpinskiArrowheadCentres;
# }
# { package Math::PlanePath::DragonCurve;
# }
# { package Math::PlanePath::DragonRounded;
# }
# { package Math::PlanePath::DragonMidpoint;
# }
# { package Math::PlanePath::ComplexMinus;
# }
{ package Math::PlanePath::Rows;
  use constant MathImage__NumSeq_X_axis_increasing => 1;
  use constant MathImage__NumSeq_Y_axis_increasing => 1;
  use constant MathImage__NumSeq_Diagonal_increasing => 1;
}
{ package Math::PlanePath::Columns;
  use constant MathImage__NumSeq_X_axis_increasing => 1;
  use constant MathImage__NumSeq_Y_axis_increasing => 1;
  use constant MathImage__NumSeq_Diagonal_increasing => 1;
}
{ package Math::PlanePath::Diagonals;
  use constant MathImage__NumSeq_X_axis_increasing => 1;
  use constant MathImage__NumSeq_Y_axis_increasing => 1;
  use constant MathImage__NumSeq_Diagonal_increasing => 1;
}
{ package Math::PlanePath::Staircase;
  use constant MathImage__NumSeq_X_axis_increasing => 1;
  use constant MathImage__NumSeq_Y_axis_increasing => 1;
  use constant MathImage__NumSeq_Diagonal_increasing => 1;
}
{ package Math::PlanePath::Corner;
  use constant MathImage__NumSeq_X_axis_increasing => 1;
  use constant MathImage__NumSeq_Y_axis_increasing => 1;
  use constant MathImage__NumSeq_Diagonal_increasing => 1;
}
{ package Math::PlanePath::PyramidRows;
  use constant MathImage__NumSeq_Y_axis_increasing => 1;
  use constant MathImage__NumSeq_Diagonal_increasing => 1; # when covered
}
{ package Math::PlanePath::PyramidSides;
  use constant MathImage__NumSeq_X_axis_increasing => 1;
  use constant MathImage__NumSeq_Y_axis_increasing => 1;
  use constant MathImage__NumSeq_Diagonal_increasing => 1;
}
{ package Math::PlanePath::CellularRule54;
  use constant MathImage__NumSeq_X_axis_increasing => 1;
  use constant MathImage__NumSeq_Diagonal_increasing => 1;
}
{ package Math::PlanePath::CellularRule190;
  use constant MathImage__NumSeq_X_axis_increasing => 1;
  use constant MathImage__NumSeq_Diagonal_increasing => 1;
}
{ package Math::PlanePath::CoprimeColumns;
  use constant MathImage__NumSeq_X_axis_increasing => 1;
  use constant MathImage__NumSeq_X_axis_i_start => 1;
  use constant MathImage__NumSeq_X_axis_use_Y => 1;
  use constant MathImage__NumSeq_Diagonal_increasing => 1;
  use constant MathImage__NumSeq_Diagonal_i_start => 1;
  use constant MathImage__NumSeq_Diagonal_X_offset => 1;
}
{ package Math::PlanePath::DivisibleColumns;
  use constant MathImage__NumSeq_X_axis_increasing => 1;
  use constant MathImage__NumSeq_X_axis_i_start => 1;
  use constant MathImage__NumSeq_X_axis_use_Y => 1;
  use constant MathImage__NumSeq_Diagonal_increasing => 1;
  use constant MathImage__NumSeq_Diagonal_i_start => 1;
}
# { package Math::PlanePath::File;
#   # File                   points from a disk file
#   # FIXME: analyze points for dx/dy min/max etc
# }
# { package Math::PlanePath::MathImageQuintetCurve;
# }
# { package Math::PlanePath::MathImageQuintetCentres;
#   # inherit QuintetCurve
# }

#------------------------------------------------------------------------------
{ package Math::PlanePath;
  use constant MathImage__NumSeq_A2 => 0;
}
{ package Math::PlanePath::TriangleSpiral;
  use constant MathImage__NumSeq_A2 => 1;
}
{ package Math::PlanePath::HexSpiral;
  use constant MathImage__NumSeq_A2 => 1;
}
{ package Math::PlanePath::HexArms;
  use constant MathImage__NumSeq_A2 => 1;
}
{ package Math::PlanePath::TriangularHypot;
  use constant MathImage__NumSeq_A2 => 1;
}
{ package Math::PlanePath::Flowsnake;
  use constant MathImage__NumSeq_A2 => 1;
  # and FlowsnakeCentres inherits
}

1;
__END__

sub can {
  my ($self, $name) = @_;
  return $self->{'pred_handler'} && $self->SUPER::can($name);
}
sub pred {
  my ($self, $value) = @_;
  return &{$self->{'pred_handler'} || return undef} ($value);
}

=for stopwords Ryde MathImage PlanePath

=head1 NAME

App::MathImage::NumSeq::PlanePathN -- sequence of N from PlanePath module

=head1 SYNOPSIS

 use App::MathImage::NumSeq::PlanePathN;
 my $seq = App::MathImage::NumSeq::PlanePathN->new (planepath => 'SquareSpiral',
                                                    line_type => 'X_axis');
 my ($i, $value) = $seq->next;

=head1 DESCRIPTION

This module presents N values from a C<Math::PlanePath> as a sequence.  The
default is the X axis, or the C<line_type> parameter (a string) can choose
among

    "X_axis"        X axis
    "Y_axis"        Y axis
    "Diagonal"      leading diagonal X=Y

=head1 FUNCTIONS

=over 4

=item C<$seq = App::MathImage::NumSeq::PlanePathN-E<gt>new (key=E<gt>value,...)>

Create and return a new sequence object.

=back

=head1 SEE ALSO

L<Math::NumSeq>
L<Math::NumSeq::PlanePathCoord>,
L<Math::NumSeq::PlanePathDelta>

=cut

# Local variables:
# compile-command: "math-image --values=PlanePathN"
# End:
