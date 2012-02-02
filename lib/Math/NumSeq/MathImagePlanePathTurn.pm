# Copyright 2011, 2012 Kevin Ryde

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


# math-image --values=PlanePathTurn
#
# LSR
# Turn90
# Turn60 0,1,2,3, -1,-2,-3



package Math::NumSeq::MathImagePlanePathTurn;
use 5.004;
use strict;
use Carp;

use vars '$VERSION','@ISA';
$VERSION = 92;
use Math::NumSeq;
@ISA = ('Math::NumSeq');

use Math::NumSeq::PlanePathCoord;

# uncomment this to run the ### lines
#use Smart::Comments;


use constant characteristic_smaller => 1;
use constant description => Math::NumSeq::__('Coordinates from a PlanePath');

use constant::defer parameter_info_array =>
  sub {
    return [
            Math::NumSeq::PlanePathCoord::_parameter_info_planepath(),
            {
             name    => 'turn_type',
             display => Math::NumSeq::__('Turn Type'),
             type    => 'enum',
             default => 'LSR_pn',
             choices => ['LSR_pn',
                         'LR_01',
                         'RL_01',
                        ],
             # description => Math::NumSeq::__(''),
            },
           ];
  };

my %oeis_anum
  = (
     # 'Math::PlanePath::HilbertCurve' =>
     # {
     #  # cf 1,0,-1 here
     #  # A163542    relative direction (ahead=0,right=1,left=2)
     #  # A163543    relative direction, transpose X,Y
     # },

     # 'Math::PlanePath::PeanoCurve,radix=3' =>
     # {
     #  # A163536 relative direction 0=ahead,1=right,2=left
     # },

     # but A014577 has OFFSET=0 cf first elem for N=1
     # 'Math::PlanePath::DragonCurve' =>
     # {
     #  'LR_01' => 'A014577', # turn, 0=left,1=right
     #  # OEIS-Catalogue: A014577 planepath=DragonCurve turn_type=LR_01
     # },

     # but A106665 has OFFSET=0 cf first elem for N=1
     # 'Math::PlanePath::AlternatePaper' =>
     # {
     #  'RL_01' => 'A106665', # turn, 1=left,0=right
     #  # OEIS-Catalogue: A106665 planepath=AlternatePaper turn_type=RL_01
     # },

     # but A080846 has OFFSET=0 cf first elem for N=1
     # 'Math::PlanePath::TerdragonCurve' =>
     # {
     #  'LR_01' => 'A080846', # turn, 0=left,1=right
     #  # OEIS-Catalogue: A080846 planepath=TerdragonCurve turn_type=LR_01
     # },
    );

sub oeis_anum {
  my ($self) = @_;
  return $oeis_anum{Math::NumSeq::PlanePathCoord::_planepath_oeis_key($self->{'planepath_object'})} -> {$self->{'turn_type'}};
}

sub new {
  my $class = shift;
  ### NumSeq-PlanePathN new(): @_
  my $self = $class->SUPER::new(@_);

  my $planepath_object = ($self->{'planepath_object'}
                          ||= Math::NumSeq::PlanePathCoord::_planepath_name_to_object($self->{'planepath'}));


  ### turn_func: "_turn_func_$self->{'turn_type'}", $self->{'turn_func'}
  $self->{'turn_func'}
    = $self->can("_turn_func_$self->{'turn_type'}")
      || croak "Unrecognised turn_type: ",$self->{'turn_type'};

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
  my $i = $self->{'i'} =  $self->i_start;
  if ((my ($x, $y) = $planepath_object->n_to_xy ($i - 1))
      && (my ($next_x, $next_y) = $planepath_object->n_to_xy ($i))) {
    $self->{'prev_dx'} = $next_x - $x;
    $self->{'prev_dy'} = $next_y - $y;
    $self->{'prev_x'} = $next_x;
    $self->{'prev_y'} = $next_y;
  }
}

sub next {
  my ($self) = @_;
  ### NumSeq-PlanePathTurn next(): $self->{'i'}
  ### n_next: $self->{'n_next'}

  my $i = $self->{'i'}++;
  return ($i, $self->ith($i));




  # my $planepath_object = $self->{'planepath_object'};
  # 
  # my ($x, $y) = $planepath_object->n_to_xy($i)
  #   or return;
  # my $ret = &{$self->{'turn_func'}}($self, $x,$y,
  #                                    $self->{'prev_x'},$self->{'prev_y'});
  # $self->{'prev_x'} = $x;
  # $self->{'prev_y'} = $y;
  # return ($i, $ret);
}

sub ith {
  my ($self, $i) = @_;
  ### NumSeq-PlanePath ith(): $i

  my $planepath_object = $self->{'planepath_object'};
  my $n = $i + $planepath_object->n_start;
  my ($prev_x, $prev_y) = $planepath_object->n_to_xy ($i - 1)
    or return undef;
  my ($x, $y) = $planepath_object->n_to_xy ($i)
    or return undef;
  my ($next_x, $next_y) = $planepath_object->n_to_xy ($i + 1)
    or return undef;

  my $dx = $x - $prev_x;
  my $dy = $y - $prev_y;
  my $next_dx = $next_x - $x;
  my $next_dy = $next_y - $y;
  return $self->{'turn_func'}->($dx,$dy, $next_dx,$next_dy);

  #   return ($i, &{$self->{'turn_func'}}($self, $next_x,$next_y, $x,$y));
}

#            dx1,dy1
#  dx2,dy2  /
#       *  /
#         /
#        /
#       /
#      /
#
# cmpy = dx2 * dy1/dx1
# left if dy2 > cmpy
#         dy2 > dx2 * dy1/dx1
#         dy2 * dx1 > dx2 * dy1
#
sub _turn_func_LSR_pn {
  my ($dx,$dy, $next_dx,$next_dy) = @_;
  ### _turn_func_LSR_pn() ...
  return ($next_dy * $dx <=> $next_dx * $dy || 0);
}

sub _turn_func_LR_01 {
  my ($dx,$dy, $next_dx,$next_dy) = @_;
  ### _turn_func_LR_01() ...
  return ($next_dy * $dx >= $next_dx * $dy || 0);
}
sub _turn_func_RL_01 {
  my ($dx,$dy, $next_dx,$next_dy) = @_;
  ### _turn_func_RL_01() ...
  return ($next_dy * $dx <= $next_dx * $dy || 0);
}


#------------------------------------------------------------------------------

sub values_min {
  my ($self) = @_;

  my $method = 'MathImage__NumSeq_' . $self->{'turn_type'} . '_min';
  return $self->{'planepath_object'}->can($method)
    ? $self->{'planepath_object'}->$method()
      : undef;
}

sub values_max {
  my ($self) = @_;

  my $method = 'MathImage__NumSeq_' . $self->{'turn_type'} . '_max';
  return $self->{'planepath_object'}->can($method)
    ? $self->{'planepath_object'}->$method()
      : undef;
}

{ package Math::PlanePath;

  use constant MathImage__NumSeq_Turn_min => -1;
  use constant MathImage__NumSeq_Turn_max => 1;
}

