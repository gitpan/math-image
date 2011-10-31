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

package App::MathImage::NumSeq::PlanePathCoord;
use 5.004;
use strict;
use Carp;

use vars '$VERSION','@ISA';
$VERSION = 79;
use Math::NumSeq;
@ISA = ('Math::NumSeq');

# uncomment this to run the ### lines
#use Devel::Comments;


use constant description => Math::NumSeq::__('Coordinate values from a PlanePath');
use constant characteristic_smaller => 1;

use constant::defer parameter_info_array =>
  sub {
    return [
            _parameter_info_planepath(),
            { name    => 'coordinate_type',
              display => Math::NumSeq::__('Coordinate Type'),
              type    => 'enum',
              default => 'X',
              choices => ['X','Y','Sum','Radius','RSq',
                         ],
              # description => Math::NumSeq::__(''),
            },
           ];
  };

use constant::defer _parameter_info_planepath => sub {
  # require Module::Util;
  # cf App::MathImage::Generator->path_choices() order
  # my @choices = sort map { s/.*:://;
  #                          if (length() > $width) { $width = length() }
  #                          $_ }
  #   Module::Util::find_in_namespace('Math::PlanePath');

  # my $choices = App::MathImage::Generator->path_choices_array;
  # foreach (@$choices) {
  #   if (length() > $width) { $width = length() }
  # }

  require File::Spec;
  require Scalar::Util;
  my $width = 0;
  my %names;

  foreach my $dir (@INC) {
    next if ! defined $dir || ref $dir;
    # next if ref $dir eq 'CODE'  # subr
    #   || ref $dir eq 'ARRAY'    # array of subr and more
    #     || Scalar::Util::blessed($dir);

    opendir DIR, File::Spec->catdir ($dir, 'Math', 'PlanePath') or next;
    while (my $name = readdir DIR) {
      $name =~ s/\.pm$// or next;
      if (length($name) > $width) { $width = length($name) }
      $names{$name} = 1;  # hash slice
    }
    closedir DIR;
  }
  my $choices = [ sort keys %names ];

  return { name    => 'planepath',
           display => Math::NumSeq::__('PlanePath Class'),
           type    => 'string',
           default => $choices->[0],
           choices => $choices,
           width   => $width + 20,
           # description => Math::NumSeq::__(''),
         };
};

my %oeis_anum
  = ('Math::PlanePath::HilbertCurve' =>
     { X => 'A059253',
       Y => 'A059252',
       # OEIS-Catalogue: A059253 planepath=HilbertCurve coordinate_type=X
       # OEIS-Catalogue: A059252 planepath=HilbertCurve coordinate_type=Y
     },

     'Math::PlanePath::PeanoCurve,radix=3' =>
     { X => 'A163528',
       Y => 'A163529',
       Sum => 'A163530',
       RSq => 'A163531',
       # OEIS-Catalogue: A163528 planepath=PeanoCurve coordinate_type=X
       # OEIS-Catalogue: A163529 planepath=PeanoCurve coordinate_type=Y
       # OEIS-Catalogue: A163530 planepath=PeanoCurve coordinate_type=Sum
       # OEIS-Catalogue: A163531 planepath=PeanoCurve coordinate_type=RSq
     },

     'Math::PlanePath::RationalsTree,tree_type=Bird' =>
     { X => 'A162909', # Bird tree numerators
       Y => 'A162910', # Bird tree denominators
       # OEIS-Catalogue: A162909 planepath=RationalsTree,tree_type=Bird coordinate_type=X
       # OEIS-Catalogue: A162910 planepath=RationalsTree,tree_type=Bird coordinate_type=Y
     },

     'Math::PlanePath::RationalsTree,tree_type=Drib' =>
     { X => 'A162911', # Drib tree numerators
       Y => 'A162912', # Drib tree denominators
       # OEIS-Catalogue: A162911 planepath=RationalsTree,tree_type=Drib coordinate_type=X
       # OEIS-Catalogue: A162912 planepath=RationalsTree,tree_type=Drib coordinate_type=Y
     },
    );

