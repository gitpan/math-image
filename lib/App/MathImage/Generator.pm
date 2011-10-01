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
use Image::Base 1.16; # 1.16 for diamond()
use Time::HiRes;
use List::Util 'min', 'max';
use Locale::TextDomain 'App-MathImage';

use App::MathImage::Image::Base::Other;

use vars '$VERSION';
$VERSION = 73;

# uncomment this to run the ### lines
#use Devel::Comments;

use constant default_options => {
                                 values       => 'Primes',
                                 path         => 'SquareSpiral',
                                 scale        => 1,
                                 width        => 10,
                                 height       => 10,
                                 foreground   => 'white',
                                 background   => 'black',
                                 filter       => 'All',
                                 figure       => 'default',

                                 # hack for prima code
                                 path_parameters => { wider => 0 },

                                 # fraction     => '5/29',
                                 # sqrt         => '2',
                                 # spectrum     => (sqrt(5)+1)/2,
                                 # polygonal    => 5,
                                 # multiples    => 90,
                                 # parity       => 'odd',
                                 # multiplicity => 'repeated',
                                 # pairs        => 'first',
                                 # radix        => 10,
                                 # aronson_lang         => 'en',
                                 # aronson_letter       => '',
                                 # aronson_lying        => 0,
                                 # path_rotation_type => 'phi',
                                 # expression      => '3*x^2 + x + 2',
                                 # planepath_class => 'SquareSpiral',
                                 # delta_type      => 'X',
                                 # coord_type      => 'X',
                                };

### *DESTROY = sub { print "Generator DESTROY\n" }

sub new {
  my $class = shift;
  ### Generator new()...
  my $self = bless { %{$class->default_options()}, @_ }, $class;
  if (! defined $self->{'undrawnground'}) {
    $self->{'undrawnground'} = $self->{'background'};
  }
  return $self;
}

# columns_of_pythagoras
use constant values_choices => do {
  my %choices;
  foreach my $module (Module::Util::find_in_namespace('App::MathImage::NumSeq'),
                      Module::Util::find_in_namespace('Math::NumSeq')) {
    my $choice = $module;
    $choice =~ s/^Math::NumSeq:://;
    $choice =~ s/^App::MathImage::NumSeq:://;
    next if $choice =~ /::/; # not sub-modules
    $choice =~ s/::/-/g;
    $choices{$choice} = 1;
  }
  if (! defined (Module::Util::find_installed('Math::Symbolic'))
      && ! defined (Module::Util::find_installed('Math::Expression::Evaluator'))
      && ! defined (Module::Util::find_installed('Language::Expr'))) {
    delete $choices{'Expression'};
  }
  my @choices;
  foreach my $prefer (qw(Primes
                         PrimeFactorCount
                         MobiusFunction
                         TwinPrimes
                         SophieGermainPrimes
                         SafePrimes
                         SemiPrimes
                         SemiPrimesOdd
                         Emirps
                         Abundant
                         Obstinate
                         Squares
                         Pronic
                         Triangular
                         Pentagonal
                         Polygonal
                         StarNumbers
                         Cubes
                         Tetrahedral

                         Odd
                         Even
                         All

                         Fibonacci
                         Lucas
                         Perrin
                         Padovan
                         Tribonacci
                         Factorials
                         Primorials

                         FractionDigits
                         SqrtDigits
                         PiBits
                         Ln2Bits

                         Aronson
                         Pell
                         GoldenSequence
                         ThueMorse
                         ChampernowneBinary
                         ChampernowneBinaryLsb
                         SternDiatomic

                         DigitLength
                         DigitLengthCumulative
                         DigitSum
                         DigitSumModulo
                         DigitProduct
                         DigitCount
                         DigitCountHigh
                         DigitCountLow

                         PrimeQuadraticEuler
                         PrimeQuadraticLegendre
                         PrimeQuadraticHonaker

                         Repdigits
                         RepdigitAnyBase
                         RepdigitBase
                         Beastly
                         RadixWithoutDigit
                         UndulatingNumbers

                         CullenNumbers
                         WoodallNumbers
                         ProthNumbers

                         Multiples
                         OEIS
                         File
                       )) {
    if (delete $choices{$prefer}) {
      push @choices, $prefer;
    }
  }
  delete $choices{'Lines'};
  delete $choices{'LinesLevel'};
  delete $choices{'LinesTree'};
  push @choices, sort keys %choices;
  push @choices, 'Lines';
  push @choices, 'LinesLevel';
  push @choices, 'LinesTree';
  ### @choices
  @choices
};

sub values_class {
  my ($class_or_self, $values) = @_;
  $values ||= $class_or_self->{'values'};
  $values =~ s/-/::/g;
  my $values_class = (Module::Util::find_installed("App::MathImage::NumSeq::$values")
                      ? "App::MathImage::NumSeq::$values"
                      : "Math::NumSeq::$values");
  Module::Load::load ($values_class);
  return $values_class;
}
sub values_object {
  my ($self) = @_;
  my $values_class = $self->values_class($self->{'values'});
  ### Generator values_object()...
  ### $values_class
  ### values_parameters: $self->{'values_parameters'}

  my $values_obj = eval {
    $values_class->new (width => $self->{'width'},
                        height => $self->{'height'},
                        %{$self->{'values_parameters'}||{}},
                        hi => 100)
  };
  if (! $values_obj) {
    my $err = $@;
    ### values_obj error: $@
    die $err;
  } else {
    ### ret: "$values_obj"
  }
  return $values_obj;
}

#------------------------------------------------------------------------------
# path square grid

my %pathname_square_grid
  = (map {$_=>1} qw(
                     SquareSpiral
                     PyramidSpiral
                     TriangleSpiral
                     TriangleSpiralSkewed
                     DiamondSpiral
                     PentSpiral
                     PentSpiralSkewed
                     HexSpiral
                     HexSpiralSkewed
                     HeptSpiralSkewed
                     OctagramSpiral
                     KnightSpiral

                     SquareArms
                     DiamondArms
                     HexArms
                     GreekKeySpiral

                     PixelRings
                     Hypot
                     HypotOctant
                     TriangularHypot
                     PythagoreanTree
                     RationalsTree
                     CoprimeColumns

                     PeanoCurve
                     HilbertCurve
                     ZOrderCurve
                     ImaginaryBase

                     Flowsnake
                     FlowsnakeCentres
                     GosperIslands
                     GosperSide

                     QuintetCurve
                     QuintetCentres
                     QuintetReplicate

                     DragonCurve
                     DragonRounded
                     DragonMidpoint
                     ComplexMinus

                     KochCurve
                     KochPeaks
                     KochSnowflakes
                     KochSquareflakes
                     QuadricCurve
                     QuadricIslands
                     SierpinskiArrowhead
                     SierpinskiArrowheadCentres
                     SierpinskiTriangle

                     Rows
                     Columns
                     Diagonals
                     Staircase
                     Corner
                     PyramidRows
                     PyramidSides
                     CellularRule54

                     MathImageComplexPlus
                     MathImageCornerReplicate
                     MathImageGosperTiling
                     MathImageKochSquareflakes
                     MathImageQuintetSide
                     MathImageSierpinskiCurve
                     MathImageSquareReplicate
                     MathImageWunderlichCurve
                  )
    );
