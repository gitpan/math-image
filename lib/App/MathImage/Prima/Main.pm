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


package App::MathImage::Prima::Main;
use 5.008;
use strict;
use warnings;
use List::Util qw(min max);
use Locale::TextDomain 1.19 ('App-MathImage');
use Locale::Messages 'dgettext';
use Prima 'Application';
use App::MathImage::Generator;

# uncomment this to run the ### lines
#use Smart::Comments;

our $VERSION = 18;

sub run {
  my ($class, $gen_options) = @_;

  my $main = Prima::MainWindow->new
    (text => 'Hello',
     menuItems =>
     [ [ "~File" => [
                     [ "E~xit" => sub {
                         $::application->destroy;
                       }
                     ]
                    ] ],
       [ ef => "~View" => [
                           _menu_for_values(),
                           [],  # separator
                           _menu_for_path(),
                          ]],

       [],
       [ "~Help" => [ [ "~About" => "About",
                        sub {
                          require Prima::MsgBox;
                          Prima::MsgBox::message
                              (__x('Math Image version {version}', version => $VERSION),
                               mb::Information() + mb::Ok());
                          # require App::MathImage::Prima::About;
                          # App::MathImage::Prima::About->new;
                        }],
                    ] ],
     ],
     onPaint  => \&_paint,
    );

  $main->{__PACKAGE__.'.gen_options'} = $gen_options;
  my $image = Prima::Image->create (owner => $main);

  Prima->run;
}

my %_values_to_mnemonic =
  (primes        => __('_Primes'),
   twin_primes   => __('_Twin Primes'),
   twin_primes_1 => __('Twin Primes _1'),
   twin_primes_2 => __('Twin Primes _2'),
   squares       => __('S_quares'),
   pronic        => __('Pro_nic'),
   triangular    => __('Trian_gular'),
   cubes         => __('_Cubes'),
   tetrahedral   => __('_Tetrahedral'),
   perrin        => __('Perr_in'),
   padovan       => __('Pado_van'),
   fibonacci     => __('_Fibonacci'),
   fraction_bits => __('F_raction Bits'),
   polygonal     => __('Pol_ygonal Numbers'),
   pi_bits       => __('_Pi Bits'),
   ln2_bits      => __x('_Log Natural {logarg} Bits', logarg => 2),
   ln3_bits      => __x('_Log Natural {logarg} Bits', logarg => 3),
   ln10_bits     => __x('_Log Natural {logarg} Bits', logarg => 10),
   odd           => __('_Odd Integers'),
   even          => __('_Even Integers'),
   all           => __('_All Integers'),
  );
sub _values_to_mnemonic {
  my ($str) = @_;
  $str = ($_values_to_mnemonic{$str}
          || App::MathImage::Glib::Ex::EnumBits::to_text_default(undef,$str));
  $str =~ tr/_/~/;
  return $str;
}
sub _menu_for_values {
  my ($self) = @_;

  return map {
    my $values = $_;
    [ _values_to_mnemonic($_) => sub {
        print $values,"\n";
      }
    ]
  } App::MathImage::Generator->values_choices;
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
  return ($_values_to_mnemonic{$str}
          || App::MathImage::Glib::Ex::EnumBits::to_text_default(undef,$str));
}
sub _menu_for_path {
  my ($self) = @_;

  return map {
    my $path = $_;
    [ _path_to_mnemonic($_) => sub {
        print $path,"\n";
      }
    ]
  } App::MathImage::Generator->path_choices;
}


sub _paint {
  my ($self, $canvas) = @_;
  ### _paint
  $canvas->clear;
  $canvas->fill_ellipse(50,50, 20,20);

  _draw_image ($canvas, $self->{__PACKAGE__.'.gen_options'});
}