sub oeis_anum {
  my ($self) = @_;
  ### oeis_anum(), path key: _planepath_oeis_key($self->{'planepath_object'})

  return $oeis_anum{_planepath_oeis_key($self->{'planepath_object'})}
    -> {$self->{'coordinate_type'}};
}

sub _planepath_oeis_key {
  my ($path) = @_;
  return join(',',
              ref($path),
              map {
                my $value = $path->{$_->{'name'}};
                ### $_
                ### $value
                ### gives: "$_->{'name'}=$value"
                (defined $value ? "$_->{'name'}=$value" : ())
              }
              $path->parameter_info_list);
}

sub new {
  my $class = shift;
  ### NumSeq-PlanePathCoord new(): @_

  my $self = $class->SUPER::new(@_);

  my $planepath_object = ($self->{'planepath_object'}
                          ||= _planepath_name_to_object($self->{'planepath'}));
  $self->{'coordinate_func'}
    = $self->can('coordinate_func_'.$self->{'coordinate_type'})
      || croak "Unrecognised coordinate_type: ",$self->{'coordinate_type'};
  $self->rewind;
  return $self;
}

sub _planepath_name_to_object {
  my ($name) = @_;
  ($name, my @args) = split /,+/, $name;
  $name = "Math::PlanePath::$name";
  require Module::Load;
  Module::Load::load ($name);
  return $name->new (map {/(.*?)=(.*)/} @args);

  # width => $options{'width'},
  # height => $options{'height'},
}

sub rewind {
  my ($self) = @_;
  $self->{'i'} = 0;
  $self->{'n_next'} = ($self->{'planepath_object'}
                       ? $self->{'planepath_object'}->n_start
                       : 0);
}

sub next {
  my ($self) = @_;
  ### NumSeq-PlanePath next(): "$self->{'i'}, n_next $self->{'n_next'}"

  my ($x, $y) = $self->{'planepath_object'}->n_to_xy($self->{'n_next'}++)
    or return;
  return ($self->{'i'}++,
          &{$self->{'coordinate_func'}}($self, $x,$y));
}

sub ith {
  my ($self, $i) = @_;
  ### NumSeq-PlanePath ith(): $i

  my $planepath_object = $self->{'planepath_object'};
  my ($x, $y) = $planepath_object->n_to_xy ($i + $planepath_object->n_start)
    or return undef;
  return &{$self->{'coordinate_func'}}($self, $x,$y);
}

sub coordinate_func_X {
  my ($self, $x,$y) = @_;
  return $x;
}
sub coordinate_func_Y {
  my ($self, $x,$y) = @_;
  return $y;
}
sub coordinate_func_Sum {
  my ($self, $x,$y, $prev_x,$prev_y) = @_;
  return $x+$y;
}
sub coordinate_func_Radius {
  return sqrt(coordinate_func_RSq(@_));
}
sub coordinate_func_RSq {
  my ($self, $x,$y, $prev_x,$prev_y) = @_;
  return $x*$x + $y*$y;
}


#------------------------------------------------------------------------------

sub characteristic_monotonic {
  my ($self) = @_;
  my $planepath_object = $self->{'planepath_object'};
  my $method = 'MathImage__NumSeq_' . $self->{'coordinate_type'} . '_monotonic';
  return $planepath_object->can($method) && $planepath_object->$method();
}

sub values_min {
  my ($self) = @_;
  my $method = 'MathImage__NumSeq_' . $self->{'coordinate_type'} . '_min';
  return $self->{'planepath_object'}->$method();
}

sub values_max {
  my ($self) = @_;
  my $method = 'MathImage__NumSeq_' . $self->{'coordinate_type'} . '_max';
  return $self->{'planepath_object'}->$method();
}

