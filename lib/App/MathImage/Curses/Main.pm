# Copyright 2010 Kevin Ryde

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

package App::MathImage::Curses::Main;
use 5.004;
use strict;
use warnings;
use Carp;
use POSIX ();
use Module::Util;
use Curses::UI;
use Locale::TextDomain 'App-MathImage';

use App::MathImage::Generator;
use App::MathImage::Curses::Drawing;

use vars '$VERSION';
$VERSION = 29;

# uncomment this to run the ### lines
#use Smart::Comments;

# define the menu datastructure.
my $menu_data
  = [ { -label => __('File'),
        -submenu =>
        [ { -label => __('Randomize'),
              -value => sub {
                my ($menu) = @_;
                ### _do_randomize()
                my $self = $menu->{'-parent'};
                $self->getobj('draw')->change_gen
                  (App::MathImage::Generator->random_options);
              },
            },
          { -label => __('Quit'),
            -value => sub {
              ### _do_quit()
              exit 0;
            },
          },
        ],
      },

      { -label => __('Path'),
        -submenu => [ map {
          my $path = $_;
          ({ -label       => $_,
             -value => sub {
               my ($menu) = @_;
               _do_path_menu ($menu, $path);
             },
           })
        } App::MathImage::Generator->path_choices ],
      },

      { -label => __('Values'),
        -submenu => [ map {
          my $values = $_;
          my $values_class = App::MathImage::Generator->values_class ($values);
          ({ -label       => $values_class->name,
             -value => sub {
               my ($menu) = @_;
               _do_values_menu ($menu, $values);
             },
           })
        } App::MathImage::Generator->values_choices ],
      },
    ];

sub _xterm_stderr {
  local $^F = 999;
  pipe (my $rh, my $wh) or die;

  require Fcntl;
  fcntl($wh, Fcntl::F_SETFD(),
        Fcntl::FD_CLOEXEC() | fcntl($wh, Fcntl::F_GETFD(), 0));
  fcntl($rh, Fcntl::F_SETFD(),
        ~Fcntl::FD_CLOEXEC() & fcntl($rh, Fcntl::F_GETFD(), 0));

  system ("xterm -geom -0-0 -e 'cat <&@{[fileno($rh)]}' &");
  open STDERR, '>&', $wh or die;
  close $rh or die;
  close $wh or die;
  {
    require SelectSaver;
    my $saver = SelectSaver->new(*STDERR);
    $| = 1;
  }
  print STDERR "STDERR output:\n";
  return;
}

sub run {
  my ($class, $gen_options) = @_;

  ### xterm: _xterm_stderr()

  my $cui = Curses::UI->new;
  my $self = $cui->add ('math-image', 'Window',
                        # -width  => undef,
                        # -height => undef,
                       );

  # ### $menu_data
  my $menu = $self->add ('menu', 'Curses::UI::Menubar',
                         -menu => $menu_data,
                        );
  ### $menu->getobj('__submenu_path


  #   my $toolbar = $self->add('toolbar', 'Window',
  #                            -y     => 1,
  #                           );
  #
  #   {
  #     $toolbar->add ('conjunctions', 'Checkbox',
  #                    -label => __('Conjunctions'),
  #                    -checked => 1,
  #                    -onchange => sub {
  #                      my ($checkbox) = @_;
  #                      my $self = $checkbox->parent->parent;
  #                      my $draw = $self->getobj('draw');
  #                      $self->getobj('draw')->change_gen
  #                        (aronson_conjunctions => $checkbox->get);
  #                    });
  #   }

  $self->add('draw', 'App::MathImage::Curses::Drawing',
             -bfg  => 'red',
             -y    => 1,
             # -border => 1,
            );

  $menu->focus();
  $cui->mainloop;
}

sub _do_path_menu {
  my ($menu, $path) = @_;
  ### _do_path_menu(): "@_"
  my $self = $menu->{'-parent'};
  $self->getobj('draw')->change_gen (path => $path);
}

sub _do_values_menu {
  my ($menu, $values) = @_;
  ### _do_values_menu(): "@_"
  my $self = $menu->{'-parent'};
  $self->getobj('draw')->change_gen (values => $values);
}

1;
__END__