sub _draw_image {
  my ($drawable, $gen_options) = @_;
  ### _draw_image(): ref($drawable)

  my $gen = App::MathImage::Generator->new
    (%$gen_options,
     width  => $drawable->width,
     height => $drawable->height);
  #      foreground => $self->style->fg($self->state)->to_string,
  #      background => $background_colorobj->to_string,

  #   $self->{'path_object'} = $gen->path_object;
  #   $self->{'coord'} = $gen->{'coord'};

  ### width:  $drawable->width
  ### height: $drawable->height

  require App::MathImage::Image::Base::Prima::Drawable;
  my $image = App::MathImage::Image::Base::Prima::Drawable->new
    (-drawable => $drawable);
  ### width:  $image->get('-width')
  ### height: $image->get('-height')

  $gen->draw_Image_start ($image);
  $gen->draw_Image_steps ($image, 99999);
}

# sub expose {
#           if ( $d-> begin_paint) {
#              $d-> color( cl::Black);
#              $d-> bar( 0, 0, $d-> size);
#              $d-> color( cl::White);
#              $d-> fill_ellipse( $d-> width / 2, $d-> height / 2, 30, 30);
#              $d-> end_paint;
#           } else {
#              die "can't draw on image:$@";
#           }



#   properties => [ Glib::ParamSpec->boolean
#                   ('fullscreen',
#                    'fullscreen',
#                    'Blurb.',
#                    0,           # default
#                    Glib::G_PARAM_READWRITE),

