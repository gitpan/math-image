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

package App::MathImage::Generator;
use 5.004;
use strict;
use Carp;
use POSIX 'floor', 'ceil';
use Math::Libm 'hypot';
use Module::Load;
use Module::Util;
use Image::Base 1.14;
use Time::HiRes;
use List::Util 'min', 'max';
use Locale::TextDomain 'App-MathImage';

use App::MathImage::Image::Base::Other;

# uncomment this to run the ### lines
#use Smart::Comments;
#use Smart::Comments '####';

use vars '$VERSION';
$VERSION = 50;

use constant default_options => {
                                 values       => 'Primes',
                                 path         => 'SquareSpiral',
                                 scale        => 1,
                                 width        => 10,
                                 height       => 10,
                                 foreground   => 'white',
                                 background   => 'black',
                                 fraction     => '5/29',
                                 sqrt         => '2',
                                 spectrum     => (sqrt(5)+1)/2,
                                 polygonal    => 5,
                                 multiples    => 90,
                                 parity       => 'odd',
                                 pairs        => 'first',
                                 radix        => 10,
                                 aronson_lang         => 'en',
                                 aronson_letter       => '',
                                 aronson_conjunctions => 1,
                                 aronson_lying        => 0,
                                 pyramid_step  => 2,
                                 rings_step    => 6,
                                 path_wider    => 0,
                                 path_rotation_type => 'phi',
                                 expression    => '3*x^2 + x + 2',
                                 filter        => 'All',
                                 oeis_number   => 290,
                                 planepath_class => 'SquareSpiral',
                                 delta_type      => 'X',
                                 coord_type      => 'X',
                                };

sub new {
  my $class = shift;
  ### Generator new(): @_
  my $self = bless { %{$class->default_options()}, @_ }, $class;
  if (! defined $self->{'undrawnground'}) {
    $self->{'undrawnground'} = $self->{'background'};
  }
  return $self;
}

# columns_of_pythagoras
use constant values_choices => do {
  my %choices;
  foreach my $module (Module::Util::find_in_namespace
                      ('App::MathImage::NumSeq::Sequence')) {
    my $choice = $module;
    $choice =~ s/^App::MathImage::NumSeq::Sequence:://;
    $choice =~ s/::/-/g;
    $choices{$choice} = 1;
  }
  if (! defined (Module::Util::find_installed('Math::Aronson'))) {
    delete $choices{'Aronson'};
  }
  if (! defined (Module::Util::find_installed('Math::Symbolic'))
      && ! defined (Module::Util::find_installed('Math::Expression::Evaluator'))
      && ! defined (Module::Util::find_installed('Language::Expr'))) {
    delete $choices{'Expression'};
  }
  my @choices;
  foreach my $prefer (qw(Primes
                         CountPrimeFactors
                         MobiusFunction
                         TwinPrimes
                         SophieGermainPrimes
                         SafePrimes
                         SemiPrimes
                         SemiPrimesOdd
                         Emirps
                         AbundantNumbers
                         ObstinateNumbers
                         Squares
                         Pronic
                         Triangular
                         Pentagonal
                         Polygonal
                         StarNumbers
                         Cubes
                         Tetrahedral
                         Fibonacci
                         LucasNumbers
                         Perrin
                         Padovan
                         Tribonacci
                         Factorials
                         FractionDigits
                         SqrtDigits
                         PiBits
                         Ln2Bits
                         Odd
                         Even
                         All
                         Aronson
                         PellNumbers
                         GoldenSequence
                         ThueMorse
                         ChampernowneBinary
                         ChampernowneBinaryLsb
                         BinaryLengths
                         PrimeQuadraticEuler
                         PrimeQuadraticLegendre
                         PrimeQuadraticHonaker
                         Repdigits
                         RepdigitAnyBase
                         Beastly
                         UndulatingNumbers
                         TernaryWithout2
                         Base4Without3
                         RadixWithoutDigit
                         Multiples
                         OEIS
                       )) {
    if (delete $choices{$prefer}) {
      push @choices, $prefer;
    }
  }
  delete $choices{'Lines'};
  delete $choices{'LinesLevel'};
  push @choices, sort keys %choices;
  push @choices, 'Lines';
  push @choices, 'LinesLevel';
  ### @choices
  @choices
};

sub values_class {
  my ($class_or_self, $values) = @_;
  $values ||= $class_or_self->{'values'};
  $values =~ s/-/::/g;
  my $values_class = "App::MathImage::NumSeq::Sequence::$values";
  Module::Load::load ($values_class);
  return $values_class;
}
sub values_object {
  my ($self) = @_;
  ### Generator values_object()
  my $values_class = $self->values_class($self->{'values'});

  my $values_obj = eval { $values_class->new (%$self, hi => 100) };
  if (! $values_obj) {
    my $err = $@;
    ### values_obj error: $@
  } else {
    ### ret: "$values_obj"
  }
  return $values_obj;
}

use constant path_choices => do {
  my %choices;
  my $base = 'Math::PlanePath';
  foreach my $module (Module::Util::find_in_namespace($base)) {
    my $choice = $module;
    $choice =~ s/^\Q$base\E:://;
    next if $choice =~ /::/; # not sub-parts ?
    $choices{$choice} = 1;
  }
  my @choices;
  foreach my $prefer (qw(SquareSpiral
                         SacksSpiral
                         VogelFloret
                         TheodorusSpiral
                         MultipleRings
                         PixelRings
                         Hypot
                         HypotOctant

                         DiamondSpiral
                         PentSpiral
                         PentSpiralSkewed
                         HexSpiral
                         HexSpiralSkewed
                         HeptSpiralSkewed
                         TriangleSpiral
                         TriangleSpiralSkewed
                         OctagramSpiral
                         KnightSpiral

                         PyramidRows
                         PyramidSides
                         PyramidSpiral
                         Corner
                         Diagonals
                         Staircase
                         Rows
                         Columns

                         PeanoCurve
                         HilbertCurve
                         ZOrderCurve

                       )) {
    if (delete $choices{$prefer}) {
      push @choices, $prefer;
    }
  }
  my @mi = grep {/^MathImage/} keys %choices;
  delete @choices{@mi}; # hash slice
  ### path extras: %choices
  push @choices, sort keys %choices;
  push @choices, sort @mi;  # MathImageFoo ones last
  ### path choices: @choices
  @choices
};

use constant figure_choices => qw(default
                                  point
                                  square
                                  box
                                  circle
                                  ring
                                  diamond
                                  diamunf
                                  plus
                                  X
                                  L);

# cf Data::Random

sub random_options {
  my ($class) = @_;
  my @ret;

  my @path_and_values;
  foreach my $path ($class->path_choices) {
    foreach my $values ($class->values_choices) {
      if ($values eq 'All' || $values eq 'Odd' || $values eq 'Even') {
        next unless $path eq 'SacksSpiral' || $path eq 'VogelFloret';
      }
      if ($values eq 'Flowsnake' || $values eq 'LinesLevel') {
        next;  # experimental
      }

      # too sparse?
      # next if ($values eq 'Factorials');

      # bit sparse?
      # next if $values eq 'Perrin' || $values eq 'Padovan';

      # coord values are only permutation of integers, or coord repetitions
      next if $values =~ /PlanePathCoord/;

      if ($values eq 'Squares') {
        next if $path eq 'Corner'; # just a line across the bottom
      }
      if ($values eq 'Pronic') {
        next if $path eq 'PyramidSides' # just a vertical
          || $path eq 'PyramidRows';    # just a vertical
      }
      if ($values eq 'Triangular') {
        next if ($path eq 'Diagonals' # just a line across the bottom
                 || $path eq 'DiamondSpiral');  # just a centre horizontal line
      }
      if ($values eq 'Lines' || $values eq 'LinesLevel') {
        next if $path eq 'VogelFloret'; # too much crossover
      }

      push @path_and_values, [ $path, $values ];
    }
  }
  my ($path, $values) = @{_rand_of_array(\@path_and_values)};
  push @ret, path => $path, values => $values;

  {
    my $radix;
    if ($values eq 'Repdigits' || $values eq 'Beastly') {
      $radix = _rand_of_array([2 .. 128,
                               (10) x 50]); # bias mostly 10
    } elsif ($values eq 'Emirps') {
      # for Emirps not too big or round up to 2^base becomes slow
      $radix = _rand_of_array([2,3,4,8,16,
                               10,10,10,10]); # bias mostly 10
    } else {
      $radix = _rand_of_array([2 .. 36]);
    }
    push @ret, radix => $radix;
  }

  {
    my $scale = _rand_of_array([1, 3, 5, 10, 15, 20]);
    if ($values eq 'Lines') {
      # not too small for lines to show up sensibly
      $scale = max ($scale, 5);
    }
    if ($values eq 'LinesLevel') {
      # not too small for lines to show up sensibly
      $scale = max ($scale, 2);
    }
    push @ret, scale => $scale;
  }
  {
    require Math::Prime::XS;
    my @primes = Math::Prime::XS::sieve_primes(10,100);
    my $num = _rand_of_array(\@primes);
    @primes = grep {$_ != $num} @primes;
    my $den = _rand_of_array(\@primes);
    push @ret, fraction => "$num/$den",
  }
  {
    my @primes = Math::Prime::XS::sieve_primes(2,100);
    my $sqrt = _rand_of_array(\@primes);
    push @ret, sqrt => $sqrt,
  }

  {
    my $pyramid_step = 1 + int(rand(20));
    if ($pyramid_step > 12) {
      $pyramid_step = 2;  # most of the time
    }
    push @ret, pyramid_step => $pyramid_step;
  }
  {
    my $rings_step = int(rand(20));
    if ($rings_step > 15) {
      $rings_step = 6;  # more often
    }
    push @ret, rings_step => $rings_step;
  }
  {
    my $path_wider = _rand_of_array([(0) x 10,   # 0 most of the time
                                     1 .. 20]);
    # ZOrderCurve gets slow very quickly when wider, also it's undocumented
    if ($path eq 'ZOrderCurve') {
      $path_wider = 0; # min (1, $path_wider);
    }
    push @ret, path_wider => $path_wider;
  }
  {
    push @ret, path_rotation_type => _rand_of_array(['phi','phi','phi','phi',
                                                     'sqrt2','sqrt2',
                                                     'sqrt3',
                                                     'sqrt5',
                                                    ])
      # path_rotation_factor => $rotation_factor,
  }
  {
    my @figure_choices = $class->figure_choices;
    push @figure_choices, ('default') x scalar(@figure_choices);
    push @ret, figure => _rand_of_array(\@figure_choices);
  }
  {
    push @ret, foreground => _rand_of_array(['#FFFFFF',  # white
                                             '#FFFFFF',  # white
                                             '#FFFFFF',  # white
                                             '#FF0000',  # red
                                             '#00FF00',  # green
                                             '#0000FF',  # blue
                                             '#FFAA00',  # orange
                                             '#FFFF00',  # yellow
                                             '#FFB0B0',  # pink
                                             '#FF00FF',  # magenta
                                            ]);
  }

  return (@ret,
          polygonal => (int(rand(20)) + 5), # skip 3=triangular, 4=squares
          # spectrum  => $spectrum,
          aronson_lang         => _rand_of_array(['en','fr']),
          aronson_conjunctions => int(rand(2)),
          aronson_lying        => (rand() < .25), # less likely
          parity               => _rand_of_array(['odd','even']),
          pairs                => _rand_of_array(['first','second','both']),
          #
          # FIXME: don't want to filter out everything ... have values
          # classes declare their compositeness, parity, etc
          # filter           => _rand_of_array(['All','All','All',
          #                                     'All','All','All',
          #                                     'Odd','Even','Primes']),
         );
}

sub _rand_of_array {
  my ($aref) = @_;
  return $aref->[int(rand(scalar(@$aref)))];
}

use vars '%pathname_has_wider';
%pathname_has_wider = (SquareSpiral    => 1,
                       HexSpiral       => 1,
                       HexSpiralSkewed => 1);
# ZOrderCurve => 1  # no longer

sub description {
  my ($self) = @_;

  my $ret = $self->{'path'};
  if ($pathname_has_wider{$self->{'path'}}) {
    if ($self->{'path_wider'}) {
      $ret .= " wider $self->{'path_wider'}";
    }
  } elsif ($self->{'path'} eq 'PyramidRows') {
    $ret .= " step $self->{'pyramid_step'}";
  }

  # prefer just the classname for a semi-technical descriptive summary
  $ret .= " $self->{'values'}";

  my $values = $self->{'values'};
  my $values_class = $self->values_class($values);

  foreach my $pinfo ($values_class->parameter_list) {
    $ret .= ' ';
    my $pname = $pinfo->{'name'};
    if (defined $self->{$pname}) {
      if ($pname eq 'sqrt') {
        $ret .= 'sqrt';
      } elsif ($pname eq 'radix') {
        $ret .= 'base';
      }
      $ret .= ' '.$self->{$pname};
    }
  }

  # } elsif ($self->{'values'} eq 'ThueMorse') {
  #   $ret .= ' '.($self->{'parity'} eq 'odd' ? __('odd') : __('even'));

  # } elsif ($self->{'values'} eq 'Polygonal') {
  #     $ret .= ' '.$self->{'pairs'};
  if ($values eq 'Aronson') {
    my $lang = $self->{'aronson_lang'};
    if ($lang ne default_options()->{'aronson_lang'}) {
      $ret .= " $lang";
    }
    my $default_letter = ($lang eq 'en' ? 'T'
                          : $lang eq 'fr' ? 'E'
                          : '');
    my $letter = $self->{'aronson_letter'};
    if ($letter ne '' && $letter ne $default_letter) {
      $ret .= " \U$letter";
    }
  }
  if ($self->{'filter'} ne 'All') {
    $ret .= __x(" filtered {name}",
                name => $self->values_class($self->{'filter'})->name);
  }

  return $ret . " $self->{'width'}x$self->{'height'} scale $self->{'scale'}";
}

sub path_choice_to_class {
  my ($self, $path) = @_;
  my $class = "Math::PlanePath::$path";
  if (Module::Util::find_installed ($class)) {
    return $class;
  }
  return undef;
}

sub path_object {
  my ($self) = @_;
  return ($self->{'path_object'} ||= do {

    my $path_class = $self->{'path'};
    #### $path_class
    my $err = '';
    unless ($path_class =~ /::/) {
      $path_class = $self->path_choice_to_class ($path_class)
        || croak "No module for path $path_class";
    }
    unless (eval { Module::Load::load ($path_class); 1 }) {
      ### cannot load: $@
      croak $err;
    }

    my $scale = $self->{'scale'};
    $path_class->new
      (width    => ceil($self->{'width'} / $scale),
       height   => ceil($self->{'height'} / $scale),
       step     => ($path_class eq 'Math::PlanePath::PyramidRows'
                    ? $self->{'pyramid_step'}
                    : $self->{'rings_step'}),
       wider    => $self->{'path_wider'},
       rotation_type  => $self->{'path_rotation_type'},
       rotation_factor => $self->{'path_rotation_factor'},
       radius_factor  => $self->{'path_radius_factor'})
    });
}
sub x_negative {
  my ($self) = @_;
  return $self->path_object->x_negative;
}
sub y_negative {
  my ($self) = @_;
  my $path_object = $self->path_object;

  # override flowsnake looping around to negatives takes a very long time
  if ($path_object->isa('Math::PlanePath::MathImageFlowsnake')) {
    return 0;
  }

  return $self->path_object->y_negative;
}

sub affine_object {
  my ($self) = @_;
  return ($self->{'affine_object'} ||= do {
    my $offset = int ($self->{'scale'} / 2);
    my $path_object = $self->path_object;
    my $scale = $self->{'scale'};
    my $x_origin
      = (defined $self->{'x_left'} ? - $self->{'x_left'} * $scale
         : $self->x_negative ? int ($self->{'width'} / 2)
         : $offset);
    my $y_origin
      = (defined $self->{'y_bottom'} ? $self->{'y_bottom'} * $scale + $self->{'height'}
         : $self->y_negative ? int ($self->{'height'} / 2)
         : $self->{'height'} - $self->{'scale'} + $offset);
    ### x_negative: $self->x_negative
    ### y_negative: $self->y_negative
    ### $x_origin
    ### $y_origin

    require Geometry::AffineTransform;
    Geometry::AffineTransform->VERSION('1.3'); # 1.3 for invert()
    my $affine = Geometry::AffineTransform->new;
    $affine->scale ($self->{'scale'}, - $self->{'scale'});
    $affine->translate ($x_origin, $y_origin);
  });
}

use constant _POINTS_CHUNKS     => 200 * 2;  # of X,Y
use constant _RECTANGLES_CHUNKS => 200 * 4;  # of X1,Y1,X2,Y2

sub covers_plane {
  my ($self) = @_;
  if ($self->{'background'} eq $self->{'undrawnground'}) {
    return 1;
  }
  my $path_object = $self->path_object;
  if (! _path_covers_plane ($path_object)) {
    return 0;
  }
  my $affine_object = $self->affine_object;
  my ($wx,$wy) = $affine_object->transform(-.5,-.5);
  if (! $self->x_negative && $wx > 0
      || ! $self->y_negative && $wy < $self->{'height'}-1) {
    return 0;
  }
  return 1;
}
sub _path_covers_plane {
  my ($path_object) = @_;
  if ($path_object->isa('Math::PlanePath::PyramidRows')
      || $path_object->isa('Math::PlanePath::HypotOctant')) {
    return 0;
  }
  if ($path_object->figure eq 'circle') {
    return 1;
  }
  return 1;
}

sub figure {
  my ($self) = @_;
  if ($self->{'scale'} == 1) {
    return 'point';
  }
  my $figure = $self->{'figure'};
  if (! $figure || $figure eq 'default') {
    return $self->path_object->figure;
  }
  return $figure;
}

sub colour_to_rgb {
  my ($colour) = @_;
  my $scale;
  # ENHANCE-ME: Or demand Color::Library always, or X11 helpers hexstr_to_rgb()
  if ($colour =~ /^#([0-9A-F]{2})([0-9A-F]{2})([0-9A-F]{2})$/i) {
    $scale = 255;
  } elsif ($colour =~ /^#([0-9A-F]{4})([0-9A-F]{4})([0-9A-F]{4})$/i) {
    $scale = 65535;
  } elsif (eval { require Color::Library }
           && (my $c = Color::Library->color($colour))) {
    return map {$_/255} $c->rgb;
  }
  return (hex($1)/$scale, hex($2)/$scale, hex($3)/$scale);
}

# $factor 0 to 1 for background to foreground
sub colour_scaled {
  my ($self, $factor) = @_;
  my @foreground = colour_to_rgb($self->{'foreground'});
  my @background = colour_to_rgb($self->{'background'});
  if (! @foreground) { @foreground = (1.0, 1.0, 1.0); }
  if (! @background) { @background = (0, 0, 0); }
  my $bg_factor = 1 - $factor;
  return sprintf '#%02X%02X%02X',
    map {
      int (0.5 + 255 * ($foreground[$_]*$factor + $background[$_]*$bg_factor));
    } 0,1,2;
}

