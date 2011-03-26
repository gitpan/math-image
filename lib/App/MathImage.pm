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

package App::MathImage;
use 5.004;
use strict;
use Carp;
use List::Util qw(min max);

# uncomment this to run the ### lines
#use Smart::Comments;

use vars '$VERSION';
$VERSION = 49;

sub _hopt {
  my ($self, $hashname, $key, $value) = @_;
  ### $hashname
  ### $key
  ### $value
  ### existing: $self->{$hashname}->{$key}
  if (defined $self->{$hashname}->{$key}
      && $self->{$hashname}->{$key} ne $value) {
    die "Already got \"$key\" option \"$self->{$hashname}->{$key}\"\n";
  }
  $self->{$hashname}->{$key} = $value;
}

sub getopt_long_specifications {
  my ($self) = @_;
  return
    ('values=s'  =>
     sub { my ($optname, $value) = @_;
           _hopt($self,'gen_options','values', "$value"); },
     'primes'   => sub {_hopt($self,'gen_options','values', 'Primes'); },
     'twin'     => sub { _hopt($self,'gen_options','values', 'TwinPrimes');
                         _hopt($self,'gen_options','pairs', 'both'); },
     'twin1'    => sub { _hopt($self,'gen_options','values', 'TwinPrimes');
                         _hopt($self,'gen_options','pairs', 'first');  },
     'twin2'    => sub { _hopt($self,'gen_options','values', 'TwinPrimes');
                         _hopt($self,'gen_options','pairs', 'second'); },
     'semi-primes|semiprimes' =>
     sub { _hopt($self,'gen_options','values', 'SemiPrimes'); },
     'semi-primes-odd|semiprimes-odd|semip-odd' =>
     sub { _hopt($self,'gen_options','values', 'SemiPrimesOdd'); },

     'squares'    => sub { _hopt($self,'gen_options','values', 'Squares');  },
     'pronic'     => sub { _hopt($self,'gen_options','values', 'Pronic');  },
     'triangular' => sub { _hopt($self,'gen_options','values', 'Triangular'); },
     'pentagonal' => sub { _hopt($self,'gen_options','values', 'Pentagonal'); },
     'cubes'      => sub { _hopt($self,'gen_options','values', 'Cubes');  },
     'tetrahedral'=> sub { _hopt($self,'gen_options','values', 'Tetrahedral');},
     'perrin'     => sub { _hopt($self,'gen_options','values', 'Perrin');  },
     'padovan'    => sub { _hopt($self,'gen_options','values', 'Padovan');  },
     'fibonacci'  => sub { _hopt($self,'gen_options','values', 'Fibonacci');  },
     'fraction-bits=s' =>
     sub { my ($optname, $value) = @_;
           _hopt($self,'gen_options','values',   'FractionDigits');
           _hopt($self,'gen_options','fraction', $value);
         },
     'expression=s' =>
     sub { my ($optname, $value) = @_;
           ### $value
           _hopt($self,'gen_options','values', 'Expression');
           _hopt($self,'gen_options','expression', $value);
         },
     'polygonal=i' =>
     sub { my ($optname, $value) = @_;
           _hopt($self,'gen_options','values', 'Polygonal');
           _hopt($self,'gen_options','polygonal', "$value"); },
     'pi'      =>sub { _hopt($self,'gen_options','values', 'PiBits');  },
     'ln2'     => sub{_hopt($self,'gen_options','values', 'Ln2Bits');  },
     'odd'     => sub{_hopt($self,'gen_options','values', 'Odd');  },
     'even'    => sub{_hopt($self,'gen_options','values', 'Even');  },
     'all'     => sub{_hopt($self,'gen_options','values', 'All');  },
     'lines'   => sub{_hopt($self,'gen_options','values', 'Lines');  },
     'aronson' => sub{_hopt($self,'gen_options','values', 'Aronson');  },

     # this one undocumented yet ...
     'prime-quadratic-euler' => sub{
       _hopt($self,'gen_options','values', 'PrimeQuadraticEuler');
       _hopt($self,'gen_options','filter', 'Primes');
     },

     'path=s'  => sub{ my ($optname, $value) = @_;
                       _hopt($self,'gen_options','path', "$value");  },
     do {
       my %path_options = (ulam             => 'SquareSpiral',
                           'sacks'          => 'SacksSpiral',
                           'vogel'          => 'VogelFloret',
                           'theodorus'      => 'TheodorusSpiral',
                           'diamond'               => 'DiamondSpiral',
                           'pyramid|pyramid-sides' => 'PyramidSides',
                           'pyramid-rows'          => 'PyramidRows',
                           'corner'                => 'Corner',
                           'diagonals'             => 'Diagonals',
                           'rows'                  => 'Rows',
                           'columns'               => 'Columns',

                           # never documented, don't much want individual
                           # options
                           # hex                     => 'HexSpiral',
                           # 'hex-skewed'            => 'HexSpiralSkewed',
                           # 'knight-spiral'         => 'KnightSpiral',
                           # 'square-spiral' => 'SquareSpiral',
                          );
       (map { my $opt = $_;
              ($opt => sub { _hopt ($self,'gen_options','path',
                                    $path_options{$opt}) })
            } keys %path_options)
     },

     'scale=i'  => sub{my ($optname, $value) = @_;
                       _hopt($self,'gen_options','scale', "$value");  },

     'output=s'   => sub{ my ($optname, $value) = @_;
                          _hopt($self, 'gui_options', 'output', "$value");  },
     'root'     => sub{_hopt($self, 'gui_options', 'output', 'root');  },
     'xpm'      => sub{_hopt($self, 'gui_options', 'output', 'XPM');  },
     'png'      => sub{_hopt($self, 'gui_options', 'output', 'PNG');  },

     'module=s' => sub{ my ($optname, $value) = @_;
                        _hopt($self, 'gui_options', 'module', "$value");  },
     'prima'    => sub{_hopt($self, 'gui_options', 'module', 'Prima');  },
     'curses'   => sub{_hopt($self, 'gui_options', 'module', 'Curses');  },
     'text'     => sub{_hopt($self, 'gui_options', 'output', 'text');
                       _hopt($self, 'gui_options', 'module', 'Text'); },

     # use --output=numbers
     # use --output=list
     # 'text-numbers' => sub{
     #   _hopt($self, 'gui_options', 'output', 'numbers');
     #   _hopt($self, 'gui_options', 'module', 'Text');
     # },
     # 'text-list' => sub{
     #   _hopt($self, 'gui_options', 'output', 'list');
     #   _hopt($self, 'gui_options', 'module', 'Text');
     # },

     'display=s' =>
     sub { my ($optname, $value) = @_;
           _hopt($self, 'other_options', 'display', $value);  },
     'flash'      => sub{ _hopt ($self, 'gui_options', 'flash', 1);  },
     'fullscreen' => sub{ _hopt ($self, 'gui_options', 'fullscreen', 1);  },

     'help|?'  => sub{_hopt($self, 'gui_options', 'output', 'help'); },
     'version' => sub{_hopt($self, 'gui_options', 'output', 'version'); },

     'random'  => sub {
       require App::MathImage::Generator;
       my @random = App::MathImage::Generator->random_options;
       while (my ($key, $value) = splice @random,0,2) {
         if ($key eq 'path' || $key eq 'values') {
           _hopt($self,'gen_options', $key, $value);
         } else {
           $self->{'gen_defaults'}->{$key} = $value;
         }
       }
     },

     'size=s' => sub {
       my ($optname, $value) = @_;
       my ($width, $height) = split /x/, $value;
       _hopt($self,'gen_options','width', $width);
       _hopt($self,'gen_options','height', $height || $width);
     },
     'size-scale=s' => sub {
       my ($optname, $value) = @_;
       my ($width, $height) = split /x/, $value;
       _hopt($self,'gen_options','width', $width);
       _hopt($self,'gen_options','height', $height || $width);
       $self->{'gen_options'}->{'width_in_scale'} = 1;
       $self->{'gen_options'}->{'height_in_scale'} = 1;
     },
     'foreground=s'  => sub {
       my ($optname, $value) = @_;
       _hopt ($self, 'gen_options','foreground',$value);
     },
     'background=s'  => sub {
       my ($optname, $value) = @_;
       _hopt ($self, 'gen_options','background',$value);
     },
     'verbose:1'      => \$self->{'verbose'},
    );
}