{ package Math::PlanePath;
  sub MathImage__NumSeq_X_min {
    my ($self) = @_;
    return ($self->x_negative ? undef : 0);
  }
  use constant MathImage__NumSeq_X_max => undef;

  sub MathImage__NumSeq_Y_min {
    my ($self) = @_;
    return ($self->x_negative ? undef : 0);
  }
  use constant MathImage__NumSeq_Y_max => undef;

  sub MathImage__NumSeq_Sum_min {
    my ($self) = @_;
    return ($self->x_negative || $self->y_negative
            ? undef
            : 0);  # X>=0 and Y>=0
  }
  use constant MathImage__NumSeq_Sum_max => undef;

  sub MathImage__NumSeq_Radius_min {
    return sqrt($_[0]->MathImage__NumSeq_RSq_min);
  }
  sub MathImage__NumSeq_Radius_max {
    my $max = $_[0]->MathImage__NumSeq_RSq_max;
    return (defined $max ? sqrt($max) : undef);
  }
  use constant MathImage__NumSeq_RSq_min => 0;
  use constant MathImage__NumSeq_RSq_max => undef;

  sub MathImage__NumSeq_pred_X {
    my ($path, $value) = @_;
    return (($path->figure ne 'square' || $value == int($value))
            && ($path->x_negative || $value >= 0));
  }
  sub MathImage__NumSeq_pred_Y {
    my ($path, $value) = @_;
    return (($path->figure ne 'square' || $value == int($value))
            && ($path->y_negative || $value >= 0));
  }
  sub MathImage__NumSeq_pred_Sum {
    my ($path, $value) = @_;
    return (($path->figure ne 'square' || $value == int($value))
            && ($path->x_negative || $path->y_negative || $value >= 0));
  }
  sub MathImage__NumSeq_pred_R {
    my ($path, $value) = @_;
    return ($value >= 0);
  }
  sub MathImage__NumSeq_pred_RSq {
    my ($path, $value) = @_;
    # whether x^2+y^2 ...
    return (($path->figure ne 'square' || $value == int($value))
            && $value >= 0);
  }
}

# { package Math::PlanePath::SquareSpiral;
# }
# { package Math::PlanePath::PyramidSpiral;
# }
# { package Math::PlanePath::TriangleSpiralSkewed;
# }
# { package Math::PlanePath::DiamondSpiral;
# }
# { package Math::PlanePath::PentSpiralSkewed;
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
# { package Math::PlanePath::GreekKeySpiral;
# }
# { package Math::PlanePath::SacksSpiral;
# }
# { package Math::PlanePath::VogelFloret;
# }
# { package Math::PlanePath::TheodorusSpiral;
# }
# { package Math::PlanePath::ArchimedeanChords;
# }
# { package Math::PlanePath::MultipleRings;
# }
# { package Math::PlanePath::PixelRings;
# }
# { package Math::PlanePath::Hypot;
# }
# { package Math::PlanePath::HypotOctant;
# }
{ package Math::PlanePath::PythagoreanTree;
  sub MathImage__NumSeq_pred_R {
    my ($path, $value) = @_;
    return ($value >= 0
            && ($path->{'coordinate_type'} ne 'AB' || $value == int($value)));
  }
}
# { package Math::PlanePath::RationalsTree;
# }
# { package Math::PlanePath::PeanoCurve;
# }
# { package Math::PlanePath::HilbertCurve;
# }
# { package Math::PlanePath::ZOrderCurve;
# }
# { package Math::PlanePath::ImaginaryBase;
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
{ package Math::PlanePath::QuadricCurve;
  use constant MathImage__NumSeq_Sum_min => 0;  # triangular X>=-Y
}
{ package Math::PlanePath::QuadricIslands;
}
{ package Math::PlanePath::SierpinskiTriangle;
  use constant MathImage__NumSeq_Sum_min => 0;  # triangular X>=-Y
}
{ package Math::PlanePath::SierpinskiArrowhead;
  use constant MathImage__NumSeq_Sum_min => 0;  # triangular X>=-Y
}
{ package Math::PlanePath::SierpinskiArrowheadCentres;
  use constant MathImage__NumSeq_Sum_min => 0;  # triangular X>=-Y
}
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
# { package Math::PlanePath::Staircase;
# }
# { package Math::PlanePath::Corner;
# }
{ package Math::PlanePath::PyramidRows;
  sub MathImage__NumSeq_X_max {
    my ($self) = @_;
    return ($self->{'step'} == 0
            ? 0    # X=0 vertical
            : undef);
  }
  sub MathImage__NumSeq_Sum_min {
    my ($self) = @_;
    return ($self->{'step'} <= 2
            ? 0    # triangular X>=-Y for step=2, vertical X>=0 step=1,0
            : undef);
  }
}
{ package Math::PlanePath::PyramidSides;
}
{ package Math::PlanePath::CellularRule54;
  use constant MathImage__NumSeq_Sum_min => 0;  # triangular X>=-Y
}
{ package Math::PlanePath::CellularRule190;
  use constant MathImage__NumSeq_Sum_min => 0;  # triangular X>=-Y
}
{ package Math::PlanePath::UlamWarburton;
}
{ package Math::PlanePath::UlamWarburtonQuarter;
  use constant MathImage__NumSeq_Sum_min => 0;  # triangular Y>=-X
}
# { package Math::PlanePath::CoprimeColumns;
# }
# { package Math::PlanePath::DivisibleColumns;
# }
{ package Math::PlanePath::File;
  # File                   points from a disk file
  # FIXME: analyze points for min/max maybe
}
# { package Math::PlanePath::QuintetCurve;
# }
# { package Math::PlanePath::QuintetCentres;
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