# my %pathname_fractional_grid
#   = (SacksSpiral => 1,
#      VogelFloret => 1,
#      TheodorusSpiral => 1,
#      MultipleRings => 1,
#      ArchimedeanChords => 1,
#      File => 1,
#
#     );
# {
#   my %all;
#   @all{__PACKAGE__->path_choices} = (); # hash slice
#   delete @all{keys %pathname_square_grid};
#   delete @all{keys %pathname_fractional_grid};
#   my @omitted = sort keys %all;
#   print "pathname_square_grid omitted: ",scalar(@omitted),
#     "  ",join(' ', @omitted),"\n";
# }


#------------------------------------------------------------------------------
# path discontinuity

{ package Math::PlanePath;
  use constant MathImage__n_fraction_discontinuity => undef;
}
{ package Math::PlanePath::PyramidRows;
  use constant MathImage__n_fraction_discontinuity => .5;
}
{ package Math::PlanePath::PyramidSides;
  use constant MathImage__n_fraction_discontinuity => .5;
}
{ package Math::PlanePath::CellularRule54;
  use constant MathImage__n_fraction_discontinuity => .5;
}
{ package Math::PlanePath::Corner;
  use constant MathImage__n_fraction_discontinuity => .5;
}
{ package Math::PlanePath::Staircase;
  use constant MathImage__n_fraction_discontinuity => .5;
}
{ package Math::PlanePath::Rows;
  use constant MathImage__n_fraction_discontinuity => .5;
}
{ package Math::PlanePath::Columns;
  use constant MathImage__n_fraction_discontinuity => .5;
}
{ package Math::PlanePath::Diagonals;
  use constant MathImage__n_fraction_discontinuity => .5;
}
{ package Math::PlanePath::KochPeaks;
  use constant MathImage__n_fraction_discontinuity => .5;
}
{ package Math::PlanePath::CoprimeColumns;
  use constant MathImage__n_fraction_discontinuity => .5;
}
{ package Math::PlanePath::MultipleRings;
  use constant MathImage__n_fraction_discontinuity => 0;
}
{ package Math::PlanePath::KochSnowflakes;
  use constant MathImage__n_fraction_discontinuity => 0;
}
{ package Math::PlanePath::KochSquareflakes;
  use constant MathImage__n_fraction_discontinuity => 0;
}
{ package Math::PlanePath::GosperIslands;
  use constant MathImage__n_fraction_discontinuity => 0;
}
     # PixelRings  => 0,

#------------------------------------------------------------------------------
# path lattice

{ package Math::PlanePath;
  use constant MathImage__lattice_type => '';
}
{ package Math::PlanePath::HexSpiral;
  use constant MathImage__lattice_type => 'triangular';
}
{ package Math::PlanePath::HexArms;
  use constant MathImage__lattice_type => 'triangular';
}
{ package Math::PlanePath::TriangularHypot;
  use constant MathImage__lattice_type => 'triangular';
}
{ package Math::PlanePath::KochCurve;
  use constant MathImage__lattice_type => 'triangular';
}
{ package Math::PlanePath::KochPeaks;
  use constant MathImage__lattice_type => 'triangular';
}
{ package Math::PlanePath::KochSnowflakes;
  use constant MathImage__lattice_type => 'triangular';
}
{ package Math::PlanePath::KochSquareflakes;
  use constant MathImage__lattice_type => 'triangular';
}
{ package Math::PlanePath::SierpinskiTriangle;
  use constant MathImage__lattice_type => 'triangular';
}
{ package Math::PlanePath::SierpinskiArrowhead;
  use constant MathImage__lattice_type => 'triangular';
}
{ package Math::PlanePath::SierpinskiArrowheadCentres;
  use constant MathImage__lattice_type => 'triangular';
}
{ package Math::PlanePath::GosperSide;
  use constant MathImage__lattice_type => 'triangular';
}
{ package Math::PlanePath::GosperIslands;
  use constant MathImage__lattice_type => 'triangular';
}
{ package Math::PlanePath::Flowsnake;
  use constant MathImage__lattice_type => 'triangular';
}
{ package Math::PlanePath::FlowsnakeCentres;
  use constant MathImage__lattice_type => 'triangular';
}


#------------------------------------------------------------------------------
# path x,y negative

# { package Math::PlanePath;
#   sub MathImage__x_negative { $_[0]->x_negative }
#   sub MathImage__y_negative { $_[0]->y_negative }
# }
sub x_negative {
  my ($self) = @_;
  return $self->path_object->x_negative;
}
sub y_negative {
  my ($self) = @_;
  return $self->path_object->y_negative;
}