sub colours_grey_exp {
  my ($self) = @_;
  my $colours = $self->{'colours'} = [];
  my $f = 1.0;
  for (;;) {
    push @$colours, $self->colour_scaled ($f);
    last if ($f < 1/255);
    $f = 0.6 * $f;
  }
  ### grey exp colours: $self->{'colours'}
}
sub colours_grey_linear {
  my ($self, $n, $colour) = @_;
  my $colours = $self->{'colours'} = [];
  foreach my $i (0 .. $n-1) {
    push @$colours, $self->colour_scaled ($i / ($n-1));
  }
  ### colours_grey_linear: $self->{'colours'}
}

# seven colours
sub colours_rainbow {
  my ($self) = @_;
  # ROYGBIV
  $self->{'colours'} = [ 'red', 'orange', 'yellow', 'green', 'blue', 'purple', 'violet' ];
  ### colours: $self->{'colours'}
}

# ENHANCE-ME: two shades of each to make radix==6
sub colours_rgb {
  my ($self) = @_;
  $self->{'colours'} = [ 'red', 'green', 'blue' ];
  ### colours: $self->{'colours'}
}

# # ($x,$y, $x,$y, ...) = $aff->untransform($x,$y, $x,$y, ...)
# sub untransform {
#   my $self = shift;
#   my @result;
#   my $det = $self->{m11}*$self->{m22} - $self->{m12}*$self->{m21};
#   while (@_) {
#     my $x = shift() - $self->{tx};
#     my $y = shift() - $self->{ty};
#     push @result,
#       ($self->{m22} * $x - $self->{m21} * $y) / $det,
#         ($self->{m11} * $y - $self->{m12} * $x) / $det;
#   }
#   return @result;
# }
#
# # $aff = $aff->invert
# sub invert {
#   my ($self) = @_;
#   my $det = $self->{m11}*$self->{m22} - $self->{m12}*$self->{m21};
#   return $self->set_matrix_2x3
#     ($self->{m22} / $det,     # 11
#      - $self->{m12} / $det,   # 12
#      - $self->{m21} / $det,   # 21
#      $self->{m11} / $det,     # 22
#      $self->App::MathImage::Generator::untransform(0,0));
#
#   # tx,ty as full expressions instead of untransform(), if preferred
#   # ($self->{m21} * $self->{ty} - $self->{m22} * $self->{tx}) / $det,
#   # ($self->{m12} * $self->{tx} - $self->{m11} * $self->{ty}) / $det);
# }

sub draw_Image_start {
  my ($self, $image) = @_;
  ### draw_Image_start()
  ### values: $self->{'values'}

  $self->{'image'} = $image;
  my $width  = $self->{'width'}  = $image->get('-width');
  my $height = $self->{'height'} = $image->get('-height');
  my $scale = $self->{'scale'};
  ### $width
  ### $height

  my $path_object = $self->path_object;
  my $foreground    = $self->{'foreground'};
  my $background    = $self->{'background'};
  my $undrawnground = $self->{'undrawnground'};
  my $covers = $self->covers_plane;

  my @colours = ($foreground, $background);
  if ($covers) {
    $undrawnground = $background;
  } else {
    push @colours, $undrawnground;
  }

  # clear
  $image->rectangle (0, 0, $width-1, $height-1, $undrawnground, 1);
  my $affine = $self->affine_object;

  my ($n_lo, $n_hi);
  if ($self->{'values'} eq 'LinesLevel') {
    my $level = ($self->{'level'} ||= 2);
    ($n_lo, undef) = $path_object->rect_to_n_range (0,0, 0,0);
    ### n_range of 0,0: $path_object->rect_to_n_range (0,0, 0,0)
    my $base = 4;
    my $end = -1;
    my $yfactor = 1;
    if ($path_object->isa ('Math::PlanePath::MathImageFlowsnake')) {
      $base = 7;
      $yfactor = sqrt(3);
      $end = 0;
    } elsif ($path_object->isa ('Math::PlanePath::PeanoCurve')) {
      $base = 9;
    }
    $n_hi = $base ** $self->{'level'} + $end;
    my $n_angle = $n_hi;
    if ($path_object->isa ('Math::PlanePath::MathImageFlowsnake')) {
      $n_angle = 6;
      foreach (2 .. $level) {
        $n_angle = (7 * $n_angle + 0);
      }
      ### $n_hi
      ### $n_angle
    }
    ### $base
    ### $level
    ### $yfactor

    $affine = Geometry::AffineTransform->new;

    my ($x, $y) = $path_object->n_to_xy ($n_angle);
    my $theta = - atan2 ($y, $x);
    ### $theta

    ($x, $y) = $path_object->n_to_xy ($n_hi);
    ### end raw: "$x, $y"
    my $r = hypot ($x,$y);
    ### $r

    ### origin: $self->{'width'} * .15, $self->{'height'} * .5
    $affine->rotate ($theta / 3.14159 * 180);
    $affine->scale ($self->{'width'} * .7 / $r,
                    - $self->{'width'} * .7 / $r * .3);
    $affine->translate ($self->{'width'} * .15,
                        $self->{'height'} * .5);

    if (defined $self->{'x_left'}) {
      ### x_left: $self->{'x_left'}
      $affine->translate (- $self->{'x_left'} * $self->{'scale'},
                          0);
    }
    if (defined $self->{'y_bottom'}) {
      ### y_bottom: $self->{'y_bottom'}
      $affine->translate (0,
                          $self->{'y_bottom'} * $self->{'scale'});
    }

    ($x,$y) = $path_object->n_to_xy ($n_lo++);
    ### start raw: "$x, $y"
    ($x,$y) = $affine->transform ($x, $y);
    $x = floor ($x + 0.5);
    $y = floor ($y + 0.5);

    $self->{'xprev'} = $x;
    $self->{'yprev'} = $y;
    $self->{'affine_object'} = $affine;
    ### prev: "$x,$y"
    ### theta degrees: $theta*180/3.14159
    ### start: "$self->{'xprev'}, $self->{'yprev'}"

  } else {
    my $affine_inv = $affine->clone->invert;
    my ($x1, $y1) = $affine_inv->transform (-$scale, -$scale);
    my ($x2, $y2) = $affine_inv->transform ($self->{'width'} + $scale,
                                            $self->{'height'} + $scale);
    ### limits around:
    ### $x1
    ### $x2
    ### $y1
    ### $y2

    ($n_lo, $n_hi) = $path_object->rect_to_n_range ($x1,$y1, $x2,$y2);
  }

  $self->{'n_prev'} = $n_lo - 1;
  $self->{'upto_n'} = $n_lo;
  $self->{'n_hi'}   = $n_hi;
  $self->{'count_total'}   = 0;
  $self->{'count_outside'} = 0;
  ### $n_lo
  ### $n_hi

  # origin point
  if ($scale >= 3 && $self->figure ne 'point') {
    my ($x,$y) = $affine->transform(0,0);
    $x = floor ($x + 0.5);
    $y = floor ($y + 0.5);
    if ($x >= 0 && $y >= 0 && $x < $width && $y < $height) {
      $image->xy ($x, $y, $foreground);
    }
  }

  if ($self->{'values'} eq 'Lines') {
    foreach my $class ('Math::PlanePath::MathImageFlowsnake',
                       'Math::PlanePath::MathImageOctagramSpiral',
                      ) {
      if ($path_object->isa($class)) {
        $self->{'lines_full_step'} = 1;
      }
    }
    ### lines_full_step: $self->{'lines_full_step'}

  } else {
    my $values_class = $self->values_class($self->{'values'});
    my $values_obj = $self->{'values_obj'}
      = $values_class->new (%$self,
                            lo => $n_lo,
                            hi => $n_hi);

    if ($values_obj->is_type('pn1')) {
      if ($image->isa('Image::Base::Text')) {
        $self->{'colours'} = [ '-',' ','+' ];
      } else {
        $self->colours_grey_linear (3);
        my $colours = $self->{'colours'};
        $self->{'colours'} = [ $colours->[1],  # grey
                               $background,
                               $colours->[2],  # white
                             ];
      }
      $self->{'colours_offset'} = 1;
      $self->{'use_colours'} = 1;
      ### pn1
      ### colours: $self->{'colours'}
      ### colours_offset: $self->{'colours_offset'}

    } elsif ($values_obj->is_type('count')) {
      $self->{'colours_offset'} = 0;
      if ($image->isa('Image::Base::Text')) {
        $self->{'colours'} = [ 0 .. 9 ];
      } else {
        $self->colours_grey_exp ($self);
      }
      push @colours, @{$self->{'colours'}};
      $self->{'use_colours'} = 1;
      $self->{'colours_offset'} = - $values_obj->values_min;
      ### type "count"
      ### colours_offset: $self->{'colours_offset'}
      ### per values_min: $values_obj->values_min
      ### colours: $self->{'colours'}

    } elsif ($values_obj->is_type('radix')) {
      $self->{'colours_offset'} = 0;
      if ($image->isa('Image::Base::Text')) {
        $self->{'colours'} = [ 0 .. 9, 'A' .. 'Z' ];
      } else {
        $self->colours_grey_linear ($values_obj->{'radix'});
      }
      $self->{'use_colours'} = 1;
      push @colours, @{$self->{'colours'}};
    }
    ### values_obj: $self->{'values_obj'}

    my $filter = $self->{'filter'};
    $self->{'filter_obj'} = $filter &&
      $self->values_class($filter)->new (lo => $n_lo,
                                         hi => $n_hi);
  }

  $image->add_colours (@colours);


  # $self->use_xy($image);
}

my %figure_is_circular = (circle  => 1,
                          ring    => 1,
                          point   => 1,
                          diamond => 1,
                          plus    => 1,
                         );
my %figure_fill = (square  => 1,
                   circle  => 1,
                   diamond => 1,
                  );
my %figure_method = (square  => 'rectangle',
                     box     => 'rectangle',
                     circle  => 'ellipse',
                     ring    => 'ellipse',
                     diamond => \&App::MathImage::Image::Base::Other::diamond,
                     diamunf => \&App::MathImage::Image::Base::Other::diamond,
                     plus    => \&App::MathImage::Image::Base::Other::plus,
                     X       => \&App::MathImage::Image::Base::Other::draw_X,
                     L       => \&App::MathImage::Image::Base::Other::draw_L,
                    );

sub draw_Image_steps {
  my ($self) = @_;
  #### draw_Image_steps()
  my $steps = 0;

  my $step_figures = $self->{'step_figures'};
  my $step_time = $self->{'step_time'};
  my $count_figures = 0;
  my ($time_lo, $time_hi);
  my $more = 0;
  my $cont = sub {
    if (defined $step_figures) {
      if ($count_figures >= $step_figures) {
        $more = 1;
        return 0; # don't continue
      }
    }
    if (defined $step_time) {
      if (defined $time_lo) {
        my $time = _gettime();
        if ($time < $time_lo  # oops, time gone backwards
            || $time > $time_hi) {
          $more = 1;
          return 0; # don't continue
        }
      } else {
        $time_lo = _gettime();
        $time_hi = $time_lo + $step_time;
        # at least one iteration no matter how long the initializers take
      }
    }
    return 1; # continue
  };

  my $path_object = $self->path_object;
  my $image  = $self->{'image'};
  my $width  = $self->{'width'};
  my $height = $self->{'height'};
  my $foreground = $self->{'foreground'};
  my $background = $self->{'background'};
  my $scale = $self->{'scale'};
  ### $scale

  my $covers = $self->covers_plane;
  my $affine = $self->affine_object;
  my $values_obj = $self->{'values_obj'};
  my $filter_obj = $self->{'filter_obj'};

  my $figure = $self->figure;
  my $pscale = $scale;
  if ($path_object->figure eq 'circle' && ! $figure_is_circular{$figure}) {
    $pscale = max (1, floor ($self->{'scale'} * (1/sqrt(2))));
  }
  if ($pscale == 1) {
    $figure = 'point';
  }
  $pscale--;
  my $figure_method = $figure_method{$figure} || $figure;
  my $figure_fill = $figure_fill{$figure};
  ### $figure

  my %points_by_colour;
  my %rectangles_by_colour;
  my $flush = sub {
    ### flush points: scalar(%points_by_colour)
    ### colours: keys %points_by_colour
    foreach my $colour (keys %points_by_colour) {
      my $aref = delete $points_by_colour{$colour};
      App::MathImage::Image::Base::Other::xy_points
          ($image, $colour, @$aref);
    }
    ### flush rectangles: scalar(%rectangles_by_colour)
    foreach my $colour (keys %rectangles_by_colour) {
      my $aref = delete $rectangles_by_colour{$colour};
      App::MathImage::Image::Base::Other::rectangles
          ($image, $colour, 1, @$aref);
    }
  };

  my $n_hi = $self->{'n_hi'};

  if ($self->{'values'} eq 'Lines') {
    my $n = $self->{'upto_n'};

    if ($self->{'lines_full_step'}) {
      ### n raw: $path_object->n_to_xy($n)
      my ($x1, $y1) = $path_object->n_to_xy($n)
        or return 0; # no more
      ($x1, $y1) = $affine->transform ($x1, $y1);
      $x1 = floor ($x1 + 0.5);
      $y1 = floor ($y1 + 0.5);

      for (;;) {
        &$cont() or last;
        last if ++$n > $n_hi;

        my ($x2, $y2) = $path_object->n_to_xy($n)
          or last;
        ($x2, $y2) = $affine->transform ($x2, $y2);
        $x2 = floor ($x2 + 0.5);
        $y2 = floor ($y2 + 0.5);

        _image_line_clipped ($image, $x1,$y1, $x2,$y2,
                             $width,$height, $foreground);
        $x1 = $x2;
        $y1 = $y2;
      }

    } else {
      for ( ; $n < $n_hi; $n++) {
        &$cont() or last;

        ### n raw: $path_object->n_to_xy($n)
        my ($x2, $y2) = $path_object->n_to_xy($n)
          or next;
        ($x2, $y2) = $affine->transform ($x2, $y2);
        ### npos: "$n   $x2, $y2"
        $x2 = floor ($x2 + 0.5);
        $y2 = floor ($y2 + 0.5);

        if (my ($x1, $y1) = $path_object->n_to_xy($n-0.499)) {
          ($x1, $y1) = $affine->transform ($x1, $y1);
          ### minus: "$x1, $y1"
          $x1 = floor ($x1 + 0.5);
          $y1 = floor ($y1 + 0.5);
          _image_line_clipped ($image, $x1,$y1, $x2,$y2, $width,$height, $foreground);
          $count_figures++;
        }

        if (my ($x3, $y3) = $path_object->n_to_xy($n+0.499)) {
          ($x3, $y3) = $affine->transform ($x3, $y3);
          ### plus: "$x3, $y3"
          $x3 = floor ($x3 + 0.5);
          $y3 = floor ($y3 + 0.5);
          _image_line_clipped ($image, $x2,$y2, $x3,$y3, $width,$height, $foreground);
          $count_figures++;
        }
      }
    }
    $self->{'upto_n'} = $n;
    return $more;
  }

  if ($self->{'values'} eq 'LinesLevel') {
    ### LinesLevel step
    my $n = $self->{'upto_n'};
    my $xprev = $self->{'xprev'};
    my $yprev = $self->{'yprev'};

    ### upto_n: $n
    ### $xprev
    ### $yprev

    for ( ; $n <= $n_hi; $n++) {
      &$cont() or last;

      my ($x,$y) = $path_object->n_to_xy($n)
        or last; # no more
      ### $n;
      ### xy raw: "$x,$y"

      ($x,$y) = $affine->transform ($x, $y);
      ### xy affine: "$x,$y"
      $x = floor ($x + 0.5);
      $y = floor ($y + 0.5);

      _image_line_clipped ($image, $xprev,$yprev, $x,$y,
                           $width,$height, $foreground);
      $count_figures++;

      $xprev = $x;
      $yprev = $y;
    }
    $self->{'upto_n'} = $n;
    $self->{'xprev'} = $xprev;
    $self->{'yprev'} = $yprev;
    return $more;
  }

  my $n_prev = $self->{'n_prev'};
  my $offset = ($figure eq 'point' ? 0 : int(($pscale+1)/2));
  my $count_total = $self->{'count_total'};
  my $count_outside = $self->{'count_outside'};

  my $background_fill_proc;
  if (! $covers && $figure eq 'point') {
    $background_fill_proc = sub {
      my ($n_to) = @_;
      ### background fill for point
      foreach my $n ($n_prev+1 .. $n_to) {
        $steps++;
        $count_total++;
        my ($x, $y) = $path_object->n_to_xy($n) or do {
          $count_outside++;
          next;
        };
        ($x, $y) = $affine->transform($x, $y);
        $x = floor ($x - $offset + 0.5);
        $y = floor ($y - $offset + 0.5);
        ### back_point: $n
        ### $x
        ### $y
        next if ($x < 0 || $y < 0 || $x >= $width || $y >= $height);

        push @{$points_by_colour{$background}}, $x, $y;
        if (@{$points_by_colour{$background}} >= _POINTS_CHUNKS) {
          $flush->();
        }
      }
    };
  } elsif (! $covers && $figure eq 'square') {
    $background_fill_proc = sub {
      my ($n_to) = @_;
      ### background fill for rectangle
      foreach my $n ($n_prev+1 .. $n_to) {
        $steps++;
        my ($x, $y) = $path_object->n_to_xy($n) or next;
        ($x, $y) = $affine->transform($x, $y);
        ### back_rectangle: "$n   $x,$y"
        $x = floor ($x - $offset + 0.5);
        $y = floor ($y - $offset + 0.5);
        $count_total++;
        my @rect = rect_clipper ($x, $y, $x+$pscale, $y+$pscale,
                                 $width,$height)
          or do {
            $count_outside++;
            next;
          };
        push @{$rectangles_by_colour{$background}}, @rect;
        if (@{$rectangles_by_colour{$background}} >= _RECTANGLES_CHUNKS) {
          $flush->();
        }
      }
    };
  } else {
    ### background_fill_proc is noop
    $background_fill_proc = \&_noop;
  }

  my $colours = $self->{'colours'};
  my $colours_offset = $self->{'colours_offset'};
  my $colour = $foreground;
  my $use_colours = $self->{'use_colours'};
  my $n;
  ### $use_colours
  ### $colours_offset

  if ($self->{'use_xy'}) {
    my $x    = $self->{'x'};
    my $x_hi = $self->{'x_hi'};
    my $y    = $self->{'y'};
    #### draw by xy from: "$x,$y"

    for (;;) {
      ### use_xy: "$x,$y"
      &$cont() or last;

      if (++$x > $x_hi) {
        if (++$y > $self->{'y_hi'}) {
          $values_obj->finish;
          last;
        }
        $x = $self->{'x_lo'};
        #### next row: "$x,$y"
      }

      if (! defined ($n = $path_object->xy_to_n ($x, $y))) {
        next; # no N for this x,y
      }
      #### path: "$x,$y  $n"

      my $count = ($use_colours
                   ? $values_obj->ith($n)
                   : $values_obj->pred($n));
      #### $count
      if (! $count || ! $filter_obj->pred($n)) {
        if (! $covers) {
          ##### background fill

          my ($wx, $wy) = $affine->transform($x, $y);
          $wx = floor ($wx - $offset + 0.5);
          $wy = floor ($wy - $offset + 0.5);
          ### win: "$wx,$wy"

          if ($figure eq 'point') {
            $count_figures++;
            push @{$points_by_colour{$background}}, $wx, $wy;
            if (@{$points_by_colour{$background}} >= _POINTS_CHUNKS) {
              $flush->();
            }
          } elsif ($figure eq 'diamond') {
            if (my @coords = ellipse_clipper ($x,$y, $x+$pscale,$y+$pscale,
                                              $width,$height)) {
              $count_figures++;
              $image->$figure_method (@coords, $colour, $figure_fill);
            }
          } else { # $figure eq 'square'
            $count_figures++;
            push @{$rectangles_by_colour{$background}},
              rect_clipper ($wx, $wy,
                            $wx+$pscale, $wy+$pscale,
                            $width,$height);
            if (@{$rectangles_by_colour{$background}} >= _RECTANGLES_CHUNKS) {
              $flush->();
            }
          }
        }
        next;
      }

      my ($wx, $wy) = $affine->transform($x, $y);
      $wx = floor ($wx - $offset + 0.5);
      $wy = floor ($wy - $offset + 0.5);
      ### win: "$wx,$wy"

      if ($use_colours) {
        $colour = $colours->[min ($#$colours,
                                  max (0, $count + $colours_offset))];
        #### $colour
      }
      if ($figure eq 'point') {
        $count_figures++;
        push @{$points_by_colour{$colour}}, $wx, $wy;
        if (@{$points_by_colour{$colour}} >= _POINTS_CHUNKS) {
          $flush->();
        }
      } elsif ($figure eq 'diamond') {
        if (my @coords = ellipse_clipper ($x,$y, $x+$pscale,$y+$pscale,
                                          $width,$height)) {
          $count_figures++;
          $image->$figure_method (@coords, $colour, $figure_fill);
        }
      } else { # $figure eq 'square'
        $count_figures++;
        push @{$rectangles_by_colour{$colour}},
          rect_clipper ($wx, $wy,
                        $wx+$pscale, $wy+$pscale,
                        $width,$height);
        if (@{$rectangles_by_colour{$colour}} >= _RECTANGLES_CHUNKS) {
          $flush->();
        }
      }
    }
    $self->{'x'} = $x;
    $self->{'y'} = $y;

  } else {
    #### draw by N

    for (;;) {
      &$cont() or last;

      my ($i, $value) = $values_obj->next;
      ### $n_prev
      ### $n
      ### $count
      my $n = ($use_colours ? $i : $value);
      if (! defined $n || $n > $n_hi) {
        ### final background fill
        $background_fill_proc->($n_hi);
        last;
      }
      $filter_obj->pred($n)
        or next;
      my ($x, $y) = $path_object->n_to_xy($n) or next;
      ### path: "$x,$y"

      if ($use_colours) {
        if (! defined $value || $value == 0) {
          next; # background
        }
        $colour = $colours->[min ($#$colours,
                                  max (0, $value + $colours_offset))];
        #### $colour
        #### at index: $value + $colours_offset
      }

      ($x, $y) = $affine->transform($x, $y);
      $x = floor ($x - $offset + 0.5);
      $y = floor ($y - $offset + 0.5);
      ### $x
      ### $y

      if ($figure eq 'point') {
        $background_fill_proc->($n-1);

        $count_total++;
        if ($x < 0 || $y < 0 || $x >= $width || $y >= $height) {
          ### skip, outside width,height
          $count_outside++;
          next;
        }
        push @{$points_by_colour{$colour}}, $x, $y;
        if (@{$points_by_colour{$colour}} >= _POINTS_CHUNKS) {
          $flush->();
        }

      } elsif ($figure eq 'square') {
        $background_fill_proc->($n-1);

        $count_total++;
        my @rect = rect_clipper ($x, $y, $x+$pscale, $y+$pscale,
                                 $width,$height)
          or do {
            $count_outside++;
            next;
          };
        $count_figures++;
        push @{$rectangles_by_colour{$colour}}, @rect;
        if (@{$rectangles_by_colour{$colour}} >= _RECTANGLES_CHUNKS) {
          $flush->();
        }

      } else {
        if (my @coords = ellipse_clipper ($x,$y, $x+$pscale,$y+$pscale,
                                          $width,$height)) {
          $count_figures++;
          $image->$figure_method (@coords, $colour, $figure_fill);
        }
      }

      $n_prev = $n;
    }

    ##### $count_total
    ##### $count_outside
    if ($path_object->figure ne 'circle'
        && $count_total > 1000
        && $count_outside > .5 * $count_total
        && $values_obj->can('pred')
       ) {
      ### use_xy from now on
      $self->use_xy($image);
    } else {
      $self->{'n_prev'} = $n_prev;
      $self->{'count_total'} = $count_total;
      $self->{'count_outside'} = $count_outside;
    }
  }

  $flush->();
  ### $more
  return $more;
}

sub use_xy {
  my ($self, $image) = @_;
  # print "use_xy from now on\n";
  $self->{'use_xy'} = 1;

  my $affine = $self->affine_object;
  my $affine_inv = $affine->clone->invert;
  my $width  = $image->get('-width');
  my $height = $image->get('-height');

  my ($x_lo, $y_hi) = $affine_inv->transform (0,0);
  my ($x_hi, $y_lo) = $affine_inv->transform ($width,$height);

  $x_lo = floor($x_lo);
  $y_lo = floor($y_lo);
  $x_hi = ceil($x_hi);
  $y_hi = ceil($y_hi);
  my $path_object = $self->path_object;
  if (! $self->x_negative) {
    $x_lo = max (0, $x_lo);
    $x_hi = max (0, $x_hi);
  }
  if (! $self->y_negative) {
    $y_lo = max (0, $y_lo);
    $y_hi = max (0, $y_hi);
  }
  $self->{'x_lo'} = $x_lo;
  $self->{'y_lo'} = $y_lo;
  $self->{'x_hi'} = $x_hi;
  $self->{'y_hi'} = $y_hi;

  $self->{'x'} = $x_lo - 1;
  $self->{'y'} = $y_lo;
  #### x: "$x_lo to $x_hi start $self->{'x'}"
  #### y: "$y_lo to $y_hi start $self->{'y'}"

  my $x_width = $self->{'x_width'} = $x_hi - $x_lo + 1;
  $self->{'xy_total'} = ($y_hi - $y_lo + 1) * $x_width;
}