#------------------------------------------------------------------------------
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

  my $coordinate_type = $self->{'coordinate_type'};
  if ($coordinate_type eq 'X') {
    if ($planepath_object->x_negative) {
      return 1;
    } else {
      return ($value >= 0);
    }
  } elsif ($coordinate_type eq 'Y') {
    if ($planepath_object->y_negative) {
      return 1;
    } else {
      return ($value >= 0);
    }
  } elsif ($coordinate_type eq 'Sum') {
    if ($planepath_object->x_negative || $planepath_object->y_negative) {
      return 1;
    } else {
      return ($value >= 0);
    }
  } elsif ($coordinate_type eq 'RSq') {
    # FIXME: only sum of two squares, and for triangular same odd/even
    return ($value >= 0);
  }

  return undef;
}


=for stopwords Ryde MathImage Math-PlanePath PlanePath

=head1 NAME

App::MathImage::NumSeq::PlanePathCoord -- sequence of coordinate values from a PlanePath module

=head1 SYNOPSIS

 use App::MathImage::NumSeq::PlanePathCoord;
 my $seq = App::MathImage::NumSeq::PlanePathCoord->new (planepath => 'SquareSpiral',
                                                        coordinate_type => 'X');
 my ($i, $value) = $seq->next;

=head1 DESCRIPTION

This module gives a coordinate from a C<Math::PlanePath> as a sequence.

=head1 FUNCTIONS

=over 4

=item C<$seq = App::MathImage::NumSeq::PlanePathCoord-E<gt>new (planepath =E<gt> $name, coordinate_type =E<gt> 'X')>

Create and return a new sequence object.  The C<planepath> option is the
name of one of the C<Math::PlanePath> modules.

The C<coordinate_type> option (a string) is which coordinate from the path's
X,Y is wanted.  The choices are

    "X"      the X coordinate
    "Y"      the Y coordinate

=item C<$value = $seq-E<gt>ith($i)>

Return the coordinate at N=$i in the PlanePath.

=back

=head1 SEE ALSO

L<Math::NumSeq>

=cut

# Local variables:
# compile-command: "math-image --values=PlanePathCoord"
# End:
