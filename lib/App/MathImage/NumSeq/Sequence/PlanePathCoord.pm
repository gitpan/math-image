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

package App::MathImage::NumSeq::Sequence::PlanePathCoord;
use 5.004;
use strict;
use Carp;
use List::Util 'max';
use Locale::TextDomain 'App-MathImage';

use base 'App::MathImage::NumSeq::Sequence';

use vars '$VERSION';
$VERSION = 49;

# uncomment this to run the ### lines
#use Smart::Comments;

use constant name => __('PlanePath Coords');
# use constant description => __('');
my @choices = (map { s/.*:://; $_ }
               Module::Util::find_in_namespace('Math::PlanePath'),
              );
### @choices
use constant parameter_list => ({ name    => 'planepath_class',
                                  display => __('PlanePath Class'),
                                  type    => 'enum',
                                  default => 'SquareSpiral',
                                  choices => \@choices,
                                  # width   => 3 + max(0,map{length}@choices),
                                  # description => __(''),
                                },
                                { name    => 'coord_type',
                                  display => __('Coord Type'),
                                  type    => 'enum',
                                  default => 'X',
                                  choices => ['X','Y','Sum','SqDist'],
                                  # description => __(''),
                                },
                               );
# OeisCatalogue: A059253 planepath_class=HilbertCurve coord_type=X
# OeisCatalogue: A059252 planepath_class=HilbertCurve coord_type=Y
# OeisCatalogue: A163528 planepath_class=PeanoCurve coord_type=X
# OeisCatalogue: A163529 planepath_class=PeanoCurve coord_type=Y
# OeisCatalogue: A163530 planepath_class=PeanoCurve coord_type=Sum
# OeisCatalogue: A163531 planepath_class=PeanoCurve coord_type=SqDist


sub new {
  my ($class, %options) = @_;
  ### PlanePathCoord new(): @_

  my $planepath_object = $options{'planepath_object'}
    || do {
      my $path_class = $options{'planepath_class'}
        || (parameter_list)[0]->{'default'};
      unless ($path_class =~ /::/) {
        my $fullclass = "Math::PlanePath::$path_class";
        if (Module::Util::find_installed($fullclass)) {
          $path_class = $fullclass;
        } else {
          croak "No such planepath class: ",$path_class;
        }
      }
      Module::Load::load ($path_class);
      $path_class->new;
    };
  ### $planepath_object

  my $coord_type = $options{'coord_type'} || (parameter_list)[1]->{'default'};
  my $coord_func = $class->can("coord_func_$coord_type")
    || croak "Unrecognised coord_type: ",$coord_type;

  my ($n_start, undef) = $planepath_object->rect_to_n_range (0,0, 0,0);
  ### $n_start

  my $self = bless { planepath_object => $planepath_object,
                     coord_func       => $coord_func,
                     type_hash => {},
                     n_start   => $n_start,
                     i         => 0,
                     prev_x    => 0,
                     prev_y    => 0,
                   }, $class;

  return $self;
}

sub next {
  my ($self) = @_;
  ### PlanePathCoord next(): $self->{'i'}
  my $i = $self->{'i'}++;
  my ($x, $y) = $self->{'planepath_object'}->n_to_xy($i + $self->{'n_start'});
  my $ret = &{$self->{'coord_func'}}
    ($self->{'prev_x'},$self->{'prev_y'}, $x,$y);
  $self->{'prev_x'} = $x;
  $self->{'prev_y'} = $y;
  ### $ret
  return ($i, $ret);
}

sub coord_func_X {
  my ($x,$y) = @_;
  return $x;
}
sub coord_func_Y {
  my ($x,$y) = @_;
  return $y;
}
sub coord_func_Sum {
  my ($x,$y) = @_;
  return $x+$y;
}
sub coord_func_SqDist {
  my ($x,$y) = @_;
  return $x*$x + $y*$y;
}

# sub pred {
#   my ($self, $n) = @_;
#   return (($n >= 0)
#           && do {
#             $n = sqrt($n);
#             $n == int($n)
#           });
# }

1;
__END__
