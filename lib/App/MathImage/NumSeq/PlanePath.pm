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

package App::MathImage::NumSeq::PlanePath;
use 5.004;
use strict;
use Carp;

use vars '$VERSION','@ISA';
$VERSION = 74;
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
    # cf App::MathImage::Generator->path_choices() order
    # my @choices = sort map { s/.*:://;
    #                          if (length() > $width) { $width = length() }
    #                          $_ }
    #   Module::Util::find_in_namespace('Math::PlanePath');

    my $choices = App::MathImage::Generator->path_choices_array;
    my $width = 0;
    foreach (@$choices) {
      if (length() > $width) { $width = length() }
    }

    return [
            { name    => 'planepath',
              display => Math::NumSeq::__('PlanePath Class'),
              type    => 'string',
              default => 'SquareSpiral',
              choices => $choices,
              width   => 5 + $width,
              # description => Math::NumSeq::__(''),
            },
            { name    => 'coord_type',
              display => Math::NumSeq::__('Coordinate Type'),
              type    => 'enum',
              default => 'X',
              choices => ['X','Y','Sum','Radius','RSquared',
                          'dX','dY','dDist','dDistSq',
                          'ENSW', 'Turn'],
              # description => Math::NumSeq::__(''),
            },
           ];
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
      $planepath->new (width => $options{'width'},
                       height => $options{'height'},
                       map {/(.*?)=(.*)/} @args);
    };
  ### $planepath_object

  my $coord_type = $options{'coord_type'} || 'X';
  my $coord_func = $class->can("coord_func_$coord_type")
    || croak "Unrecognised coord_type: ",$coord_type;

  my $self = bless { planepath_object => $planepath_object,
                     coord_type => $coord_type, # for oeis_anum()
                     coord_func => $coord_func,
                     type_hash  => {},
                   }, $class;
  $self->rewind;
  return $self;
}

sub rewind {
  my ($self) = @_;
  $self->{'i'} = 0;
  my $planepath_object = $self->{'planepath_object'};

  my $n = $planepath_object->n_start;
  ### $n

  if ($self->{'coord_type'} =~ /^[dT]/) {
    my ($x, $y) = $planepath_object->n_to_xy ($n++);
    if ($self->{'coord_type'} eq 'Turn') {
      my ($next_x, $next_y) = $planepath_object->n_to_xy ($n++);
      $self->{'prev_dx'} = $next_x - $x;
      $self->{'prev_dy'} = $next_y - $y;
      $self->{'prev_x'} = $next_x;
      $self->{'prev_y'} = $next_y;
    } else {
      $self->{'prev_x'} = $x;
      $self->{'prev_y'} = $y;
    }
  }
  $self->{'n_next'} = $n;
}

sub next {
  my ($self) = @_;
  ### NumSeq-PlanePath next(): $self->{'i'}
  ### n_next: $self->{'n_next'}

  my $i = $self->{'i'}++;

  my ($x, $y) = $self->{'planepath_object'}->n_to_xy($self->{'n_next'}++)
    or return;
  my $ret = &{$self->{'coord_func'}}($self, $x,$y,
                                     $self->{'prev_x'},$self->{'prev_y'});
  $self->{'prev_x'} = $x;
  $self->{'prev_y'} = $y;
  return ($i, $ret);
}

