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

# math-image --values=PlanePath

package App::MathImage::NumSeq::PlanePathN;
use 5.004;
use strict;
use Carp;

use vars '$VERSION','@ISA';
$VERSION = 79;
use Math::NumSeq;
@ISA = ('Math::NumSeq');

use App::MathImage::NumSeq::PlanePathCoord;

# uncomment this to run the ### lines
#use Devel::Comments;


use constant description => Math::NumSeq::__('N values from a PlanePath');

use constant::defer parameter_info_array =>
  sub {
    return [
            App::MathImage::NumSeq::PlanePathCoord::_parameter_info_planepath(),

            { name    => 'line_type',
              display => Math::NumSeq::__('Line Type'),
              type    => 'enum',
              default => 'X_axis',
              choices => ['X_axis','Y_axis','X_neg','Y_neg',
                          # 'NE','NW','SW','SE',
                         ],
              # description => Math::NumSeq::__(''),
            },
           ];
  };

my %oeis_anum
  = ('Math::PlanePath::HilbertCurve' =>
     { X_axis => 'A163482',
       Y_axis => 'A163483',
       # OEIS-Catalogue: A163482 planepath=HilbertCurve line_type=X_axis
       # OEIS-Catalogue: A163483 planepath=HilbertCurve line_type=Y_axis
     },
    );

sub oeis_anum {
  my ($self) = @_;
  return $oeis_anum{App::MathImage::NumSeq::PlanePathCoord::_planepath_oeis_key($self->{'planepath_object'})} -> {$self->{'line_type'}};
}

sub new {
  my $class = shift;
  ### NumSeq-PlanePathN new(): @_

  my $self = $class->SUPER::new(@_);

  my $planepath_object = ($self->{'planepath_object'}
                          ||= App::MathImage::NumSeq::PlanePathCoord::_planepath_name_to_object($self->{'planepath'}));

  $self->{'i_func'}
    = $self->can('i_func_'.$self->{'line_type'})
      || croak "Unrecognised line_type: ",$self->{'line_type'};

  $self->{'A2_factor'} = ($planepath_object->MathImage__NumSeq_A2 ? 2 : 1);
  $self->rewind;
  return $self;
}

sub rewind {
  my ($self) = @_;
  $self->{'i'} = 0;
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
  return $self->{'planepath_object'}->xy_to_n($i * $self->{'A2_factor'},0);
}
sub i_func_Y_axis {
  my ($self, $i) = @_;
  return $self->{'planepath_object'}->xy_to_n(0,$i);
}
sub i_func_X_neg {
  my ($self, $i) = @_;
  return $self->{'planepath_object'}->xy_to_n(-$i,0);
}
sub i_func_Y_neg {
  my ($self, $i) = @_;
  return $self->{'planepath_object'}->xy_to_n(0,-$i);
}


#------------------------------------------------------------------------------

sub characteristic_monotonic {
  my ($self) = @_;
  my $method = 'MathImage__NumSeq_' . $self->{'line_type'} . '_monotonic';
  my $planepath_object = $self->{'planepath_object'};
  return $planepath_object->can($method) && $planepath_object->$method();
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
    return $path->xy_to_n(0,0);
  }
  sub MathImage__NumSeq_Y_axis_min {
    my ($path) = @_;
    return $path->xy_to_n(0,0);
  }
  sub MathImage__NumSeq_X_neg_min {
    my ($path) = @_;
    return $path->xy_to_n(0,0);
  }
  sub MathImage__NumSeq_Y_neg_min {
    my ($path) = @_;
    return $path->xy_to_n(0,0);
  }

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
  use constant MathImage__NumSeq_X_axis_monotonic => 1;
  use constant MathImage__NumSeq_Y_axis_monotonic => 1;
}
# { package Math::PlanePath::PyramidSpiral;
# }
# { package Math::PlanePath::TriangleSpiral;
# }
# { package Math::PlanePath::TriangleSpiralSkewed;
# }
{ package Math::PlanePath::DiamondSpiral;
  use constant MathImage__NumSeq_X_axis_monotonic => 1;
  use constant MathImage__NumSeq_Y_axis_monotonic => 1;
}
# { package Math::PlanePath::PentSpiralSkewed;
# }
# { package Math::PlanePath::HexSpiral;
# }
# { package Math::PlanePath::HexSpiralSkewed;
# }
# { package Math::PlanePath::HeptSpiralSkewed;
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
  use constant MathImage__NumSeq_X_axis_monotonic => 1;
  use constant MathImage__NumSeq_Y_axis_monotonic => 1;
}
# { package Math::PlanePath::VogelFloret;
# }
# { package Math::PlanePath::TheodorusSpiral;
# }
# { package Math::PlanePath::ArchimedeanChords;
# }
# { package Math::PlanePath::MultipleRings;
# }
{ package Math::PlanePath::PixelRings;
  use constant MathImage__NumSeq_X_axis_monotonic => 1;
  use constant MathImage__NumSeq_Y_axis_monotonic => 1;
}
{ package Math::PlanePath::Hypot;
  use constant MathImage__NumSeq_X_axis_monotonic => 1;
  use constant MathImage__NumSeq_Y_axis_monotonic => 1;
}
{ package Math::PlanePath::HypotOctant;
  use constant MathImage__NumSeq_X_axis_monotonic => 1;
  use constant MathImage__NumSeq_Y_axis_monotonic => 1;
}
# { package Math::PlanePath::TriangularHypot;
# }
# { package Math::PlanePath::PythagoreanTree;
# }
# { package Math::PlanePath::RationalsTree;
# }
# { package Math::PlanePath::PeanoCurve;
# }
# { package Math::PlanePath::HilbertCurve;
# }
{ package Math::PlanePath::ZOrderCurve;
  use constant MathImage__NumSeq_X_axis_monotonic => 1;
  use constant MathImage__NumSeq_Y_axis_monotonic => 1;
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
# { package Math::PlanePath::Rows;
# }
# { package Math::PlanePath::Columns;
# }
# { package Math::PlanePath::Diagonals;
# }
{ package Math::PlanePath::Staircase;
  use constant MathImage__NumSeq_X_axis_monotonic => 1;
  use constant MathImage__NumSeq_Y_axis_monotonic => 1;
}
{ package Math::PlanePath::Corner;
  use constant MathImage__NumSeq_X_axis_monotonic => 1;
  use constant MathImage__NumSeq_Y_axis_monotonic => 1;
}
# { package Math::PlanePath::PyramidRows;
# }
{ package Math::PlanePath::PyramidSides;
  use constant MathImage__NumSeq_X_axis_monotonic => 1;
  use constant MathImage__NumSeq_Y_axis_monotonic => 1;
}
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
#   # inherit QuintetCurve
# }

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

App::MathImage::NumSeq::PlanePathN -- sequence of N values from PlanePath module

=head1 SYNOPSIS

 use App::MathImage::NumSeq::PlanePathN;
 my $seq = App::MathImage::NumSeq::PlanePathN->new (planepath => 'SquareSpiral',
                                                    line_type => 'X');
 my ($i, $value) = $seq->next;

=head1 DESCRIPTION

This module gives N values from a C<Math::PlanePath> as a sequence.

=head1 FUNCTIONS

=over 4

=item C<$seq = App::MathImage::NumSeq::PlanePathN-E<gt>new (key=E<gt>value,...)>

Create and return a new sequence object.

=back

=head1 SEE ALSO

L<Math::NumSeq>

=cut