# sub INIT_INSTANCE {
#   my ($self) = @_;
# 
#   my $vbox = $self->{'vbox'} = Prima::VBox->new (0, 0);
#   $vbox->show;
#   $self->add ($vbox);
# 
#   my $draw = $self->{'draw'} = App::MathImage::Prima::Drawing->new;
#   $draw->show;
# 
#   my $actiongroup = $self->{'actiongroup'}
#     = Prima::ActionGroup->new ('main');
#   $actiongroup->add_actions
#     ([                          # name,        stock-id,  label
#       [ 'ViewMenu',   undef,    dgettext('gtk20-properties','_View')  ],
#       [ 'ToolsMenu',  undef,    dgettext('gtk20-properties','_Tools')  ],
# 
#       # name,       stock id,     label,  accelerator,  tooltip
# 
#       { name     => 'SaveAs',
#         stock_id => 'gtk-save-as',
#         callback => \&_do_action_save_as,
#       },
#       { name     => 'SetRoot',
#         label    => 'Set _Root Window',
#         callback => \&_do_action_setroot,
#       },
#       [ 'Quit',     'gtk-quit',   undef,
#         __p('Main-accelerator-key','<Control>Q'),
#         undef, \&_do_action_quit,
#       ],
# 
#       { name     => 'About',
#         stock_id => 'gtk-about',
#         callback => \&_do_action_about,
#       },
# 
#       { name     => 'Randomize',
#         label    => __('Randomize'),
#         callback => \&_do_action_randomize,
#       },
#      ],
#      $self);
# 
#   {
#     my $action = Prima::ToggleAction->new (name => 'Fullscreen',
#                                           label => '_Fullscreen');
#     $actiongroup->add_action_with_accel
#       ($action, __p('Main-accelerator-key','<Control>F'));
#     Glib::Ex::ConnectProperties->new ([$self,  'fullscreen'],
#                                       [$action,'active']);
#   }
#   $actiongroup->add_toggle_actions
#     # name, stock id, label, accel, tooltip, subr, is_active
#     ([[ 'Cross', undef, __('_Cross'), __p('Main-accelerator-key','C'), undef,
#         \&_do_action_crosshair,
#         0                       # inactive
#       ],
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
#     Glib::Ex::ConnectProperties->new
#         ([$draw,  'values'],
#          [$group, 'current-value', hash_in => \%hash, hash_out => \%hash ]);
#   }
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
#     Glib::Ex::ConnectProperties->new
#         ([$draw,  'path'],
#          [$group, 'current-value', hash_in => \%hash,  hash_out => \%hash]);
#   }
# 
#   my $ui = $self->{'ui'} = Prima::UIManager->new;
#   $ui->insert_action_group ($actiongroup, 0);
#   $self->add_accel_group ($ui->get_accel_group);
#   my $ui_str = <<'HERE';
# <ui>
#   <menubar name='MenuBar'>
#     <menu action='FileMenu'>
#       <menuitem action='SaveAs'/>
#       <menuitem action='SetRoot'/>
#       <menuitem action='Quit'/>
#     </menu>
#     <menu action='ViewMenu'>
# HERE
#   $ui_str .= "      <separator/>\n";
#   foreach my $path (App::MathImage::Generator->path_choices) {
#     $ui_str .= "      <menuitem action='Path-$path'/>\n";
#   }
#   $ui_str .= <<'HERE';
#     </menu>
#     <menu action='ToolsMenu'>
#       <menuitem action='Cross'/>
#       <menuitem action='Fullscreen'/>
#     </menu>
#     <menu action='HelpMenu'>
#       <menuitem action='About'/>
#     </menu>
#   </menubar>
#   <toolbar  name='ToolBar'>
#     <separator/>
#     <toolitem action='Randomize'/>
#   </toolbar>
# </ui>
# HERE
#   $ui->add_ui_from_string ($ui_str);
# 
#   my $menubar = $self->menubar;
#   $menubar->show;
#   $vbox->pack_start ($menubar, 0,0,0);
# 
#   my $toolbar = $self->toolbar;
#   $vbox->pack_start ($toolbar, 0,0,0);
# 
#   my $table = $self->{'table'} = Prima::Table->new (1, 1);
#   $vbox->pack_start ($table, 1,1,0);
# 
#   my $vbox2 = $self->{'vbox2'} = Prima::VBox->new;
#   $table->attach ($vbox2, 0,1, 0,1, ['expand','fill'],['expand','fill'],0,0);
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
#            $entry->set (visible => ($values && $values eq 'fraction_bits'));
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
# sub menubar {
#   my ($self) = @_;
#   return $self->{'ui'}->get_widget('/MenuBar');
# }
# sub toolbar {
#   my ($self) = @_;
#   return $self->{'ui'}->get_widget('/ToolBar');
# }
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
#   require App::MathImage::Image::Base::Prima::Gdk::Pixmap;
#   my $image = App::MathImage::Image::Base::Prima::Gdk::Pixmap->new
#     (-for_window => $rootwin,
#      -width      => $width,
#      -height     => $height);
#   $gen->draw_Image ($image);
# 
#   $rootwin->set_back_pixmap ($image->get('-pixmap'));
#   $rootwin->clear;
# }
# sub _do_action_quit {
#   my ($action, $self) = @_;
#   $self->destroy;
# }
# sub _do_action_about {
#   my ($action, $self) = @_;
#   require App::MathImage::Prima::AboutDialog;
#   App::MathImage::Prima::AboutDialog->new->present;
# }
# 
# sub _do_action_randomize {
#   my ($action, $self) = @_;
#   $self->{'draw'}->set (App::MathImage::Generator->random_options);
# }
# sub _do_action_crosshair {
#   my ($action, $self) = @_;
#   $self->{'crosshair_connect'} ||= do {
#     require Prima::Ex::CrossHair;
#     require Glib::Ex::ConnectProperties;
#     my $cross = $self->{'crosshair'}
#       = Prima::Ex::CrossHair->new (widget => $self->{'draw'},
#                                   foreground => 'orange',
#                                   active => 1);
#     Glib::Ex::ConnectProperties->new ([$action,'active'],
#                                       [$cross,'active']);
#     $self->{'draw'}->signal_connect
#       ('notify::scale' => sub {
#          my ($draw) = @_;
#          my $self = $draw->get_ancestor (__PACKAGE__);
#          my $scale = $draw->get('scale');
#          $cross->set (line_width => min($scale,3));
#        });
#     $self->{'draw'}->notify('scale'); # initial
#   };
# }
# 
# 1;


#       my $toplevel = App::MathImage::Prima::Main->new
#         (fullscreen => $gui_options{'fullscreen'});
#       $toplevel->signal_connect (destroy => sub { Prima->main_quit });
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
# 
#       $toplevel->show;
#       Prima->main;

1;
__END__