sub output_method_version {
  my ($self) = @_;
  print "math-image version ",$self->VERSION,"\n";
  return 0;
}

sub output_method_help {
  # my ($self) = @_;
  print <<'HERE';
math-image [--options]
Path:
  --ulam         Ulam's square spiral of primes
  --sacks        Sacks spiral
  --vogel        Vogel floret
  --pyramid      rows 1  2,3,4  5,6,7,8,9  etc
  --diagonal     diagonal rows 1  2,3  4,5,6   7,8,9,10  etc
  --corner
  --rows         across in rows
  --columns      downwards in columns
  --diamond
  --path=WHAT
Values:
  --squares      squares 1,4,9,16,25,...
  --pronic       pronic numbers x*(x+1)  2,6,12,20,30,...
  --triangular   triangle numbers x*(x+1)/2  1,3,6,10,15,21,...
  --polygonal=K  the K-sided polygon numbers
  --cubes        cubes 1,8,27,64,125,...
  --tetrahedral  numbers 1,4,10,20,35,56,...
  --perrin       sequence 3,0,2,3,2,5,5,7,10,12,17,...
  --padovan      sequence 1,1,2,2,3,4,5,7,9,12,...
  --primes       primes 2,3,5,7,11,13,...
  --twin         twin primes 3,5,7, 11,13, 17,19,...
  --twin1        first of each twin prime 3,5,11,17,...
  --twin2        second of each twin prime 5,7,13,19,...
  --fibonacci    fibonacci numbers 1,1,2,3,5,8,13,21,...
  --fraction=NUM/DEN   base-2 of given fraction
  --ln2          bits of natural log(2)
  --all          all integers 1,2,3,...
  --odd          odd numbers 1,3,5,7,9,...
  --even         even numbers 2,4,6,8,10,...
  --lines        draw lines showing the path, instead of values
  --values=WHAT
Other:
  --help         print this help
  --version      print program version number
HERE
  return 0;
}

sub new {
  my $class = shift;
  require App::MathImage::Generator;
  return bless { gen_options  => {},
                 gen_defaults => { values     =>
                                   App::MathImage::Generator->default_options->{'values'},
                                   path       =>
                                   App::MathImage::Generator->default_options->{'path'},
                                   foreground => 'white',
                                   background => 'black',
                                 },
                 gui_options  => {},
                 other_options => {},
                 verbose => 0,
                 @_ }, $class;
}

sub command_line {
  my ($self) = @_;
  ref $self or $self = $self->new;

  require Getopt::Long;
  Getopt::Long::Configure ('no_ignore_case');
  Getopt::Long::Configure ('pass_through');
  Getopt::Long::GetOptions ($self->getopt_long_specifications) or return 1;
  ### @ARGV

  my $gui_options = $self->{'gui_options'};
  my $gen_options = $self->{'gen_options'};
  my $gen_defaults = $self->{'gen_defaults'};
  my $other_options = $self->{'other_options'};

  # defaults
  %$gui_options = (output => 'gui',
                   %$gui_options);
  ### gui_options: $gui_options
  my $output = $gui_options->{'output'};
  my $module = $gui_options->{'module'};

  # cap random scale at a requested width/height
  if ($gen_defaults->{'scale'} && defined $gen_options->{'width'}) {
    if ($gen_defaults->{'scale'} > $gen_options->{'width'}) {
      $gen_defaults->{'scale'} = $gen_options->{'width'};
    }
    if ($gen_defaults->{'scale'} > $gen_options->{'height'}) {
      $gen_defaults->{'scale'} = $gen_options->{'height'};
    }
  }

  ### command line: $gen_options
  %$gen_options = (%$gen_defaults,
                   %$gen_options);
  ### gen_options: $gen_options
  if (! defined $gen_options->{'scale'}) {
    $gen_options->{'scale'}
      = ($output eq 'text'
         ? ($gen_options->{'values'} eq 'Lines' ? 2 : 1)
         : ($gen_options->{'values'} eq 'Lines' ? 5 : 3));
  }
  if (defined $gen_options->{'width'} && delete $gen_options->{'width_in_scale'}) {
    $gen_options->{'width'} *= $gen_options->{'scale'};
  }
  if ($gen_options->{'height'} && delete $gen_options->{'height_in_scale'}) {
    $gen_options->{'height'} *= $gen_options->{'scale'};
  }
  ### gen_options now: $gen_options

  if (! defined $module) {
    if ($output eq 'gui') {
      if (eval { require Image::Base::Prima::Image }) {
        $module = 'Prima';
      }
    }
  }

  if (@ARGV) {
    die "Unrecognised option(s): ",join(' ',@ARGV);
  }

  if ($self->{'verbose'}) {
    print STDERR $self->make_generator->description,"\n";
  }
  my $output_method = "output_method_\L$output";
  my $coderef = $self->can($output_method)
    || die "Unrecognised output option: $output";
  return $self->$coderef;
}

sub try_gtk {
  my ($self) = @_;
  if ($self->{'gtk_tried'}) {
    return 0;
  }
  if (defined (my $display = $self->{'other_options'}->{'display'})) {
    unshift @ARGV, '--display', $display;
  }
  ### Gtk2 init
  ### @ARGV
  $self->{'gtk_tried'} = 1;
  return (eval { require Gtk2 } && Gtk2->init_check && 1);
}

sub output_method_gui {
  my ($self) = @_;

  my $gui_options = $self->{'gui_options'};
  my $module = $gui_options->{'module'};
  if (defined $module) {
    $module = ucfirst ($module);
  } else {
    $module = 'Gtk2';
  }
  my $class = "App::MathImage::${module}::Main";
  if (! Module::Util::find_installed ($class)) {
    die "No such GUI module: $module";
  }
  require Module::Load;
  Module::Load::load ($class);
  return $class->command_line ($self);
}

sub output_method_root {
  my ($self) = @_;
  ### output_method_root()
  my $gui_options = $self->{'gui_options'};

  if (! defined $gui_options->{'module'}) {
    my $x11_error;
    if (eval { $self->x11_protocol_object }) {
      $gui_options->{'module'} = 'X11';
    } else {
      $x11_error = $@;
      if ($self->try_gtk) {
        $gui_options->{'module'} = 'Gtk2';
      } else {
        die "Cannot use X11::Protocol nor Gtk2 for root:\n",$x11_error;
      }
    }
  }

  my $module = ucfirst ($gui_options->{'module'});
  my $method = "output_method_root_$module";
  if ($self->can($method)) {
    $self->$method;
  } else {
    die "Unrecognised root window output module: $module";
  }
}

sub output_method_root_X11 {
  my ($self) = @_;

  my $X = $self->x11_protocol_object;
  my $gen_options = $self->{'gen_options'};
  $gen_options->{'width'}  = $X->{'width_in_pixels'};
  $gen_options->{'height'} = $X->{'height_in_pixels'};

  my $rootwin = $X->{'root'};
  my $colormap = $X->{'default_colormap'};
  ### $rootwin

  require App::MathImage::X11::Generator;
  my $x11gen = App::MathImage::X11::Generator->new
    (%$gen_options,
     X => $X,
     window => $rootwin,
     flash  => $self->{'gui_options'}->{'flash'});
  $x11gen->draw;
  return 0;
}

*output_method_root_Gtk = \&output_method_root_Gtk2;
sub output_method_root_Gtk2 {
  my ($self) = @_;
  $self->try_gtk || die "Cannot initialize Gtk";

  my $rootwin = Gtk2::Gdk->get_default_root_window;
  ### $rootwin

  # force size for root window
  my ($width, $height) = $rootwin->get_size;
  my $gen_options = $self->{'gen_options'};
  $gen_options->{'width'} = $width;
  $gen_options->{'height'} = $height;

  my $pixmap;
  {
    require Image::Base::Gtk2::Gdk::Window;
    my $image_rootwin = Image::Base::Gtk2::Gdk::Window->new
      (-window => $rootwin);

    require Image::Base::Gtk2::Gdk::Pixmap;
    my $image_pixmap = Image::Base::Gtk2::Gdk::Pixmap->new
      (-for_drawable => $rootwin,
       -width        => $width,
       -height       => $height);
    $pixmap = $image_pixmap->get('-pixmap');
    ### $pixmap

    require Image::Base::Multiplex;
    my $image = Image::Base::Multiplex->new
      (-images => [ $image_pixmap, $image_rootwin ]);

    my $gen = $self->make_generator;
    $gen->draw_Image ($image);
  }

  $rootwin->set_back_pixmap ($pixmap);
  $rootwin->clear;

  if ($self->{'gui_options'}->{'flash'}) {
    require App::MathImage::Gtk2::Ex::Splash;
    App::MathImage::Gtk2::Ex::Splash->run (pixmap => $pixmap,
                                           time => .75);
  }

  $rootwin->get_display->flush;
  return 0;
}

my %image_modules = (Prima => 'Image::Base::Prima::Image',
                     Gtk2  => 'Image::Base::Gtk2::Gdk::Pixbuf',
                     Xpm   => 'Image::Xpm',
                    );
sub output_method_png {
  my ($self) = @_;
  binmode (\*STDOUT) or die;
  foreach my $module (defined $self->{'gui_options'}->{'module'}
                      ? $self->{'gui_options'}->{'module'}
                      : ('GD',
                         'PNGwriter',
                         'Imager',
                         'Gtk2::Gdk::Pixbuf',
                         'Prima',
                        )) {
    if ($self->try_module($module)) {
      $self->output_image ($module, -file_format => 'PNG');
      return 0;
    }
  }
  die "Output module(s) not available";
}
sub output_method_xpm {
  my ($self) = @_;
  # Imager 0.80 can't write xpm
  foreach my $module (defined $self->{'gui_options'}->{'module'}
                      ? $self->{'gui_options'}->{'module'}
                      : ('Xpm',
                         'Prima')) {
    if ($self->try_module($module)) {
      $self->output_image ($module, -file_format => 'XPM');
      return 0;
    }
  }
  die "Output module(s) not available";
}

sub module_image_class {
  my ($self, $module) = @_;
  foreach my $bclass ("Image::Base::$module",
                      $image_modules{$module},
                      ($module =~ /::/ ? ($module) : ())) {
    foreach my $class ($bclass,
                       "App::MathImage::$bclass") {
      if (Module::Util::find_installed ($class)) {
        return $class;
      }
    }
  }
  return undef;
}

sub try_module {
  my ($self, $module) = @_;
  my $image_class = $self->module_image_class($module) || return 0;
  require Module::Load;
  return eval { Module::Load::load ($image_class); 1 };
}

sub output_image {
  my ($self, $module, @image_options) = @_;
  my $image_class = $self->module_image_class($module)
    || die "No such image module: ",$module;
  ### output_image(): $image_class
  require Module::Load;
  Module::Load::load ($image_class);

  my $gen_options = $self->{'gen_options'};
  if (! defined $gen_options->{'width'}) {
    $gen_options->{'width'} = 200;
    $gen_options->{'height'} = 200;
  }

  my $image = $image_class->new
    (-width  => $gen_options->{'width'},
     -height => $gen_options->{'height'},
     @image_options);
  if ($image->isa('Image::Base::Prima::Drawable')) {
    $image->get('-drawable')->begin_paint;
  }
  {
    my $gen = $self->make_generator;
    $gen->draw_Image ($image);
  }
  if ($image->isa('Image::Base::Prima::Drawable')) {
    $image->get('-drawable')->end_paint;
  }
  require App::MathImage::Image::Base::Other;
  App::MathImage::Image::Base::Other::save_fh ($image, \*STDOUT);
  return 0;
}

sub x11_protocol_object {
  my ($self) = @_;
  return ($self->{'X'} ||= do {
    my $display = (defined $self->{'other_options'}->{'display'}
                   ? $self->{'other_options'}->{'display'}
                   : defined $ENV{'DISPLAY'} ? $ENV{'DISPLAY'}
                   : die "No --display or \$DISPLAY given\n");
    require X11::Protocol;
    X11::Protocol->new ($display)
    });
}

