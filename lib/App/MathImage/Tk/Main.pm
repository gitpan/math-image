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


package App::MathImage::Tk::Main;
use 5.008;
use strict;
use warnings;
use FindBin;
use List::Util 'max';
use Tk;
use Tk::Balloon;
use Locale::TextDomain 1.19 ('App-MathImage');

use App::MathImage::Generator;
use App::MathImage::Tk::Drawing;

# uncomment this to run the ### lines
#use Devel::Comments;

use base 'Tk::Derived', 'Tk::MainWindow';
Tk::Widget->Construct('AppMathImageTkMain');

our $VERSION = 72;

sub Populate {
  my ($self, $args) = @_;
  $self->SUPER::Populate($args);

  my $gui_options = delete $args->{'-gui_options'};
  my $gen_options = delete $args->{'-gen_options'};
  $gen_options = { %{App::MathImage::Generator->default_options},
                   %{$gen_options||{}} };
  ### Main gen_options: $gen_options


  $self->geometry(int($self->screenwidth * .8).'x'.int($self->screenheight * .8));
  my $balloon = $self->Balloon;

  my $menubar = $self->Component('Frame','menubar',
                                 -relief => 'raised', -bd => 2);
  $menubar->pack(-side => 'top', -fill => 'x');
  {
    my $menu = $menubar->Menubutton(-text => 'File',
                                    -underline => 0,
                                    -tearoff => 0);
    $menu->pack(-side => 'left');

    $menu->cascade (-label => 'Path',
                    -underline => 0,
                    -tearoff => 1,
                    -menuitems => [ map {
                      ['Button', _path_to_mnemonic($_),
                       -command => [ \&_path_menu_action, $self, $_ ]]
                    } App::MathImage::Generator->path_choices ]);

    $menu->cascade (-label => 'Values',
                    -underline => 0,
                    -tearoff => 1,
                    -menuitems => [ map {
                      ['Button', _values_to_mnemonic($_),
                       -command => [ \&_values_menu_action, $self, $_ ]]
                    } App::MathImage::Generator->values_choices ]);

    $menu->command (-label => __('Save As ...'),
                    -underline => 5,
                    -command => [ $self, 'popup_save_as' ]);

    $menu->command (-label => 'Quit',
                    -command => [ $self, 'destroy' ],
                    -underline => 0);
  }

  {
    my $menu = $menubar->Menubutton(-text => "Tools",
                                    -underline => 0);
    $menu->pack(-side => 'left');

    $menu->command (-label => 'Fullscreen',
                    -command => [$self, 'fullscreen_toggle'],
                    -underline => 0);
    # $item->uncheck('fullscreen'); # initially unchecked
  }
  {
    my $menu = $menubar->Menubutton(-text => "Help",
                                    -underline => 0);
    $menu->pack(-side => 'right');
    $menu->command (-label => 'About',
                    -command => [ \&_do_about, $self ],
                    -underline => 0);
    $menu->command (-label => 'Program POD',
                    -underline => 0,
                    -command => sub {
                      require Tk::Pod;
                      $self->Pod(-file => "$FindBin::Bin/$FindBin::Script");
                    });
    $menu->command
      (-label => 'This Path POD',
       -command => sub {
         my ($path, $module);
         if (($path = $self->Subwidget('drawing')->{'gen_options'}->{'path'})
             && ($module = App::MathImage::Generator->path_choice_to_class ($path))) {
           require Tk::Pod;
           $self->Pod(-file => $module);
         }
       });
    $menu->command (-label => __('Diagnostics ...'),
                    -underline => 3,
                    -command => [ $self, 'popup_diagnostics' ]);

  }

  # cf Tk::ToolBar
  my $toolbar = $self->Component('Frame','toolbar');
  $toolbar->pack(-side => 'top', -fill => 'x');

  my $draw = $self->Component ('AppMathImageTkDrawing','drawing',
                               -background => 'black',
                               -foreground => 'white',
                               -activebackground => 'black',
                               -activeforeground => 'white',
                               -disabledforeground => 'white',
                              );
  $draw->bind('<Motion>', [\&_do_motion_notify, Ev('x'), Ev('y')]);
  $draw->{'gen_options'} = $gen_options;
  $draw->pack(-side => 'top',
              -fill => 'both',
              -expand => 1,
              -after => $toolbar);

  {
    my $button = $toolbar->Button
      (-text  => __('Randomize'),
       -command => sub {
         %$gen_options = (%$gen_options,
                          App::MathImage::Generator->random_options);
         ### randomize to: $gen_options
         $draw->queue_reimage;
       });
    $button->pack (-side => 'left');
    $balloon->attach($button, -balloonmsg => __('Choose a random path, values, scale, etc.  Click repeatedly to see interesting things.'));
  }
  {
    my $frame = $toolbar->Frame;
    $frame->pack (-side => 'left');
    $frame->Label(-text => __('Scale'))->pack(-side => 'left');
    $frame->Spinbox (-from => 1,
                     -to => 9999,
                     -width => 2,
                     -text => 3,
                     -command => sub {
                       my ($value, $direction) = @_;
                       $gen_options->{'scale'} = $value;
                       $draw->queue_reimage;
                     })->pack(-side => 'left');
    $balloon->attach($frame, -balloonmsg => __('How many pixels per square.'));
  }
  {
    my @values = map { $_ eq 'default' ? 'figure' : $_ }
      App::MathImage::Generator->figure_choices;
    my $spin = $toolbar->Spinbox
      (-values => \@values,
       -width => max(map{length} @values),
       -command => sub {
         my ($value, $direction) = @_;
         if ($value eq 'figure') { $value = 'default' }
         $gen_options->{'figure'} = $value;
         $draw->queue_reimage;
       });
    $spin->pack(-side => 'left');
    $balloon->attach($spin, -balloonmsg => __('The figure to draw at each position.'));
  }

  $self->Component ('Label','statusbar',
                    -justify => 'left')
    ->pack(-side => 'bottom', -fill => 'x');
}

