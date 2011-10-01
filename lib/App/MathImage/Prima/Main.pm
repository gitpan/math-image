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


package App::MathImage::Prima::Main;
use 5.004;
use strict;
use warnings;
use FindBin;
use List::Util 'max';
use Locale::TextDomain 1.19 ('App-MathImage');

use Prima 'Application';
use Prima::Buttons;
use Prima::ComboBox;
use Prima::Label;
use Prima::Sliders; # SpinEdit
use App::MathImage::Prima::Drawing;
use App::MathImage::Generator;

# uncomment this to run the ### lines
#use Devel::Comments;

use vars '$VERSION', '@ISA';
$VERSION = 73;
@ISA = ('Prima::MainWindow');

sub new {
  my ($class, %args) = @_;

  my $gui_options = delete $args{'gui_options'};
  my $gen_options = delete $args{'gen_options'};
  $gen_options = { %{App::MathImage::Generator->default_options},
                   %{$gen_options||{}} };
  ### Main gen_options: $gen_options

  my $self = $class->SUPER::new
    (
     # text => 'Hello',
     menuItems =>
     [ [ "~File" => [
                     [ __('~Print') => sub { $_[0]->print_image } ],
                     [ __('E~xit')  => sub { $_[0]->destroy } ],
                    ] ],
       [ ef => "~Path" => [ _menu_for_path() ]],
       [ ef => "~Values" => [ _menu_for_values() ]],

       [ ef => "~Tools" => [ [ '*fullscreen', __('~Fullscreen'),
                               sub { $_[0]->fullscreen_toggle } ],
                           ]],

       # [],  # separator to put Help at the right
       [ "~Help" => [ [ __('~About'), sub { $_[0]->about_dialog } ],

                      [ __('~Program POD'),
                        sub {
                          my ($self) = @_;
                          ### POD: "@_"
                          $::application->open_help ("$FindBin::Bin/$FindBin::Script");
                          # $::application->open_help ('/tmp/foo.pod');
                        }],

                      [ __('~This Path POD'),
                        sub {
                          my ($self) = @_;
                          ### POD: "@_"
                          my $path = $self->{'draw'}->gen_options->{'path'};
                          if (my $module = App::MathImage::Generator->path_choice_to_class ($path)) {
                            $::application->open_help ($module);
                          }
                        }],
                    ] ],
     ],
     # onPaint  => \&_paint,
     %args);

  my $menu = $self->menu;
  $menu->uncheck('fullscreen'); # initially unchecked

  my $toolbar = $self->{'toolbar'}
    = $self->insert ('Widget',
                     pack => { in => $self,
                               side => 'top',
                               fill => 'x',
                               expand => 0,
                               anchor => 'n',
                             },
                    );

  $toolbar->insert ('Button',
                    text => __('Randomize'),
                    pack => { side => 'left' },
                    hint  => __('Choose a random path, values, scale, etc.
Click repeatedly to see interesting things.'),
                    onClick  => sub {
                      my ($button) = @_;
                      $self->{'draw'}->gen_options (App::MathImage::Generator->random_options);
                      _update($self);
                    },
                   );

  my $combobox_height = do {
    my $dummy = Prima::ComboBox->create;
    my $height = $dummy->editHeight;
    $dummy->destroy;
    $height
  };

  my $path_combo = $self->{'path_combo'}
    = $toolbar->insert ('ComboBox',
                        pack   => { side => 'left',
                                    fill => 'none',
                                    expand => 0},
                        hint  => __('The path for where to place values in the plane.'),
                        style => cs::DropDown,
                        # override dodgy height when style set
                        height => $combobox_height,
                        items => [ map { $_ } App::MathImage::Generator->path_choices ],
                        onChange  => sub {
                          my ($combo) = @_;
                          ### Main path_combo onChange
                          my $path = $combo->text;
                          $self->{'draw'}->gen_options (path => $path);
                          _update ($self);
                        },
                       );

  $self->{'values_combo'}
    = $toolbar->insert ('ComboBox',
                        pack  => { side => 'left',
                                   fill => 'none',
                                   expand => 0 },
                        style  => cs::DropDown,
                        # override dodgy height when style set
                        height => $combobox_height,
                        hint   => __('The values to display.'),
                        items => [ map { $_ } App::MathImage::Generator->values_choices ],
                        onChange  => sub {
                          my ($combo) = @_;
                          ### Main values combo onChange
                          my $values = $combo->text;
                          $self->{'draw'}->gen_options (values => $values);
                          _update ($self);
                        },
                       );

  # {
  #   my $max = 0;
  #   foreach (0 .. $self->{'values_combo'}->{list}->count() - 1) {
  #     ### wid: $self->{'values_combo'}->{list}->get_item_width($_)
  #     $max = max ($max, $self->{'values_combo'}->{list}->get_item_width($_));
  #   }
  #   ### $max
  #   $self->{'values_combo'}->width($max+10);
  # }

  {
    $toolbar->insert ('Label',
                      text => __('Scale'),
                      pack => { side => 'left' },);
    $self->{'scale_spin'}
      = $toolbar->insert ('SpinEdit',
                          pack => { side => 'left' },
                          min => 1,
                          step => 1,
                          pageStep => 10,
                          onChange  => sub {
                            my ($spin) = @_;
                            ### Main scale onChange
                            my $scale = $spin->value;
                            $self->{'draw'}->gen_options (scale => $scale);
                          },
                         );
  }

  $self->{'draw'} = $self->insert ('App::MathImage::Prima::Drawing',
                                   gen_options => $gen_options,
                                   width   => -1, # (defined $gen_options->{'width'} ? $gen_options->{'width'} : -1),
                                   height  => -1, # (defined $gen_options->{'height'} ? $gen_options->{'height'} : -1),
                                   pack => { expand => 1,
                                             fill => 'both' });

  #   my $toolbar = Prima::Widget->create (
  #                                        # growMode => gm::GrowHiX(),
  #                                        # left => 0,
  #                                        # right => -1,
  #                                        # top => 0,
  #                                        # origin => [0,0],
  #                                        owner => $self,
  #                                       );
  #

  _update ($self);
  return $self;
}

sub _update {
  my ($self) = @_;
  my $gen_options = $self->{'draw'}->gen_options;

  my $menu = $self->menu;
  foreach my $path (App::MathImage::Generator->path_choices) {
    $menu->uncheck("path-$path");
  }
  $menu->check("path-$gen_options->{'path'}");

  foreach my $values (App::MathImage::Generator->values_choices) {
    $menu->uncheck("values-$values");
  }
  $menu->check("values-$gen_options->{'values'}");

  my $path = $gen_options->{'path'};
  if ($self->{'path_combo'}->text ne $path) {
    $self->{'path_combo'}->text ($path);
  }

  if ($path eq 'SquareSpiral') {
    $self->{'path_wider_spin'}
      ||= $self->{'toolbar'}->insert ('SpinEdit',
                                      pack => { side => 'left',
                                                after => $self->{'path_combo'},
                                              },
                                      min => 0,
                                      step => 1,
                                      pageStep => 1,
                                      hint => __('Wider path.'),
                                      onChange  => sub {
                                        my ($spin) = @_;
                                        ### Main wider onChange
                                        my $wider = $spin->value;
                                        $self->{'draw'}->path_parameters (wider => $wider);
                                      },
                                     );
    $self->{'path_wider_spin'}->value ($self->{'draw'}->path_parameters->{'wider'});
  } else {
    if (my $spin = delete $self->{'path_wider_spin'}) {
      $spin->destroy;
    }
  }

  my $values = $gen_options->{'values'};
  if ($self->{'values_combo'}->text ne $values) {
    $self->{'values_combo'}->text ($values);
  }

  $self->{'scale_spin'}->value ($gen_options->{'scale'});
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
sub _menu_for_values {
  my ($self) = @_;

  return map {
    my $values = $_;
    [ "*values-$_",
      _values_to_mnemonic($_),
      \&_values_menu_action,
    ]
  } App::MathImage::Generator->values_choices;
}
sub _values_menu_action {
  my ($self, $itemname) = @_;
  ### Values menu item name: $itemname
  $itemname =~ s/^values-//;
  $self->{'draw'}->gen_options (values => $itemname);
  _update($self);
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
sub _menu_for_path {
  my ($self) = @_;

  return map {
    my $path = $_;
    [ "*path-$_", _path_to_mnemonic($_), \&_path_menu_action,
    ]
  } App::MathImage::Generator->path_choices;
}
sub _path_menu_action {
  my ($self, $itemname) = @_;
  ### _path_menu_action(): "@_"
  $itemname =~ s/^path-//;
  $self->{'draw'}->gen_options (path => $itemname);
  _update($self);
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
  ### fullscreen_toggle(): "@_"
  $self->windowState ($self->menu->toggle($itemname)
                      ? ws::Maximized()
                      : ws::Normal());
  ### windowState now: $self->windowState
}

sub about_dialog {
  my ($self) = @_;
  require App::MathImage::Prima::About;
  App::MathImage::Prima::About->popup;
}

# sub INIT_INSTANCE {
#   my ($self) = @_;
# 
#   my $draw = $self->{'draw'} = App::MathImage::Prima::Drawing->new;
#   $draw->show;
# 
#       { name     => 'SaveAs',
#         stock_id => 'gtk-save-as',
#         callback => \&_do_action_save_as,
#       },
#       { name     => 'SetRoot',
#         label    => 'Set _Root Window',
#         callback => \&_do_action_setroot,
#       },
#       { name     => 'Randomize',
#         label    => __('Randomize'),
#         callback => \&_do_action_randomize,
#       },
#      ],
#      $self);
# 
#   {
#     my $n = 0;
#     my $group;
#     my %hash;
#     foreach my $values (App::MathImage::Generator->values_choices) {
#       my $action = Prima::RadioAction->new (name  => "Values-$values",
#                                            label => _values_to_mnemonic($values),
#                                            value => $n);
#       $action->set_group ($group);
#       $group ||= $action;
#       $actiongroup->add_action ($action);
#       $hash{$values} = $n;
#       $hash{$n++} = $values;
#     }
#   {
#     my $n = 0;
#     my $group;
#     my %hash;
#     foreach my $path (App::MathImage::Generator->path_choices) {
#       my $action = Prima::RadioAction->new (name  => "Path-$path",
#                                            label => _values_to_mnemonic($path),
#                                            value => $n);
#       $action->set_group ($group);
#       $group ||= $action;
#       $actiongroup->add_action ($action);
#       $hash{$path} = $n;
#       $hash{$n++} = $path;
#     }
# 
#       <menuitem action='SaveAs'/>
#       <menuitem action='SetRoot'/>
#   </menubar>
# </ui>
# HERE
#   $ui->add_ui_from_string ($ui_str);
# 
#   $draw->add_events ('pointer-motion-mask');
#   $draw->signal_connect (motion_notify_event => \&_do_motion_notify);
#   $table->attach ($draw, 0,1, 0,1, ['expand','fill'],['expand','fill'],0,0);
# 
#   my $statusbar = $self->{'statusbar'} = Prima::Statusbar->new;
#   $vbox->pack_start ($statusbar, 0,0,0);
# 
#   {
#     #       my $action = $actiongroup->get_action ('Toolbar');
#     #       Glib::Ex::ConnectProperties->new ([$toolbar,'visible'],
#     #                                         [$action,'active']);
# 
#     my $tpos = 0;
#     {
#       my $item = Prima::ToolItem->new;
#       $toolbar->insert ($item, $tpos++);
# 
#       my $hbox = Prima::HBox->new;
#       $item->add ($hbox);
#       $hbox->pack_start (Prima::Label->new(__('Path')), 0,0,0);
#       my $combobox = Prima::ComboBox->new
#         (App::MathImage::Prima::Drawing::Path->model);
#       $combobox->set (tearoff_title => __('Path'));
# 
#       my $renderer = Prima::CellRendererText->new;
#       $renderer->set (ypad => 0);
#       $combobox->pack_start ($renderer, 1);
#       $combobox->set_attributes ($renderer, text => 1);
# 
#       my $hash = App::MathImage::Prima::Drawing::Path->model_rows_hash;
#       ### $hash
#       Glib::Ex::ConnectProperties->new ([$draw,'path'],
#                                         [$combobox,'active',
#                                          hash_in => $hash,
#                                          hash_out => $hash ]);
#       $hbox->pack_start ($combobox, 0,0,0);
#     }
#     {
#       my $item = Prima::ToolItem->new;
#       $toolbar->insert ($item, $tpos++);
# 
#       my $hbox = Prima::HBox->new;
#       $item->add ($hbox);
# 
#       $hbox->pack_start (Prima::Label->new(__('Values')), 0,0,0);
#       my $combobox = $self->{'values_combobox'} = Prima::ComboBox->new
#         (App::MathImage::Prima::Drawing::Values->model);
#       $combobox->set (tearoff_title => __('Values'));
# 
#       my $renderer = Prima::CellRendererText->new;
#       $renderer->set (ypad => 0);
#       $combobox->pack_start ($renderer, 1);
#       $combobox->set_attributes ($renderer, text => 1);
# 
#       my $hash = App::MathImage::Prima::Drawing::Values->model_rows_hash;
#       ### $hash
#       Glib::Ex::ConnectProperties->new ([$draw,'values'],
#                                         [$combobox,'active',
#                                          hash_in => $hash,
#                                          hash_out => $hash ]);
#       $hbox->pack_start ($combobox, 0,0,0);
#     }
#     {
#       my $item = Prima::ToolItem->new;
#       $toolbar->insert ($item, $tpos++);
# 
#       my $entry = $self->{'fraction_entry'} = Prima::Entry->new;
#       $entry->set_width_chars (8);
#       $item->add ($entry);
#       $entry->signal_connect (activate => sub {
#                                 my ($entry) = @_;
#                                 my $self = $entry->get_ancestor(__PACKAGE__);
#                                 my $draw = $self->{'draw'};
#                                 $draw->set(fraction => $entry->get_text);
#                               });
#       $draw->signal_connect ('notify::fraction' => \&_do_notify_fraction);
#       _do_notify_fraction ($draw);  # initial value
#       $self->{'values_combobox'}->signal_connect
#         ('notify::active' => sub {
#            my ($combobox) = @_;
#            my $active = $combobox->get_active;
#            my $hash = App::MathImage::Prima::Drawing::Values->model_rows_hash;
#            my $values = $hash->{$active};
#            $entry->set (visible => ($values && $values eq 'FractionDigits'));
#          });
#     }
#     {
#       my $item = Prima::ToolItem->new;
#       $toolbar->insert ($item, $tpos++);
# 
#       my $adj = Prima::Adjustment->new (1,        # initial
#                                        2, 999,   # min,max
#                                        1,10,     # steps
#                                        0);       # page_size
#       Glib::Ex::ConnectProperties->new ([$draw,'polygonal'],
#                                         [$adj,'value']);
#       my $spin = Prima::SpinButton->new ($adj, 10, 0);
#       $item->add ($spin);
#       $self->{'values_combobox'}->signal_connect
#         ('notify::active' => sub {
#            my ($combobox) = @_;
#            my $active = $combobox->get_active;
#            my $hash = App::MathImage::Prima::Drawing::Values->model_rows_hash;
#            my $values = $hash->{$active};
#            $spin->set (visible => ($values && $values eq 'polygonal'));
#          });
#     }
# 
#     {
#       my $item = Prima::ToolItem->new;
#       $toolbar->insert ($item, $tpos++);
# 
#       my $hbox = Prima::HBox->new;
#       $item->add ($hbox);
#       $hbox->pack_start (Prima::Label->new(__('Scale')), 0,0,0);
#       my $adj = Prima::Adjustment->new (1,        # initial
#                                        1, 999,   # min,max
#                                        1,10,     # steps
#                                        0);       # page_size
#       Glib::Ex::ConnectProperties->new ([$draw,'scale'],
#                                         [$adj,'value']);
#       my $spin = Prima::SpinButton->new ($adj, 10, 0);
#       $hbox->pack_start ($spin, 0,0,0);
#     }
#   }
# 
#   $vbox->show_all;
#   $self->{'values_combobox'}->notify('active');
# }
# 
# sub _do_notify_fraction {
#   my ($draw) = @_;
#   ### Entry draw notify-fraction: $draw->get('fraction')
#   my $self = $draw->get_ancestor(__PACKAGE__);
#   ### $self
#   my $entry = $self->{'fraction_entry'};
#   ### $entry
#   $entry->set_text ($draw->get('fraction'));
# }
# 
# sub _do_motion_notify {
#   my ($draw, $event) = @_;
#   my $self = $draw->get_ancestor (__PACKAGE__);
# 
#   my $statusbar = $self->{'statusbar'};
#   my $id = $statusbar->get_context_id (__PACKAGE__);
#   $statusbar->pop ($id);
# 
#   my ($x, $y, $n) = $draw->pointer_xy_to_image_xyn ($event->x, $event->y);
#   if (defined $x) {
#     my $message = sprintf ("x=%.*f, y=%.*f",
#                            (int($x)==$x ? 0 : 2), $x,
#                            (int($y)==$y ? 0 : 2), $y);
#     if (defined $n) {
#       $message .= "   N=$n";
#     }
#     $statusbar->push ($id, $message);
#   }
#   return 0;
# }
# 
# sub SET_PROPERTY {
#   my ($self, $pspec, $newval) = @_;
#   my $pname = $pspec->get_name;
#   $self->{$pname} = $newval;
#   ### SET_PROPERTY: $pname, $newval
# 
#   if ($pname eq 'fullscreen') {
#     # hide the draw widget until fullscreen change takes effect, so as not
#     # to do the slow drawing stuff until the new size set by the window
#     # manager
#     if ($self->mapped) {
#       $self->{'draw'}->hide;
#     }
#     if ($newval) {
#       ### fullscreen
#       $self->fullscreen;
#     } else {
#       ### unfullscreen
#       $self->unfullscreen;
#     }
#   }
#   ### SET_PROPERTY done
# }
# sub _do_window_state_event {
#   my ($self, $event) = @_;
#   ### _do_window_state_event: "@{[$event->new_window_state]}"
# 
#   my $visible = ! ($event->new_window_state & 'fullscreen');
#   $self->toolbar->set (visible => $visible);
#   $self->{'statusbar'}->set (visible => $visible);
#   $self->{'draw'}->show;
# 
#   # reparent the menubar
#   my $menubar = $self->menubar;
#   my $vbox = ($visible ? $self->{'vbox'} : $self->{'vbox2'});
#   if ($menubar->parent != $vbox) {
#     $menubar->parent->remove ($menubar);
#     $vbox->pack_start ($menubar, 0,0,0);
#     $vbox->reorder_child ($menubar, 0); # at the start
#     if ($self->{'draw'}->window) {
#       $self->{'draw'}->window->raise;
#     }
#   }
# }
# 
# # sub _do_map {
# #   my ($self) = @_;
# #   ### _do_map()
# #   shift->signal_chain_from_overridden (@_);
# #   ### mapped now: $self->mapped
# # 
# # #   $self->{'draw'}->realize;
# # #   _fullscreen_windows ($self);
# # }
# # sub _fullscreen_windows {
# #   my ($self) = @_;
# #   ### _fullscreen_windows()
# #   my $fullscreen = $self->{'fullscreen'};
# #   if (my $win = $self->{'draw'}->window) { # $self->window) {
# #     if ($fullscreen) {
# #       ### win fullscreen
# #       $win->fullscreen;
# #     } else {
# #       ### win unfullscreen
# #       $win->unfullscreen;
# #     }
# #   }
# # #   if ($self->{'draw'}->window) {
# # #     $self->{'draw'}->window->raise;
# # #   }
# # }
# 
# sub _do_action_save_as {
#   my ($action, $self) = @_;
#   require App::MathImage::Prima::SaveDialog;
#   my $dialog = ($self->{'save_dialog'}
#                 ||= App::MathImage::Prima::SaveDialog->new
#                 (draw => $self->{'draw'},
#                  transient_for => $self));
#   $dialog->present;
# }
# sub _do_action_setroot {
#   my ($action, $self) = @_;
#   Prima::Ex::WidgetCursor->busy;
# 
#   my $draw = $self->{'draw'};
#   my $rootwin = Prima::Gdk->get_default_root_window;
#   my ($width, $height) = $rootwin->get_size;
# 
#   require App::MathImage::Generator;
#   my $gen = App::MathImage::Generator->new
#     (values     => $draw->get('values'),
#      path       => $draw->get('path'),
#      scale      => $draw->get('scale'),
#      fraction   => $draw->get('fraction'),
#      width      => $width,
#      height     => $height,
#      foreground => $draw->style->fg($self->state),
#      background => $draw->style->bg($self->state));
# 
#   require Image::Base::Prima::Drawable;
#   my $image = Image::Base::Prima::Drawable->new
#     (-for_window => $rootwin,
#      -width      => $width,
#      -height     => $height);
#   $gen->draw_Image ($image);
# 
#   $rootwin->set_back_pixmap ($image->get('-pixmap'));
#   $rootwin->clear;
# }

# sub _do_action_randomize {
#   my ($action, $self) = @_;
#   $self->{'draw'}->set (App::MathImage::Generator->random_options);
# }

#       my $toplevel = App::MathImage::Prima::Main->new
#         (fullscreen => $gui_options{'fullscreen'});
# 
#       my $fg_color = Prima::Gdk::Color->parse (delete $gen_options{'foreground'});
#       my $bg_color = Prima::Gdk::Color->parse (delete $gen_options{'background'});
# 
#       my $draw = $toplevel->{'draw'};
#       if (defined $gen_options{'width'}) {
#         require Prima::Ex::Units;
#         Prima::Ex::Units::set_default_size_with_subsizes
#             ($toplevel,
#              [ $draw,
#                delete $gen_options{'width'}, delete $gen_options{'height'} ]);
#       } else {
#         $toplevel->set_default_size
#           (map {$_*0.8} $toplevel->get_root_window->get_size);
#       }
#       ### draw set: %gen_options
#       $draw->set (%gen_options);
#       $draw->modify_fg ('normal', $fg_color);
#       $draw->modify_bg ('normal', $bg_color);


#------------------------------------------------------------------------------
# printer

sub print_image {
  my ($self) = @_;
  require Prima::PrintDialog;
  my $dialog = Prima::PrintSetupDialog->create;
  if ($dialog->execute) {
    _draw_to_printer($self);
  }
}

sub _draw_to_printer {
  my ($self) = @_;
  my $printer = $::application->get_printer;
  if (! $printer->begin_doc(__('Math-Image'))) {
    warn "Print begin_doc() failed: $@\n";
    return;
  }

  my $draw = $self->{'draw'};
  my $gen_options = $draw->gen_options;
  my $gen = App::MathImage::Generator->new
    (step_time       => 0.25,
     step_figures    => 1000,
     %$gen_options,
     #      foreground => $self->style->fg($self->state)->to_string,
     #      background => $background_colorobj->to_string,
    );

  my $printer_width = $printer->width;
  my $printer_height = $printer->height;

  $printer->font->size(12);  # in points
  # ### fonts: $printer->fonts

  my $str = $gen->description . "\n\n";
  my $str_height = $printer->draw_text
    ($str, 0,10, $printer_width,$printer_height-10,
     dt::Left | dt::NewLineBreak | tw::WordBreak | dt::UseExternalLeading
     | dt::QueryHeight);
  ### $str
  ### $str_height
  ### font height: $printer->font->height

  ### clipRect is: $printer->clipRect
  # $printer->clipRect (0, 0, $printer_width, $printer_height);
  # $printer->translate (0, 20);  # up from bottom of page
  my $factor = max ($printer_width / $draw->width,
                    ($printer_height-10-5) / $draw->height);
  $gen->{'scale'} *= $factor,

  ### draw width: $draw->width
  ### draw height: $draw->height
  ### printer width: $printer->width
  ### printer height: $printer->height
  ### $factor
  ### $gen_options

  require Image::Base::Prima::Drawable;
  my $image = Image::Base::Prima::Drawable->new (-drawable => $printer);
  ### printer width:  $image->get('-width')
  ### printer height: $image->get('-height')

  $gen->draw_Image ($image);
  ### printer end_doc() ...


  $printer->translate (0, 0);  # up from bottom of page
  $printer->color (cl::White);
  $printer->bar (0, $printer_height-10-$str_height-5,
                  $printer_width, $printer_height);

  $printer->color (cl::Black);
  $printer->draw_text
    ($str, 0,10, $printer_width,$printer_height-10,
     dt::Left | dt::NewLineBreak | tw::WordBreak | dt::UseExternalLeading
     | dt::QueryHeight);

  $printer->end_doc;
  ### printer done ...
}


#------------------------------------------------------------------------------
# command line

sub command_line {
  my ($class, $mathimage) = @_;
  my $gen_options = $mathimage->{'gen_options'};
  my $mainwin = $class->new
    (gui_options => $mathimage->{'gui_options'},
     gen_options => $gen_options,
     (! defined $gen_options->{'width'}
      ? (width  => 600,
         height => 400)
      : ()),
    );
  Prima->run;
  return 0;
}

1;
__END__