sub output_method_text {
  my ($self) = @_;
  $self->term_size;
  #   $gen_options->{'foreground'} = '*';
  #   $gen_options->{'background'} = ' ';
  #   @image_options = (-cindex => { $gen_options->{'foreground'} => '*',
  #                                  $gen_options->{'background'} => ' ' });
  $self->output_image ('Text');
}
sub output_method_list {
  my ($self) = @_;
  my $gen = $self->make_generator;
  my $path = $gen->path_object;
  my $values_class = $gen->values_class ($gen->{'values'});
  my $values_obj = $values_class->new (%$gen, lo => 1, hi => 1000);

  my $count = 0;
  while (my ($n) = $values_obj->next) {
    next if $n < 1;
    last if $count++ > 100;
    my ($x, $y) = $path->n_to_xy ($n)
      or next;
    printf "%4d  x=%g  y=%g\n", $n, $x, $y;
  }
  return 0;
}
sub output_method_numbers {
  my ($self) = @_;
  $self->term_size;
  my $gen = $self->make_generator;

  my $path = $gen->path_object;
  my $width = $gen->{'width'};
  my $height = $gen->{'height'};
  my $pwidth = int($width/5);
  my $pwidth_half = int($pwidth/2);
  my $height_half = int($height/2);

  my $rect_x1 = 0;
  my $rect_x2 = $pwidth-1;
  my $rect_y1 = 0;
  my $rect_y2 = $height-1;
  if ($gen->x_negative) {
    $rect_x1 = -$pwidth_half;
    $rect_x2 = $pwidth_half;
  }
  if ($gen->y_negative) {
    $rect_y1 = -$height_half;
    $rect_y2 = $height_half;
  }
  my ($n_lo, $n_hi) = $path->rect_to_n_range
    ($rect_x1, $rect_y1, $rect_x2, $rect_y2);

  my $values_class = $gen->values_class ($gen->{'values'});
  my $values_obj = $values_class->new (%$gen, lo => $n_lo, hi => $n_hi);

  my %array;
  my $x_min = 0;
  my $y_min = 0;
  my $x_max = 0;
  my $y_max = 0;
  while (my ($n) = $values_obj->next) {
    last if ! defined $n || $n > $n_hi;
    next if $n < $n_lo;
    my ($x, $y) = $path->n_to_xy ($n)
      or next;
    ($array{$x}->{$y} .= "/$n") =~ s{^/}{};
    $x_min = min ($x_min, $x);
    $x_max = max ($x_max, $x);
    $y_min = min ($y_min, $y);
    $y_max = max ($y_max, $y);
  }
  if ($x_min < 0) {
    $x_min = -$pwidth_half;
    $x_max = $pwidth_half;
  } else {
    $x_max = min ($x_max, $pwidth);
  }
  if ($y_min < 0) {
    $y_min = -$height_half;
    $y_max = $height_half;
  } else {
    $y_max = min ($y_max, $height);
  }
  my $cell_width = 0;
  foreach my $y (reverse $y_min .. $y_max) {
    foreach my $x ($x_min .. $x_max) {
      my $elem = $array{$x}->{$y} || next;
      $cell_width = max ($cell_width, length($elem) + 1) ;
    }
  }
  foreach my $y (reverse $y_min .. $y_max) {
    foreach my $x ($x_min .. $x_max) {
      my $elem = $array{$x}->{$y};
      if (! defined $elem) { $elem = ''; }
      printf "%*s", $cell_width, $elem;
    }
    print "\n";
  }
  return 0;
}

# establish default width and height from Term::Size
sub term_size {
  my ($self) = @_;
  my $gen_options = $self->{'gen_options'};
  if (! defined $gen_options->{'width'}) {
    require Term::Size;
    my ($width, $height) = Term::Size::chars();
    ### term size
    ### $width
    ### $height

    $gen_options->{'width'} = (defined $width && $width >= 2
                               ? $width - 1 : 79);
    $gen_options->{'height'} = (defined $height && $height >= 2
                                ? $height -1 : 20);
  }
}

# return App::MathImage::Generator object
sub make_generator {
  my ($self) = @_;
  require App::MathImage::Generator;
  return App::MathImage::Generator->new (%{$self->{'gen_options'}});
}

1;
__END__

=for stopwords Ryde MathImage

=head1 NAME

App::MathImage -- math-image application module

=head1 SYNOPSIS

 use App::MathImage;
 my $mi = App::MathImage->new;
 exit $mi->command_line;

=head1 DESCRIPTION

This is the guts of the C<math-image> program, see L<math-image> for
user-level operation.

=head1 FUNCTIONS

=over 4

=item C<< $mi = App::MathImage->new (key=>value,...) >>

Create and return a new MathImage object.

=item C<< $exitcode = App::MathImage->command_line () >>

=item C<< $exitcode = $mi->command_line () >>

Run the C<math-image> program command line.  Arguments are taken from
C<@ARGV> and the return value is an exit code suitable for C<exit>.

=back

=head1 SEE ALSO

L<math-image>

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