sub draw_progress_fraction {
  my ($self) = @_;
  if ($self->{'use_xy'}) {
    return (($self->{'x'} - $self->{'x_lo'})
            + ($self->{'y'} - $self->{'y_lo'}) * $self->{'x_width'})
      / $self->{'xy_total'};
  } else {
    return $self->{'n_prev'} / $self->{'n_hi'};
  }
}

sub draw_Image {
  my ($self, $image) = @_;
  local $self->{'step_time'} = undef;
  local $self->{'step_figures'} = undef;
  $self->draw_Image_start ($image);
  $self->draw_Image_steps;
}


# draw $image->line() but clipped to width x height
sub _image_line_clipped {
  my ($image, $x1,$y1, $x2,$y2, $width,$height, $foreground) = @_;
  ### _image_line_clipped(): "$x1,$y1 $x2,$y2  ${width}x${height}"
  if (($x1,$y1, $x2,$y2) = line_clipper ($x1,$y1, $x2,$y2, $width,$height)) {
    ### clipped draw: "$x1,$y1 $x2,$y2"
    $image->line ($x1,$y1, $x2,$y2, $foreground);
  }
}

sub ellipse_clipper {
  my ($x1,$y1, $x2,$y2, $width, $height) = @_;

  # Image::Xpm and Xbm have trouble partially off-screen
  return if ($x1 < 0 || $x1 >= $width
             || $x2 < 0 || $x2 >= $width
             || $y1 < 0 || $y1 >= $height
             || $y2 < 0 || $y2 >= $height);
  return ($x1,$y1, $x2,$y2);
}