sub ith {
  my ($self, $i) = @_;
  ### NumSeq-PlanePath ith(): $i

  my $planepath_object = $self->{'planepath_object'};
  my $n = $i + $planepath_object->n_start;
  my ($x, $y)
    = $planepath_object->n_to_xy ($n)
      or return undef;

  if ($self->{'coord_type'} =~ /^[dT]/) {
    my ($next_x, $next_y)
      = $planepath_object->n_to_xy ($n += 1)
        or return undef;

    if ($self->{'coord_type'} eq 'Turn') {
      my ($next_next_x, $next_next_y)
        = $planepath_object->n_to_xy ($n += 1)
          or return undef;
      my $next_dx = $next_next_x - $next_x;
      my $next_dy = $next_next_y - $next_y;
      my $dx = $next_x - $x;
      my $dy = $next_y - $y;

      ### ith path: "n=$n"
      ### ith at: "$x,$y  $next_x,$next_y  $next_next_x,$next_next_y"
      ### ith deltas: "$dx,$dy  $next_dx,$next_dy"
      ### ith ret: ($next_dy * $dx <=> $next_dx * $dy)

      return ($next_dy * $dx <=> $next_dx * $dy);
    }

    return ($i, &{$self->{'coord_func'}}($self, $next_x,$next_y, $x,$y));
  }
  return ($i, &{$self->{'coord_func'}}($self, $x,$y));
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
  my ($self, $x,$y, $prev_x,$prev_y) = @_;
  return $prev_x+$prev_y;
}
sub coord_func_Radius {
  return sqrt(coord_func_RSquared(@_));
}
sub coord_func_RSquared {
  my ($self, $x,$y, $prev_x,$prev_y) = @_;
  return $prev_x*$prev_x + $prev_y*$prev_y;
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
  return sqrt(coord_func_dDistSq(@_));
}
sub coord_func_dDistSq {
  my ($self, $x,$y, $prev_x,$prev_y) = @_;
  $x -= $prev_x;
  $y -= $prev_y;
  return $x*$x + $y*$y;
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
sub coord_func_Turn {
  my ($self, $x,$y, $prev_x,$prev_y) = @_;

  my $dx = $x - $prev_x;
  my $dy = $y - $prev_y;

  ### next at: "prev=$prev_x,$prev_y  xy=$x,$y"
  ### next deltas: "dprev=$self->{'prev_dx'},$self->{'prev_dy'}  dxy=$dx,$dy"
  ### next ret: ($dx * $self->{'prev_dy'} <=> $dy * $self->{'prev_dx'})

  my $ret = ( $dy * $self->{'prev_dx'} <=> $dx * $self->{'prev_dy'});

  $self->{'prev_dx'} = $dx;
  $self->{'prev_dy'} = $dy;
  return $ret;
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

sub values_min {
  my ($self) = @_;

  my $method = 'MathImage__NumSeq_' . $self->{'coord_type'} . '_min';
  return $self->{'planepath_object'}->$method;

  # my $planepath_object = $self->{'planepath_object'};
  # my $coord_type = $self->{'coord_type'};
  # 
  # if ($coord_type eq 'X') {
  #   if (! $planepath_object->x_negative) {
  #     return 0;
  #   }
  # 
  # } elsif ($coord_type eq 'Y') {
  #   if (! $planepath_object->y_negative) {
  #     return 0;
  #   }
  # 
  # } elsif ($coord_type eq 'Sum') {
  #   return $planepath_object->MathImage__NumSeq_Sum_min;
  # 
  # } elsif ($coord_type eq 'Radius'
  #          || $coord_type eq 'RSquared'
  #          || $coord_type eq 'dDist'
  #          || $coord_type eq 'dDistSq'
  #          ) {
  #   return 0;
  # 
  # } elsif ($coord_type eq 'dX') {
  #   return $planepath_object->MathImage__NumSeq_dX_min;
  # } elsif ($coord_type eq 'dY') {
  #   return $planepath_object->MathImage__NumSeq_dY_min;
  # 
  # } elsif ($coord_type eq 'dDistSq') {
  #   return $planepath_object->MathImage__NumSeq_dDistSq_min;
  # }
}

sub values_max {
  my ($self) = @_;

  my $method = 'MathImage__NumSeq_' . $self->{'coord_type'} . '_max';
  return $self->{'planepath_object'}->$method;

  # my $planepath_object = $self->{'planepath_object'};
  # my $coord_type = $self->{'coord_type'};
  # 
  # if ($coord_type eq 'dX') {
  #   return $planepath_object->MathImage__NumSeq_dX_max;
  # } elsif ($coord_type eq 'dY') {
  #   return $planepath_object->MathImage__NumSeq_dY_max;
  # 
  # } elsif ($coord_type eq 'dDistSq') {
  #   return $planepath_object->MathImage__NumSeq_dDistSq_max;
  # }
  # 
  # return undef;
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

  sub MathImage__NumSeq_Radius_min { sqrt($_[0]->MathImage__NumSeq_RSquared_min) }
  sub MathImage__NumSeq_Radius_max {
    my $max = $_[0]->MathImage__NumSeq_RSquared_max;
    return (defined $max ? sqrt($max) : undef);
  }
  use constant MathImage__NumSeq_RSquared_min => 0;
  use constant MathImage__NumSeq_RSquared_max => undef;

  use constant MathImage__NumSeq_dX_min => undef;
  use constant MathImage__NumSeq_dX_max => undef;

  use constant MathImage__NumSeq_dY_min => undef;
  use constant MathImage__NumSeq_dY_max => undef;

  sub MathImage__NumSeq_dDist_min { sqrt($_[0]->MathImage__NumSeq_dDistSq_min) }
  sub MathImage__NumSeq_dDist_max {
    my $max = $_[0]->MathImage__NumSeq_dDistSq_max;
    return (defined $max ? sqrt($max) : undef);
  }

  use constant MathImage__NumSeq_dDistSq_min => undef;
  use constant MathImage__NumSeq_dDistSq_max => undef;

  use constant MathImage__NumSeq_Turn_min => -1;
  use constant MathImage__NumSeq_Turn_max => 1;

  use constant MathImage__NumSeq_ENSW_min => 0;
  use constant MathImage__NumSeq_ENSW_max => 3;
}

{ package Math::PlanePath::SquareSpiral;
  use constant MathImage__NumSeq_dX_min => -1;
  use constant MathImage__NumSeq_dX_max => 1;
  use constant MathImage__NumSeq_dY_min => -1;
  use constant MathImage__NumSeq_dY_max => 1;
  use constant MathImage__NumSeq_dDistSq_min => 1;
  use constant MathImage__NumSeq_dDistSq_max => 1;
  use constant MathImage__NumSeq_Turn_min => 0; # left or straight
  use constant MathImage__NumSeq_Turn_max => 1;
}
{ package Math::PlanePath::PyramidSpiral;
  use constant MathImage__NumSeq_dX_min => -1;
  use constant MathImage__NumSeq_dX_max => 1;
  use constant MathImage__NumSeq_dY_min => -1;
  use constant MathImage__NumSeq_dY_max => 1;
  use constant MathImage__NumSeq_dDistSq_min => 1;
  use constant MathImage__NumSeq_dDistSq_max => 2;
  use constant MathImage__NumSeq_Turn_min => 0; # left or straight
  use constant MathImage__NumSeq_Turn_max => 1;
}
{ package Math::PlanePath::TriangleSpiral;
  use constant MathImage__NumSeq_dX_min => -1;
  use constant MathImage__NumSeq_dX_max => 2;
  use constant MathImage__NumSeq_dY_min => -1;
  use constant MathImage__NumSeq_dY_max => 1;
  use constant MathImage__NumSeq_dDistSq_min => 2;
  use constant MathImage__NumSeq_dDistSq_max => 4;
  use constant MathImage__NumSeq_Turn_min => 0; # left or straight
  use constant MathImage__NumSeq_Turn_max => 1;
}
{ package Math::PlanePath::TriangleSpiralSkewed;
  use constant MathImage__NumSeq_dX_min => -1;
  use constant MathImage__NumSeq_dX_max => 1;
  use constant MathImage__NumSeq_dY_min => -1;
  use constant MathImage__NumSeq_dY_max => 1;
  use constant MathImage__NumSeq_dDistSq_min => 1;
  use constant MathImage__NumSeq_dDistSq_max => 2;
  use constant MathImage__NumSeq_Turn_min => 0; # left or straight
  use constant MathImage__NumSeq_Turn_max => 1;
}
{ package Math::PlanePath::DiamondSpiral;
  use constant MathImage__NumSeq_dX_min => -1;
  use constant MathImage__NumSeq_dX_max => 1;
  use constant MathImage__NumSeq_dY_min => -1;
  use constant MathImage__NumSeq_dY_max => 1;
  use constant MathImage__NumSeq_dDistSq_min => 1;
  use constant MathImage__NumSeq_dDistSq_max => 2;
  use constant MathImage__NumSeq_Turn_min => 0; # left or straight
  use constant MathImage__NumSeq_Turn_max => 1;
}
{ package Math::PlanePath::PentSpiralSkewed;
  use constant MathImage__NumSeq_dX_min => -1;
  use constant MathImage__NumSeq_dX_max => 1;
  use constant MathImage__NumSeq_dY_min => -1;
  use constant MathImage__NumSeq_dY_max => 1;
  use constant MathImage__NumSeq_dDistSq_min => 1;
  use constant MathImage__NumSeq_dDistSq_max => 2;
  use constant MathImage__NumSeq_Turn_min => 0; # left or straight
  use constant MathImage__NumSeq_Turn_max => 1;
}
{ package Math::PlanePath::HexSpiral;
  use constant MathImage__NumSeq_dX_min => -2;
  use constant MathImage__NumSeq_dX_max => 2;
  use constant MathImage__NumSeq_dY_min => -1;
  use constant MathImage__NumSeq_dY_max => 1;
  use constant MathImage__NumSeq_dDistSq_min => 2;
  use constant MathImage__NumSeq_dDistSq_max => 4;
  use constant MathImage__NumSeq_Turn_min => 0; # left or straight
  use constant MathImage__NumSeq_Turn_max => 1;
}
{ package Math::PlanePath::HexSpiralSkewed;
  use constant MathImage__NumSeq_dX_min => -1;
  use constant MathImage__NumSeq_dX_max => 1;
  use constant MathImage__NumSeq_dY_min => -1;
  use constant MathImage__NumSeq_dY_max => 1;
  use constant MathImage__NumSeq_dDistSq_min => 1;
  use constant MathImage__NumSeq_dDistSq_max => 2;
  use constant MathImage__NumSeq_Turn_min => 0; # left or straight
  use constant MathImage__NumSeq_Turn_max => 1;
}
{ package Math::PlanePath::HeptSpiralSkewed;
  use constant MathImage__NumSeq_dX_min => -1;
  use constant MathImage__NumSeq_dX_max => 1;
  use constant MathImage__NumSeq_dY_min => -1;
  use constant MathImage__NumSeq_dY_max => 1;
  use constant MathImage__NumSeq_dDistSq_min => 1;
  use constant MathImage__NumSeq_dDistSq_max => 2;
  use constant MathImage__NumSeq_Turn_min => 0; # left or straight
  use constant MathImage__NumSeq_Turn_max => 1;
}
{ package Math::PlanePath::OctagramSpiral;
  use constant MathImage__NumSeq_dX_min => -1;
  use constant MathImage__NumSeq_dX_max => 1;
  use constant MathImage__NumSeq_dY_min => -1;
  use constant MathImage__NumSeq_dY_max => 1;
  use constant MathImage__NumSeq_dDistSq_min => 1;
  use constant MathImage__NumSeq_dDistSq_max => 2;
}
{ package Math::PlanePath::KnightSpiral;
  use constant MathImage__NumSeq_dX_min => -2;
  use constant MathImage__NumSeq_dX_max => 2;
  use constant MathImage__NumSeq_dY_min => -2;
  use constant MathImage__NumSeq_dY_max => 2;
  use constant MathImage__NumSeq_dDistSq_min => 5;
  use constant MathImage__NumSeq_dDistSq_max => 5;
}
{ package Math::PlanePath::SquareArms;
}
{ package Math::PlanePath::DiamondArms;
}
{ package Math::PlanePath::HexArms;
}
{ package Math::PlanePath::GreekKeySpiral;
  use constant MathImage__NumSeq_dX_min => -1;
  use constant MathImage__NumSeq_dX_max => 1;
  use constant MathImage__NumSeq_dY_min => -1;
  use constant MathImage__NumSeq_dY_max => 1;
  use constant MathImage__NumSeq_dDistSq_min => 1;
  use constant MathImage__NumSeq_dDistSq_max => 1;
}
{ package Math::PlanePath::SacksSpiral;
  use constant MathImage__NumSeq_dDistSq_min => 1;
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
  use constant MathImage__NumSeq_dX_min => -1;
  use constant MathImage__NumSeq_dX_max => 1;
  use constant MathImage__NumSeq_dY_min => -1;
  use constant MathImage__NumSeq_dY_max => 1;
  use constant MathImage__NumSeq_dDistSq_min => 1;
  use constant MathImage__NumSeq_dDistSq_max => 1;
  use constant MathImage__NumSeq_Turn_min => 1; # left always
  use constant MathImage__NumSeq_Turn_max => 1;
}
{ package Math::PlanePath::ArchimedeanChords;
  use constant MathImage__NumSeq_dX_min => -1;
  use constant MathImage__NumSeq_dX_max => 1;
  use constant MathImage__NumSeq_dY_min => -1;
  use constant MathImage__NumSeq_dY_max => 1;
  use constant MathImage__NumSeq_dDistSq_min => 1;
  use constant MathImage__NumSeq_dDistSq_max => 1;
  use constant MathImage__NumSeq_Turn_min => 1; # left always
  use constant MathImage__NumSeq_Turn_max => 1;
}
{ package Math::PlanePath::MultipleRings;
  use constant MathImage__NumSeq_dX_min => -1;
  use constant MathImage__NumSeq_dY_min => -1;
  use constant MathImage__NumSeq_dY_max => 1;
  use constant MathImage__NumSeq_dDistSq_min => 1;
  use constant MathImage__NumSeq_dDistSq_max => 1; # FIXME: bit bigger actually
}
{ package Math::PlanePath::PixelRings;
  use constant MathImage__NumSeq_dX_min => -1;
  use constant MathImage__NumSeq_dX_max => 1;
  use constant MathImage__NumSeq_dY_min => -1;
  use constant MathImage__NumSeq_dY_max => 1;
  use constant MathImage__NumSeq_dDistSq_min => 1;
  use constant MathImage__NumSeq_dDistSq_max => 2;
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
  sub MathImage__NumSeq_dX_min {
    my ($self) = @_;
    return ($self->{'radix'} % 2
            ? -1
            : undef);
  }
  sub MathImage__NumSeq_dX_max {
    my ($self) = @_;
    return ($self->{'radix'} % 2
            ? 1
            : undef);
  }
  sub MathImage__NumSeq_dY_min {
    my ($self) = @_;
    return ($self->{'radix'} % 2
            ? -1
            : undef);
  }
  sub MathImage__NumSeq_dY_max {
    my ($self) = @_;
    return ($self->{'radix'} % 2
            ? 1
            : undef);
  }
  sub MathImage__NumSeq_dDistSq_min {
    my ($self) = @_;
    return ($self->{'radix'} % 2
            ? 1
            : undef);
  }
  sub MathImage__NumSeq_dDistSq_max {
    my ($self) = @_;
    return ($self->{'radix'} % 2
            ? 1
            : undef);
  }
}
{ package Math::PlanePath::HilbertCurve;
  use constant MathImage__NumSeq_dX_min => -1;
  use constant MathImage__NumSeq_dX_max => 1;
  use constant MathImage__NumSeq_dY_min => -1;
  use constant MathImage__NumSeq_dY_max => 1;
  use constant MathImage__NumSeq_dDistSq_min => 1;
  use constant MathImage__NumSeq_dDistSq_max => 1;
}
{ package Math::PlanePath::ZOrderCurve;
  use constant MathImage__NumSeq_dX_max => 1;
  use constant MathImage__NumSeq_dY_max => 1;
  use constant MathImage__NumSeq_dDistSq_min => 1;
}
{ package Math::PlanePath::ImaginaryBase;
}
{ package Math::PlanePath::Flowsnake;
  sub MathImage__NumSeq_dX_min {
    my ($self) = @_;
    return ($self->{'arms'} == 1
            ? -2
            : undef);
  }
  sub MathImage__NumSeq_dX_max {
    my ($self) = @_;
    return ($self->{'arms'} == 1
            ? 2
            : undef);
  }
  sub MathImage__NumSeq_dY_min {
    my ($self) = @_;
    return ($self->{'arms'} == 1
            ? -1
            : undef);
  }
  sub MathImage__NumSeq_dY_max {
    my ($self) = @_;
    return ($self->{'arms'} == 1
            ? 1
            : undef);
  }
  sub MathImage__NumSeq_dDistSq_min {
    my ($self) = @_;
    return ($self->{'arms'} == 1
            ? 1
            : undef);
  }
  sub MathImage__NumSeq_dDistSq_max {
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
  use constant MathImage__NumSeq_dDistSq_min => 1;
}
{ package Math::PlanePath::GosperSide;
  use constant MathImage__NumSeq_dX_min => -2;
  use constant MathImage__NumSeq_dX_max => 2;
  use constant MathImage__NumSeq_dY_min => -1;
  use constant MathImage__NumSeq_dY_max => 1;
  use constant MathImage__NumSeq_dDistSq_min => 2;
  use constant MathImage__NumSeq_dDistSq_max => 4;
}

{ package Math::PlanePath::KochCurve;
  use constant MathImage__NumSeq_dX_min => -2;
  use constant MathImage__NumSeq_dX_max => 2;
  use constant MathImage__NumSeq_dDistSq_min => 2;
  use constant MathImage__NumSeq_dDistSq_max => 4;
}
{ package Math::PlanePath::KochPeaks;
  use constant MathImage__NumSeq_dX_max => 2;
  use constant MathImage__NumSeq_dY_max => 1;
  use constant MathImage__NumSeq_dDistSq_min => 2;
}
{ package Math::PlanePath::KochSnowflakes;
  use constant MathImage__NumSeq_dX_min => 1;
  use constant MathImage__NumSeq_dDistSq_min => 2;
}
{ package Math::PlanePath::KochSquareflakes;
  use constant MathImage__NumSeq_dX_max => 1;
  use constant MathImage__NumSeq_dY_max => 1;
  use constant MathImage__NumSeq_dDistSq_min => 1;
}

{ package Math::PlanePath::QuadricCurve;
  use constant MathImage__NumSeq_Sum_min => 0;  # triangular X>=-Y
  use constant MathImage__NumSeq_dX_min => -1;
  use constant MathImage__NumSeq_dX_max => 1;
  use constant MathImage__NumSeq_dY_min => -1;
  use constant MathImage__NumSeq_dY_max => 1;
  use constant MathImage__NumSeq_dDistSq_min => 1;
}
{ package Math::PlanePath::QuadricIslands;
  use constant MathImage__NumSeq_dX_max => 1;
  use constant MathImage__NumSeq_dY_max => 1;
  use constant MathImage__NumSeq_dDistSq_min => 1;
}

{ package Math::PlanePath::SierpinskiTriangle;
  use constant MathImage__NumSeq_dY_min => 0;
  use constant MathImage__NumSeq_dY_max => 1;
  use constant MathImage__NumSeq_Sum_min => 0;  # triangular X>=-Y
  use constant MathImage__NumSeq_dDistSq_min => 2;
}
{ package Math::PlanePath::SierpinskiArrowhead;
  use constant MathImage__NumSeq_dX_min => -2;
  use constant MathImage__NumSeq_dX_max => 2;
  use constant MathImage__NumSeq_dY_min => -1;
  use constant MathImage__NumSeq_dY_max => 1;
  use constant MathImage__NumSeq_Sum_min => 0;  # triangular X>=-Y
  use constant MathImage__NumSeq_dDistSq_min => 2;
  use constant MathImage__NumSeq_dDistSq_max => 4;
}
{ package Math::PlanePath::SierpinskiArrowheadCentres;
  use constant MathImage__NumSeq_Sum_min => 0;  # triangular X>=-Y
  use constant MathImage__NumSeq_dX_min => -2;
  use constant MathImage__NumSeq_dX_max => 2;
  use constant MathImage__NumSeq_dY_min => -1;
  use constant MathImage__NumSeq_dY_max => 1;
  use constant MathImage__NumSeq_dDistSq_min => 2;
  use constant MathImage__NumSeq_dDistSq_max => 4;
}

{ package Math::PlanePath::DragonCurve;
  use constant MathImage__NumSeq_dX_min => -1;
  use constant MathImage__NumSeq_dX_max => 1;
  use constant MathImage__NumSeq_dY_min => -1;
  use constant MathImage__NumSeq_dY_max => 1;
  use constant MathImage__NumSeq_dDistSq_min => 1;
  use constant MathImage__NumSeq_dDistSq_max => 1;
}
{ package Math::PlanePath::DragonRounded;
  use constant MathImage__NumSeq_dX_min => -1;
  use constant MathImage__NumSeq_dX_max => 1;
  use constant MathImage__NumSeq_dY_min => -1;
  use constant MathImage__NumSeq_dY_max => 1;
  use constant MathImage__NumSeq_dDistSq_min => 1;
  use constant MathImage__NumSeq_dDistSq_max => 2;
}
{ package Math::PlanePath::DragonMidpoint;
  use constant MathImage__NumSeq_dX_min => -1;
  use constant MathImage__NumSeq_dX_max => 1;
  use constant MathImage__NumSeq_dY_min => -1;
  use constant MathImage__NumSeq_dY_max => 1;
  use constant MathImage__NumSeq_dDistSq_min => 1;
  use constant MathImage__NumSeq_dDistSq_max => 1;
}
{ package Math::PlanePath::ComplexMinus;
}
{ package Math::PlanePath::Rows;
  sub MathImage__NumSeq_dX_min {
    my ($self) = @_;
    return - ($self->{'width'}-1);
  }
  use constant MathImage__NumSeq_dX_max => 1;
  use constant MathImage__NumSeq_dY_min => 0;
  use constant MathImage__NumSeq_dY_max => 1;
  use constant MathImage__NumSeq_dDistSq_min => 1;

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
  use constant MathImage__NumSeq_dX_min => 0;
  use constant MathImage__NumSeq_dX_max => 1;
  sub MathImage__NumSeq_dY_min {
    my ($self) = @_;
    return - ($self->{'height'}-1);
  }
  use constant MathImage__NumSeq_dY_max => 1;
  use constant MathImage__NumSeq_dDistSq_min => 1;

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
{ package Math::PlanePath::Diagonals;
  use constant MathImage__NumSeq_dX_max => 1;
  use constant MathImage__NumSeq_dY_min => -1;
  use constant MathImage__NumSeq_dDistSq_min => 2;
}
{ package Math::PlanePath::Staircase;
  use constant MathImage__NumSeq_dX_max => 1;
  use constant MathImage__NumSeq_dY_min => -1;
  use constant MathImage__NumSeq_dDistSq_min => 1;
}
{ package Math::PlanePath::Corner;
  use constant MathImage__NumSeq_dX_max => 1;
  use constant MathImage__NumSeq_dY_min => -1;
  use constant MathImage__NumSeq_dDistSq_min => 1;
}
{ package Math::PlanePath::PyramidRows;
  sub MathImage__NumSeq_Sum_min {
    my ($self) = @_;
    return ($self->{'step'} <= 2
            ? 0    # triangular X>=-Y for step=2, vertical X>=0 step=1,0
            : undef)
  }
  sub MathImage__NumSeq_X_max {
    my ($self) = @_;
    return ($self->{'step'} == 0
            ? 0    # X=0 vertical
            : undef)
  }
  use constant MathImage__NumSeq_dY_min => 0;
  use constant MathImage__NumSeq_dY_max => 1;
  use constant MathImage__NumSeq_dDistSq_min => 1;
  sub MathImage__NumSeq_dDistSq_max {
    my ($self) = @_;
    return ($self->{'step'} == 0
            ? 1    # X=0 vertical
            : undef)
  }

  # if step==0 then always straight ahead horizontal
  sub MathImage__NumSeq_Turn_min {
    my ($self) = @_;
    return ($self->{'step'} > 0 ? -1 : 0);
  }
  sub MathImage__NumSeq_Turn_max {
    my ($self) = @_;
    return ($self->{'step'} > 0 ? 1 : 0);
  }

  # if step==0 then always north
  sub MathImage__NumSeq_ENSW_min {
    my ($self) = @_;
    return ($self->{'step'} > 0 ? 0 : 1);
  }
  sub MathImage__NumSeq_ENSW_max {
    my ($self) = @_;
    return ($self->{'step'} > 0 ? 3 : 1);
  }
}
{ package Math::PlanePath::PyramidSides;
  use constant MathImage__NumSeq_dX_max => 1;
  use constant MathImage__NumSeq_dY_min => -1;
  use constant MathImage__NumSeq_dY_max => 1;
  use constant MathImage__NumSeq_dDistSq_min => 2;
}
{ package Math::PlanePath::CellularRule54;
  use constant MathImage__NumSeq_dX_max => 4;
  use constant MathImage__NumSeq_dY_min => 0;
  use constant MathImage__NumSeq_dY_max => 1;
  use constant MathImage__NumSeq_Sum_min => 0;  # triangular X>=-Y
  use constant MathImage__NumSeq_dDistSq_min => 1;
}
{ package Math::PlanePath::CoprimeColumns;
  use constant MathImage__NumSeq_dX_min => 0;
  use constant MathImage__NumSeq_dX_max => 1;
  use constant MathImage__NumSeq_dY_max => 1;
  use constant MathImage__NumSeq_dDistSq_min => 1;
}
{ package Math::PlanePath::File;
  # File                   points from a disk file
  # FIXME: analyze points for dx/dy min/max etc
}


{ package Math::PlanePath::MathImageQuintetCurve;
  sub MathImage__NumSeq_dX_min {
    my ($self) = @_;
    return ($self->{'arms'} == 1
            ? -1
            : undef);
  }
  sub MathImage__NumSeq_dX_max {
    my ($self) = @_;
    return ($self->{'arms'} == 1
            ? 1
            : undef);
  }
  sub MathImage__NumSeq_dY_min {
    my ($self) = @_;
    return ($self->{'arms'} == 1
            ? -1
            : undef);
  }
  sub MathImage__NumSeq_dY_max {
    my ($self) = @_;
    return ($self->{'arms'} == 1
            ? 1
            : undef);
  }
  sub MathImage__NumSeq_dDistSq_min {
    my ($self) = @_;
    return ($self->{'arms'} == 1
            ? 1
            : undef);
  }
  sub MathImage__NumSeq_dDistSq_max {
    my ($self) = @_;
    return ($self->{'arms'} == 1
            ? 1
            : undef);
  }
}
{ package Math::PlanePath::MathImageQuintetCentres;
  # inherit QuintetCurve, except
  sub MathImage__NumSeq_dDistSq_max {
    my ($self) = @_;
    return ($self->{'arms'} == 1
            ? 2         # goes diagonally
            : undef);
  }
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


=for stopwords Ryde MathImage

=head1 NAME

App::MathImage::NumSeq::PlanePath -- sequences of coordinates from PlanePath modules

=head1 SYNOPSIS

 use App::MathImage::NumSeq::PlanePath;
 my $seq = App::MathImage::NumSeq::PlanePath->new (planepath => 'SquareSpiral',
                                                   coord_type => 'X');
 my ($i, $value) = $seq->next;

=head1 DESCRIPTION

This module gives coordinates from a C<Math::PlanePath> as a sequence.
There's various choices of what coordinate to take from the path, such as X,
Y, radius, dX, dy, etc.

=head1 FUNCTIONS

=over 4

=item C<$seq = App::MathImage::NumSeq::PlanePath-E<gt>new (key=E<gt>value,...)>

Create and return a new sequence object.

=item C<$bool = $seq-E<gt>pred($value)>

Return true if C<$value> is a happy number, meaning repeated sum of squares
of its digits reaches 1.

=back

=head1 SEE ALSO

L<Math::NumSeq>

=head1 HOME PAGE

http://user42.tuxfamily.org/math-image/index.html

=head1 LICENSE

Copyright 2010, 2011 Kevin Ryde

Math-Image is free software; you can redistribute it and/or modify it
under the terms of the GNU General Public License as published by the Free
Software Foundation; either version 3, or (at your option) any later
version.

Math-Image is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
more details.

You should have received a copy of the GNU General Public License along with
Math-Image.  If not, see <http://www.gnu.org/licenses/>.

=cut