#------------------------------------------------------------------------------

  sub path_choices {
    my ($class) = @_;
    return @{$class->path_choices_array};
  }
  use constant path_choices_array => do {
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
                           ArchimedeanChords
                           MultipleRings
                           PixelRings
                           Hypot
                           HypotOctant
                           TriangularHypot

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

                           SquareArms
                           DiamondArms
                           HexArms
                           GreekKeySpiral

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
                           ImaginaryBase

                           Flowsnake
                           FlowsnakeCentres
                           GosperIslands
                           GosperSide

                           QuintetCurve
                           QuintetCentres
                           QuintetReplicate

                           KochSnowflakes
                           KochSquareflakes
                           KochPeaks
                           KochCurve

                           SierpinskiTriangle
                           SierpinskiArrowhead
                           SierpinskiArrowheadCentres
                           DragonCurve
                           DragonRounded
                           DragonMidpoint
                           ComplexMinus

                           PythagoreanTree
                           RationalsTree
                           File
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
    \@choices
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
                                    L
                                    V
                                    triangle
                                    hexagon
                                    undiamond
                                    unellipse
                                    unellipunf);

  #------------------------------------------------------------------------------
  # random

  # cf Data::Random

  sub random_options {
    my ($self) = @_;
    my $values_parameters =
      {
       polygonal => (int(rand(20)) + 5), # skip 3=triangular, 4=squares
       pairs     => _rand_of_array(['first','second','both']),
       parity    => _rand_of_array(['odd','even']),
       # aronson
       lang         => _rand_of_array(['en','fr']),
       conjunctions => int(rand(2)),
       lying        => (rand() < .25), # less likely
      };
    my $path_parameters =
      {
      };
    my @ret = (values_parameters => $values_parameters,
               path_parameters => $path_parameters);

    my @path_choices = $self->path_choices;
    @path_choices
      = grep {!/PythagoreanTree|RationalsTree/}  # values too big for many seqs
        @path_choices;
    @path_choices = (@path_choices,
                     grep {!/KochCurve|GosperSide/} @path_choices);

    my @values_choices = $self->values_choices;
    @values_choices = grep {!/LinesLevel     # experimental
                             /x}
      @values_choices;
    #   # coord values are only permutation of integers, or coord repetitions ?
    # |PlanePath

    my @path_and_values;
    foreach my $path (@path_choices) {
      next if $path eq 'File';

      foreach my $values (@values_choices) {
        next if $values eq 'File';

        if ($values eq 'All' || $values eq 'Odd' || $values eq 'Even') {
          next unless $path eq 'SacksSpiral' || $path eq 'VogelFloret';
        }

        # too sparse?
        # next if ($values eq 'Factorials');

        # bit sparse?
        # next if $values eq 'Perrin' || $values eq 'Padovan';

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
        if ($values eq 'Lines' || $values eq 'LinesTree'
            || $values eq 'LinesLevel') {
          next if $path eq 'VogelFloret'; # too much crossover
        }

        push @path_and_values, [ $path, $values ];
      }
    }
    my ($path, $values) = @{_rand_of_array(\@path_and_values)};
    push @ret, path => $path, values => $values;

    my $path_class = $self->path_class($path);

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
      $values_parameters->{'radix'} = $radix;
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
      if ($values eq 'LinesTree') {
        # not too small for lines to show up sensibly
        $scale = max ($scale, 50);
      }
      push @ret, scale => $scale;
    }
    {
      require Math::Prime::XS;
      my @primes = Math::Prime::XS::sieve_primes(10,100);
      my $num = _rand_of_array(\@primes);
      @primes = grep {$_ != $num} @primes;
      my $den = _rand_of_array(\@primes);
      $values_parameters->{'fraction'} = "$num/$den";
    }
    {
      my @primes = Math::Prime::XS::sieve_primes(2,100);
      my $sqrt = _rand_of_array(\@primes);
      $values_parameters->{'sqrt'} = $sqrt;
    }

    {
      my $pyramid_step = 1 + int(rand(20));
      if ($pyramid_step > 12) {
        $pyramid_step = 2;  # most of the time
      }
      $path_parameters->{'step'} = $pyramid_step;
    }
    if ($path eq 'MultipleRings') {  # FIXME: go from parameter_info_array
      my $rings_step = int(rand(20));
      if ($rings_step > 15) {
        $rings_step = 6;  # more often
      }
      $path_parameters->{'step'} = $rings_step;
    }
    {
      my $path_wider = _rand_of_array([(0) x 10,   # 0 most of the time
                                       1 .. 20]);
      $path_parameters->{'wider'} = $path_wider;
    }
    {
      if (my $info = $path_class->parameter_info_hash->{'radix'}) {
        $path_parameters->{'radix'} = _rand_of_array([ ($info->{'default'}) x 3,
                                                       2 .. 7 ]);
      }
    }
    {
      $path_parameters->{'rotation_type'}
        = _rand_of_array(['phi','phi','phi','phi',
                          'sqrt2','sqrt2',
                          'sqrt3',
                          'sqrt5',
                         ]);
      # path_rotation_factor => $rotation_factor,
    }
    {
      my @figure_choices = $self->figure_choices;
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
            # spectrum  => $spectrum,

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

#------------------------------------------------------------------------------
# generator names

sub description {
  my ($self) = @_;

  my $path_object = $self->path_object;
  my @path_desc = ($self->{'path'},
                   map {
                     my $pname = $_->{'name'};
                     "$pname $path_object->{$pname}"
                   } @{$path_object->parameter_info_array});

  my $values_object = $self->values_object;
  my @values_desc = ($self->{'values'},
                     # $self->values_object->name,  # NumSeq name method
                     map {
                       my $pname = $_->{'name'};
                       my $dispname = ($pname eq 'radix' ? 'base' : $pname);
                       my $value = $values_object->{$pname};
                       if (! defined $value) { $value = $_->{'default'}; }
                       "$dispname $value"
                     } $values_object->parameter_info_list);

  my $filtered;
  if (($self->{'filter'}||'') ne 'All') {
    $filtered = __x(", filtered {name}",
                    name => $self->{'filter'});
    # $self->values_class($self->{'filter'})->name); NumSeq name() method
  } else {
    $filtered = '';
  }

  return __x('{path_desc}, {values_desc}{filtered}, {width}x{height} scale {scale}',
             path_desc => join(' ',@path_desc),
             values_desc => join(' ',@values_desc),
             filtered => $filtered,
             width => $self->{'width'},
             height => $self->{'height'},
             scale => $self->{'scale'});
}

sub filename_base {
  my ($self) = @_;
  return join('-',
              (map { tr{/}{_}; $_ }
               $self->{'path'},
               do {
                 my $path_object = $self->path_object;
                 ### $path_object
                 ### info array: $path_object->parameter_info_array
                 map {
                   (defined $path_object->{$_->{'name'}}
                    && $path_object->{$_->{'name'}} ne $_->{'default'})
                     ? $path_object->{$_->{'name'}}
                       : ()
                     }
                   @{$path_object->parameter_info_array}
                 },
               $self->{'values'},
               do {
                 my $values_object = $self->values_object;
                 map {
                   (defined $values_object->{$_->{'name'}}
                    && $values_object->{$_->{'name'}} ne $_->{'default'})
                     ? $values_object->{$_->{'name'}}
                       : ()
                     } $values_object->parameter_info_list
                   },
               (($self->{'filter'}||'') eq 'All' ? () : $self->{'filter'}),
               $self->{'width'}.'x'.$self->{'height'},
               ($self->{'scale'} == 1 ? () : 's'.$self->{'scale'}),
               ($self->{'figure'} ne 'default' ? $self->{'figure'} : ()),
              ));
}


#------------------------------------------------------------------------------

sub path_choice_to_class {
  my ($self, $path) = @_;
  my $class = "Math::PlanePath::$path";
  if (Module::Util::find_installed ($class)) {
    return $class;
  }
  return undef;
}
sub path_class {
  my ($self, $path) = @_;
  unless ($path =~ /::/) {
    $path = $self->path_choice_to_class ($path)
      || croak "No module for path $path";
  }
  unless (eval { Module::Load::load ($path); 1 }) {
    my $err = $@;
    ### cannot load: $err
    croak $err;
  }
  return $path;
}

sub path_object {
  my ($self) = @_;
  return ($self->{'path_object'} ||= do {

    my $path_class = $self->path_class ($self->{'path'});
    #### $path_class

    my $scale = $self->{'scale'} || 1;
    my %parameters = %{$self->{'path_parameters'} || {}};
    ### %parameters
    $parameters{'width'} = ceil(($parameters{'width'}||0) / $scale);
    $parameters{'height'} = ceil(($parameters{'height'}||0) / $scale);
    if (($parameters{'rotation_type'}||'') eq 'custom') {
      delete $parameters{'rotation_type'};
    }
    $path_class->new (%parameters)
  });
}

sub affine_object {
  my ($self) = @_;
  return ($self->{'affine_object'} ||= do {
    my $s_mid = int ($self->{'scale'} / 2);
    my $scale = $self->{'scale'};
    my $x_origin
      = (defined $self->{'x_left'} ? - $self->{'x_left'} * $scale
         : $self->x_negative ? int ($self->{'width'} / 2)
         : $s_mid);
    my $y_origin
      = (defined $self->{'y_bottom'} ? $self->{'y_bottom'} * $scale + $self->{'height'}
         : $self->y_negative ? int ($self->{'height'} / 2)
         : $self->{'height'} - $self->{'scale'} + $s_mid);
    if (defined (my $x_offset = $self->{'x_offset'})) {
      $x_origin += $x_offset;
    }
    if (defined (my $y_offset = $self->{'y_offset'})) {
      $y_origin -= $y_offset;
    }
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

use constant 1.02; # for leading underscore
use constant _POINTS_CHUNKS     => 200 * 2;  # of X,Y
use constant _RECTANGLES_CHUNKS => 200 * 4;  # of X1,Y1,X2,Y2

sub covers_quadrants {
  my ($self) = @_;
  if ($self->{'background'} eq $self->{'undrawnground'}) {
    return 1;
  }
  if ($self->{'values'} eq 'Lines'
      || $self->{'values'} eq 'LinesLevel'
      || $self->{'values'} eq 'LinesTree') {
    # no undrawnground when drawing lines
    return 1;
  }
  my $path_object = $self->path_object;
  if (! _path_covers_quadrants ($path_object)) {
    return 0;
  }
  return 1;

  # my $affine_object = $self->affine_object;
  # my ($wx,$wy) = $affine_object->transform(-.5,-.5);
  # $wx = floor($wx+0.5);
  # $wy = floor($wy+0.5);
  # if (! $self->x_negative && $wx >= 0
  #     || ! $self->y_negative && $wy < $self->{'height'}-1) {
  #   return 0;
  # }
}
sub _path_covers_quadrants {
  my ($path_object) = @_;
  if ($path_object->isa('Math::PlanePath::PyramidRows')
      || ref($path_object) =~ /Octant/  # HypotOctant

      # too much contrast of undrawn points
      # || $path_object->isa('Math::PlanePath::CoprimeColumns')
     ) {
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
    return ($self->{'values'} =~ /^Lines/
            ? 'circle'
            : $self->path_object->figure);
  }
  return $figure;
}

sub colour_to_rgb {
  my ($colour) = @_;
  my $scale;
  # ENHANCE-ME: Or demand Color::Library always, or
  # X11::Protocol::Other::hexstr_to_rgb()
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

sub colours_grey_exp {
  my ($self) = @_;
  my $colours = $self->{'colours'} = [];
  my $f = 1.0;
  my $shrink = 0.6;
  if ($self->{'values'} eq 'Totient') {
    $shrink = .9995;
  } elsif ($self->{'values'} eq 'CunninghamChain') {
    $shrink = .7;
  } elsif ($self->{'values'} eq 'TotientSteps') {
    $shrink = .88;
  } elsif ($self->{'values'} eq 'SternDiatomic') {
    $shrink = 1 - 1/30;
  } elsif ($self->{'values'} eq 'CollatzSteps') {
    if ($self->values_object->{'step_type'} eq 'up') {
      $shrink = 1 - 1/15;
    } elsif ($self->values_object->{'step_type'} eq 'down') {
      $shrink = 1 - 1/40;
    } elsif ($self->values_object->{'step_type'} eq 'both') {
      $shrink = 1 - 1/50;
    }
  } elsif ($self->{'values'} eq 'HappySteps') {
    $shrink = 1 - 1/10;
  } elsif ($self->{'values'} eq 'DigitProduct') {
    $shrink = .99;
  } elsif ($self->{'values'} eq 'DigitSum') {
    $shrink = .95;
  } elsif ($self->{'values'} eq 'DigitCount') {
    $shrink = .8;
  } elsif ($self->{'values'} eq 'RepdigitBase') {
    $shrink = .95;
  }
  for (;;) {
    push @$colours, $self->colour_scaled ($f);
    last if ($f < 1/255);
    $f = $shrink * $f;
  }
  ### grey exp colours: $self->{'colours'}
}
sub colours_grey_linear {
  my ($self, $n, $colour) = @_;
  $self->{'colour_method'} = \&_colour_array;
  my $colours = $self->{'colours'} = [];
  foreach my $i (0 .. $n-1) {
    push @$colours, $self->colour_scaled ($i / ($n-1));
  }
  ### colours_grey_linear: $self->{'colours'}
}
sub _colour_array {
  my ($self, $count) = @_;
  return $self->{'colours'}->[$count];

}

# $factor=0 background, through $factor=1 foreground
sub colour_scaled {
  my ($self, $factor) = @_;
  return $self->colour_heat($factor);

  my @foreground = colour_to_rgb($self->{'foreground'});
  my @background = colour_to_rgb($self->{'background'});
  if (! @foreground) { @foreground = (1.0, 1.0, 1.0); }
  if (! @background) { @background = (0, 0, 0); }
  my $bg_factor = 1 - $factor;
  return rgb1_to_rgbstr (map {
    ($foreground[$_]*$factor + $background[$_]*$bg_factor)
  } 0,1,2);
}
# x=0 blue through x=1 red
sub colour_heat {
  my ($self, $x) = @_;
  return rgb1_to_rgbstr (map { ($x < $_        ? 0
                                : $x < $_+.25  ? 4*($x-$_)
                                : $x < $_+.5   ? 1
                                : $x < $_+.75  ? 4*($_+.75 - $x)
                                : 0)
                             } .375, .125, -.125);
}
sub rgb1_to_rgbstr {
  return sprintf("#%04X%04X%04X",
                 map { max (0, min (0xFFFF, int (0.5 + 0xFFFF * $_))) }
                 @_);

  # return sprintf("#%02X%02X%02X",
  #                map { max (0, min (0xFF, int (0.5 + 0xFF * $_))) }
  #                @_);

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
  ### draw_Image_start()...
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
  my $covers = $self->covers_quadrants;
  my $affine = $self->affine_object;
  my @colours = ($foreground);

  # clear undrawn quadrants
  {
    my @undrawn_rects;
    my @background_rects;
    if ($covers) {
      my ($x_origin,$y_origin) = $affine->transform(-.51,-.51);
      $x_origin = floor ($x_origin + 0.5);
      $y_origin = floor ($y_origin + 0.5);
      my $x_clear = 0;
      my $y_clear = $height-1;
      if (! $path_object->x_negative) {
        if ($x_origin > 0) {
          push @undrawn_rects, 0,0, $x_origin-1,$height-1;
          $x_clear = $x_origin;
        }
      }
      if (! $path_object->y_negative) {
        if ($y_origin < $height-1) {
          push @undrawn_rects, $x_clear,$y_origin+1, $width-1,$height-1;
          $y_clear = $y_origin;
        }
      }
      push @background_rects, $x_clear,0, $width-1,$y_clear;
    } else {
      push @undrawn_rects, 0,0, $width-1,$height-1;
    }
    $image->add_colours ($background, (@undrawn_rects ? $undrawnground : ()));
    App::MathImage::Image::Base::Other::rectangles
        ($image, $undrawnground, 1, @undrawn_rects);
    App::MathImage::Image::Base::Other::rectangles
        ($image, $background, 1, @background_rects);
  }

  my ($n_lo, $n_hi);
  my $rectangle_area = 1;
  if ($self->{'values'} eq 'LinesLevel') {
    my $level = ($self->{'values_parameters'}->{'level'} ||= 2);
    ### $level
    $n_lo = $path_object->n_start;
    my $yfactor = 1;
    my $n_angle;
    my $xmargin = .05;
    if ($path_object->isa ('Math::PlanePath::Flowsnake')
        || $path_object->isa ('Math::PlanePath::FlowsnakeCentres')) {
      $yfactor = sqrt(3);
      $n_hi = 7 ** $level;
      $n_angle = 6;
      foreach (2 .. $level) {
        $n_angle = (7 * $n_angle + 0);
      }
    } elsif ($path_object->isa ('Math::PlanePath::PeanoCurve')) {
      $n_hi = 9 ** $level - 1;
    } elsif ($path_object->isa ('Math::PlanePath::KochCurve')) {
      $n_hi = 4 ** $level;
      $yfactor = sqrt(3)*2;
    } elsif ($path_object->isa ('Math::PlanePath::KochPeaks')) {
      $n_lo = $level + (2*4**$level + 1)/3;
      $n_hi = ($level+1) + (2*4**($level+1) + 1)/3 - 1;
      $yfactor = sqrt(3)*2;
    } elsif ($path_object->isa ('Math::PlanePath::KochSnowflakes')) {
      $n_lo = 4 ** $level;
      $n_hi = 4 ** ($level+1) - 1;
      $yfactor = sqrt(3)*2;
    } elsif ($path_object->isa ('Math::PlanePath::KochSquareflakes')) {
      $n_lo = (4 ** ($level+1) - 1) / 3;
      $n_hi = (4 ** ($level+2) - 4) / 3;
      $yfactor = sqrt(3)*2;
    } elsif ($path_object->isa ('Math::PlanePath::SierpinskiArrowhead')
             || $path_object->isa ('Math::PlanePath::SierpinskiArrowheadCentres')
             || $path_object->isa ('Math::PlanePath::SierpinskiTriangle')) {
      $n_hi = 3 ** $level;
      $n_angle = 2 * 3**($level-1);
      $yfactor = sqrt(3);
    } elsif ($path_object->isa ('Math::PlanePath::MathImageSierpinskiCurve')) {
      $n_hi = 4 ** $level;
      $yfactor = 2;
    } elsif ($path_object->isa ('Math::PlanePath::QuadricCurve')) {
      $n_hi = 8 ** $level;
    } elsif ($path_object->isa ('Math::PlanePath::QuadricIslands')) {
      $n_hi = 4 * 8 ** $level;
    } elsif ($path_object->isa ('Math::PlanePath::QuintetCurve')
             || $path_object->isa ('Math::PlanePath::QuintetCentres')
             || $path_object->isa ('Math::PlanePath::QuintetReplicate')) {
      $n_hi = 5 ** $level - 1;
    } else {
      $n_hi = $level*$level;
    }
    $n_angle ||= $n_hi;

    ### $level
    ### $n_lo
    ### $n_hi
    ### $n_angle
    ### $yfactor

    $affine = Geometry::AffineTransform->new;
    $affine->scale (1, $yfactor);

    my ($xlo, $ylo) = $path_object->n_to_xy ($n_lo);
    my ($xang, $yang) = $path_object->n_to_xy ($n_angle);
    my $theta = - atan2 ($yang*$yfactor, $xang);
    my $r = hypot ($xlo-$xang,($ylo-$yang)*$yfactor) || 1;
    ### lo raw: "$xlo, $ylo"
    ### ang raw: "$xang, $yang"
    ### hi raw: $path_object->n_to_xy($n_hi)
    ### $theta
    ### $r

    ### origin: $self->{'width'} * .15, $self->{'height'} * .5
    $affine->rotate ($theta / 3.14159 * 180);
    my $rot = $affine->clone;
    $affine->scale ($self->{'width'} * (1-2*$xmargin) / $r,
                    - $self->{'width'} * .7 / $r * .3);
    $affine->translate ($self->{'width'} * $xmargin,
                        $self->{'height'} * .5);

    ### width: $self->{'width'}
    ### scale x: $self->{'width'} * (1-2*$xmargin) / $r
    ### transform lo: join(',',$affine->transform($xlo,$ylo))
    ### transform ang: join(',',$affine->transform($xang,$yang))

    # FIXME: wrong when rotated ... ??
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

    my ($x,$y) = $path_object->n_to_xy ($n_lo++);
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
    $rectangle_area = (abs($x2-$x1)+2) * (abs($y2-$y1)+2);
    ### limits around:
    ### $x1
    ### $x2
    ### $y1
    ### $y2

    ($n_lo, $n_hi) = $path_object->rect_to_n_range ($x1,$y1, $x2,$y2);

    if ($self->{'values'} eq 'Lines') {
      $n_hi += 1;
    } elsif ($self->{'values'} eq 'LinesTree') {
      $n_hi += ($self->{'values_parameters'}->{'branches'} ||= 3);
    }
  }

  ### $n_lo
  ### $n_hi
  $self->{'n_prev'} = $n_lo - 1;
  $self->{'upto_n'} = $n_lo;
  $self->{'n_hi'}   = $n_hi;
  $self->{'count_total'} = 0;
  $self->{'count_outside'} = 0;

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

  } elsif ($self->{'values'} eq 'LinesTree') {
    my $branches = ($self->{'values_parameters'}->{'branches'} ||= 3);
    $self->{'branch_i'} = $branches;
    $self->{'upto_n'} = $path_object->n_start - 1;
    $self->{'upto_n_dest'} = $path_object->n_start + 1;

  } else {
    my $values_class = $self->values_class($self->{'values'});
    ### values_parameters: $self->{'values_parameters'}
    my $values_obj = $self->{'values_obj'}
      = $values_class->new (%{$self->{'values_parameters'} || {}},
                            lo => $n_lo,
                            hi => $n_hi);

    if ($values_obj->characteristic('pn1')) {
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
      ### pn1...
      ### colours: $self->{'colours'}
      ### colours_offset: $self->{'colours_offset'}

    } elsif ($values_obj->characteristic('count')
             || $values_obj->characteristic('smaller')) {
      $self->{'colours_offset'} = 0;
      if ($image->isa('Image::Base::Text')) {
        $self->{'colours'} = [ 0 .. 9 ];
      } else {
        $self->colours_grey_exp ($self);
      }
      push @colours, @{$self->{'colours'}};
      $self->{'use_colours'} = 1;
      $self->{'colours_offset'} = - ($values_obj->values_min || 0);
      ### type "count" ...
      ### colours_offset: $self->{'colours_offset'}
      ### per values_min: $values_obj->values_min
      ### colours: $self->{'colours'}

    } elsif (my $num = ($values_obj->characteristic('digits')
                        || $values_obj->characteristic('modulus'))) {
      $self->{'colours_offset'} = 0;
      if ($image->isa('Image::Base::Text')) {
        $self->{'colours'} = [ 0 .. 9, 'A' .. 'Z' ];
      } else {
        $self->colours_grey_linear ($num);
      }
      $self->{'use_colours'} = 1;
      push @colours, @{$self->{'colours'}};
    }
    ### values_obj: $self->{'values_obj'}

    my $filter = $self->{'filter'} || 'All';
    $self->{'filter_obj'} =
      $self->values_class($filter)->new (lo => $n_lo,
                                         hi => $n_hi);

    ### $rectangle_area
    ### $n_hi
    ### $n_lo

    if ($n_hi - $n_lo > $rectangle_area * 100
        && $self->can_use_xy) {
      ### use_xy from the start due to big n_hi: $n_hi
      $self->use_xy($image);
    }
  }

  $image->add_colours (@colours);


  # ### force use_xy...
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
                   unellipse => 1,
                  );
my %figure_method = (square  => 'rectangle',
                     box     => 'rectangle',
                     circle  => 'ellipse',
                     ring    => 'ellipse',
                     diamond => 'diamond',
                     diamunf => 'diamond',
                     plus    => \&App::MathImage::Image::Base::Other::plus,
                     X       => \&App::MathImage::Image::Base::Other::draw_X,
                     L       => \&App::MathImage::Image::Base::Other::draw_L,
                     V       => \&App::MathImage::Image::Base::Other::draw_V,
                     unellipse => \&App::MathImage::Image::Base::Other::unellipse,
                     unellipunf => \&App::MathImage::Image::Base::Other::unellipse,
                     undiamond => \&undiamond,
                     triangle => \&_triangle,
                     hexagon => \&_hexagon,
                    );
sub undiamond {
  my ($image, $x1,$y1, $x2,$y2, $colour, $fill) = @_;
  my $width = $x2 - $x1 + 1;
  my $height = $y2 - $y1 + 1;
  my $halfheight = int($height/2);
  my $xoff = int($width/2);
  for (my $yoff = 0; $yoff <= $halfheight; $yoff++) {
    foreach my $y ($y1 + $yoff, $y2-$yoff) {
      $image->line ($x1,$y,       $x1+$xoff,$y, $colour);
      $image->line ($x2-$xoff,$y, $x2,$y,       $colour);
    }
    $xoff--;
  }
}

sub _triangle {
  my ($image, $x1,$y1, $x2,$y2, $colour, $fill) = @_;
  my $xc = int (($x1+$x2)/2);  # top centre
  $image->line ($xc,$y1, $x1,$y2, $colour);
  $image->line ($xc,$y1, $x2,$y2, $colour);
  $image->line ($x1,$y2, $x2,$y2, $colour);
}
# sub _triangle {
#   my ($image, $x1,$y1, $x2,$y2, $colour, $fill) = @_;
#   triangle ($image,
#             int (($x1+$x2)/2), $y1,   # top vertex
#             $x1,$y2,
#             $x2,$y2,
#             $colour,
#             $fill);
# }

sub _hexagon {
  my ($image, $x1,$y1, $x2,$y2, $colour, $fill) = @_;
  my $yc = int (($y1+$y2)/2);  # side centre
  my $xoffset = int(.25 * ($x2-$x1+1));
  ### $xoffset

  $image->line ($x1,$yc, $x1+$xoffset,$y1, $colour);
  $image->line ($x1,$yc, $x1+$xoffset,$y2, $colour);

  $image->line ($x1+$xoffset,$y1, $x2-$xoffset,$y1, $colour);
  $image->line ($x1+$xoffset,$y2, $x2-$xoffset,$y2, $colour);

  $image->line ($x2-$xoffset,$y1, $x2,$yc, $colour);
  $image->line ($x2-$xoffset,$y2, $x2,$yc, $colour);
}

sub draw_Image_steps {
  my ($self) = @_;
  #### draw_Image_steps()
  my $steps = 0;

  my $path_object = $self->path_object;
  my $step_figures = $self->{'step_figures'};
  if ($pathname_square_grid{$self->{'path'}}) {
    # opportunity to switch to use_xy
    $step_figures ||= 10;
  }
  my $step_time = $self->{'step_time'};
  my $count_figures = 0;
  my ($time_lo, $time_hi);
  my $more = 0;
  ### $step_figures
  ### $step_time
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

  my $image  = $self->{'image'};
  my $width  = $self->{'width'};
  my $height = $self->{'height'};
  my $foreground = $self->{'foreground'};
  my $background = $self->{'background'};
  my $scale = $self->{'scale'};
  ### $scale

  my $covers = $self->covers_quadrants;
  my $affine = $self->affine_object;
  my $values_obj = $self->{'values_obj'};
  my $filter_obj = $self->{'filter_obj'};

  my $figure = $self->figure;
  my $xpscale = $scale;
  my $ypscale = $scale;
  if ($self->{'values'} =~ /^Lines/) {
    $xpscale = $ypscale = floor ($self->{'scale'} * .4);
  } elsif ($path_object->figure eq 'circle' && ! $figure_is_circular{$figure}) {
    $xpscale = $ypscale = floor ($self->{'scale'} * (1/sqrt(2)));
  } elsif ($path_object->MathImage__lattice_type eq 'triangular'
           && $figure_is_circular{$figure}) {
    $xpscale = sqrt(2)*$self->{'scale'};
    $ypscale = sqrt(2)*$self->{'scale'};
  } elsif ($path_object->MathImage__lattice_type eq 'triangular'
           && $figure eq 'triangle') {
    $xpscale = 2*$self->{'scale'};
    $ypscale = $self->{'scale'};
  } elsif ($path_object->MathImage__lattice_type eq 'triangular'
           && $figure eq 'hexagon') {
    $xpscale = 2*$self->{'scale'};
    $ypscale = $self->{'scale'};
    # $xpscale = $ypscale = floor ($self->{'scale'} * sqrt(3));
  }
  $xpscale = max (1, $xpscale);
  $ypscale = max (1, $ypscale);
  if ($xpscale == 1 && $ypscale == 1) {
    $figure = 'point';
  }
  $xpscale--;  # for x,y corner instead of width
  $ypscale--;
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

  my $count_total = $self->{'count_total'};
  my $count_outside = $self->{'count_outside'};
  my $n_hi = $self->{'n_hi'};

  my $figure_at_transformed =
    ($figure eq 'point' || $xpscale < 2
     ? sub { }
     : sub {
       my ($x,$y) = @_;
       $x = floor ($x - int($xpscale/2) + .5);
       $y = floor ($y - int($ypscale/2) + .5);
       if (my @coords = ellipse_clipper ($x,$y, $x+$xpscale,$y+$ypscale,
                                         $width,$height)) {
         $image->$figure_method (@coords, $foreground, $figure_fill);
         $count_figures++;
       }
     });

  if ($self->{'values'} eq 'Lines') {
    my $increment = $self->{'values_parameters'}->{'increment'} ||
      $path_object->arms_count;
    my $n_offset_from = ($self->{'use_xy'} ? -$increment : 0);
    my $n_offset_to = $increment;

    if ($increment == 1
        && defined (my $disc = $path_object->MathImage__n_fraction_discontinuity)) {
      $n_offset_from = -$disc;
      $n_offset_to = $n_offset_from + .9999;
    }
    ### $n_offset_from
    ### $n_offset_to

    my ($x,$y, $n);
    my $frag = sub {
      #### lines frag: "$n  $x,$y"
      my ($x, $y) = $affine->transform ($x, $y);
      $figure_at_transformed->($x,$y);

      $x = floor ($x + 0.5);
      $y = floor ($y + 0.5);

      foreach my $n_offset (($n_offset_from ? $n_offset_from : ()),
                            $n_offset_to) {
        my ($x2, $y2) = $path_object->n_to_xy($n+$n_offset)
          or next;
        ($x2, $y2) = $affine->transform ($x2, $y2);
        ### n offset: ($n+$n_offset)."   $x2, $y2"
        $x2 = floor ($x2 + 0.5);
        $y2 = floor ($y2 + 0.5);

        my $drawn = _image_line_clipped ($image, $x,$y, $x2,$y2,
                                         $width,$height,
                                         $foreground);
        $count_total++;
        $count_outside += !$drawn;
        $count_figures += $drawn;
      }
    };

    if ($self->{'use_xy'}) {
      ### Lines use_xy...
      $x = $self->{'x'};
      $y = $self->{'y'};
      my $x_hi = $self->{'x_hi'};
      #### draw by xy from: "$x,$y"

      for (;;) {
        ### use_xy: "$x,$y"
        &$cont() or last;

        if (++$x > $x_hi) {
          if (++$y > $self->{'y_hi'}) {
            last;
          }
          $x = $self->{'x_lo'};
          #### next row: "$x,$y"
        }

        if (! defined ($n = $path_object->xy_to_n ($x, $y))) {
          next; # no N for this x,y
        }
        &$frag();
      }
      $self->{'x'} = $x;
      $self->{'y'} = $y;

    } else {
      ### Lines by N...
      $n = $self->{'upto_n'};

      for ( ; $n < $n_hi; $n++) {
        &$cont() or last;

        ($x, $y) = $path_object->n_to_xy($n)
          or next;
        &$frag();
      }
      $self->{'upto_n'} = $n;
      $self->{'count_total'} = $count_total;
      $self->{'count_outside'} = $count_outside;
      $self->maybe_use_xy;
    }
    return $more;
  }

  if ($self->{'values'} eq 'LinesTree') {
    # math-image --path=PythagoreanTree --values=LinesTree --scale=100
    my $branches = $self->{'values_parameters'}->{'branches'};

    if ($self->{'use_xy'}) {
      ### LinesTree use_xy...
      my $x    = $self->{'x'};
      my $x_hi = $self->{'x_hi'};
      my $y    = $self->{'y'};
      my $n_start = $path_object->n_start;
      #### draw by xy from: "$x,$y"

      for (;;) {
        ### use_xy: "$x,$y"
        &$cont() or last;

        if (++$x > $x_hi) {
          if (++$y > $self->{'y_hi'}) {
            last;
          }
          $x = $self->{'x_lo'};
          #### next row: "$x,$y"
        }

        my $n;
        if (! defined ($n = $path_object->xy_to_n ($x, $y))) {
          next; # no N for this x,y
        }
        #### path: "$x,$y  $n"
        my ($wx, $wy) = $affine->transform ($x, $y);
        $figure_at_transformed->($wx,$wy);
        $wx = floor ($wx + 0.5);
        $wy = floor ($wy + 0.5);

        foreach my $n_dest (_n_to_tree_children($n, $branches, $n_start)) {
          my ($x_dest, $y_dest) = $path_object->n_to_xy ($n_dest)
            or next;
          ($x_dest, $y_dest) = $affine->transform ($x_dest, $y_dest);
          $x_dest = floor ($x_dest + 0.5);
          $y_dest = floor ($y_dest + 0.5);
          _image_line_clipped ($image, $wx,$wy, $x_dest,$y_dest,
                               $width,$height, $foreground);
        }
      }
      $self->{'x'} = $x;
      $self->{'y'} = $y;

    } else {
      ### LinesTree by N...
      my $n = $self->{'upto_n'};
      my $n_dest = $self->{'upto_n_dest'};
      my $branch_i = $self->{'branch_i'};
      my $x    = $self->{'x'};
      my $y    = $self->{'y'};

      for (;;) {
        &$cont() or last;

        if (++$branch_i >= $branches) {
          if (++$n > $n_hi) {
            $more = 0;
            last;
          }
          $branch_i = 0;
          ($x, $y) = $path_object->n_to_xy($n)
            or return 0; # no more
          ### n raw: "n=$n  $x,$y"
          ($x, $y) = $affine->transform ($x, $y);
          $figure_at_transformed->($x,$y);
          $x = floor ($x + 0.5);
          $y = floor ($y + 0.5);
        }

        my ($x_dest, $y_dest) = $path_object->n_to_xy($n_dest);
        ### $n
        ### $n_dest
        ### dest raw: "$x_dest, $y_dest"
        ($x_dest, $y_dest) = $affine->transform ($x_dest, $y_dest);
        $x_dest = floor ($x_dest + 0.5);
        $y_dest = floor ($y_dest + 0.5);

        my $drawn = _image_line_clipped ($image, $x,$y, $x_dest,$y_dest,
                                         $width,$height, $foreground);
        $count_figures++;
        $count_total++;
        $count_outside += !$drawn;

        $n_dest++;
      }

      $self->{'count_total'} = $count_total;
      $self->{'count_outside'} = $count_outside;
      $self->{'upto_n'} = $n;
      $self->{'upto_n_dest'} = $n_dest;
      $self->{'branch_i'} = $branch_i;
      $self->{'x'} = $x;
      $self->{'y'} = $y;
      $self->maybe_use_xy;
    }
    return $more;
  }

  if ($self->{'values'} eq 'LinesLevel') {
    ### LinesLevel step...

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
      ### $n
      ### xy raw: "$x,$y"

      ($x,$y) = $affine->transform ($x, $y);
      ### xy affine: "$x,$y"
      $figure_at_transformed->($x,$y);
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
  my $offset = ($figure eq 'point' ? 0 : int(($xpscale+1)/2));

  my $background_fill_proc;
  if (! $covers && $figure eq 'point') {
    $background_fill_proc = sub {
      my ($n_to) = @_;
      ### background fill for point...
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
      ### background fill for rectangle...
      foreach my $n ($n_prev+1 .. $n_to) {
        $steps++;
        my ($x, $y) = $path_object->n_to_xy($n) or next;
        ($x, $y) = $affine->transform($x, $y);
        ### back_rectangle: "$n   $x,$y"
        $x = floor ($x - $offset + 0.5);
        $y = floor ($y - $offset + 0.5);
        $count_total++;
        my @rect = rect_clipper ($x, $y, $x+$xpscale, $y+$ypscale,
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
    ### background_fill_proc is noop...
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
          # $values_obj->finish;
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
          ##### background fill...

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
            if (my @coords = ellipse_clipper ($x,$y, $x+$xpscale,$y+$ypscale,
                                              $width,$height)) {
              $count_figures++;
              $image->$figure_method (@coords, $colour, $figure_fill);
            }
          } else { # $figure eq 'square'
            $count_figures++;
            push @{$rectangles_by_colour{$background}},
              rect_clipper ($wx, $wy,
                            $wx+$xpscale, $wy+$ypscale,
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
        if (my @coords = ellipse_clipper ($x,$y, $x+$xpscale,$y+$ypscale,
                                          $width,$height)) {
          $count_figures++;
          $image->$figure_method (@coords, $colour, $figure_fill);
        }
      } else { # $figure eq 'square'
        $count_figures++;
        push @{$rectangles_by_colour{$colour}},
          rect_clipper ($wx, $wy,
                        $wx+$xpscale, $wy+$ypscale,
                        $width,$height);
        if (@{$rectangles_by_colour{$colour}} >= _RECTANGLES_CHUNKS) {
          $flush->();
        }
      }
    }
    $self->{'x'} = $x;
    $self->{'y'} = $y;

  } else {
    #### draw by N...

    for (;;) {
      &$cont() or last;

      my ($i, $value) = $values_obj->next;
      ### $n_prev
      ### $i
      ### $value
      my $n;
      if ($use_colours) {
        $n = $i;
        if (! defined $n || $n > $n_hi) {
          ### n under or past n_hi, stop ...
          last;
        }
      } else {
        $n = $value;
        if (! defined $n) {
          if (++$self->{'n_outside'} > 10) {
            ### n_outside >= 10, stop ...
            last;
          }
          next;
        }
        if (($n <= $n_prev || $n > $n_hi)
            && ++$self->{'n_outside'} > 10) {
          ### n_outside >= 10 on n<prev n>hi, stop ...
          last;
        }
      }
      $n_prev = $n;

      $filter_obj->pred($n)
        or next;
      my ($x, $y) = $path_object->n_to_xy($n) or next;
      ### $n
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
          ### skip, outside width,height...
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
        my @rect = rect_clipper ($x, $y, $x+$xpscale, $y+$ypscale,
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
        if (my @coords = ellipse_clipper ($x,$y, $x+$xpscale,$y+$ypscale,
                                          $width,$height)) {
          $count_figures++;
          $image->$figure_method (@coords, $colour, $figure_fill);
        }
      }
    }

    $self->{'n_prev'} = $n_prev;
    $self->{'count_total'} = $count_total;
    $self->{'count_outside'} = $count_outside;
    $self->maybe_use_xy;
  }

  if (! $more) {
    ### final background fill...
    $background_fill_proc->($n_hi);
  }
  $flush->();
  ### $more
  return $more;
}

sub _n_to_tree_children {
  my ($n, $branches, $n_start) = @_;
  ### _n_to_tree_children() ...
  if ($n < $n_start) { return }
  $n_start ||= 0;
  $n -= ($n_start-1);
  my $h = ($branches-1)*($n-1)+1;
  ### $branches
  ### $n_start
  ### $n
  ### $h
  my $level = int(log($h)/log($branches));
  my $range = $branches ** $level;
  my $base = ($range - 1)/($branches-1) + 1;
  my $rem = $n - $base;
  if ($rem < 0) {
    $rem += $range/$branches;
    $level--;
    $range /= $branches;
  }
  if ($rem >= $range) {
    $rem -= $range;
    $level++;
    $range *= $branches;
  }
  my $child = $base + $range + $rem * $branches + $n_start-1;
  # map{} addition to allow for $child outside iterator range
  return map {$_+$child} 0 .. $branches-1;
}

sub maybe_use_xy {
  my ($self) = @_;

  ### maybe_use_xy() ...
  ### count_total: $self->{'count_total'}
  ### count_outside: $self->{'count_outside'}
  ### square_grid: $pathname_square_grid{$self->{'path'}}

  my ($count_total, $values_obj);
  if (($count_total = $self->{'count_total'}) > 1000
      && $self->{'count_outside'} > .5 * $count_total
      && $self->can_use_xy ) {
    ### use_xy from now on...
    $self->use_xy($self->{'image'});
  }
}

sub can_use_xy {
  my ($self) = @_;
  my $values_object;
  return ($self->path_object->figure eq 'square'
          && (! ($values_object = $self->values_object)  # Lines can use xy
              || $values_object->can($self->{'use_colours'}
                                     ? 'ith' : 'pred')));

  # $pathname_square_grid{$self->{'path'}}
  # $values_obj->can('pred')
  #         && $values_obj->can('ith')) {
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
  while ($self->draw_Image_steps) {
    # more
  }
}


# draw $image->line() but clipped to width x height
sub _image_line_clipped {
  my ($image, $x1,$y1, $x2,$y2, $width,$height, $foreground) = @_;
  ### _image_line_clipped(): "$x1,$y1 $x2,$y2  ${width}x${height}"
  if (($x1,$y1, $x2,$y2) = line_clipper ($x1,$y1, $x2,$y2, $width,$height)) {
    ### clipped draw: "$x1,$y1 $x2,$y2"
    $image->line ($x1,$y1, $x2,$y2, $foreground);
    return 1;
  } else {
    return 0;
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
    local $^W = undef; # no warnings;
    *_gettime = \&Time::HiRes::time;
  }
}

sub _noop {}

1;
__END__