sub rect_clipper {
  my ($x1,$y1, $x2,$y2, $width,$height) = @_;

  return if ($x1 < 0 && $x2 < 0)
    || ($x1 >= $width && $x2 >= $width)
      || ($y1 < 0 && $y2 < 0)
        || ($y1 >= $height && $y2 >= $height);

  return (max($x1,0),
          max($y1,0),
          min($x2,$width-1),
          min($y2,$height-1));
}

sub line_clipper {
  my ($x1,$y1, $x2,$y2, $width, $height) = @_;

  return if ($x1 < 0 && $x2 < 0)
    || ($x1 >= $width && $x2 >= $width)
      || ($y1 < 0 && $y2 < 0)
        || ($y1 >= $height && $y2 >= $height);

  my $x1new = $x1;
  my $y1new = $y1;
  my $x2new = $x2;
  my $y2new = $y2;
  my $xlen = ($x1 - $x2);
  my $ylen = ($y1 - $y2);

  if ($x1new < 0) {
    $x1new = 0;
    $y1new = floor (0.5 + ($y1 * (-$x2)
                                  + $y2 * ($x1)) / $xlen);
    ### x1 neg: "y1new to $x1new,$y1new"
  } elsif ($x1new >= $width) {
    $x1new = $width-1;
    $y1new = floor (0.5 + ($y1 * ($x1new-$x2)
                                  + $y2 * ($x1 - $x1new)) / $xlen);
    ### x1 big: "y1new to $x1new,$y1new"
  }
  if ($y1new < 0) {
    $y1new = 0;
    $x1new = floor (0.5 + ($x1 * (-$y2)
                                  + $x2 * ($y1)) / $ylen);
    ### y1 neg: "x1new to $x1new,$y1new   left ".($y1new-$y2)." right ".($y1-$y1new)
    ### x1new to: $x1new
  } elsif ($y1new >= $height) {
    $y1new = $height-1;
    $x1new = floor (0.5 + ($x1 * ($y1new-$y2)
                                  + $x2 * ($y1 - $y1new)) / $ylen);
    ### y1 big: "x1new to $x1new,$y1new   left ".($y1new-$y2)." right ".($y1-$y1new)
  }
  if ($x1new < 0 || $x1new >= $width) {
    ### x1new outside
    return;
  }

  if ($x2new < 0) {
    $x2new = 0;
    $y2new = floor (0.5 + ($y2 * ($x1)
                                  + $y1 * (-$x2)) / $xlen);
    ### x2 neg: "y2new to $x2new,$y2new"
  } elsif ($x2new >= $width) {
    $x2new = $width-1;
    $y2new = floor (0.5 + ($y2 * ($x1-$x2new)
                                  + $y1 * ($x2new-$x2)) / $xlen);
    ### x2 big: "y2new to $x2new,$y2new"
  }
  if ($y2new < 0) {
    $y2new = 0;
    $x2new = floor (0.5 + ($x2 * ($y1)
                                  + $x1 * (-$y2)) / $ylen);
    ### y2 neg: "x2new to $x2new,$y2new"
  } elsif ($y2new >= $height) {
    $y2new = $height-1;
    $x2new = floor (0.5 + ($x2 * ($y1-$y2new)
                                  + $x1 * ($y2new-$y2)) / $ylen);
    ### y2 big: "x2new $x2new,$y2new"
  }
  if ($x2new < 0 || $x2new >= $width) {
    ### x2new outside
    return;
  }

  return ($x1new,$y1new, $x2new,$y2new);
}


#------------------------------------------------------------------------------
# generic

use constant TRUE => 1;

# _gettime() returns a floating point count of seconds since some fixed but
# unspecified origin time.
#
# clock_gettime(CLOCK_REALTIME) is preferred.  clock_gettime() always
# exists, but it croaks if there's no such C library func.  In that case
# fall back on the hires time(), which is whatever best thing Time::HiRes
# can do, probably gettimeofday() normally.
#
# Maybe it'd be worth checking clock_getres() to see it's a decent
# resolution.  It's conceivable some old implementations might do
# CLOCK_REALTIME just from the CLK_TCK times() counter, giving only 10
# millisecond resolution.  That's enough for _IDLE_TIME_SLICE of 250 ms
# though.
#
sub _gettime {
  return Time::HiRes::clock_gettime (Time::HiRes::CLOCK_REALTIME());
}
BEGIN {
  unless (eval { _gettime(); 1 }) {
    ### _gettime() no clock_gettime(): $@
    no warnings;
    *_gettime = \&Time::HiRes::time;
  }
}

sub _noop {}

1;
__END__