my %_values_to_mnemonic =
  (primes          => __('_Primes'),
   TwinPrimes      => __('_Twin Primes'),
   Squares         => __('S_quares'),
   Pronic          => __('Pro_nic'),
   triangular      => __('Trian_gular'),
   cubes           => __('_Cubes'),
   Tetrahedral     => __('_Tetrahedral'),
   Perrin          => __('Perr_in'),
   Padovan         => __('Pado_van'),
   Fibonacci       => __('_Fibonacci'),
   FractionDigits  => __('F_raction Digits'),
   Polygonal       => __('Pol_ygonal Numbers'),
   PiBits          => __('_Pi Bits'),
   Ln2Bits         => __x('_Log Natural {logarg} Bits', logarg => 2),
   Ln3Bits         => __x('_Log Natural {logarg} Bits', logarg => 3),
   Ln10Bits        => __x('_Log Natural {logarg} Bits', logarg => 10),
   odd             => __('_Odd Integers'),
   even            => __('_Even Integers'),
   all             => __('_All Integers'),
  );
sub _values_to_mnemonic {
  my ($str) = @_;
  $str = ($_values_to_mnemonic{$str} || nick_to_display($str));
  $str =~ tr/_/~/;
  return $str;
}
sub _values_menu_action {
  my ($self, $itemname) = @_;
  ### _values_menu_action(): $itemname
  my $drawing = $self->Subwidget('drawing');
  $drawing->{'gen_options'}->{'values'} = $itemname;
  $drawing->queue_reimage;
}

my %_path_to_mnemonic =
  (SquareSpiral    => __('_Square Spiral'),
   SacksSpiral     => __('_Sacks Spiral'),
   VogelFloret     => __('_Vogel Floret'),
   DiamondSpiral   => __('_Diamond Spiral'),
   PyramidRows     => __('_Pyramid Rows'),
   PyramidSides    => __('_Pyramid Sides'),
   HexSpiral       => __('_Hex Spiral'),
   HexSpiralSkewed => __('_Hex Spiral Skewed'),
   KnightSpiral    => __('_Knight Spiral'),
   Corner          => __('_Corner'),
   Diagonals       => __('_Diagonals'),
   Rows            => __('_Rows'),
   Columns         => __('_Columns'),
  );
sub _path_to_mnemonic {
  my ($str) = @_;
  return ($_values_to_mnemonic{$str} || nick_to_display($str));
}
sub _path_menu_action {
  my ($self, $itemname) = @_;
  ### _path_menu_action(): $itemname
  my $drawing = $self->Subwidget('drawing');
  $drawing->{'gen_options'}->{'path'} = $itemname;
  $drawing->queue_reimage;
}

sub nick_to_display {
  my ($nick) = @_;
  return join (' ',
               map {ucfirst}
               split(/[-_ ]+
                    |(?<=\D)(?=\d)
                    |(?<=\d)(?=\D)
                    |(?<=[[:lower:]])(?=[[:upper:]])
                     /x,
                     $nick));
}

sub fullscreen_toggle {
  my ($self, $itemname) = @_;
  ### _do_fullscreen_toggle(): "@_"
  $self->FullScreen;
}

sub _do_about {
  my ($self) = @_;
  require App::MathImage::Tk::About;
  $self->AppMathImageTkAbout->Popup;
}

sub _do_motion_notify {
  my ($drawing, $x, $y) = @_;
  ### _do_motion_notify(): "@_"
  my $self = $drawing->parent;

  my $statusbar = $self->Subwidget('statusbar');

  # my ($x, $y, $n) = $drawing->pointer_xy_to_image_xyn ($x, $y);
  my $message;
  if (defined $x) {
    $message = sprintf ("x=%.*f, y=%.*f",
                        (int($x)==$x ? 0 : 2), $x,
                        (int($y)==$y ? 0 : 2), $y);
    # if (defined $n) {
    #   $message .= "   N=$n";
    # }
  }
  $statusbar->configure(-text => $message);
}

sub popup_save_as {
  my ($self) = @_;
  require App::MathImage::Tk::SaveDialog;
  my $dialog = ($self->{'save_dialog'}
                ||= $self->AppMathImageTkSaveDialog
                (-drawing => $self->Subwidget('drawing')));
  $dialog->Popup;
}

sub popup_diagnostics {
  my ($self) = @_;
  require App::MathImage::Tk::Diagnostics;
  $self->AppMathImageTkDiagonostics->Popup;
}

sub command_line {
  my ($class, $mathimage) = @_;
  my $gui_options = $mathimage->{'gui_options'};
  my $gen_options = $mathimage->{'gen_options'};
  my $self = $class->new
    (-gui_options => $gui_options,
     -gen_options => $gen_options,
     # (! defined $gen_options->{'width'}
     #  ? (width  => 600,
     #     height => 400)
     #  : ()),
    );
  if ($gui_options->{'fullscreen'}) {
    $self->Fullscreen;
  }
  MainLoop;
  return 0;
}

1;
__END__