{ package Math::PlanePath::SquareSpiral;
  use constant MathImage__NumSeq_Turn_min => 0; # left or straight
  use constant MathImage__NumSeq_Turn_max => 1;
}
{ package Math::PlanePath::PyramidSpiral;
  use constant MathImage__NumSeq_Turn_min => 0; # left or straight
  use constant MathImage__NumSeq_Turn_max => 1;
}
{ package Math::PlanePath::TriangleSpiral;
  use constant MathImage__NumSeq_Turn_min => 0; # left or straight
  use constant MathImage__NumSeq_Turn_max => 1;
}
{ package Math::PlanePath::TriangleSpiralSkewed;
  use constant MathImage__NumSeq_Turn_min => 0; # left or straight
  use constant MathImage__NumSeq_Turn_max => 1;
}
{ package Math::PlanePath::DiamondSpiral;
  use constant MathImage__NumSeq_Turn_min => 0; # left or straight
  use constant MathImage__NumSeq_Turn_max => 1;
}
{ package Math::PlanePath::PentSpiralSkewed;
  use constant MathImage__NumSeq_Turn_min => 0; # left or straight
  use constant MathImage__NumSeq_Turn_max => 1;
}
{ package Math::PlanePath::HexSpiral;
  use constant MathImage__NumSeq_Turn_min => 0; # left or straight
  use constant MathImage__NumSeq_Turn_max => 1;
}
{ package Math::PlanePath::HexSpiralSkewed;
  use constant MathImage__NumSeq_Turn_min => 0; # left or straight
  use constant MathImage__NumSeq_Turn_max => 1;
}
{ package Math::PlanePath::HeptSpiralSkewed;
  use constant MathImage__NumSeq_Turn_min => 0; # left or straight
  use constant MathImage__NumSeq_Turn_max => 1;
}
# { package Math::PlanePath::AnvilSpiral;
# }
# { package Math::PlanePath::OctagramSpiral;
# }
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
  use constant MathImage__NumSeq_Turn_min => 1; # left always
  use constant MathImage__NumSeq_Turn_max => 1;
}
{ package Math::PlanePath::VogelFloret;
  sub MathImage__NumSeq_Turn_min {
    my ($self) = @_;
    return ($self->{'radius_factor'} > 0.5 ? 0 : -1);
  }
  sub MathImage__NumSeq_Turn_max {
    my ($self) = @_;
    return ($self->{'radius_factor'} > 0.5 ? 1 : 0);
  }
}
{ package Math::PlanePath::TheodorusSpiral;
  use constant MathImage__NumSeq_Turn_min => 1; # left always
  use constant MathImage__NumSeq_Turn_max => 1;
}
{ package Math::PlanePath::ArchimedeanChords;
  use constant MathImage__NumSeq_Turn_min => 1; # left always
  use constant MathImage__NumSeq_Turn_max => 1;
}
# { package Math::PlanePath::MultipleRings;
# }
# { package Math::PlanePath::PixelRings;
# }
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
# { package Math::PlanePath::FractionsTree;
# }
# { package Math::PlanePath::DiagonalRationals;
# }
# { package Math::PlanePath::FactorRationals;
# }
# { package Math::PlanePath::GcdRationals;
# }
# { package Math::PlanePath::PeanoCurve;
# }
# { package Math::PlanePath::HilbertCurve;
# }
# { package Math::PlanePath::ZOrderCurve;
# }
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
# { package Math::PlanePath::TerdragonCurve;
# }
# { package Math::PlanePath::TerdragonMidpoint;
# }
# { package Math::PlanePath::AlternatePaper;
# }
# { package Math::PlanePath::ComplexPlus;
# }
# { package Math::PlanePath::ComplexMinus;
# }
# { package Math::PlanePath::ComplexRevolving;
# }
{ package Math::PlanePath::Rows;
  # if width==1 then always straight ahead vertical
  sub MathImage__NumSeq_Turn_min {
    my ($self) = @_;
    return ($self->{'width'} > 1 ? -1 : 0);
  }
  sub MathImage__NumSeq_Turn_max {
    my ($self) = @_;
    return ($self->{'width'} > 1 ? 1 : 0);
  }
}
{ package Math::PlanePath::Columns;
  # if height==1 then always stright ahead
  sub MathImage__NumSeq_Turn_min {
    my ($self) = @_;
    return ($self->{'height'} > 1 ? -1 : 0);
  }
  sub MathImage__NumSeq_Turn_max {
    my ($self) = @_;
    return ($self->{'height'} > 1 ? 1 : 0);
  }
}
# { package Math::PlanePath::Diagonals;
# }
# { package Math::PlanePath::Staircase;
# }
# { package Math::PlanePath::Corner;
# }
{ package Math::PlanePath::PyramidRows;
  # if step==0 then always straight ahead horizontal
  sub MathImage__NumSeq_Turn_min {
    my ($self) = @_;
    return ($self->{'step'} > 0 ? -1 : 0);
  }
  sub MathImage__NumSeq_Turn_max {
    my ($self) = @_;
    return ($self->{'step'} > 0 ? 1 : 0);
  }
}
# { package Math::PlanePath::PyramidSides;
# }
# { package Math::PlanePath::CellularRule;
# }
# { package Math::PlanePath::CellularRule54;
# }
# { package Math::PlanePath::CellularRule190;
# }
# { package Math::PlanePath::CoprimeColumns;
# }
# { package Math::PlanePath::DivisibleColumns;
# }
# { package Math::PlanePath::File;
#   # File                   points from a disk file
#   # FIXME: analyze points for dx/dy min/max etc
# }
# { package Math::PlanePath::MathImageQuintetCurve;
# }
# { package Math::PlanePath::MathImageQuintetCentres;
# }

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

  my $turn_type = $self->{'turn_type'};
  if ($turn_type eq 'X') {
    if ($planepath_object->x_negative) {
      return 1;
    } else {
      return ($value >= 0);
    }
  } elsif ($turn_type eq 'Y') {
    if ($planepath_object->y_negative) {
      return 1;
    } else {
      return ($value >= 0);
    }
  } elsif ($turn_type eq 'Sum') {
    if ($planepath_object->x_negative || $planepath_object->y_negative) {
      return 1;
    } else {
      return ($value >= 0);
    }
  } elsif ($turn_type eq 'SqRadius') {
    # FIXME: only sum of two squares, and for triangular same odd/even
    return ($value >= 0);
  }

  return undef;
}


=for stopwords Ryde MathImage PlanePath Math-NumSeq

=head1 NAME

Math::NumSeq::MathImagePlanePathTurn -- sequences of coordinates from PlanePath modules

=head1 SYNOPSIS

 use Math::NumSeq::MathImagePlanePathTurn;
 my $seq = Math::NumSeq::MathImagePlanePathTurn->new (planepath => 'SquareSpiral',
                                                   turn_type => 'LSR');
 my ($i, $value) = $seq->next;

=head1 DESCRIPTION

The sequence of turns in a C<Math::PlanePath> path.

=head1 FUNCTIONS

=over 4

=item C<$seq = Math::NumSeq::MathImagePlanePathTurn-E<gt>new (key=E<gt>value,...)>

Create and return a new sequence object.

=back

=head1 SEE ALSO

L<Math::NumSeq>,
L<Math::NumSeq::PlanePathCoord>

=cut

# Local variables:
# compile-command: "math-image --values=PlanePathTurn"
# End:

# not implemented yet
#
# =item C<$bool = $seq-E<gt>pred($value)>
# 
# Return true if C<$value> occurs as a turn.  Often this is merely the
# possible turn values 1,0,-1, etc, but some spiral paths for example only go
# left or straight in which case only 1 and 0 occur and return true from
# C<pred()>.

